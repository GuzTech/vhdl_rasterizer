------------------------------------------------------------------------------
-- Filename:          acc_geometry.vhd
-- Version:           1.00
-- Description:       Nebula ring compatibile geometry engine
-- Author:            Oguz Meteer <o.meteer@student.utwente.nl>
------------------------------------------------------------------------------
-- This accelerator reads four values (x,y,z,w), and performs a vector-matrix
-- multiplication. The sixteen components of the 4x4 matrix can be set by
-- configuring the accelerator as described below. The matrix components are
-- indexed as m[row][column], so m11 is the upper left component, m32 is the
-- component in the third row and the second column, etc.
-- 
-- The values are single precision floating point numbers, and the supplied
-- 4x1 vector is assumed to be the same.
-- 
-- The default value of both matrices is the identity matrix.
-- 
-- There are 34 configuration registers:
-- 0x20: value of m11 of the WV matrix
-- 0x24: value of m12 of the WV matrix
-- 0x28: value of m13 of the WV matrix
-- 0x2C: value of m14 of the WV matrix
-- 0x30: value of m21 of the WV matrix
-- ..
-- 0x3C: value of m24 of the WV matrix
-- 0x40: value of m31 of the WV matrix
-- ..
-- 0x5C: value of m44 of the WV matrix

-- 0x60: value of m11 of the WVP matrix
-- 0x64: value of m12 of the WVP matrix
-- 0x68: value of m13 of the WVP matrix
-- 0x6C: value of m14 of the WVP matrix
-- 0x70: value of m21 of the WVP matrix
-- ..
-- 0x7C: value of m24 of the WVP matrix
-- 0x80: value of m31 of the WVP matrix
-- ..
-- 0x9C: value of m44 of the WVP matrix

-- 0xA0: screen width as a single precision float (default 800.0f)
-- 0xA4: screen height as a single precision float (default 600.0f)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;

entity acc_geometry is
    generic(
        ADDR_WIDTH      : integer := 32;
        DATA_WIDTH      : integer := 32;
        CONF_ADDR_SIZE  : integer := 12
    );
    port(
        clk             : in  std_logic;
        rstn            : in  std_logic;

        -- ring2bram i/f
        addr_in         : in  std_logic_vector( ADDR_WIDTH - 1 downto 0 );
        data_in         : in  std_logic_vector( DATA_WIDTH - 1 downto 0 );
        mask_in         : in  std_logic_vector( DATA_WIDTH / 8 - 1 downto 0 );
        valid_in        : in  std_logic;
        accept_in       : out std_logic;

        -- axi2ring i/f
        addr_out        : out std_logic_vector( ADDR_WIDTH - 1 downto 0 );
        data_out        : out std_logic_vector( DATA_WIDTH - 1 downto 0 );
        mask_out        : out std_logic_vector( DATA_WIDTH / 8 - 1 downto 0 );
        valid_out       : out std_logic;
        accept_out      : in  std_logic;

        -- Configuration interface
        conf_addr       : in  std_logic_vector( CONF_ADDR_SIZE - 1 downto 0 );
        conf_data_mosi  : in  std_logic_vector( DATA_WIDTH - 1 downto 0 );
        conf_cs         : in  std_logic;
        conf_rnw        : in  std_logic;
        conf_data_miso  : out std_logic_vector( DATA_WIDTH - 1 downto 0 );
        conf_rdack      : out std_logic;
        conf_wrack      : out std_logic;
        conf_done       : out std_logic
    );
end acc_geometry;

