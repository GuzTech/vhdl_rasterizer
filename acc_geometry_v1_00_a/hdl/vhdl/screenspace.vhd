library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;

entity screenspace is
    port(
        clk        : in  std_logic;
        rst        : in  std_logic;

        -- Input
        data_in_a  : in  float2_t;
        data_in_b  : in  float2_t;
        data_in_c  : in  float2_t;
        valid_in   : in  std_logic;
        accept_in  : out std_logic;
        vp_width   : in  slv32_t;
        vp_height  : in  slv32_t;

        -- Output
        data_out_a : out int16_2_t;
        data_out_b : out int16_2_t;
        data_out_c : out int16_2_t;
        valid_out  : out std_logic;
        accept_out : in  std_logic
    );
end screenspace;

architecture rtl of screenspace is
    type state_t is ( PLUS1, MUL_HALF, SUB_1, MUL_HEIGHT, ADD_HALF, FLOAT_TO_INT, OUTPUT_RESULT );

    signal reg_data_a : int16_2_t;
    signal reg_data_b : int16_2_t;
    signal reg_data_c : int16_2_t;
    signal reg_valid  : std_logic;
    
    -- Accelerator data
    type proc_t is record
        data_a  : int16_2_t;
        data_b  : int16_2_t;
        data_c  : int16_2_t;
        state   : state_t;
        input_a : float2_t;
        input_b : float2_t;
        input_c : float2_t;
    end record;

    constant PROC_RESET : proc_t := (
        data_a  => ( ( others => '0' ), ( others => '0' ) ),
        data_b  => ( ( others => '0' ), ( others => '0' ) ),
        data_c  => ( ( others => '0' ), ( others => '0' ) ),
        state   => PLUS1,
        input_a => ( ( others => '0' ), ( others => '0' ) ),
        input_b => ( ( others => '0' ), ( others => '0' ) ),
        input_c => ( ( others => '0' ), ( others => '0' ) )
    );

    signal R, Rin : proc_t := PROC_RESET;

    -- Multiplier signals
    type mul_input_t is array ( 0 to 5 ) of slv32_t;
    
    signal mul0_in_a    : float2_t;
    signal mul0_in_b    : float2_t;
    signal mul0_res     : float2_t;
    signal mul0_rdy     : std_logic_vector( 1 downto 0 );

    signal mul1_in_a    : float2_t;
    signal mul1_in_b    : float2_t;
    signal mul1_res     : float2_t;
    signal mul1_rdy     : std_logic_vector( 1 downto 0 );

    signal mul2_in_a    : float2_t;
    signal mul2_in_b    : float2_t;
    signal mul2_res     : float2_t;
    signal mul2_rdy     : std_logic_vector( 1 downto 0 );

    signal mul_nd       : std_logic;
    signal mul_all_rdy  : std_logic;

    -- Addsub signals
    signal addsub0_a      : float2_t;
    signal addsub0_b      : float2_t;
    signal addsub0_res    : float2_t;
    signal addsub0_rdy    : std_logic_vector( 1 downto 0 );

    signal addsub1_a      : float2_t;
    signal addsub1_b      : float2_t;
    signal addsub1_res    : float2_t;
    signal addsub1_rdy    : std_logic_vector( 1 downto 0 );

    signal addsub2_a      : float2_t;
    signal addsub2_b      : float2_t;
    signal addsub2_res    : float2_t;
    signal addsub2_rdy    : std_logic_vector( 1 downto 0 );

    signal addsub_nd      : std_logic;
    signal addsub_op      : std_logic_vector( 5 downto 0 );
    signal addsub_all_rdy : std_logic;

    -- Floating point to int signals
    signal toint_a        : float3_t;
    signal toint_res      : int16_3_t;
    signal toint_rdy      : std_logic_vector( 2 downto 0 );
    signal toint_nd       : std_logic;
    signal toint_all_rdy  : std_logic;
    
