library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;

entity TriangleMem is
    port(
        clk         : in std_logic;
        rst         : in std_logic;
        clr         : in std_logic;

        -- Write to memory
        data_in     : in  slv32_t;
        write_en_in : in  std_logic;
        last_in     : in  std_logic;
        accept_in   : out std_logic;
        
        -- Read from memory
        addr_out    : in  std_logic_vector( 3 downto 0 );
        data_out    : out std_logic_vector( 223 downto 0 );
        valid_out   : out std_logic;
        read_en_out : in  std_logic;
        ready_out   : out std_logic;
        num_tr_out  : out std_logic_vector( 4 downto 0 )
    );
end TriangleMem;

architecture rtl of TriangleMem is
    type out_state_t is ( S_READ, S_WAIT, S_OUTPUT );

    signal reg_data   : std_logic_vector( 223 downto 0 );
    signal reg_valid  : std_logic;
    signal reg_accept : std_logic;
    
    -- Entity data
    type proc_t is record
        out_state : out_state_t;
        tr_cnt    : integer range 0 to 16; -- Maximum of 16 triangles
        cnt       : integer range 0 to 6;  -- 7 words of data per triangle
        addr_32   : unsigned( 3 downto 0 );
        addr_64   : unsigned( 4 downto 0 );
        addr_128  : unsigned( 5 downto 0 );
        ready     : std_logic;
        last      : std_logic;
    end record;

    signal R             : proc_t;
    signal Rin           : proc_t;

    signal mem_data_out  : std_logic_vector( 223 downto 0 );

    signal mem_32_wea    : std_logic;
    signal mem_32_addra  : std_logic_vector( 3 downto 0 );
    signal mem_32_dina   : slv32_t;
    signal mem_32_enb    : std_logic;
    signal mem_32_addrb  : std_logic_vector( 3 downto 0 );
    signal mem_32_doutb  : std_logic_vector( 31 downto 0 );
    
    signal mem_64_wea    : std_logic;
    signal mem_64_addra  : std_logic_vector( 4 downto 0 );
    signal mem_64_dina   : slv32_t;
    signal mem_64_enb    : std_logic;
    signal mem_64_addrb  : std_logic_vector( 3 downto 0 );
    signal mem_64_doutb  : std_logic_vector( 63 downto 0 );

    signal mem_128_wea   : std_logic;
    signal mem_128_addra : std_logic_vector( 5 downto 0 );
    signal mem_128_dina  : slv32_t;
    signal mem_128_enb   : std_logic;
    signal mem_128_addrb : std_logic_vector( 3 downto 0 );
    signal mem_128_doutb : std_logic_vector( 127 downto 0 );

