library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;

entity triangle_setup is
    port(
        clk        : in std_logic;
        rst        : in std_logic;

        -- Memory interface
        data_in    : in  std_logic_vector( 223 downto 0 );
        read_out   : out std_logic;
		addr_out   : out std_logic_vector( 3 downto 0 );
        valid_in   : in  std_logic;
        ready_in   : in  std_logic;
        
        -- Rasterizer core interface
        read_in    : in  std_logic;
        addr_in    : in  std_logic_vector( 3 downto 0 );
        data_out   : out std_logic_vector( 319 downto 0 );
        valid_out  : out std_logic;

        -- Accelerator interface
        tile_min_x : in  u16_t;
        tile_min_y : in  u16_t
    );
end triangle_setup;

architecture rtl of triangle_setup is
    type state_t is ( S_READ, S_WAIT, S_PRECALC_1, S_PRECALC_2, S_WRITE );

    signal reg_data  : std_logic_vector( 319 downto 0 );
	signal reg_addr  : std_logic_vector(   3 downto 0 );
    signal reg_valid : std_logic;
    signal reg_read  : std_logic;

    type proc_t is record
        state     : state_t;
        e0        : s32_t;
        e1        : s32_t;
        e2        : s32_t;
        A01       : s16_t;
        A12       : s16_t;
        A20       : s16_t;
        B01       : s16_t;
        B12       : s16_t;
        B20       : s16_t;
        half_recp : slv32_t; -- int32_t and slv32_t are the same, but half_recp
                             -- is stored as Q8.24 fixed-point, so it's not a
                             -- 32-bit integer.
        d0        : u32_t;
        d1        : u32_t;
        d2        : u32_t;

		-- Buffered pixel values
		V0x       : s16_t;
		V0y       : s16_t;
		V1x       : s16_t;
		V1y       : s16_t;
		V2x       : s16_t;
		V2y       : s16_t;
    end record;

    constant REG_RESET : proc_t :=
    (
        state     => S_READ,
        e0        => ( others => '0' ),
        e1        => ( others => '0' ),
        e2        => ( others => '0' ),
        A01       => ( others => '0' ),
        A12       => ( others => '0' ),
        A20       => ( others => '0' ),
        B01       => ( others => '0' ),
        B12       => ( others => '0' ),
        B20       => ( others => '0' ),
        half_recp => ( others => '0' ),
        d0        => ( others => '0' ),
        d1        => ( others => '0' ),
        d2        => ( others => '0' ),
        V0x       => ( others => '0' ),
        V0y       => ( others => '0' ),
        V1x       => ( others => '0' ),
        V1y       => ( others => '0' ),
        V2x       => ( others => '0' ),
        V2y       => ( others => '0' )
    );

    signal R, Rin : proc_t := REG_RESET;
   
begin

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

    proc_comb : process( R, data_in, valid_in, ready_in, read_in, addr_in, tile_min_x, tile_min_y )
        variable V : proc_t;
    begin
        V := R;

        -- Default values
        reg_data  <= ( others => '0' );
        reg_addr  <= addr_in;
        reg_valid <= '0';
        
        -- If TriangleMem is ready
        if( ready_in = '1' )
        then
            case R.state is
                when S_READ =>
                    if( read_in = '1' )
                    then
                        -- Enable reading from triangle_mem
                        reg_read <= '1';
                        V.state  := S_PRECALC_1;
                    else
						reg_read <= '0';
                        V.state  := S_READ;
                    end if;
                when S_PRECALC_1 =>
                    reg_read <= '1';
                    
                    if( valid_in = '1' )
                    then
						-- Buffer the pixel position so that we can use it in the next state
						V.V0x := signed( data_in( 15 downto  0 ) );
						V.V0y := signed( data_in( 31 downto 16 ) );
						V.V1x := signed( data_in( 47 downto 32 ) );
						V.V1y := signed( data_in( 63 downto 48 ) );
						V.V2x := signed( data_in( 79 downto 64 ) );
						V.V2y := signed( data_in( 95 downto 80 ) );
						
                        -- Calculate constants for this tile and triangle
                        V.A01 := resize( V.V0y - V.V1y, 16 );
                        V.A12 := resize( V.V1y - V.V2y, 16 );
                        V.A20 := resize( V.V2y - V.V0y, 16 );

                        V.B01 := resize( V.V1x - V.V0x, 16 );
                        V.B12 := resize( V.V2x - V.V1x, 16 );
                        V.B20 := resize( V.V0x - V.V2x, 16 );

                        -- Store the other data
                        V.half_recp := data_in( 127 downto  96 );
                        V.d0        := unsigned( data_in( 159 downto 128 ) );
                        V.d1        := unsigned( data_in( 191 downto 160 ) );
                        V.d2        := unsigned( data_in( 223 downto 192 ) );
                        
                        V.state     := S_PRECALC_2;
                    else
                        V.state     := S_PRECALC_1;
                    end if;
                when S_PRECALC_2 =>
                    -- Calculate the edge functions for the minimum pixel position
                    V.e0 := edgeFunction( to_integer( R.V1x ), to_integer( R.V1y ),
                                          to_integer( R.V2x ), to_integer( R.V2y ),
                                          to_integer( signed( tile_min_x ) ),  to_integer( signed( tile_min_y ) ) );
                    V.e1 := edgeFunction( to_integer( R.V2x ), to_integer( R.V2y ),
                                          to_integer( R.V0x ), to_integer( R.V0y ),
                                          to_integer( signed( tile_min_x ) ),  to_integer( signed( tile_min_y ) ) );
                    V.e2 := edgeFunction( to_integer( R.V0x ), to_integer( R.V0y ),
                                          to_integer( R.V1x ), to_integer( R.V1y ),
                                          to_integer( signed( tile_min_x ) ),  to_integer( signed( tile_min_y ) ) );
                    
                    V.state  := S_WRITE;
					reg_read <= '0';
                when S_WRITE =>
                    reg_data(  31 downto   0 ) <= std_logic_vector( R.e0 );
                    reg_data(  63 downto  32 ) <= std_logic_vector( R.e1 );
                    reg_data(  95 downto  64 ) <= std_logic_vector( R.e2 );
                    reg_data( 111 downto  96 ) <= std_logic_vector( R.A01 );
                    reg_data( 127 downto 112 ) <= std_logic_vector( R.A12 );
                    reg_data( 143 downto 128 ) <= std_logic_vector( R.A20 );
                    reg_data( 159 downto 144 ) <= std_logic_vector( R.B01 );
                    reg_data( 175 downto 160 ) <= std_logic_vector( R.B12 );
                    reg_data( 191 downto 176 ) <= std_logic_vector( R.B20 );
                    reg_data( 223 downto 192 ) <= std_logic_vector( R.half_recp );
                    reg_data( 255 downto 224 ) <= std_logic_vector( R.d0 );
                    reg_data( 287 downto 256 ) <= std_logic_vector( R.d1 );
                    reg_data( 319 downto 288 ) <= std_logic_vector( R.d2 );

                    reg_valid <= '1';
                    V.state   := S_READ;
                when others => null;
            end case;
		else
			reg_read <= '0';
        end if;

        Rin <= V;
    end process proc_comb;

	addr_out  <= reg_addr;
    data_out  <= reg_data;
    valid_out <= reg_valid;
    read_out  <= reg_read;
end rtl;
