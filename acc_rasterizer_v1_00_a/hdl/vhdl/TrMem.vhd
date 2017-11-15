library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;
use work.rasterizer_pkg.all;

entity TrMem is
    port(
        clk : in std_logic;
        rst : in std_logic;
        i   : in  tr_mem_in_t;
        o   : out tr_mem_out_t
    );
end TrMem;

architecture rtl of TrMem is
    type state_t is ( S_READ, S_WAIT, S_OUTPUT );

    signal reg_data   : std_logic_vector( 223 downto 0 );
    signal reg_valid  : std_logic;
    signal reg_accept : std_logic;
    
    -- Entity data
    type reg_t is record
        state    : state_t;
        tr_cnt   : integer range 0 to 15; -- Maximum of 16 triangles
        cnt      : integer range 0 to 6; -- 7 words of data per triangle
        addr_32  : unsigned( 3 downto 0 );
        addr_64  : unsigned( 4 downto 0 );
        addr_128 : unsigned( 5 downto 0 );
        ready    : std_logic;
		settle   : std_logic;
        last     : std_logic;
    end record;

    constant REG_RESET : reg_t := (
        state    => S_READ,
        tr_cnt   => 0,
        cnt      => 0,
        addr_32  => ( others => '0' ),
        addr_64  => ( others => '0' ),
        addr_128 => ( others => '0' ),
        ready    => '0',
        settle   => '0',
        last     => '0'
    );

    signal R, Rin : reg_t := REG_RESET;

    signal mem_data_out    : std_logic_vector( 223 downto 0 );

    signal mem_32_wea      : std_logic;
    signal mem_32_addra    : std_logic_vector( 3 downto 0 );
    signal mem_32_dina     : slv32_t;
    signal mem_32_enb      : std_logic;
    signal mem_32_addrb    : std_logic_vector( 3 downto 0 );
    signal mem_32_doutb    : std_logic_vector( 31 downto 0 );
    
    signal mem_64_wea      : std_logic;
    signal mem_64_addra    : std_logic_vector( 4 downto 0 );
    signal mem_64_dina     : slv32_t;
    signal mem_64_enb      : std_logic;
    signal mem_64_addrb    : std_logic_vector( 3 downto 0 );
    signal mem_64_doutb    : std_logic_vector( 63 downto 0 );

    signal mem_128_wea     : std_logic;
    signal mem_128_addra   : std_logic_vector( 5 downto 0 );
    signal mem_128_dina    : slv32_t;
    signal mem_128_enb     : std_logic;
    signal mem_128_addrb   : std_logic_vector( 3 downto 0 );
    signal mem_128_doutb   : std_logic_vector( 127 downto 0 );

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
            R <= REG_RESET;
        elsif( rising_edge( clk ) )
        then
            R <= Rin;
        end if;
    end process proc_seq;

    proc_comb : process( R, i )
        variable V : reg_t;
    begin
        V := R;
        
        reg_valid     <= '0';
        reg_data      <= ( others => '0' );

        -- If we're not done writing triangle data
        if( R.ready = '0' )
        then
            if( last_in = '1' )
            then
                V.last <= '1';
            end if;
            
            -- Handle the writing to memory
            if( write_en_in = '1' )
            then
                -- We have valid data, check which memory block we should write to
                if( proc_current.cnt = 0 )
                then
                    mem_32_addra       <= std_logic_vector( proc_current.addr_32 );
                    mem_32_dina        <= data_in;
                    mem_32_wea         <= '1';
                    proc_next.addr_32  <= proc_current.addr_32 + 1;
                elsif( proc_current.cnt > 0 and proc_current.cnt < 3 )
                then
                    mem_64_addra       <= std_logic_vector( proc_current.addr_64 );
                    mem_64_dina        <= data_in;
                    mem_64_wea         <= '1';
                    proc_next.addr_64  <= proc_current.addr_64 + 1;
                else
                    mem_128_addra      <= std_logic_vector( proc_current.addr_128 );
                    mem_128_dina       <= data_in;
                    mem_128_wea        <= '1';
                    proc_next.addr_128 <= proc_current.addr_128 + 1;
                end if;

                -- Update the data counter
                proc_next.cnt <= proc_current.cnt + 1;

                -- If we have processed 7 data words for this triangle, then reset
                -- the counter back to zero
                if( proc_current.cnt = 6 )
                then
                    proc_next.cnt    <= 0;
                    proc_next.tr_cnt <= proc_current.tr_cnt + 1;

                    -- If we have processed at most 16 triangles, or when we know
                    -- this was the last triangle, then we are done.
                    if( proc_current.tr_cnt = 15 or proc_current.last = '1' )
                    then
                        proc_next.settle <= '1';
                        reg_accept       <= '0';
                    end if;
                end if;
            else
                mem_32_addra  <= ( others => '0' );
                mem_64_addra  <= ( others => '0' );
                mem_128_addra <= ( others => '0' );

                mem_32_dina   <= ( others => '0' );
                mem_64_dina   <= ( others => '0' );
                mem_128_dina  <= ( others => '0' );
                
                mem_32_wea    <= '0';
                mem_64_wea    <= '0';
                mem_128_wea   <= '0';
            end if;

            -- If we have processed 7 data words for this triangle, then reset
            -- the counter back to zero
            --if( proc_current.cnt = 6 and write_en_in = '1' )
            --then
            --    proc_next.cnt    <= 0;
			--	proc_next.tr_cnt <= proc_current.tr_cnt + 1;
            --
            --    -- If we have processed at most 16 triangles, or when we know
            --    -- this was the last triangle, then we are done.
            --    if( proc_current.tr_cnt = 15 or proc_current.last = '1' )
            --    then
			--		proc_next.settle <= '1';
            --        reg_accept       <= '0';
            --    end if;
            --end if;
			
			if( proc_current.settle = '1' )
			then
				proc_next.ready <= '1';
                proc_next.last  <= '0';
			end if;
        end if;
        
        case proc_current.state is
            when S_READ =>
                if( proc_current.ready = '1' and read_en_out = '1' )
                then
                    proc_next.state <= S_WAIT;
					mem_32_addrb    <= addr_out;
					mem_64_addrb    <= addr_out;
					mem_128_addrb   <= addr_out;
					mem_32_enb      <= '1';
					mem_64_enb      <= '1';
					mem_128_enb     <= '1';
                else
                    proc_next.state <= S_READ;
                end if;
            when S_WAIT =>
                proc_next.state <= S_OUTPUT;
            when S_OUTPUT =>
                reg_valid <= '1';
                reg_data  <= mem_data_out;
                
                if( read_en_out = '1' )
                then
                    proc_next.state <= S_READ;
                end if;
            when others => null;
        end case;

        if( rst = '1' )
        then
            -- Set default values for signals
            mem_32_addra  <= ( others => '0' );
            mem_32_dina   <= ( others => '0' );
            mem_32_wea    <= '0';
            mem_32_enb    <= '0';
            mem_32_addrb  <= ( others => '0' );
            
            mem_64_addra  <= ( others => '0' );
            mem_64_dina   <= ( others => '0' );
            mem_64_wea    <= '0';
            mem_64_enb    <= '0';
            mem_64_addrb  <= ( others => '0' );

            mem_128_addra <= ( others => '0' );
            mem_128_dina  <= ( others => '0' );
            mem_128_wea   <= '0';
            mem_128_enb   <= '0';
            mem_128_addrb <= ( others => '0' );

            V := REG_RESET;

            --reg_accept    <= '1';
        end if;

        Rin <= V;
        o   <= R.o;
        
    end process proc_comb;

    data_out   <= reg_data;
    valid_out  <= reg_valid;
    ready_out  <= proc_current.ready;
    accept_in  <= reg_accept;--not proc_current.settle;
    num_tr_out <= std_logic_vector( to_unsigned( proc_current.tr_cnt, 4 ) );
end rtl;