begin

    triangle_mem_32 : entity work.tr_mem_32
    PORT MAP (
        clka   => clk,
        wea(0) => mem_32_wea,
        addra  => mem_32_addra,
        dina   => mem_32_dina,
        clkb   => clk,
        rstb   => rst,
        enb    => mem_32_enb,
        addrb  => mem_32_addrb,
        doutb  => mem_32_doutb
    );

    triangle_mem_64 : entity work.tr_mem_64
    PORT MAP (
        clka   => clk,
        wea(0) => mem_64_wea,
        addra  => mem_64_addra,
        dina   => mem_64_dina,
        clkb   => clk,
        rstb   => rst,
        enb    => mem_64_enb,
        addrb  => mem_64_addrb,
        doutb  => mem_64_doutb
    );

    triangle_mem_128 : entity work.tr_mem_128
    PORT MAP (
        clka   => clk,
        wea(0) => mem_128_wea,
        addra  => mem_128_addra,
        dina   => mem_128_dina,
        clkb   => clk,
        rstb   => rst,
        enb    => mem_128_enb,
        addrb  => mem_128_addrb,
        doutb  => mem_128_doutb
    );

    mem_data_out(  31 downto  0 ) <= mem_32_doutb;
    mem_data_out(  95 downto 32 ) <= mem_64_doutb;
    mem_data_out( 223 downto 96 ) <= mem_128_doutb;
    
    proc_seq : process( clk, rst )
    begin
        if( rst = '1' )
        then
            R.out_state  <= S_READ;
            R.tr_cnt     <= 0;
            R.cnt        <= 0;
            R.addr_32    <= ( others => '0' );
            R.addr_64    <= ( others => '0' );
            R.addr_128   <= ( others => '0' );
            R.ready      <= '0';
            R.last       <= '0';
        elsif( rising_edge( clk ) )
        then
            R <= Rin;
        end if;
    end process proc_seq;
    
    proc_comb : process( R, rst, data_in, last_in, write_en_in, addr_out, read_en_out )
        variable V : proc_t;
    begin
        V := R;

        if( rst = '1' )
        then
            reg_accept <= '1';
        else
            reg_accept <= R.ready;
        end if;
        
        -- Default values
        reg_valid  <= '0';
        reg_data   <= ( others => '0' );

        mem_32_addra   <= ( others => '0' );
        mem_32_dina    <= ( others => '0' );
        mem_32_wea     <= '0';

        mem_64_addra   <= ( others => '0' );
        mem_64_dina    <= ( others => '0' );
        mem_64_wea     <= '0';

        mem_128_addra  <= ( others => '0' );
        mem_128_dina   <= ( others => '0' );
        mem_128_wea    <= '0';

        mem_32_addrb  <= ( others => '0' );
        mem_32_enb    <= '0';

        mem_64_addrb  <= ( others => '0' );
        mem_64_enb    <= '0';

        mem_128_addrb <= ( others => '0' );
        mem_128_enb   <= '0';
        
        -- If we're not done writing triangle data
        if( V.ready = '0' )
        then
            if( last_in = '1' )
            then
                V.last := '1';
            end if;
            
            -- Handle the writing to memory
            if( write_en_in = '1' )
            then
                -- We have valid data, check which memory block we should write to
                if( R.cnt = 0 )
                then
                    mem_32_addra  <= std_logic_vector( R.addr_32 );
                    mem_32_dina   <= data_in;
                    mem_32_wea    <= '1';
                    V.addr_32     := R.addr_32 + 1;
                elsif( R.cnt > 0 and R.cnt < 3 )
                then
                    mem_64_addra  <= std_logic_vector( R.addr_64 );
                    mem_64_dina   <= data_in;
                    mem_64_wea    <= '1';
                    V.addr_64     := R.addr_64 + 1;
                else
                    mem_128_addra <= std_logic_vector( R.addr_128 );
                    mem_128_dina  <= data_in;
                    mem_128_wea   <= '1';
                    V.addr_128    := R.addr_128 + 1;
                end if;

                -- Update the data counter
                V.cnt := R.cnt + 1;

                -- If we have processed 7 data words for this triangle, then reset
                -- the counter back to zero
                if( R.cnt = 6 )
                then
                    V.cnt    := 0;
                    V.tr_cnt := R.tr_cnt + 1;

                    -- If we have processed at most 16 triangles, or when we know
                    -- this was the last triangle, then we are done.
                    if( R.tr_cnt = 15 or R.last = '1' )
                    then
                        V.ready := '1';
                    end if;
                end if;
            end if;
        end if;
        
        case R.out_state is
            when S_READ =>
                if( R.ready = '1' and read_en_out = '1' )
                then
                    mem_32_addrb  <= addr_out;
                    mem_64_addrb  <= addr_out;
                    mem_128_addrb <= addr_out;
                    mem_32_enb    <= '1';
                    mem_64_enb    <= '1';
                    mem_128_enb   <= '1';

                    V.out_state   := S_WAIT;
                else
                    V.out_state   := S_READ;
                end if;
            when S_WAIT =>
                mem_32_addrb  <= addr_out;
                mem_64_addrb  <= addr_out;
                mem_128_addrb <= addr_out;
                mem_32_enb    <= '1';
                mem_64_enb    <= '1';
                mem_128_enb   <= '1';

                V.out_state := S_OUTPUT;
            when S_OUTPUT =>
                reg_valid <= '1';
                reg_data  <= mem_data_out;
                
                if( read_en_out = '1' )
                then
                    V.out_state := S_READ;
                end if;
            when others => null;
        end case;

        Rin <= V;
    end process proc_comb;

    data_out   <= reg_data;
    valid_out  <= reg_valid;
    ready_out  <= R.ready;
    accept_in  <= not reg_accept;
    num_tr_out <= std_logic_vector( to_unsigned( R.tr_cnt, 5 ) );
end rtl;
