library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;

entity cross3 is
    generic(
        DATA_WIDTH : integer := 32
    );
    port(
        clk        : in  std_logic;
        rst        : in  std_logic;

        -- Input
        data_in_a  : in  float3_t;
        data_in_b  : in  float3_t;
        valid_in   : in  std_logic;
        accept_in  : out std_logic;

        -- Output
        data_out   : out float3_t;
        valid_out  : out std_logic;
        accept_out : in  std_logic
    );
end cross3;

architecture rtl of cross3 is
    type state_t is ( MUL_1, SUB_1, OUTPUT_RESULT );

    signal reg_data   : float3_t;
    signal reg_valid  : std_logic;
    
    -- Accelerator data
    type proc_t is record
        data   : float3_t;
        state  : state_t;
    end record;

    constant PROC_RESET : proc_t := (
        data  => ( ( others => '0' ), ( others => '0' ), ( others => '0' ) ),
        state => MUL_1
    );

    signal R, Rin : proc_t := PROC_RESET;

    -- Multiplier signals
    type mul_input_t is array ( 0 to 5 ) of slv32_t;
    
    signal mul_in_a     : mul_input_t;
    signal mul_in_b     : mul_input_t;
    signal mul_res      : mul_input_t;
    signal mul_rdy      : std_logic_vector( 5 downto 0 );
    signal mul_nd       : std_logic;

    signal mul_all_rdy  : std_logic;

    -- Subtracter signals
    signal sub_a        : float3_t;
    signal sub_b        : float3_t;
    signal sub_res      : float3_t;
    signal sub_nd       : std_logic;
    signal sub_rdy      : std_logic_vector( 2 downto 0 );

    signal sub_all_rdy  : std_logic;

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
    GEN_MUL : for i in 0 to 5 generate
        mul : entity work.fp_mul
        port map (
            a             => mul_in_a( i ),
            b             => mul_in_b( i ),
            operation_nd  => mul_nd,
            clk           => clk,
            sclr          => rst,
            result        => mul_res( i ),
            rdy           => mul_rdy( i )
        );
        
        mul_in_a( i ) <= data_in_a( 1 ) when mul_nd = '1' and i = 0 else
                         data_in_a( 2 ) when mul_nd = '1' and i = 1 else
                         data_in_a( 0 ) when mul_nd = '1' and i = 2 else
                         data_in_a( 2 ) when mul_nd = '1' and i = 3 else
                         data_in_a( 0 ) when mul_nd = '1' and i = 4 else
                         data_in_a( 1 ) when mul_nd = '1' and i = 5 else
                         ( others => '0' );

        mul_in_b( i ) <= data_in_b( 2 ) when mul_nd = '1' and i = 0 else
                         data_in_b( 0 ) when mul_nd = '1' and i = 1 else
                         data_in_b( 1 ) when mul_nd = '1' and i = 2 else
                         data_in_b( 1 ) when mul_nd = '1' and i = 3 else
                         data_in_b( 2 ) when mul_nd = '1' and i = 4 else
                         data_in_b( 0 ) when mul_nd = '1' and i = 5 else
                         ( others => '0' );
        
        mul_nd        <= '1' when R.state = MUL_1 and valid_in = '1' else
                         '0';
    end generate GEN_MUL;

    mul_all_rdy <= mul_rdy( 0 ) and mul_rdy( 1 ) and mul_rdy( 2 ) and
                   mul_rdy( 3 ) and mul_rdy( 4 ) and mul_rdy( 5 );

    -------------------
    --- Subtracters ---
    -------------------
    GEN_SUB : for i in 0 to 2 generate
        sub : entity work.fp_addsub
        port map (
            a             => sub_a( i ),
            b             => sub_b( i ),
            operation     => "000001", -- Subtract
            operation_nd  => sub_nd,
            clk           => clk,
            sclr          => rst,
            result        => sub_res( i ),
        	rdy           => sub_rdy( i )
        );

        sub_nd <= '1' when mul_all_rdy = '1' else
                  '0';

        sub_a( i ) <= mul_res( i ) when sub_nd = '1' else
                      ( others => '0' );
        sub_b( i ) <= mul_res( i + 3 ) when sub_nd = '1' else
                      ( others => '0' );
    end generate GEN_SUB;

    sub_all_rdy <= sub_rdy( 0 ) and sub_rdy( 1 ) and sub_rdy( 2 );
        
    proc_comb : process( R, data_in_a, data_in_b, valid_in, accept_out, mul_res, mul_all_rdy, sub_res, sub_all_rdy )
        variable V : proc_t;
    begin
        V := R;
        
        -- By default, we don't have a valid value at the output
        reg_valid <= '0';
        reg_data  <= ( ( others => '0' ), ( others => '0' ), ( others => '0' ) );

        case R.state is
            when MUL_1 =>
                if( valid_in = '1' ) then
                    V.state := SUB_1;
                else
                    V.state := MUL_1;
                end if; 
            when SUB_1 =>
                if( mul_all_rdy = '1' ) then
                    V.state := OUTPUT_RESULT;
                else
                    V.state := SUB_1;
                end if;
            when OUTPUT_RESULT =>
                if( sub_all_rdy = '1' ) then
                    V.data   := sub_res;
                    reg_data <= sub_res;
                end if;

                if( accept_out = '1' ) then
                    if( sub_all_rdy = '1' ) then
                        reg_data <= sub_res;
                    else
                        reg_data <= R.data;
                    end if;

                    V.state := MUL_1;
                    reg_valid       <= '1';
                else
                    V.state := OUTPUT_RESULT;
                end if;
            when others => null;
        end case;

        Rin <= V;
    end process;
    
    accept_in <= '1' when R.state = MUL_1 else
                 '0';
    valid_out <= reg_valid;
    data_out  <= reg_data;

end rtl;
