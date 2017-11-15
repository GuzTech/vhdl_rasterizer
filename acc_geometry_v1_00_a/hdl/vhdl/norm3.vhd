library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;

entity norm3 is
    generic(
        DATA_WIDTH : integer := 32
    );
    port(
        clk        : in  std_logic;
        rst        : in  std_logic;

        -- Input
        data_in    : in  float3_t;
        valid_in   : in  std_logic;
        accept_in  : out std_logic;

        -- Output
        data_out   : out float3_t;
        valid_out  : out std_logic;
        accept_out : in  std_logic
    );
end norm3;

architecture rtl of norm3 is
    type state_t is ( READ_INPUT, ADD_1, ADD_2, SQRT, DIV_LENGTH, OUTPUT_RESULT );

    -- Helper signal(s)
    signal add_states : std_logic; -- Is '1' if the current state is ADD_1 or ADD_2.

    signal reg_data   : float3_t;
    signal reg_valid  : std_logic;
    
    -- Accelerator data
    type proc_t is record
        data    : float3_t; -- Holds the input data
        mul_res : float3_t; -- Holds the multiplication result
        length  : slv32_t;
        state   : state_t;
    end record;

    constant PROC_RESET : proc_t := (
        data    => ( ( others => '0' ), ( others => '0' ), ( others => '0' ) ),
        mul_res => ( ( others => '0' ), ( others => '0' ), ( others => '0' ) ),
        length  => ( others => '0' ),
        state   => READ_INPUT
    );

    signal R, Rin : proc_t := PROC_RESET;

    -- Multiplier signals
    signal mul_in       : float3_t;
    signal mul_res      : float3_t;
    signal mul_rdy      : std_logic_vector( 2 downto 0 );
    signal mul_nd       : std_logic;

    signal mul_all_rdy  : std_logic;

    -- Adder signals
    signal add_a        : slv32_t;
    signal add_b        : slv32_t;
    signal add_res      : slv32_t;
    signal add_nd       : std_logic;
    signal add_rdy      : std_logic;

    -- Square-root signals
    signal sqrt_in      : slv32_t;
    signal sqrt_res     : slv32_t;
    signal sqrt_nd      : std_logic;
    signal sqrt_rdy     : std_logic;

    -- Divider signals
    signal div_res      : float3_t;
    signal div_nd       : std_logic;
    signal div_rdy      : std_logic_vector( 2 downto 0 );

    signal div_all_rdy  : std_logic;

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
    --- Multipliers ---
    -------------------
    GEN_MUL : for i in 0 to 2 generate
        mul : entity work.fp_mul
        port map (
            a             => mul_in( i ),
            b             => mul_in( i ),
            operation_nd  => mul_nd,
            clk           => clk,
            sclr          => rst,
            result        => mul_res( i ),
            rdy           => mul_rdy( i )
        );
        
        mul_in( i ) <= data_in( i ) when mul_nd = '1' else
                       ( others => '0' );
    end generate GEN_MUL;

    mul_nd      <= '1' when R.state = READ_INPUT and valid_in = '1' else
                   '0';

    mul_all_rdy <= mul_rdy( 0 ) and mul_rdy( 1 ) and mul_rdy( 2 );

    -------------------
    ------ Adder ------
    -------------------
    add : entity work.fp_add
    port map (
        a             => add_a,
        b             => add_b,
        operation_nd  => add_nd,
        clk           => clk,
        sclr          => rst,
        result        => add_res,
        rdy           => add_rdy
    );

    -- These assignments could fail as the ready signal of the floating point IPs used
    -- (fp_add, fp_mul, etc.) is only high for one clock cycle. They are
    -- configured to take one clock cycle per operation, so it isn't a problem
    -- in this case, but it could be if we increase the latency of the operations.
    add_nd <= '1' when mul_all_rdy = '1' and R.state = ADD_1 else
              '1' when add_rdy = '1'     and R.state = ADD_2 else
              '0';

    add_a  <= mul_res( 0 ) when add_nd = '1' and R.state = ADD_1 else
              add_res      when add_nd = '1' and R.state = ADD_2 else
              ( others => '0' );

    add_b  <= mul_res( 1 )   when add_nd = '1' and R.state = ADD_1 else
              R.mul_res( 2 ) when add_nd = '1' and R.state = ADD_2 else
              ( others => '0' );

    -------------------
    --- Square-root ---
    -------------------
    sqrt_ip : entity work.fp_sqrt
    port map (
        a             => sqrt_in,
        operation_nd  => sqrt_nd,
        clk           => clk,
        sclr          => rst,
        result        => sqrt_res,
        rdy           => sqrt_rdy
    );

    sqrt_nd <= '1' when add_rdy = '1' and R.state = SQRT else
               '0';
    sqrt_in <= add_res when add_rdy = '1' and R.state = SQRT else
               ( others => '0' );

    -------------------
    ----- Dividers ----
    -------------------
    GEN_DIV : for i in 0 to 2 generate
        div : entity work.fp_div
        port map (
            a             => R.data( i ),
            b             => sqrt_res,
            operation_nd  => div_nd,
            clk           => clk,
            sclr          => rst,
            result        => div_res( i ),
            rdy           => div_rdy( i )
        );
    end generate GEN_DIV;

    div_nd  <= '1' when sqrt_rdy = '1' and R.state = DIV_LENGTH else
               '0';

    div_all_rdy <= div_rdy( 0 ) and div_rdy( 1 ) and div_rdy( 2 );
        
    proc_comb : process( R, data_in, valid_in, accept_out, mul_res, mul_all_rdy, add_res, add_rdy, sqrt_res, sqrt_rdy, div_res, div_all_rdy )
        variable V : proc_t;
    begin
        V := R;
        
        -- By default, we don't have a valid value at the output
        reg_valid <= '0';
        reg_data  <= ( ( others => '0' ), ( others => '0' ), ( others => '0' ) );

        case R.state is
            when READ_INPUT =>
                if( valid_in = '1' ) then
                    V.data  := data_in;
                    V.state := ADD_1;
                else
                    V.state := READ_INPUT;
                end if; 
            when ADD_1 =>
                if( mul_all_rdy = '1' ) then
                    V.mul_res := mul_res;
                    V.state   := ADD_2;
                else
                    V.state := ADD_1;
                end if;
            when ADD_2 =>
                if( add_rdy = '1' ) then
                    V.state := SQRT;
                else
                    V.state := ADD_2;
                end if;
            when SQRT =>
                if( add_rdy = '1' ) then
                    V.length := add_res;
                    V.state  := DIV_LENGTH;
                else
                    V.state  := SQRT;
                end if;
            when DIV_LENGTH =>
                if( sqrt_rdy = '1' ) then
                    V.length := sqrt_res;
                    V.state  := OUTPUT_RESULT;
                else
                    V.state  := DIV_LENGTH;
                end if;
            when OUTPUT_RESULT =>
                if( div_all_rdy = '1' ) then
                    V.data   := div_res;
                    reg_data <= div_res;
                end if;

                if( accept_out = '1' ) then
                    if( div_all_rdy = '1' ) then
                        reg_data <= div_res;
                    else
                        reg_data <= R.data;
                    end if;

                    V.state   := READ_INPUT;
                    reg_valid <= '1';
                else
                    V.state := OUTPUT_RESULT;
                end if;
            when others => null;
        end case;

        Rin <= V;
    end process;
    
    add_states <= '1' when R.state = ADD_1 or
                           R.state = ADD_2 else
                  '0';

    accept_in <= '1' when R.state = READ_INPUT else
                 '0';
    valid_out <= reg_valid;
    data_out  <= reg_data;

end rtl;
