------------------------------------------------------------------------------
-- Filename:          acc_rasterizer.vhd
-- Version:           1.00
-- Description:       Nebula ring compatibile rasterizer engine
-- Author:            Oguz Meteer <o.meteer@student.utwente.nl>
------------------------------------------------------------------------------
-- This accelerator reads four values (x,y,z,w), and performs a vector-matrix
-- multiplication. The sixteen components of the 4x4 matrix can be set by
-- configuring the accelerator as described below. The matrix components are
-- indexed as m[row][column], so m11 is the upper left component, m32 is the
-- component in the third row and the second column, etc.
-- 
-- There are 3 configuration registers:
-- 0x20: the framebuffer address
-- 0x24: the number of tiles on the x axis
-- 0x28: the number of tiles on the y axis
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;

entity acc_rasterizer is
    generic(
        ADDR_WIDTH         : integer := 32;
        DATA_WIDTH         : integer := 32;
        CONF_ADDR_SIZE     : integer := 12;

        C_USE_WSTRB        : integer := 0;
		C_M_AXI_ADDR_WIDTH : integer := 32;
		C_M_AXI_DATA_WIDTH : integer := 256;
		C_MAX_BURST_LEN    : integer := 256
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
        conf_done       : out std_logic;

        -- AXI4 Write-only Interfaces
		m_axi_aclk      : in  std_logic;
		m_axi_aresetn   : in  std_logic;
		-- Address write channel
		m_axi_awready   : in  std_logic;
		m_axi_awvalid   : out std_logic;
		m_axi_awaddr    : out std_logic_vector( 31 downto 0 );
		m_axi_awlen     : out std_logic_vector(  7 downto 0 );
		m_axi_awsize    : out std_logic_vector(  2 downto 0 );
		m_axi_awburst   : out std_logic_vector(  1 downto 0 );
		m_axi_awprot    : out std_logic_vector(  2 downto 0 );
		m_axi_awcache   : out std_logic_vector(  3 downto 0 );
		
		-- Data write channel
		m_axi_wready    : in  std_logic;
		m_axi_wvalid    : out std_logic;
		m_axi_wdata     : out std_logic_vector( 255 downto 0 );
		m_axi_wstrb     : out std_logic_vector(  31 downto 0 );
		m_axi_wlast     : out std_logic;
		
		-- Write response channel
		m_axi_bready    : out std_logic;
		m_axi_bvalid    : in  std_logic;
		m_axi_bresp     : in  std_logic_vector( 1 downto 0 )
    );
end acc_rasterizer;