architecture rtl of acc_geometry is
    type acc_state_t is  ( READ_V0_X, READ_V0_Y, READ_V0_Z, READ_V0_W,
                           READ_V1_X, READ_V1_Y, READ_V1_Z, READ_V1_W,
                           READ_V2_X, READ_V2_Y, READ_V2_Z, READ_V2_W,
                           HANG,
                           OUTPUT_V0, OUTPUT_V1, OUTPUT_V2, OUTPUT_AREA,
                           OUTPUT_DEPTH_0, OUTPUT_DEPTH_1, OUTPUT_DEPTH_2 );
    type norm_state_t is ( V0WV, NORMAL );
    type sub_state_t is  ( SUB_V1_V0, SUB_V2_V0 );
    type wvp_state_t is  ( WVP_V0, WVP_V1, WVP_V2 );
    type div_state_t is  ( DIV_V0, DIV_V1, DIV_V2 );
    type ss_state_t  is  ( INT_TO_FLOAT, AREA_RECP, FLOAT_TO_INT, AREA_RESULT );

    -- Helper signals
    signal reading     : std_logic; -- Is '1' when in any READ_* states
    signal writing     : std_logic; -- Is '1' when in any OUTPUT_* states
    signal READ_V0     : std_logic; -- Is '1' when in any READ_V0_* states while
                                    -- reading the first vertex
    signal READ_V1     : std_logic; -- Is '1' when in any READ_V1_* states while
                                    -- reading the second vertex
    signal READ_V2     : std_logic; -- Is '1' when in any READ_V2_* states while
                                    -- reading the third vertex
    signal READ_V1_XYZ : std_logic; -- Is '1' when the XYZ components of V1 are read.
    signal READ_V2_XYZ : std_logic; -- Is '1' when the XYZ components of V2 are read.
    
    signal reg_data  : std_logic_vector( DATA_WIDTH - 1 downto 0 );
    signal reg_addr  : std_logic_vector( ADDR_WIDTH - 1 downto 0 );
    signal reg_mask  : std_logic_vector( DATA_WIDTH / 8 - 1 downto 0 );
    signal reg_valid : std_logic;

    -- Accelerator configuration
    type config_t is record
        WV        : matrix4x4_t; -- WorldView matrix
        WVP       : matrix4x4_t; -- WorldViewProjection matrix
        vp_width  : slv32_t;
        vp_height : slv32_t;
    end record;

    constant CONFIG_RESET : config_t := (
        WV        => ( ( FLOAT_1F, ( others => '0' ), ( others => '0' ), ( others => '0' ) ),
                       ( ( others => '0' ), FLOAT_1F, ( others => '0' ), ( others => '0' ) ),
                       ( ( others => '0' ), ( others => '0' ), FLOAT_1F, ( others => '0' ) ),
                       ( ( others => '0' ), ( others => '0' ), ( others => '0' ), FLOAT_1F ) ),
        WVP       => ( ( FLOAT_1F, ( others => '0' ), ( others => '0' ), ( others => '0' ) ),
                       ( ( others => '0' ), FLOAT_1F, ( others => '0' ), ( others => '0' ) ),
                       ( ( others => '0' ), ( others => '0' ), FLOAT_1F, ( others => '0' ) ),
                       ( ( others => '0' ), ( others => '0' ), ( others => '0' ), FLOAT_1F ) ),
        vp_width  => x"4448_0000", -- 800.0f
        vp_height => x"4416_0000"  -- 600.0f
    );

    signal reg_current : config_t;
    signal reg_next    : config_t;
    
    -- Accelerator data
    type proc_t is record
        v0            : float3_t;      		    -- Stores V0 (without W component)
        v0_WV         : float3_t;      		    -- Stores V0 * WV first, then |V0 * WV|
        v0_WVP        : float4_t;      		    -- Stores V0 * WVP, and later perspective divided vertices
        v1_WVP        : float4_t;      		    -- Stores V1 * WVP, and later perspective divided vertices
        v2_WVP        : float4_t;      		    -- Stores V2 * WVP, and later perspective divided vertices
        v1v0          : float3_t;      		    -- Stores V1 - V0
        v2v0          : float3_t;      		    -- Stores V2 - V0
        ss_v0         : int16_2_t;              -- Stores screenspace coordinates of V0
        ss_v1         : int16_2_t;              -- Stores screenspace coordinates of V1
        ss_v2         : int16_2_t;              -- Stores screenspace coordinates of V2
        d0            : slv32_t;       		    -- Stores 1 / (V0 * WVP).w in Q1.31 fixed-point format
        d1            : slv32_t;       		    -- Stores 1 / (V1 * WVP).w in Q1.31 fixed-point format
        d2            : slv32_t;       		    -- Stores 1 / (V2 * WVP).w in Q1.31 fixed-point format
        norm          : float3_t;      		    -- Stores the normal vector (cross product result).
        areaTwice     : signed( 31 downto 0 );  -- Stores double the integer triangle area
        acc_state     : acc_state_t;            -- Stores the current accelerator state
        norm_state    : norm_state_t;           -- Stores the normalization output state
        sub_state     : sub_state_t;            -- Stores the subtraction result state
        wvp_state     : wvp_state_t;       	    -- Stores the WVP result state
        div_state     : div_state_t;       	    -- Stores the perspective divided vertex state
        ss_state      : ss_state_t;             -- Stores the area reciprocal calculation state
        dot_done      : std_logic;              -- '1' if dot product is calculated, '0' otherwise
        ss_done       : std_logic;              -- '1' if screen-space coordinates
                                                -- are calculated, '0' otherwise
        area_done     : std_logic;              -- '1' if area reciprocal has been calculated, '0' otherwise
        wvp_done      : std_logic;              -- '1' if all 3 vertices have been multiplied with WVP,
                                                -- '0' otherwise
        norm_done     : std_logic;              -- '1' if the 2 normals have been calculated, '0' otherwise
        sub_done      : std_logic;              -- '1' if the 2 subtractions have been calculated, '0' otherwise
        div_done      : std_logic;              -- '1' if the 3 divisions have been calculated, '0' otherwise
        keep_triangle : std_logic;         	    -- '1' if we keep this triangle, '0' we discard this triangle
    end record;

    constant PROC_RESET : proc_t := (
        v0            => ( ( others => '0' ), ( others => '0' ), ( others => '0' ) ),
        v0_WV         => ( ( others => '0' ), ( others => '0' ), ( others => '0' ) ),
        v0_WVP        => ( ( others => '0' ), ( others => '0' ), ( others => '0' ), ( others => '0' ) ),
        v1_WVP        => ( ( others => '0' ), ( others => '0' ), ( others => '0' ), ( others => '0' ) ),
        v2_WVP        => ( ( others => '0' ), ( others => '0' ), ( others => '0' ), ( others => '0' ) ),
        v1v0          => ( ( others => '0' ), ( others => '0' ), ( others => '0' ) ),
        v2v0          => ( ( others => '0' ), ( others => '0' ), ( others => '0' ) ),
        ss_v0         => ( ( others => '0' ), ( others => '0' ) ),
        ss_v1         => ( ( others => '0' ), ( others => '0' ) ),
        ss_v2         => ( ( others => '0' ), ( others => '0' ) ),
        norm          => ( ( others => '0' ), ( others => '0' ), ( others => '0' ) ),
        areaTwice     => ( others => '0' ),
        d0            => ( others => '0' ),
        d1            => ( others => '0' ),
        d2            => ( others => '0' ),
        acc_state     => READ_V0_X,
        norm_state    => V0WV,
        sub_state     => SUB_V1_V0,
        wvp_state     => WVP_V0,
        div_state     => DIV_V0,
        ss_state      => INT_TO_FLOAT,
        dot_done      => '0',
        ss_done       => '0',
        area_done     => '0',
        wvp_done      => '0',
        norm_done     => '0',
        sub_done      => '0',
        div_done      => '0',
        keep_triangle => '0'
    );

    signal R, Rin : proc_t := PROC_RESET;
                            
    signal wv_data_in       : std_logic_vector( DATA_WIDTH - 1 downto 0 );
    signal wv_valid_in      : std_logic;
    signal wv_accept_in     : std_logic;
    signal wv_data_out      : float4_t;
    signal wv_valid_out     : std_logic;
    signal wv_accept_out    : std_logic;
    
    signal wvp_data_out     : float4_t;
    signal wvp_valid_in     : std_logic;
    signal wvp_accept_in    : std_logic;
    signal wvp_valid_out    : std_logic;
    signal wvp_accept_out   : std_logic;
    
    signal norm_data_in     : float3_t;
    signal norm_valid_in    : std_logic;
    signal norm_data_out    : float3_t;
    signal norm_valid_out   : std_logic;
    
    signal sub_valid_in     : std_logic;
    signal sub_valid_out    : std_logic;
    signal sub_data_out     : float3_t;
    signal sub_accept_out   : std_logic;

    signal cross_valid_in   : std_logic;
    signal cross_data_out   : float3_t;
    signal cross_valid_out  : std_logic;
    signal cross_accept_out : std_logic;

    signal div_data_out     : float3_t;
    signal div_valid_out    : std_logic;
    signal div_accept_out   : std_logic;

    signal recp_data_out    : float_t;
    signal recp_valid_out   : std_logic;

    signal q8_24_data_out   : slv32_t;
    signal q8_24_valid_out  : std_logic;
    
    signal nwv_valid_in     : std_logic;
    signal nwv_data_out     : float3_t;
    signal nwv_valid_out    : std_logic;

    signal dot_data_out     : slv32_t;
    signal dot_valid_out    : std_logic;

    signal ss_data_in_a     : float2_t;
    signal ss_data_in_b     : float2_t;
    signal ss_data_in_c     : float2_t;
    signal ss_valid_in      : std_logic;
    signal ss_accept_in     : std_logic;
    signal ss_data_out_a    : int16_2_t;
    signal ss_data_out_b    : int16_2_t;
    signal ss_data_out_c    : int16_2_t;
    signal ss_valid_out     : std_logic;

    signal int_to_fp_a      : int32_t;
    signal int_to_fp_nd     : std_logic;
    signal int_to_fp_res    : float_t;
    signal int_to_fp_rdy    : std_logic;

    signal area_data_out    : float_t;
    signal area_valid_out   : std_logic;

    signal fp_to_int_res    : int32_t;
    signal fp_to_int_rdy    : std_logic;
    
    -- Misc
    signal rst              : std_logic;
    signal acc_accept_in    : std_logic;
    signal acc_valid_in     : std_logic;
    
