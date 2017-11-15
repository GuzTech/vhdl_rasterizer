library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;

entity div3 is
    port(
        clk        : in  std_logic;
        rst        : in  std_logic;

        -- Input
        data_in_a  : in  float3_t;
        data_in_b  : in  slv32_t;
        valid_in   : in  std_logic;
        accept_in  : out std_logic;

        -- Output
        data_out   : out float3_t;
        valid_out  : out std_logic;
        accept_out : in  std_logic
    );
end div3;

architecture rtl of div3 is
    type state_t is ( S_DIV, S_WAIT, S_OUTPUT_RESULT );

    signal reg_data   : float3_t;
    signal reg_valid  : std_logic;
    
    -- Accelerator data
    type proc_t is record
        data  : float3_t;
        state : state_t;
    end record;

    constant PROC_RESET : proc_t := (
        data  => ( ( others => '0' ), ( others => '0' ), ( others => '0' ) ),
        state => S_DIV
    );

    signal R, Rin : proc_t := PROC_RESET;

    -- Subtracter signals
    signal div_res     : float3_t;
    signal div_rdy     : std_logic_vector( 2 downto 0 );

    signal div_all_rdy : std_logic;

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
    ---- Dividers -----
    -------------------
    GEN_DIV : for i in 0 to 2 generate
        div : entity work.fp_div
        port map (
            a             => data_in_a( i ),
            b             => data_in_b,
            operation_nd  => valid_in,
            clk           => clk,
            sclr          => rst,
            result        => div_res( i ),
            rdy           => div_rdy( i )
        );
    end generate;

    div_all_rdy <= div_rdy( 0 ) and div_rdy( 1 ) and div_rdy( 2 );
        
    proc_comb : process( R, data_in_a, data_in_b, valid_in, accept_out, div_rdy, div_res, div_all_rdy )
        variable V : proc_t;
    begin
        V := R;
        
        -- By default, we don't have a valid value at the output
        reg_valid <= '0';
        reg_data  <= ( ( others => '0' ), ( others => '0' ), ( others => '0' ) );
        
        case R.state is
            when S_DIV =>
                if( valid_in = '1' )
                then
                    V.state := S_WAIT;
                else
                    V.state := S_DIV;
                end if;
            when S_WAIT =>
                if( div_all_rdy = '1' )
                then
                    V.data  := div_res;
                    V.state := S_OUTPUT_RESULT;
                else
                    V.state := S_WAIT;
                end if;
            when S_OUTPUT_RESULT =>
                if( accept_out = '1' )
                then
                    reg_data  <= R.data;
                    reg_valid <= '1';
                    V.state   := S_DIV;
                else
                    V.state := S_OUTPUT_RESULT;
                end if;
            when others => null;
        end case;

        Rin <= V;
    end process;

    accept_in <= '1' when R.state = S_DIV else
                 '0';
    valid_out <= reg_valid;
    data_out  <= reg_data;

end rtl;