architecture rtl of acc_rasterizer is
    type acc_state_t is ( S_RESET, S_READ_TR_DATA, S_PROCESSING, S_OUTPUT_DATA );

    -- Helper signals
    signal writing   : std_logic; -- Is '1' when in the S_OUTPUT_DATA state
    
    signal reg_data  : std_logic_vector( DATA_WIDTH - 1 downto 0 );
    signal reg_addr  : std_logic_vector( ADDR_WIDTH - 1 downto 0 );
    signal reg_mask  : std_logic_vector( DATA_WIDTH / 8 - 1 downto 0 );
    signal reg_valid : std_logic;
    signal reg_rst   : std_logic;

    -- Accelerator configuration
    type config_t is record
        base_addr  : slv32_t; -- Framebuffer base address
        fb_addr    : u32_t;   -- Framebuffer address of current tile
        line_width : u32_t;   -- Width of 1 row of pixels * 4 bytes/pixel
        num_tile_x : u16_t;   -- Number of tiles x
        num_tile_y : u16_t;   -- Number of tiles y
        tile_x     : u16_t;   -- Current tile x-coordinate
        tile_y     : u16_t;   -- Current tile y-coordinate
        tile_min_x : u16_t;   -- Minimum x pixel coordiante of this tile
        tile_min_y : u16_t;   -- Minimum y pixel coordiante of this tile

        -- Timers
        t_recv     : u32_t;     -- #cycles needed for receiving data
        t_calc     : u32_t;     -- #cycles needed for rasterizing
        t_write    : u32_t;     -- #cycles needed for writing to the framebuffer
        recv_act   : std_logic; -- '1' if t_recv timer is active
    end record;

    constant CONFIG_RESET : config_t :=
    (
        base_addr  => x"B200_0000",
        fb_addr    => x"B200_0000",
        line_width => x"0000_0C80", -- 100 tilesX * 8 pixels/tile *
                                    -- 4 bytes/pixel = 3200 = 0xC80
        num_tile_x => x"0064",      -- 100 tilesX
        num_tile_y => x"004B",      -- 75 tilesY
        tile_x     => ( others => '0' ),
        tile_y     => ( others => '0' ),
        tile_min_x => x"0000",      -- min x tile pixel coordinate
        tile_min_y => x"0000",      -- min y tile pixel coordinate
        t_recv     => ( others => '0' ),
        t_calc     => ( others => '0' ),
        t_write    => ( others => '0' ),
        recv_act   => '0'
    );
        
    signal C, Cin : config_t := CONFIG_RESET;
    
    signal reg_current : config_t;
    signal reg_next    : config_t;
    
    -- Accelerator data
    type proc_t is record
        acc_state : acc_state_t;
    end record;

    constant PROC_RESET : proc_t :=
    (
        acc_state => S_READ_TR_DATA
    );
        
    signal R, Rin : proc_t := PROC_RESET;

    signal tr_clr         : std_logic;
    signal tr_data_in     : slv32_t;
    signal tr_write_en    : std_logic;
    signal tr_last_in     : std_logic;
    signal tr_accept      : std_logic;
    signal tr_addr        : std_logic_vector( 3 downto 0 );
    signal tr_data_out    : std_logic_vector( 223 downto 0 );
    signal tr_valid       : std_logic;
    signal tr_read_en     : std_logic;
    signal tr_ready       : std_logic;
    signal tr_num_tr      : std_logic_vector( 4 downto 0 );

    signal rast_read_in   : std_logic;
    signal rast_addr_in   : std_logic_vector( 3 downto 0 );
    signal rast_data_out  : std_logic_vector( 319 downto 0 );
    signal rast_valid_out : std_logic;
    signal rast_enable    : std_logic;
    signal rast_done      : std_logic;

    signal fb_en          : std_logic;
    signal fb_wen         : std_logic;
    signal fb_addr        : std_logic_vector(   2 downto 0 );
    signal fb_data_in     : std_logic_vector( 255 downto 0 );
    signal fb_data_out    : std_logic_vector( 255 downto 0 );

    signal fb_axi_en      : std_logic;
    signal fb_axi_addr    : std_logic_vector(   2 downto 0 );
    signal fb_axi_data    : std_logic_vector( 255 downto 0 );

    signal axi_done       : std_logic;
    signal axi_enable     : std_logic;
    
    -- Misc
    signal ext_rst        : std_logic;
    signal rst            : std_logic;
    signal axi_rstn       : std_logic;
    signal acc_accept_in  : std_logic;
    signal acc_valid_in   : std_logic;
    