begin

    rst <= not rstn;

    WV_mul4x4 : entity work.matmul4x4_s
    port map (
        clk        => clk,
        rst        => rst,
        data_in    => wv_data_in,
        valid_in   => wv_valid_in,
        accept_in  => wv_accept_in,
        data_out   => wv_data_out,
        valid_out  => wv_valid_out,
        accept_out => wv_accept_out,
        matrix_in  => reg_current.WV
    );

    wv_data_in    <= data_in when READ_V0 = '1' else
                     ( others => '0' );
    wv_valid_in   <= acc_valid_in when READ_V0 = '1' else
                     '0';
    wv_accept_out <= '1';

    WV_norm : entity work.norm3
    port map (
        clk        => clk,
        rst        => rst,
        data_in    => norm_data_in,
        valid_in   => norm_valid_in,
        accept_in  => open,
        data_out   => norm_data_out,
        valid_out  => norm_valid_out,
        accept_out => '1'
    );

    GEN_NORM : for i in 0 to 2 generate
        norm_data_in( i ) <= wv_data_out( i )    when wv_valid_out = '1' else
                             cross_data_out( i ) when cross_valid_out = '1' else
                             ( others => '0' );
    end generate GEN_NORM;

    norm_valid_in <= wv_valid_out or cross_valid_out;

    WVP_mul4x4 : entity work.matmul4x4_s
    port map (
        clk        => clk,
        rst        => rst,
        data_in    => data_in,
        valid_in   => wvp_valid_in,
        accept_in  => wvp_accept_in,
        data_out   => wvp_data_out,
        valid_out  => wvp_valid_out,
        accept_out => wvp_accept_out,
        matrix_in  => reg_current.WVP
    );

    wvp_valid_in   <= acc_valid_in;
    wvp_accept_out <= '1';

    sub : entity work.sub3
    port map (
        clk        => clk,
        rst        => rst,
        data_in_a  => data_in,
        data_in_b  => R.v0,
        valid_in   => sub_valid_in,
        accept_in  => open,
        data_out   => sub_data_out,
        valid_out  => sub_valid_out,
        accept_out => sub_accept_out
    );

    sub_valid_in   <= '1' when acc_valid_in = '1' and ( READ_V1_XYZ ) = '1' else
                      '1' when acc_valid_in = '1' and ( READ_V2_XYZ ) = '1' else
                      '0';

    sub_accept_out <= '1';

    cross : entity work.cross3
    port map (
        clk        => clk,
        rst        => rst,
        data_in_a  => R.v1v0,
        data_in_b  => sub_data_out,
        valid_in   => cross_valid_in,
        accept_in  => open,
        data_out   => cross_data_out,
        valid_out  => cross_valid_out,
        accept_out => cross_accept_out
    );

    cross_valid_in   <= '1' when sub_valid_out = '1' and R.acc_state = READ_V2_W else
                        '0';

    cross_accept_out <= '1';

    -------------------
    ----- Dividers ----
    -------------------
    div_0 : entity work.div3
    port map (
        clk            => clk,
        rst            => rst,
        data_in_a( 0 ) => wvp_data_out( 0 ),
        data_in_a( 1 ) => wvp_data_out( 1 ),
        data_in_a( 2 ) => wvp_data_out( 2 ),
        data_in_b      => wvp_data_out( 3 ),
        valid_in       => wvp_valid_out,
        accept_in      => open,
        data_out       => div_data_out,
        valid_out      => div_valid_out,
        accept_out     => div_accept_out
    );

    div_accept_out <= '1';

    recp_0 : entity work.recp
    port map (
        clk        => clk,
        rst        => rst,
        data_in    => wvp_data_out( 3 ),
        valid_in   => wvp_valid_out,
        accept_in  => open,
        data_out   => recp_data_out,
        valid_out  => recp_valid_out,
        accept_out => '1'
    );

    fixed_q8_24 : entity work.fp_to_q8_24
    port map (
        a            => recp_data_out,
        operation_nd => recp_valid_out,
        clk          => clk,
        sclr         => rst,
        result       => q8_24_data_out,
        rdy          => q8_24_valid_out
    );
    
    N_WV : entity work.matmul3x3
    port map (
        clk        => clk,
        rst        => rst,
        data_in    => norm_data_out,
        valid_in   => nwv_valid_in,
        accept_in  => open,
        data_out   => nwv_data_out,
        valid_out  => nwv_valid_out,
        accept_out => '1',
        matrix_in  => reg_current.WV
    );

    -- In a design where data arrives each clock cycle, this might not work.
    nwv_valid_in <= '1' when norm_valid_out = '1' and R.norm_state = NORMAL else
                    '0';

    dot : entity work.dot3
    port map (
        clk        => clk,
        rst        => rst,
        data_in_a  => R.v0_WV,
        data_in_b  => nwv_data_out,
        valid_in   => nwv_valid_out,
        accept_in  => open,
        data_out   => dot_data_out,
        valid_out  => dot_valid_out,
        accept_out => '1'
    );

    to_ss : entity work.screenspace
    port map (
        clk        => clk,
        rst        => rst,
        data_in_a  => ss_data_in_a,
        data_in_b  => ss_data_in_b,
        data_in_c  => ss_data_in_c,
        valid_in   => ss_valid_in,
        accept_in  => ss_accept_in,
        vp_width   => reg_current.vp_width,
        vp_height  => reg_current.vp_height,
        data_out_a => ss_data_out_a,
        data_out_b => ss_data_out_b,
        data_out_c => ss_data_out_c,
        valid_out  => ss_valid_out,
        accept_out => '1'        
    );

    ss_valid_in <= '1' when R.dot_done   = '1' and
                            R.wvp_done   = '1' and
                            R.ss_done    = '0' and
                            R.area_done  = '0' and
                            ss_accept_in = '1' else
                   '0';

    ss_data_in_a( 0 ) <= R.v0_WVP( 0 );
    ss_data_in_a( 1 ) <= R.v0_WVP( 1 );
    
    ss_data_in_b( 0 ) <= R.v1_WVP( 0 );
    ss_data_in_b( 1 ) <= R.v1_WVP( 1 );

    ss_data_in_c( 0 ) <= R.v2_WVP( 0 );
    ss_data_in_c( 1 ) <= R.v2_WVP( 1 );

    int_to_fp : entity work.int32_to_fp
    port map (
        a            => int_to_fp_a,
        operation_nd => int_to_fp_nd,
        clk          => clk,
        sclr         => rst,
        result       => int_to_fp_res,
        rdy          => int_to_fp_rdy
    );

    area_reciprocal : entity work.recp
    port map (
        clk        => clk,
        rst        => rst,
        data_in    => int_to_fp_res,
        valid_in   => int_to_fp_rdy,
        accept_in  => open,
        data_out   => area_data_out,
        valid_out  => area_valid_out,
        accept_out => '1'
    );

    fp_to_int : entity work.fp_to_q8_24
    port map (
        a            => area_data_out,
        operation_nd => area_valid_out,
        clk          => clk,
        sclr         => rst,
        result       => fp_to_int_res,
        rdy          => fp_to_int_rdy
    );
    
    proc_seq : process( rstn, clk )
    begin
        if( rstn = '0' )
        then
            R <= PROC_RESET;
        elsif( rising_edge( clk ) )
        then
            R <= Rin;
        end if;
    end process proc_seq;

    proc_comb : process( R, data_in, addr_in, mask_in, valid_in, acc_valid_in, acc_accept_in, accept_out, reading, writing, norm_valid_out, norm_data_out, wvp_valid_out, sub_valid_out, cross_valid_out, cross_data_out, div_valid_out, div_data_out, dot_data_out, dot_valid_out, q8_24_valid_out, ss_valid_out, int_to_fp_rdy, int_to_fp_nd, int_to_fp_res, area_data_out, area_valid_out, fp_to_int_res, fp_to_int_rdy )
        variable V : proc_t;
    begin
        V := R;
        
        -- By default, we don't have a valid value at the output
        reg_valid <= '0';
        reg_data  <= ( others => '0' );
        reg_addr  <= ( others => '0' );
        reg_mask  <= ( others => '0' );

        if( R.norm_done = '0' and norm_valid_out = '1' )
        then
            case R.norm_state is
                when V0WV =>
                    V.v0_WV      := norm_data_out;
                    V.norm_state := NORMAL;
                when NORMAL =>
                    V.norm       := norm_data_out;
                    V.norm_state := V0WV;
                    V.norm_done  := '1';
                when others => null;
            end case;
        end if;

        if( R.sub_done = '0' and sub_valid_out = '1' )
        then
            case R.sub_state is
                when SUB_V1_V0 =>
                    V.v1v0      := sub_data_out;
                    V.sub_state := SUB_V2_V0;
                when SUB_V2_V0 =>
                    V.v2v0      := sub_data_out;
                    V.sub_state := SUB_V1_V0;
                    V.sub_done  := '1';
                when others => null;
            end case;
        end if;

        if( q8_24_valid_out = '1' )
        then
            case R.wvp_state is
                when WVP_V0 =>
                    V.d0        := q8_24_data_out;
                    V.wvp_state := WVP_V1;
                when WVP_V1 =>
                    V.d1        := q8_24_data_out;
                    V.wvp_state := WVP_V2;
                when WVP_V2 =>
                    V.d2        := q8_24_data_out;
                    V.wvp_state := WVP_V0;
                    V.wvp_done  := '1';
                when others => null;
            end case;
        end if;
        
        if( R.div_done = '0' and div_valid_out = '1' )
        then
            case R.div_state is
                when DIV_V0 =>
                    V.v0_WVP( 0 ) := div_data_out( 0 );
                    V.v0_WVP( 1 ) := div_data_out( 1 );
                    V.v0_WVP( 2 ) := div_data_out( 2 );
                    V.v0_WVP( 3 ) := FLOAT_1F; -- 1.0f
                    V.div_state   := DIV_V1;
                when DIV_V1 =>
                    V.v1_WVP( 0 ) := div_data_out( 0 );
                    V.v1_WVP( 1 ) := div_data_out( 1 );
                    V.v1_WVP( 2 ) := div_data_out( 2 );
                    V.v1_WVP( 3 ) := FLOAT_1F; -- 1.0f
                    V.div_state   := DIV_V2;
                when DIV_V2 =>
                    V.v2_WVP( 0 ) := div_data_out( 0 );
                    V.v2_WVP( 1 ) := div_data_out( 1 );
                    V.v2_WVP( 2 ) := div_data_out( 2 );
                    V.v2_WVP( 3 ) := FLOAT_1F; -- 1.0f
                    V.div_state   := DIV_V0;
                    V.div_done    := '1';
                when others => null;
            end case;
        end if;

        if( R.dot_done = '0' and dot_valid_out = '1' )
        then
            -- Discard if the sign of the dot product is positive, i.e. if bit
            -- 31 is not set. If it's set, then we do not discard the triangle.
            V.keep_triangle := dot_data_out( 31 );
            V.dot_done      := '1';
        end if;

        if( R.ss_done = '0' and ss_valid_out = '1' )
        then
            -- Repurpose these registers to hold the screen-space integer
            -- values of the vertices.
            V.ss_v0     := ss_data_out_a;
            V.ss_v1     := ss_data_out_b;
            V.ss_v2     := ss_data_out_c;
            V.ss_done   := '1';
            
            V.areaTwice := edgeFunction( to_integer( signed( ss_data_out_a( 0 ) ) ),
                                         to_integer( signed( ss_data_out_a( 1 ) ) ),
                                         to_integer( signed( ss_data_out_b( 0 ) ) ),
                                         to_integer( signed( ss_data_out_b( 1 ) ) ),
                                         to_integer( signed( ss_data_out_c( 0 ) ) ),
                                         to_integer( signed( ss_data_out_c( 1 ) ) ) );
        end if;

        -- Calculate the reciprocal of areaTwice
        if( R.ss_done = '1' and R.area_done = '0' )
        then
            case R.ss_state is
                when INT_TO_FLOAT =>
                    if( R.area_done = '0' )
                    then
                        int_to_fp_a  <= int32_t( R.areaTwice );
                        int_to_fp_nd <= '1';
                        V.ss_state   := AREA_RECP;
                    else
                        V.ss_state   := INT_TO_FLOAT;
                    end if;
                when AREA_RECP =>
                    if( int_to_fp_rdy = '1' )
                    then
                        int_to_fp_nd <= '0';
                        V.ss_state   := FLOAT_TO_INT;
                    else
                        V.ss_state   := AREA_RECP;
                    end if;
                when FLOAT_TO_INT =>
                    if( area_valid_out = '1' )
                    then
                        V.ss_state := AREA_RESULT;
                    else
                        V.ss_state := FLOAT_TO_INT;
                    end if;
                when AREA_RESULT =>
                    if( fp_to_int_rdy = '1' )
                    then
                        V.areaTwice := signed( fp_to_int_res );
                        V.area_done := '1';
                        V.ss_state  := INT_TO_FLOAT;
                    else
                        V.ss_state  := AREA_RESULT;
                    end if;
                when others => null;
            end case;
        else
            int_to_fp_a  <= ( others => '0' );
            int_to_fp_nd <= '0';
        end if;
                                        
        -- When we are reading or finishing the calculations
        --if( reading = '1' )
        if( writing = '0' )
        then
            case R.acc_state is
                when READ_V0_X =>
                    -- Reset the values when we start from the beginning
                    V := PROC_RESET;
                    
                    if( acc_valid_in = '1' ) then
                        V.v0( 0 )   := data_in;
                        V.acc_state := READ_V0_Y;
                    else
                        V.acc_state := READ_V0_X;
                    end if;
                when READ_V0_Y =>
                    if( acc_valid_in = '1' ) then
                        V.v0( 1 )   := data_in;
                        V.acc_state := READ_V0_Z;
                    else
                        V.acc_state := READ_V0_Y;
                    end if;
                when READ_V0_Z =>
                    if( acc_valid_in = '1' ) then
                        V.v0( 2 )   := data_in;
                        V.acc_state := READ_V0_W;
                    else
                        V.acc_state := READ_V0_Z;
                    end if;
                when READ_V0_W =>
                    if( acc_valid_in = '1' ) then
                        V.acc_state := READ_V1_X;
                    else
                        V.acc_state := READ_V0_W;
                    end if;
                when READ_V1_X =>
                    if( acc_valid_in = '1' ) then
                        V.acc_state := READ_V1_Y;
                    else
                        V.acc_state := READ_V1_X;
                    end if;
                when READ_V1_Y =>
                    if( acc_valid_in = '1' ) then
                        V.acc_state := READ_V1_Z;
                    else
                        V.acc_state := READ_V1_Y;
                    end if;
                when READ_V1_Z =>
                    if( acc_valid_in = '1' ) then
                        V.acc_state := READ_V1_W;
                    else
                        V.acc_state := READ_V1_Z;
                    end if;
                when READ_V1_W =>
                    if( acc_valid_in = '1' ) then
                        V.acc_state := READ_V2_X;
                    else
                        V.acc_state := READ_V1_W;
                    end if;

                when READ_V2_X =>
                    if( acc_valid_in = '1' ) then
                        V.acc_state := READ_V2_Y;
                    else
                        V.acc_state := READ_V2_X;
                    end if;
                when READ_V2_Y =>
                    if( acc_valid_in = '1' ) then
                        V.acc_state := READ_V2_Z;
                    else
                        V.acc_state := READ_V2_Y;
                    end if;
                when READ_V2_Z =>
                    if( acc_valid_in = '1' ) then
                        V.acc_state := READ_V2_W;
                    else
                        V.acc_state := READ_V2_Z;
                    end if;
                when READ_V2_W =>
                    if( acc_valid_in = '1' ) then
                        V.acc_state := HANG;
                    else
                        V.acc_state := READ_V2_W;
                    end if;
                when HANG =>
                    if( R.ss_done = '1' and
                        R.dot_done = '1' and
                        R.wvp_done = '1' and
                        R.area_done = '1' and
                        R.norm_done = '1' and
                        R.sub_done = '1' and
                        R.div_done = '1' )
                    then
                        if( R.keep_triangle = '1' )
                        then
                            V.acc_state := OUTPUT_V0;
                        else
                            V.acc_state := READ_V0_X;
                        end if;
                    else
                        V.acc_state := HANG;
                    end if;
                when others => null;
            end case;
        elsif( writing = '1' )
        then
            reg_addr <= addr_in;
            reg_mask <= mask_in;

            case R.acc_state is
                when OUTPUT_V0 =>
                    reg_data <= R.ss_v0( 1 ) & R.ss_v0( 0 );

                    if( accept_out = '1' ) then
                        V.acc_state := OUTPUT_V1;
                        reg_valid <= '1';
                    else
                        V.acc_state := OUTPUT_V0;
                    end if;
                when OUTPUT_V1 =>
                    reg_data <= R.ss_v1( 1 ) & R.ss_v1( 0 );
                    
                    if( accept_out = '1' ) then
                        V.acc_state := OUTPUT_V2;
                        reg_valid   <= '1';
                    else
                        V.acc_state := OUTPUT_V1;
                    end if;
                when OUTPUT_V2 =>
                    reg_data <= R.ss_v2( 1 ) & R.ss_v2( 0 );
                    
                    if( accept_out = '1' ) then
                        V.acc_state := OUTPUT_AREA;
                        reg_valid <= '1';
                    else
                        V.acc_state := OUTPUT_V2;
                    end if;
                when OUTPUT_AREA =>
                    reg_data <= std_logic_vector( R.areaTwice );

                    if( accept_out = '1' ) then
                        V.acc_state := OUTPUT_DEPTH_0;
                        reg_valid <= '1';
                    else
                        V.acc_state := OUTPUT_AREA;
                    end if;
                when OUTPUT_DEPTH_0 =>
                    reg_data <= R.d0;

                    if( accept_out = '1' ) then
                        V.acc_state := OUTPUT_DEPTH_1;
                        reg_valid <= '1';
                    else
                        V.acc_state := OUTPUT_DEPTH_0;
                    end if;
                when OUTPUT_DEPTH_1 =>
                    reg_data <= R.d1;
                                       
                    if( accept_out = '1' ) then
                        V.acc_state := OUTPUT_DEPTH_2;
                        reg_valid <= '1';
                    else
                        V.acc_state := OUTPUT_DEPTH_1;
                    end if;
                when OUTPUT_DEPTH_2 =>
                    reg_data <= R.d2;
                    
                    if( accept_out = '1' ) then
                        V.acc_state := READ_V0_X;
                        reg_valid <= '1';
                    else
                        V.acc_state := OUTPUT_DEPTH_2;
                    end if;
                when others => null;
            end case;
        end if;

        Rin <= V;
    end process;

    READ_V0 <= '1' when R.acc_state = READ_V0_X or
                        R.acc_state = READ_V0_Y or
                        R.acc_state = READ_V0_Z or
                        R.acc_state = READ_V0_W else
               '0';
    READ_V1 <= '1' when R.acc_state = READ_V1_X or
                        R.acc_state = READ_V1_Y or
                        R.acc_state = READ_V1_Z or
                        R.acc_state = READ_V1_W else
               '0';
    READ_V2 <= '1' when R.acc_state = READ_V2_X or
                        R.acc_state = READ_V2_Y or
                        R.acc_state = READ_V2_Z or
                        R.acc_state = READ_V2_W else
               '0';
    
    READ_V1_XYZ <= '1' when R.acc_state = READ_V1_X or
                            R.acc_state = READ_V1_Y or
                            R.acc_state = READ_V1_Z else
                   '0';
    READ_V2_XYZ <= '1' when R.acc_state = READ_V2_X or
                            R.acc_state = READ_V2_Y or
                            R.acc_state = READ_V2_Z else
                   '0';
    
    reading <= '1' when READ_V0 = '1' or
                        READ_V1 = '1' or
                        READ_V2 = '1' else
               '0';
    writing <= '1' when R.acc_state = OUTPUT_V0 or
                        R.acc_state = OUTPUT_V1 or
                        R.acc_state = OUTPUT_V2 or
                        R.acc_state = OUTPUT_AREA or
               			R.acc_state = OUTPUT_DEPTH_0 or
               			R.acc_state = OUTPUT_DEPTH_1 or
               			R.acc_state = OUTPUT_DEPTH_2 else
               '0';

    -- When reading the first vertex, we calculate both v0*WV and v0*WVP, so
    -- both IPs should be able to accept input. When reading the second and
    -- third vertices, then only v1*WVP and v2*WVP are calculated respectively,
    -- so only the WVP IP has to be able to accept new input.
    acc_accept_in <= '1' when READ_V0 = '1' and wvp_accept_in = '1' and wv_accept_in = '1' else
                     '1' when READ_V1 = '1' and wvp_accept_in = '1' else
                     '1' when READ_V2 = '1' and wvp_accept_in = '1' else
                     '0';
    acc_valid_in  <= valid_in and acc_accept_in;

    accept_in <= acc_accept_in;
    valid_out <= reg_valid;
    data_out  <= reg_data;
    addr_out  <= reg_addr;
    mask_out  <= reg_mask;

    -- Sequential configuration process
    -- Simply assigns reg_next to reg_current at each rising edge
    reg_seq : process( clk, rstn ) is
    begin
        if( rstn = '0' )
        then
            reg_current <= CONFIG_RESET;
        elsif( rising_edge( clk ) )
        then
            reg_current <= reg_next;
        end if;
    end process reg_seq;

    -- Combinatorial configuration process
    -- When we are configuring the accelerator (conf_cs = 1), conf_done should be 
    -- zero to indicate that we are not done configuring yet.
    reg_comb : process( reg_current, conf_cs, conf_rnw, conf_data_mosi, conf_addr ) is
        variable V : config_t;
        variable i_conf_addr : unsigned( 7 downto 0 );
    begin
        V := reg_current;

        conf_rdack     <= '0';
        conf_wrack     <= '0';
        conf_data_miso <= ( others => '0' );

        -- Is the configuration bus activated?
        if( conf_cs = '1' )
        then
            -- Take the configuration register address
            i_conf_addr := resize( unsigned( conf_addr( CONF_ADDR_SIZE - 1 downto 2 ) & '0' & '0' ), i_conf_addr'length );
            -- The accelerator is being configured, so we are not done.
            conf_done <= '0';
            
            -- Do we want to read a configuration register?
            if( conf_rnw = '1' )
            then
                -- Acknowledge the read request
                conf_rdack <= '1';
                
                -- Determine which register is being accessed
                case i_conf_addr is
                    when X"20" => conf_data_miso <= reg_current.WV( 0 )( 0 );
                    when X"24" => conf_data_miso <= reg_current.WV( 0 )( 1 );
                    when X"28" => conf_data_miso <= reg_current.WV( 0 )( 2 );
                    when X"2C" => conf_data_miso <= reg_current.WV( 0 )( 3 );
                    when X"30" => conf_data_miso <= reg_current.WV( 1 )( 0 );
                    when X"34" => conf_data_miso <= reg_current.WV( 1 )( 1 );
                    when X"38" => conf_data_miso <= reg_current.WV( 1 )( 2 );
                    when X"3C" => conf_data_miso <= reg_current.WV( 1 )( 3 );
                    when X"40" => conf_data_miso <= reg_current.WV( 2 )( 0 );
                    when X"44" => conf_data_miso <= reg_current.WV( 2 )( 1 );
                    when X"48" => conf_data_miso <= reg_current.WV( 2 )( 2 );
                    when X"4C" => conf_data_miso <= reg_current.WV( 2 )( 3 );
                    when X"50" => conf_data_miso <= reg_current.WV( 3 )( 0 );
                    when X"54" => conf_data_miso <= reg_current.WV( 3 )( 1 );
                    when X"58" => conf_data_miso <= reg_current.WV( 3 )( 2 );
                    when X"5C" => conf_data_miso <= reg_current.WV( 3 )( 3 );

                    when X"60" => conf_data_miso <= reg_current.WVP( 0 )( 0 );
                    when X"64" => conf_data_miso <= reg_current.WVP( 0 )( 1 );
                    when X"68" => conf_data_miso <= reg_current.WVP( 0 )( 2 );
                    when X"6C" => conf_data_miso <= reg_current.WVP( 0 )( 3 );
                    when X"70" => conf_data_miso <= reg_current.WVP( 1 )( 0 );
                    when X"74" => conf_data_miso <= reg_current.WVP( 1 )( 1 );
                    when X"78" => conf_data_miso <= reg_current.WVP( 1 )( 2 );
                    when X"7C" => conf_data_miso <= reg_current.WVP( 1 )( 3 );
                    when X"80" => conf_data_miso <= reg_current.WVP( 2 )( 0 );
                    when X"84" => conf_data_miso <= reg_current.WVP( 2 )( 1 );
                    when X"88" => conf_data_miso <= reg_current.WVP( 2 )( 2 );
                    when X"8C" => conf_data_miso <= reg_current.WVP( 2 )( 3 );
                    when X"90" => conf_data_miso <= reg_current.WVP( 3 )( 0 );
                    when X"94" => conf_data_miso <= reg_current.WVP( 3 )( 1 );
                    when X"98" => conf_data_miso <= reg_current.WVP( 3 )( 2 );
                    when X"9C" => conf_data_miso <= reg_current.WVP( 3 )( 3 );

                    when X"A0" => conf_data_miso <= reg_current.vp_width;
                    when X"A4" => conf_data_miso <= reg_current.vp_height;
                    when others => null;
                end case;
            else  -- We want to write to a configuration register
                -- Acknowledge the write request
                conf_wrack <= '1';
                
                -- Determine which register is being accessed
                case i_conf_addr is
                    when X"20" => V.WV( 0 )( 0 ) := conf_data_mosi;
                    when X"24" => V.WV( 0 )( 1 ) := conf_data_mosi;
                    when X"28" => V.WV( 0 )( 2 ) := conf_data_mosi;
                    when X"2C" => V.WV( 0 )( 3 ) := conf_data_mosi;
                    when X"30" => V.WV( 1 )( 0 ) := conf_data_mosi;
                    when X"34" => V.WV( 1 )( 1 ) := conf_data_mosi;
                    when X"38" => V.WV( 1 )( 2 ) := conf_data_mosi;
                    when X"3C" => V.WV( 1 )( 3 ) := conf_data_mosi;
                    when X"40" => V.WV( 2 )( 0 ) := conf_data_mosi;
                    when X"44" => V.WV( 2 )( 1 ) := conf_data_mosi;
                    when X"48" => V.WV( 2 )( 2 ) := conf_data_mosi;
                    when X"4C" => V.WV( 2 )( 3 ) := conf_data_mosi;
                    when X"50" => V.WV( 3 )( 0 ) := conf_data_mosi;
                    when X"54" => V.WV( 3 )( 1 ) := conf_data_mosi;
                    when X"58" => V.WV( 3 )( 2 ) := conf_data_mosi;
                    when X"5C" => V.WV( 3 )( 3 ) := conf_data_mosi;

                    when X"60" => V.WVP( 0 )( 0 ) := conf_data_mosi;
                    when X"64" => V.WVP( 0 )( 1 ) := conf_data_mosi;
                    when X"68" => V.WVP( 0 )( 2 ) := conf_data_mosi;
                    when X"6C" => V.WVP( 0 )( 3 ) := conf_data_mosi;
                    when X"70" => V.WVP( 1 )( 0 ) := conf_data_mosi;
                    when X"74" => V.WVP( 1 )( 1 ) := conf_data_mosi;
                    when X"78" => V.WVP( 1 )( 2 ) := conf_data_mosi;
                    when X"7C" => V.WVP( 1 )( 3 ) := conf_data_mosi;
                    when X"80" => V.WVP( 2 )( 0 ) := conf_data_mosi;
                    when X"84" => V.WVP( 2 )( 1 ) := conf_data_mosi;
                    when X"88" => V.WVP( 2 )( 2 ) := conf_data_mosi;
                    when X"8C" => V.WVP( 2 )( 3 ) := conf_data_mosi;
                    when X"90" => V.WVP( 3 )( 0 ) := conf_data_mosi;
                    when X"94" => V.WVP( 3 )( 1 ) := conf_data_mosi;
                    when X"98" => V.WVP( 3 )( 2 ) := conf_data_mosi;
                    when X"9C" => V.WVP( 3 )( 3 ) := conf_data_mosi;

                    when X"A0" => V.vp_width  := conf_data_mosi;
                    when X"A4" => V.vp_height := conf_data_mosi;
                    when others => null;
                end case;
            end if;
        else -- The configuration bus is not active, so we are done configuring
            conf_done <= '1';
        end if;

        reg_next <= V;
    end process reg_comb;
end rtl;
