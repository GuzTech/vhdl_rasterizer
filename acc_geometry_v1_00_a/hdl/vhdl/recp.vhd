library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;

entity recp is
    port(
        clk        : in  std_logic;
        rst        : in  std_logic;

        -- Input
        data_in    : in  float_t;
        valid_in   : in  std_logic;
        accept_in  : out std_logic;

        -- Output
        data_out   : out float_t;
        valid_out  : out std_logic;
        accept_out : in  std_logic
    );
end recp;

architecture rtl of recp is
    type state_t is ( DIV_1, OUTPUT_RESULT );

    signal reg_data   : float_t;
    signal reg_valid  : std_logic;
    
    -- Accelerator data
    type proc_t is record
        data  : float_t;
        state : state_t;
    end record;

    constant PROC_RESET : proc_t := (
        data  => ( others => '0' ),
        state => DIV_1
    );

    signal R, Rin : proc_t := PROC_RESET;

    -- Subtracter signals
    signal div_res      : float_t;
    signal div_rdy      : std_logic;

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
    ----- Divider -----
    -------------------
    div : entity work.fp_div
    port map (
        a             => FLOAT_1F,
        b             => data_in,
        operation_nd  => valid_in,
        clk           => clk,
        sclr          => rst,
        result        => div_res,
        rdy           => div_rdy
    );

    proc_comb : process( R, data_in, valid_in, accept_out, div_rdy, div_res )
        variable V : proc_t;
    begin
        V := R;
        
        -- By default, we don't have a valid value at the output
        reg_valid <= '0';
        reg_data  <= ( others => '0' );
        
        case R.state is
            when DIV_1 =>
                if( valid_in = '1' ) then
                    V.state := OUTPUT_RESULT;
                else
                    V.state := DIV_1;
                end if; 
            when OUTPUT_RESULT =>
                if( div_rdy = '1' ) then
                    V.data   := div_res;
                    reg_data <= div_res;
                end if;
                
                if( accept_out = '1' ) then
                    if( div_rdy = '1' ) then
                        reg_data <= div_res;
                    else
                        reg_data <= R.data;
                    end if;
                    
                    V.state   := DIV_1;
                    reg_valid <= '1';
                else
                    V.state := OUTPUT_RESULT;
                end if;
            when others => null;
        end case;

        Rin <= V;
    end process;

    accept_in <= '1' when R.state = DIV_1 else
                 '0';
    valid_out <= reg_valid;
    data_out  <= reg_data;

end rtl;