begin

    ext_rst <= not rstn;
    rst     <= ext_rst or reg_rst;

    tr_mem : entity work.TriangleMem
    port map (
        clk         => clk,
        rst         => rst,
        clr         => tr_clr,
        data_in     => tr_data_in,
        write_en_in => tr_write_en,
        last_in     => tr_last_in,
        accept_in   => tr_accept,
        addr_out    => tr_addr,
        data_out    => tr_data_out,
        valid_out   => tr_valid,
        read_en_out => tr_read_en,
        ready_out   => tr_ready,
        num_tr_out  => tr_num_tr
    );

    tr_setup : entity work.triangle_setup
    port map (
        clk        => clk,
        rst        => rst,
        data_in    => tr_data_out,
        read_out   => tr_read_en,
        addr_out   => tr_addr,
        valid_in   => tr_valid,
        ready_in   => tr_ready,
        read_in    => rast_read_in,
        addr_in    => rast_addr_in,
        data_out   => rast_data_out,
        valid_out  => rast_valid_out,
        tile_min_x => C.tile_min_x,
        tile_min_y => C.tile_min_y
    );

    rast : entity work.rasterizer_top
    port map (
        tr_mem_read_en => rast_read_in,
        tr_mem_addr    => rast_addr_in,
        tr_mem_data    => rast_data_out,
        tr_mem_valid   => rast_valid_out,
        tr_cnt         => tr_num_tr,
        fb_en          => fb_en,
        fb_wen         => fb_wen,
        fb_addr        => fb_addr,
        fb_data_in     => fb_data_in,
        fb_data_out    => fb_data_out,
        clk            => clk,
        rst            => rst,
        enable         => rast_enable,
        done           => rast_done
    );

    fb : entity work.frame_buffer
    port map(
        clka   => clk,
        rsta   => rst,
        ena    => fb_en,
        wea(0) => fb_wen,
        addra  => fb_addr,
        dina   => fb_data_out,
        douta  => fb_data_in,
        clkb   => clk,
        rstb   => rst,
        enb    => fb_axi_en,
        web(0) => '0',
        addrb  => fb_axi_addr,
        dinb   => ( others => '0' ),
        doutb  => fb_axi_data
    );

    axi_rstn <= ( not rst ) and m_axi_aresetn;
    
    axi4 : entity work.axi4_master
    port map (
        m_axi_aclk    => m_axi_aclk,
        m_axi_aresetn => axi_rstn,
        m_axi_awready => m_axi_awready,
        m_axi_awvalid => m_axi_awvalid,
        m_axi_awaddr  => m_axi_awaddr,
        m_axi_awlen   => m_axi_awlen,
        m_axi_awsize  => m_axi_awsize,
        m_axi_awburst => m_axi_awburst,
        m_axi_awprot  => m_axi_awprot,
        m_axi_awcache => m_axi_awcache,
        m_axi_wready  => m_axi_wready,
        m_axi_wvalid  => m_axi_wvalid,
        m_axi_wdata   => m_axi_wdata,
        m_axi_wstrb   => m_axi_wstrb,
        m_axi_wlast   => m_axi_wlast,
        m_axi_bready  => m_axi_bready,
        m_axi_bvalid  => m_axi_bvalid,
        m_axi_bresp   => m_axi_bresp,

        fb_addr_out   => fb_axi_addr,
        fb_data_in    => fb_axi_data,
        fb_data_en    => fb_axi_en,

        axi_addr      => C.fb_addr,
        line_width    => C.line_width,

        enable        => axi_enable,
        done          => axi_done
    );
        
    proc_seq : process( clk, rstn )
    begin
        if( rstn = '0' )
        then
            R.acc_state <= S_READ_TR_DATA;
            C           <= CONFIG_RESET;
        elsif( rising_edge( clk ) )
        then
            R <= Rin;
            C <= Cin;
        end if;
    end process proc_seq;

    proc_comb : process( R, C, data_in, addr_in, mask_in, valid_in, acc_valid_in, acc_accept_in, accept_out, rast_done, writing, axi_done )
        variable V  : proc_t;
        variable CV : config_t;
    begin
        V  := R;
        CV := C;
        
        -- By default, we don't have a valid value at the output
        tr_clr      <= '0';
        tr_write_en <= '0';
        reg_rst     <= '0';
        rast_enable <= tr_ready;
        tr_last_in  <= '0';
        tr_data_in  <= ( others => '0' );
        reg_valid   <= '0';
        reg_data    <= ( others => '0' );
        reg_addr    <= ( others => '0' );
        reg_mask    <= ( others => '0' );
        axi_enable  <= '0';

        -- When we are reading or finishing the calculations
        if( writing = '0' )
        then
            reg_valid <= '0';
            
            case R.acc_state is
                when S_RESET =>
                    reg_rst     <= '1';
                    V.acc_state := S_READ_TR_DATA;
                when S_READ_TR_DATA =>
                    if( tr_accept = '1' )
                    then
                        if( acc_valid_in = '1' )
                        then
                            if( data_in = x"DEADBEEF" )
                            then
                                tr_last_in  <= '1';
                                tr_data_in  <= ( others => '0' );
                                tr_write_en <= '0';
                            else
                                tr_last_in  <= '0';
                                tr_data_in  <= data_in;
                                tr_write_en <= '1';
                            end if;
                        end if;
                        
                        V.acc_state := S_READ_TR_DATA;
                    else
                        V.acc_state := S_PROCESSING;
                    end if;
                when S_PROCESSING =>
                    if( rast_done = '1' ) then
                        V.acc_state := S_OUTPUT_DATA;
                    else
                        V.acc_state := S_PROCESSING;
                    end if;
                when others => null;
            end case;
        elsif( writing = '1' )
        then
            case R.acc_state is
                when S_OUTPUT_DATA =>
                    -- Enable writing the local frame buffer to the actual
                    -- frame buffer
                    axi_enable <= '1';

                    if( axi_done = '1' ) then
                        -- Go to the next tile automatically
                        if( C.tile_x = C.num_tile_x - 1 )
                        then
                            if( C.tile_y = C.num_tile_y - 1 )
                            then
                                -- This is the last tile of the frame, so reset
                                -- the tile, but first output a word on the
                                -- ring to indicate that we are done.
                                if( accept_out = '1' )
                                then
                                    reg_valid     <= '1';
                                    reg_data      <= x"D043D043";
                                    V.acc_state   := S_RESET;

                                    CV.tile_x     := ( others => '0' );
                                    CV.tile_y     := ( others => '0' );
                                    CV.tile_min_x := ( others => '0' );
                                    CV.tile_min_y := ( others => '0' );
                                end if;
                            else
                                V.acc_state   := S_RESET;
                                
                                CV.tile_x     := ( others => '0' );
                                CV.tile_y     := C.tile_y + 1;
                                CV.tile_min_x := ( others => '0' );
                                CV.tile_min_y := resize( CV.tile_y * 8, 16 );
                            end if;
                        else
                            V.acc_state   := S_RESET;
                            
                            CV.tile_x     := C.tile_x + 1;
                            CV.tile_min_x := resize( CV.tile_x * 8, 16 );
                        end if;

                        CV.fb_addr := resize( unsigned( C.base_addr ) +
                                              ( ( CV.tile_y * C.line_width * 8 ) + ( CV.tile_min_x * 4 ) ), 32 );
                    else
                        V.acc_state := S_OUTPUT_DATA;
                    end if;
                when others => null;
            end case;
        end if;

        Rin <= V;
        Cin <= CV;
    end process;

    writing       <= '1' when R.acc_state = S_OUTPUT_DATA else
                     '0';
    
    acc_accept_in <= tr_accept;
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
    reg_comb : process( reg_current, conf_cs, conf_rnw, conf_data_mosi, conf_addr, acc_accept_in, acc_valid_in, data_in, rast_enable, rast_done, axi_enable ) is
        variable V : config_t;
        variable i_conf_addr : unsigned( 7 downto 0 );
    begin
        V := reg_current;

        conf_rdack     <= '0';
        conf_wrack     <= '0';
        conf_data_miso <= ( others => '0' );

        -- Reveive data timer section
        if( V.recv_act = '0' and acc_accept_in = '1' and acc_valid_in = '1' )
        then
            V.t_recv   := ( others => '0' );
            V.t_calc   := ( others => '0' );
            V.t_write  := ( others => '0' );
            V.recv_act := '1';
        end if;
        
        if( V.recv_act = '1' and acc_accept_in = '1' )
        then
            V.t_recv := V.t_recv + 1;
        else
            V.recv_act := '0';
        end if;

        -- Calculate data timer section
        if( rast_enable = '1' and rast_done = '0' )
        then
            V.recv_act := '0';
            V.t_calc   := reg_current.t_calc + 1;
        end if;

        -- AXI data write timer section
        if( axi_enable = '1' )
        then
            V.recv_act := '0';
            V.t_write  := reg_current.t_write + 1;
        end if;
        
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
                    when X"20" => conf_data_miso <= reg_current.base_addr;
                    when X"24" => conf_data_miso <= std_logic_vector( reg_current.num_tile_y & reg_current.num_tile_x );
                    when X"28" => conf_data_miso <= std_logic_vector( reg_current.tile_y & reg_current.tile_x );
                    when X"2C" => conf_data_miso <= std_logic_vector( reg_current.t_recv );
                    when X"30" => conf_data_miso <= std_logic_vector( reg_current.t_calc );
                    when X"34" => conf_data_miso <= std_logic_vector( reg_current.t_write );
                    when others => null;
                end case;
            else  -- We want to write to a configuration register
                -- Acknowledge the write request
                conf_wrack <= '1';
                
                -- Determine which register is being accessed
                case i_conf_addr is
                    when X"20" =>
                        V.base_addr  := conf_data_mosi;
                        V.fb_addr    := resize( unsigned( conf_data_mosi ) +
                            ( ( reg_current.tile_y * reg_current.num_tile_y ) + reg_current.tile_x ) * 4, 32 );
                    when X"24" =>
                        V.num_tile_x := unsigned( conf_data_mosi( 15 downto  0 ) );
                        V.num_tile_y := unsigned( conf_data_mosi( 31 downto 16 ) );
                        V.line_width := resize( unsigned( conf_data_mosi( 15 downto 0 ) ) * 32, 32 );

                        V.fb_addr    := resize( unsigned( reg_current.base_addr ) +
                            ( ( reg_current.tile_y * reg_current.line_width * 8 * unsigned( conf_data_mosi( 31 downto 16 ) ) ) + ( reg_current.tile_x * 32 ) ), 32 );
                    when X"28" =>
                        V.tile_x     := unsigned( conf_data_mosi( 15 downto  0 ) );
                        V.tile_y     := unsigned( conf_data_mosi( 31 downto 16 ) );
                        V.tile_min_x := resize( unsigned( conf_data_mosi( 15 downto  0 ) ) * 8, 16 );
                        V.tile_min_y := resize( unsigned( conf_data_mosi( 31 downto 16 ) ) * 8, 16 );

                        V.fb_addr    := resize( unsigned( reg_current.base_addr ) +
                            ( ( V.tile_y * reg_current.line_width * 8 ) + ( V.tile_min_x * 4 ) ), 32 );
                    when others => null;
                end case;
            end if;
        else -- The configuration bus is not active, so we are done configuring
            conf_done <= '1';
        end if;

        reg_next <= V;
    end process reg_comb;
end rtl;
