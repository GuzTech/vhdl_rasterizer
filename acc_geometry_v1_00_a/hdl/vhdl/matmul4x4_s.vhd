library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;

entity matmul4x4_s is
    port(
        clk             : in  std_logic;
        rst             : in  std_logic;

        -- Input
        data_in         : in  slv32_t;
        valid_in        : in  std_logic;
        accept_in       : out std_logic;

        -- Output
        data_out        : out float4_t;
        valid_out       : out std_logic;
        accept_out      : in  std_logic;

        -- Configuration interface
        matrix_in       : in  matrix4x4_t
    );
end matmul4x4_s;

architecture rtl of matmul4x4_s is
    type mul_state_t is ( READ_X, READ_Y, READ_Z, READ_W, FINISH, OUTPUT );
    type add_state_t is ( ADD_1, ADD_2, ADD_3 );

    -- Helper signals
    signal add_states : std_logic; -- Is '1' when in states where the adder results are valid
                                   -- (READ_Z, READ_W, FINISH)
    signal reading    : std_logic; -- Is '1' when in any READ_* states
    signal writing    : std_logic; -- Is '1' when in any OUTPUT_* states
    
    signal reg_data   : float4_t;
    signal reg_valid  : std_logic;
    
    -- Accelerator data
    type proc_t is record
        data      : float4_t;
        state     : mul_state_t;
        add_state : add_state_t;
        add_done  : std_logic;
    end record;

    constant PROC_RESET : proc_t := (
        data      => ( ( others => '0' ), ( others => '0' ), ( others => '0' ), ( others => '0' ) ),
        state     => READ_X,
        add_state => ADD_1,
        add_done  => '0'
    );

    signal R, Rin : proc_t := PROC_RESET;

    -- Multiplier signals
    signal mul_b        : float4_t;
    signal mul_res      : float4_t;
    
    signal mul_a        : slv32_t;
    signal mul_rdy      : std_logic_vector( 3 downto 0 );
    signal mul_nd       : std_logic;

    signal mul_all_rdy  : std_logic;

    -- Adder signals
    signal add_a        : float4_t;
    signal add_b        : float4_t;
    signal add_res      : float4_t;
    signal add_nd       : std_logic_vector( 3 downto 0 );
    signal add_rdy      : std_logic_vector( 3 downto 0 );

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

    GEN_ADD : for i in 0 to 3 generate
        add : entity work.fp_add
        port map (
            a             => add_a( i ),
            b             => add_b( i ),
            operation_nd  => add_nd( i ),
            clk           => clk,
            sclr          => rst,
            result        => add_res( i ),
            rdy           => add_rdy( i )
        );

        add_nd( i ) <= '1' when mul_rdy( i ) = '1' and add_states = '1' else
                       '0';

        add_a( i )  <= mul_res( i ) when add_nd( i ) = '1' else
                       ( others => '0' );

        add_b( i )  <= R.data( i ) when add_nd( i ) = '1' else
                       ( others => '0' );
        
    end generate GEN_ADD;

    add_all_rdy <= add_rdy( 0 ) and add_rdy( 1 ) and add_rdy( 2 ) and add_rdy( 3 );
    
    GEN_MUL : for i in 0 to 3 generate
        mul : entity work.fp_mul
        port map (
            a             => mul_a,
            b             => mul_b( i ),
            operation_nd  => mul_nd,
            clk           => clk,
            sclr          => rst,
            result        => mul_res( i ),
            rdy           => mul_rdy( i )
        );

        mul_b( i ) <= matrix_in( 0 )( i ) when valid_in = '1' and R.state = READ_X else
                      matrix_in( 1 )( i ) when valid_in = '1' and R.state = READ_Y else
                      matrix_in( 2 )( i ) when valid_in = '1' and R.state = READ_Z else
                      matrix_in( 3 )( i ) when valid_in = '1' and R.state = READ_W else
                      ( others => '0' );
    end generate GEN_MUL;

    mul_a       <= data_in when mul_nd = '1' else
                   ( others => '0' );
    mul_all_rdy <= mul_rdy( 0 ) and mul_rdy( 1 ) and mul_rdy( 2 ) and mul_rdy( 3 );
    mul_nd      <= '1' when reading = '1' and valid_in = '1' else
                   '0';

    proc_comb : process( R, data_in, valid_in, accept_out, reading, writing, mul_res, mul_all_rdy, add_res, add_all_rdy )
        variable V : proc_t;
    begin
        V := R;
        
        -- By default, we don't have a valid value at the output
        reg_valid <= '0';
        reg_data  <= ( ( others => '0' ), ( others => '0' ), ( others => '0' ), ( others => '0' ) );

        if( R.add_done = '0' and add_all_rdy = '1' )
        then
            case R.add_state is
                when ADD_1 =>
                    V.data      := add_res;
                    V.add_state := ADD_2;
                when ADD_2 =>
                    V.data      := add_res;
                    V.add_state := ADD_3;
                when ADD_3 =>
                    V.data      := add_res;
                    V.add_state := ADD_1;
                    V.add_done  := '1';
                when others => null;
            end case;
        end if;
        
        -- When we are reading or finishing the calculations
        if( writing = '0' )
        then
            case R.state is
                when READ_X =>
                    if( valid_in = '1' ) then
                        V.data := ( ( others => '0' ),
                                    ( others => '0' ),
                                    ( others => '0' ),
                                    ( others => '0' ) );
                        V.state := READ_Y;
                    else
                        V.state := READ_X;
                    end if;
                when READ_Y =>
                    if( mul_all_rdy = '1' ) then
                        V.data := mul_res;
                    end if;
                    
                    if( valid_in = '1' ) then
                        V.state := READ_Z;
                    else
                        V.state := READ_Y;
                    end if;
                when READ_Z =>
                    if( valid_in = '1' ) then
                        V.state := READ_W;
                    else
                        V.state := READ_Z;
                    end if;
                when READ_W =>
                    if( valid_in = '1' ) then
                        V.state := FINISH;
                    else
                        V.state := READ_W;
                    end if;
                when FINISH =>
                    if( R.add_done = '1' ) then
                        V.state := OUTPUT;
                    end if;
                when others => null;
            end case;
        elsif( writing = '1' )
        then
            case R.state is
                when OUTPUT =>
                    -- Clear data that was stored before
                    V.add_done := '0';
                    reg_data   <= R.data;
                    
                    if( accept_out = '1' ) then
                        V.state   := READ_X;
                        reg_valid <= '1';
                    else
                        V.state := OUTPUT;
                    end if;
                when others => null;
            end case;
        end if;

        Rin <= V;
    end process;
    
    reading <= '1' when R.state = READ_X or 
                        R.state = READ_Y or 
                        R.state = READ_Z or 
                        R.state = READ_W else
               '0';
    writing <= '1' when R.state = OUTPUT else
               '0';
    add_states <= '1' when R.state = READ_Z or
                           R.state = READ_W or
                           R.state = FINISH else
                  '0';

    accept_in <= reading;
    valid_out <= reg_valid;
    data_out  <= reg_data;

end rtl;
