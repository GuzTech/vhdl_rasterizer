library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;

entity sub3 is
    port(
        clk        : in  std_logic;
        rst        : in  std_logic;

        -- Input
        data_in_a  : in  slv32_t;
        data_in_b  : in  float3_t;
        valid_in   : in  std_logic;
        accept_in  : out std_logic;

        -- Output
        data_out   : out float3_t;
        valid_out  : out std_logic;
        accept_out : in  std_logic
    );
end sub3;

architecture rtl of sub3 is
    type state_t        is ( SUB_1, SUB_2, SUB_3, OUTPUT_RESULT );
    type result_state_t is ( RES_1, RES_2, RES_3 );

    -- Helper signals
    signal read_states : std_logic; -- Is '1' when the current state is SUB_1,
                                    -- SUB_2 or SUB_3.

    signal reg_data   : float3_t;
    signal reg_valid  : std_logic;
    
    -- Accelerator data
    type proc_t is record
        data      : float3_t;
        state     : state_t;
        res_state : result_state_t;
    end record;

    constant PROC_RESET : proc_t := (
        data      => ( ( others => '0' ), ( others => '0' ), ( others => '0' ) ),
        state     => SUB_1,
        res_state => RES_1
    );

    signal R, Rin : proc_t := PROC_RESET;

    -- Subtracter signals
    signal sub_a   : slv32_t;
    signal sub_b   : slv32_t;
    signal sub_res : slv32_t;
    signal sub_nd  : std_logic;
    signal sub_rdy : std_logic;

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
    --- Subtracter ----
    -------------------
    sub : entity work.fp_addsub
    port map (
        a             => sub_a,
        b             => sub_b,
        operation     => "000001", -- Subtract
        operation_nd  => sub_nd,
        clk           => clk,
        sclr          => rst,
        result        => sub_res,
        rdy           => sub_rdy
    );

    -- These assignments could fail as the ready signal of the floating point IPs used
    -- (fp_add, fp_mul, etc.) is only high for one clock cycle. They are
    -- configured to take one clock cycle per operation, so it isn't a problem
    -- in this case, but it could be if we increase the latency of the operations.
    sub_nd <= '1' when valid_in = '1' and read_states = '1' else
              '0';

    sub_a  <= data_in_a when sub_nd = '1' else
              ( others => '0' );

    sub_b  <= data_in_b( 0 ) when sub_nd = '1' and R.state = SUB_1 else
              data_in_b( 1 ) when sub_nd = '1' and R.state = SUB_2 else
              data_in_b( 2 ) when sub_nd = '1' and R.state = SUB_3 else
              ( others => '0' );
        
    proc_comb : process( R, data_in_a, data_in_b, valid_in, accept_out, sub_rdy, sub_res )
        variable V : proc_t;
    begin
        V := R;
        
        -- By default, we don't have a valid value at the output
        reg_valid <= '0';
        reg_data  <= ( ( others => '0' ), ( others => '0' ), ( others => '0' ) );

        if( sub_rdy = '1' )
        then
            case R.res_state is
                when RES_1 =>
                    V.data( 0 ) := sub_res;
                    V.res_state := RES_2;
                when RES_2 =>
                    V.data( 1 ) := sub_res;
                    V.res_state := RES_3;
                when RES_3 =>
                    V.data( 2 ) := sub_res;
                    V.res_state := RES_1;
                when others => null;
            end case;
        end if;
        
        case R.state is
            when SUB_1 =>
                if( valid_in = '1' ) then
                    V.state := SUB_2;
                else
                    V.state := SUB_1;
                end if; 
            when SUB_2 =>
                if( valid_in = '1' ) then
                    V.state := SUB_3;
                else
                    V.state := SUB_2;
                end if;
            when SUB_3 =>
                if( valid_in = '1' ) then
                    V.state := OUTPUT_RESULT;
                else
                    V.state := SUB_3;
                end if;
            when OUTPUT_RESULT =>
                if( sub_rdy = '1' ) then
                    reg_data( 0 ) <= R.data( 0 );
                    reg_data( 1 ) <= R.data( 1 );
                    reg_data( 2 ) <= sub_res;
                end if;
                
                if( accept_out = '1' ) then
                    if( sub_rdy = '1' ) then
                        reg_data( 0 ) <= R.data( 0 );
                        reg_data( 1 ) <= R.data( 1 );
                        reg_data( 2 ) <= sub_res;
                    else
                        reg_data <= R.data;
                    end if;
                    
                    V.state   := SUB_1;
                    reg_valid <= '1';
                else
                    V.state := OUTPUT_RESULT;
                end if;
            when others => null;
        end case;

        Rin <= V;
    end process;

    read_states <= '1' when R.state = SUB_1 or
                            R.state = SUB_2 or
                            R.state = SUB_3 else
                   '0';
    accept_in <= read_states;
    valid_out <= reg_valid;
    data_out  <= reg_data;

end rtl;
