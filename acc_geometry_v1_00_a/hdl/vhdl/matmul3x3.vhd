library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;

entity matmul3x3 is
    port(
        clk             : in  std_logic;
        rst             : in  std_logic;

        -- Input
        data_in         : in  float3_t;
        valid_in        : in  std_logic;
        accept_in       : out std_logic;

        -- Output
        data_out        : out float3_t;
        valid_out       : out std_logic;
        accept_out      : in  std_logic;

        -- Configuration interface
        matrix_in       : in  matrix4x4_t
    );
end matmul3x3;

architecture rtl of matmul3x3 is
    type mul_state_t is ( MUL_1, MUL_2, MUL_3, ADD_1, FINISH, OUTPUT );
    
    -- Helper signals
    signal mul_states : std_logic; -- Is '1' when in MUL_* states
    signal add_states : std_logic; -- Is '1' when in states where the adder results are valid
                                   -- (MUL_3, MUL_4, FINISH)
    signal writing    : std_logic; -- Is '1' when in OUTPUT
    
    signal reg_data   : float3_t;
    signal reg_valid  : std_logic;
    
    -- Accelerator data
    type proc_t is record
        input : float3_t;
        data  : float3_t;
        state : mul_state_t;
    end record;

    constant PROC_RESET : proc_t := (
        input => ( ( others => '0' ), ( others => '0' ), ( others => '0' ) ),
        data  => ( ( others => '0' ), ( others => '0' ), ( others => '0' ) ),
        state => MUL_1
    );
    
    signal R, Rin : proc_t := PROC_RESET;
    
    -- Multiplier signals
    signal mul_a        : float3_t;
    signal mul_b        : float3_t;
    signal mul_res      : float3_t;
    signal mul_rdy      : std_logic_vector( 2 downto 0 );
    signal mul_nd       : std_logic;
    
    signal mul_all_rdy  : std_logic;
    
    -- Adder signals
    signal add_a        : float3_t;
    signal add_b        : float3_t;
    signal add_res      : float3_t;
    signal add_nd       : std_logic;
    signal add_rdy      : std_logic_vector( 2 downto 0 );
    
    signal add_all_rdy  : std_logic;

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

    GEN_ADD : for i in 0 to 2 generate
        add : entity work.fp_add
        port map (
            a             => add_a( i ),
            b             => add_b( i ),
            operation_nd  => add_nd,
            clk           => clk,
            sclr          => rst,
            result        => add_res( i ),
            rdy           => add_rdy( i )
        );    
       
        add_a( i ) <= mul_res( i ) when add_nd = '1' else
                      ( others => '0' );
    
        add_b( i ) <= R.data( i )  when add_nd = '1' and R.state = MUL_3 else
                      add_res( i ) when add_nd = '1' and R.state = ADD_1 else
                      ( others => '0' );
        
    end generate GEN_ADD;

    add_nd      <= '1' when mul_all_rdy = '1' and add_states = '1' else
                   '0';
    
    add_all_rdy <= add_rdy( 0 ) and add_rdy( 1 ) and add_rdy( 2 );
    
    GEN_MUL : for i in 0 to 2 generate
        mul : entity work.fp_mul
        port map (
            a             => mul_a( i ),
            b             => mul_b( i ),
            operation_nd  => mul_nd,
            clk           => clk,
            sclr          => rst,
            result        => mul_res( i ),
            rdy           => mul_rdy( i )
        );
    
        mul_a( i ) <= data_in( i ) when R.state = MUL_1 else
                      R.input( i ) when mul_states = '1' else
                      ( others => '0' );
    
        mul_b( i ) <= matrix_in( 0 )( i ) when R.state = MUL_1 else
                      matrix_in( 1 )( i ) when R.state = MUL_2 else
                      matrix_in( 2 )( i ) when R.state = MUL_3 else
                      ( others => '0' );
    end generate GEN_MUL;

    mul_nd      <= '1' when ( R.state = MUL_1 and valid_in = '1' ) or
                            R.state = MUL_2 or
                            R.state = MUL_3 else
                   '0';
    
    mul_all_rdy <= mul_rdy( 0 ) and mul_rdy( 1 ) and mul_rdy( 2 );

    proc_comb : process( R, data_in, valid_in, accept_out, writing, mul_states, mul_res, mul_all_rdy, add_res, add_all_rdy )
        variable V : proc_t;
    begin
        V := R;
        
        -- By default, we don't have a valid value at the output
        reg_valid <= '0';
        reg_data  <= ( ( others => '0' ), ( others => '0' ), ( others => '0' ) );
        
        -- When we are reading or finishing the calculations
        if( writing = '0' )
        then
            case R.state is
                when MUL_1 =>
                    if( valid_in = '1' ) then
                        V.input := data_in;
                        V.state := MUL_2;
                    else
                        V.state := MUL_1;
                    end if;
                when MUL_2 =>
                    if( mul_all_rdy = '1' ) then
                        V.data  := mul_res;
                        V.state := MUL_3;
                    else
                        V.state := MUL_2;
                    end if;
                when MUL_3 =>
                    if( mul_all_rdy = '1' ) then
                        V.state := ADD_1;
                    else
                        V.state := MUL_3;
                    end if;
                when ADD_1 =>
                    if( add_all_rdy = '1' ) then
                        V.data  := add_res;
                        V.state := FINISH;
                    else
                        V.state := ADD_1;
                    end if;
                when FINISH =>
                    if( add_all_rdy = '1' ) then
                        V.data  := add_res;
                        V.state := OUTPUT;
                    end if;
                when others => null;
            end case;
        elsif( writing = '1' )
        then
            case R.state is
                when OUTPUT =>
                    reg_data <= R.data;
                    
                    if( accept_out = '1' ) then
                        V.state   := MUL_1;
                        reg_valid <= '1';
                    else
                        V.state := OUTPUT;
                    end if;
                when others => null;
            end case;
        end if;

        Rin <= V;
    end process;
    
    writing <= '1' when R.state = OUTPUT else
               '0';
    
    mul_states <= '1' when R.state = MUL_1 or
                           R.state = MUL_2 or
                           R.state = MUL_3 else
                  '0';
                  
    add_states <= '1' when R.state = MUL_3 or
                           R.state = ADD_1 else
                  '0';
    
    accept_in <= '1' when R.state = MUL_1 else
                 '0';
    valid_out <= reg_valid;
    data_out  <= reg_data;

end rtl;