begin

    proc_seq : process( rst, clk )
    begin
        if( rst = '1' )
        then
            R <= PROC_RESET;
        elsif( rising_edge( clk ) )
        then
            R <= Rin;
        end if;
    end process proc_seq;

    -------------------
    ----- Add/sub -----
    -------------------
    GEN_ADDSUB : for i in 0 to 1 generate
        addsub_v0 : entity work.fp_addsub
        port map (
            a             => addsub0_a( i ),
            b             => addsub0_b( i ),
            operation     => addsub_op,
            operation_nd  => addsub_nd,
            clk           => clk,
            sclr          => rst,
            result        => addsub0_res( i ),
            rdy           => addsub0_rdy( i )
        );

        addsub0_a( i ) <= FLOAT_1F  when R.state = PLUS1                else -- 1.0f
                          FLOAT_1F  when R.state = SUB_1      and i = 1 else -- 1.0f
                          FLOAT_05F when R.state = MUL_HEIGHT and i = 0 else -- 0.5f
                          FLOAT_05F when R.state = ADD_HALF   and i = 1 else -- 0.5f
                          ( others => '0' );
        addsub0_b( i ) <= data_in_a( i ) when R.state = PLUS1      and valid_in = '1' else
                          mul0_res( 1 )  when R.state = SUB_1      and i = 1          else
                          mul0_res( 0 )  when R.state = MUL_HEIGHT and i = 0          else
                          mul0_res( 1 )  when R.state = ADD_HALF   and i = 1          else
                          ( others => '0' );

        addsub_v1 : entity work.fp_addsub
        port map (
            a             => addsub1_a( i ),
            b             => addsub1_b( i ),
            operation     => addsub_op,
            operation_nd  => addsub_nd,
            clk           => clk,
            sclr          => rst,
            result        => addsub1_res( i ),
            rdy           => addsub1_rdy( i )
        );

        addsub1_a( i ) <= FLOAT_1F  when R.state = PLUS1                else -- 1.0f
                          FLOAT_1F  when R.state = SUB_1      and i = 1 else -- 1.0f
                          FLOAT_05F when R.state = MUL_HEIGHT and i = 0 else -- 0.5f
                          FLOAT_05F when R.state = ADD_HALF   and i = 1 else -- 0.5f
                          ( others => '0' );
        addsub1_b( i ) <= data_in_b( i ) when R.state = PLUS1      and valid_in = '1' else
                          mul1_res( 1 )  when R.state = SUB_1      and i = 1          else
                          mul1_res( 0 )  when R.state = MUL_HEIGHT and i = 0          else
                          mul1_res( 1 )  when R.state = ADD_HALF   and i = 1          else
                          ( others => '0' );

        addsub_v2 : entity work.fp_addsub
        port map (
            a             => addsub2_a( i ),
            b             => addsub2_b( i ),
            operation     => addsub_op,
            operation_nd  => addsub_nd,
            clk           => clk,
            sclr          => rst,
            result        => addsub2_res( i ),
            rdy           => addsub2_rdy( i )
        );

        addsub2_a( i ) <= FLOAT_1F when R.state = PLUS1                else -- 1.0f
                          FLOAT_1F when R.state = SUB_1      and i = 1 else -- 1.0f
                          FLOAT_1F when R.state = MUL_HEIGHT and i = 0 else -- 0.5f
                          FLOAT_1F when R.state = ADD_HALF   and i = 1 else -- 0.5f
                          ( others => '0' );
        addsub2_b( i ) <= data_in_c( i ) when R.state = PLUS1      and valid_in = '1' else
                          mul2_res( 1 )  when R.state = SUB_1      and i = 1          else
                          mul2_res( 0 )  when R.state = MUL_HEIGHT and i = 0          else
                          mul2_res( 1 )  when R.state = ADD_HALF   and i = 1          else
                          ( others => '0' );

    end generate GEN_ADDSUB;

    addsub_nd <= '1' when R.state = PLUS1 and valid_in = '1' else
                 '1' when R.state = SUB_1                    else
                 '1' when R.state = MUL_HEIGHT               else
                 '1' when R.state = ADD_HALF                 else
                 '0';
    
    addsub_op <= "000000" when R.state = PLUS1 else -- Add
                 "000001" when R.state = SUB_1 else -- Subtract
                 ( others => '0' );

    addsub_all_rdy <= addsub0_rdy( 0 ) and addsub0_rdy( 1 ) and
                      addsub1_rdy( 0 ) and addsub1_rdy( 1 ) and
                      addsub2_rdy( 0 ) and addsub2_rdy( 1 );
    
    -------------------
    --- Multipliers ---
    -------------------
    GEN_MUL : for i in 0 to 1 generate
        mul_v0 : entity work.fp_mul
        port map (
            a             => mul0_in_a( i ),
            b             => mul0_in_b( i ),
            operation_nd  => mul_nd,
            clk           => clk,
            sclr          => rst,
            result        => mul0_res( i ),
            rdy           => mul0_rdy( i )
        );
        
        mul0_in_a( i ) <= FLOAT_05F        when R.state = MUL_HALF             else
                          mul0_res( 0 )    when R.state = SUB_1      and i = 0 else
                          addsub0_res( 1 ) when R.state = MUL_HEIGHT and i = 1 else
                          ( others => '0' );
    
        mul0_in_b( i ) <= addsub0_res( i ) when R.state = MUL_HALF             else
                          vp_width         when R.state = SUB_1      and i = 0 else
                          vp_height        when R.state = MUL_HEIGHT and i = 1 else
                          ( others => '0' );

        mul_v1 : entity work.fp_mul
        port map (
            a             => mul1_in_a( i ),
            b             => mul1_in_b( i ),
            operation_nd  => mul_nd,
            clk           => clk,
            sclr          => rst,
            result        => mul1_res( i ),
            rdy           => mul1_rdy( i )
        );
        
        mul1_in_a( i ) <= FLOAT_05F        when R.state = MUL_HALF             else
                          mul1_res( 0 )    when R.state = SUB_1      and i = 0 else
                          addsub1_res( 1 ) when R.state = MUL_HEIGHT and i = 1 else
                          ( others => '0' );
    
        mul1_in_b( i ) <= addsub1_res( i ) when R.state = MUL_HALF             else
                          vp_width         when R.state = SUB_1      and i = 0 else
                          vp_height        when R.state = MUL_HEIGHT and i = 1 else
                          ( others => '0' );

        mul_v2 : entity work.fp_mul
        port map (
            a             => mul2_in_a( i ),
            b             => mul2_in_b( i ),
            operation_nd  => mul_nd,
            clk           => clk,
            sclr          => rst,
            result        => mul2_res( i ),
            rdy           => mul2_rdy( i )
        );
        
        mul2_in_a( i ) <= FLOAT_05F        when R.state = MUL_HALF             else
                          mul2_res( 0 )    when R.state = SUB_1      and i = 0 else
                          addsub2_res( 1 ) when R.state = MUL_HEIGHT and i = 1 else
                          ( others => '0' );
    
        mul2_in_b( i ) <= addsub2_res( i ) when R.state = MUL_HALF             else
                          vp_width         when R.state = SUB_1      and i = 0 else
                          vp_height        when R.state = MUL_HEIGHT and i = 1 else
                          ( others => '0' );
    end generate GEN_MUL;

    mul_nd      <= '1' when R.state = MUL_HALF   and addsub_all_rdy = '1'                       else
                   '1' when R.state = SUB_1      and mul_all_rdy = '1'                          else
                   '1' when R.state = MUL_HEIGHT and addsub_all_rdy = '1' and mul_all_rdy = '1' else
                   '0';
    
    mul_all_rdy <= mul0_rdy( 0 ) and mul0_rdy( 1 ) and
                   mul1_rdy( 0 ) and mul1_rdy( 1 ) and
                   mul2_rdy( 0 ) and mul2_rdy( 1 );

    GEN_FLOAT_TO_INT : for i in 0 to 2 generate
        toint : entity work.fp_to_int16
        port map (
            a             => toint_a( i ),
            operation_nd  => toint_nd,
            clk           => clk,
            sclr          => rst,
            result        => toint_res( i ),
            rdy           => toint_rdy( i )
        );

    end generate GEN_FLOAT_TO_INT;

    toint_nd      <= '1' when R.state = ADD_HALF     else
                     '1' when R.state = FLOAT_TO_INT else
                     '0';
    
    toint_a( 0 )  <= addsub0_res( 0 ) when R.state = ADD_HALF     else
                     addsub0_res( 1 ) when R.state = FLOAT_TO_INT else
                     ( others => '0' );
    toint_a( 1 )  <= addsub1_res( 0 ) when R.state = ADD_HALF     else
                     addsub1_res( 1 ) when R.state = FLOAT_TO_INT else
                     ( others => '0' );
    toint_a( 2 )  <= addsub2_res( 0 ) when R.state = ADD_HALF     else
                     addsub2_res( 1 ) when R.state = FLOAT_TO_INT else
                     ( others => '0' );

    toint_all_rdy <= toint_rdy( 0 ) and toint_rdy( 1 ) and toint_rdy( 2 );
            
    proc_comb : process( R, data_in_a, data_in_b, data_in_c, valid_in, accept_out, addsub_all_rdy, mul_all_rdy )
        variable V : proc_t;
    begin
        V := R;
        
        -- By default, we don't have a valid value at the output
        reg_valid <= '0';
        reg_data_a <= ( ( others => '0' ), ( others => '0' ) );
        reg_data_b <= ( ( others => '0' ), ( others => '0' ) );
        reg_data_c <= ( ( others => '0' ), ( others => '0' ) );

        case R.state is
            when PLUS1 =>
                if( valid_in = '1' )
                then
                    V.input_a := data_in_a;
                    V.input_b := data_in_b;
                    V.input_c := data_in_c;
                    
                    V.state := MUL_HALF;
                else
                    V.state := PLUS1;
                end if; 
            when MUL_HALF =>
                if( addsub_all_rdy = '1' )
                then
                    V.state := SUB_1;
                else
                    V.state := MUL_HALF;
                end if;
            when SUB_1 =>
                if( mul_all_rdy = '1' )
                then
                    V.state := MUL_HEIGHT;
                else
                    V.state := SUB_1;
                end if;
            when MUL_HEIGHT =>
                if( mul_all_rdy = '1' and addsub_all_rdy = '1' )
                then
                    V.state := ADD_HALF;
                else
                    V.state := MUL_HEIGHT;
                end if;
            when ADD_HALF =>
                if( mul_all_rdy = '1' and addsub_all_rdy = '1' )
                then
                    V.state := FLOAT_TO_INT;
                else
                    V.state := ADD_HALF;
                end if;
            when FLOAT_TO_INT =>
                if( addsub_all_rdy = '1' )
                then
                    V.data_a( 0 ) := toint_res( 0 ); -- x
                    V.data_b( 0 ) := toint_res( 1 ); -- x
                    V.data_c( 0 ) := toint_res( 2 ); -- x
                    V.state       := OUTPUT_RESULT;
                else
                    V.state := FLOAT_TO_INT;
                end if;
            when OUTPUT_RESULT =>
                if( toint_all_rdy = '1' )
                then
                    V.data_a( 1 ) := toint_res( 0 ); -- y
                    V.data_b( 1 ) := toint_res( 1 ); -- y
                    V.data_c( 1 ) := toint_res( 2 ); -- y

                    reg_data_a( 0 ) <= R.data_a( 0 );
                    reg_data_b( 0 ) <= R.data_b( 0 );
                    reg_data_c( 0 ) <= R.data_c( 0 );
                    reg_data_a( 1 ) <= toint_res( 0 );
                    reg_data_b( 1 ) <= toint_res( 1 );
                    reg_data_c( 1 ) <= toint_res( 2 );
                end if;

                if( accept_out = '1' )
                then
                    if( toint_all_rdy = '1' )
                    then
                        reg_data_a( 0 ) <= R.data_a( 0 );
                        reg_data_b( 0 ) <= R.data_b( 0 );
                        reg_data_c( 0 ) <= R.data_c( 0 );
                        reg_data_a( 1 ) <= toint_res( 0 );
                        reg_data_b( 1 ) <= toint_res( 1 );
                        reg_data_c( 1 ) <= toint_res( 2 );
                    else
                        reg_data_a <= R.data_a;
                        reg_data_b <= R.data_b;
                        reg_data_c <= R.data_c;
                    end if;
                        
                    V.state   := PLUS1;
                    reg_valid <= '1';
                else
                    V.state := OUTPUT_RESULT;
                end if;
            when others => null;
        end case;

        Rin <= V;
    end process;
    
    accept_in  <= '1' when R.state = PLUS1 else
                  '0';
    valid_out  <= reg_valid;
    data_out_a <= reg_data_a;
    data_out_b <= reg_data_b;
    data_out_c <= reg_data_c;

end rtl;
