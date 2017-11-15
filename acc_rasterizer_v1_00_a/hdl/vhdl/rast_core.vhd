library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.types.all;
use work.rasterizer_pkg.all;

entity rast_core is
    port ( clk : in  std_logic;
           rst : in  std_logic;
           i   : in  rasterizer_core_in_t;
           o   : out rasterizer_core_out_t );
end rast_core;

architecture Behavioral of rast_core is
    type state_t is ( S_CLEAR_BUFFERS, S_SETUP, S_DEPTH_REQUEST, S_STALL, S_DEPTH_CHECK, S_ADVANCE, S_FINISHED );

    type reg_t is record
        state    : state_t;
		row      : integer range 0 to TILE_SIZE_Y - 1;
        w0       : s32_t;
        w1       : s32_t;
        w2       : s32_t;
        b0       : u64_t;
        b1       : u64_t;
        b2       : u64_t;
        h_w      : u32_t;
        depth_v  : u32_t;
		bd0      : u64_t;
		bd1      : u64_t;
		bd2      : u64_t;
		buffered : std_logic;

        o        : rasterizer_core_out_t;
    end record;

    constant REG_RESET : reg_t := (
        state    => S_CLEAR_BUFFERS,
		row      => 0,
        w0       => ( others => '0' ),
        w1       => ( others => '0' ),
        w2       => ( others => '0' ),
        b0       => ( others => '0' ),
        b1       => ( others => '0' ),
        b2       => ( others => '0' ),
        h_w      => ( others => '0' ),
        bd0      => ( others => '0' ),
        bd1      => ( others => '0' ),
        bd2      => ( others => '0' ),
        depth_v  => MAX_32,
        buffered => '0',
		o => ( depth_en  => '1',
			   depth_W_r => '0',
			   depth_val => ( others => '0' ),
			   depth_msk => ( others => '1' ),
			   fr_en     => '1',
			   fr_W_r    => '0',
			   fr_val    => ( others => '0' ),
			   fr_msk    => ( others => '1' ),
			   row       => 0,
			   done      => '0' )
    );

    signal R, Rin : reg_t := REG_RESET;
     
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

    proc_comb : process( R, i )
        variable V   : reg_t;
		variable b0  : u64_t;
		variable b1  : u64_t;
		variable b2  : u64_t;
		variable h_w : u32_t;
		variable dp  : u32_t;
    begin
        V := R;

		if( i.enable = '1' )
		then
			if( i.valid_in = '1' and R.buffered = '0' )
			then
				V.w0       := i.e0;
				V.w1       := i.e1;
				V.w2       := i.e2;
				V.bd0      := i.half_recp * i.d0;
				V.bd1      := i.half_recp * i.d1;
				V.bd2      := i.half_recp * i.d2;
				V.buffered := '1';
			end if;
			
			case R.state is
				when S_CLEAR_BUFFERS =>
					-- Check if we have cleared every row
					if( R.row < TILE_SIZE_Y )
					then
						-- We're not done clearing yet

						-- Clear the frame buffer to black
						V.o.fr_en  := '1';
						V.o.fr_W_r := '1';
						V.o.fr_val := ( others => '0' );
						V.o.fr_msk := ( others => '0' );

						-- Clear the depth buffer to max value
						V.o.depth_en  := '1';
						V.o.depth_W_r := '1';
						V.o.depth_val := ( others => '1' );
						V.o.depth_msk := ( others => '0' );

						-- Update the row counter
						if( R.o.row = TILE_SIZE_Y - 1 )
						then
							V.row   := 0;
							V.o.row := 0;
							V.state := S_SETUP;
						else
							V.row   := R.row + 1;
							V.o.row := R.row;
							V.state := S_CLEAR_BUFFERS;
						end if;
					else
						-- We are done clearing the buffers

						-- Disable frame buffer writes
						V.o.fr_en  := '1';
						V.o.fr_W_r := '0';
						V.o.fr_val := ( others => '0' );
						V.o.fr_msk := ( others => '1' );

						-- Disable depth buffer writes
						V.o.depth_en  := '1';
						V.o.depth_W_r := '0';
						V.o.depth_val := ( others => '0' );
						V.o.depth_msk := ( others => '1' );

						-- Reset row counter
						V.row   := 0;
						V.o.row := 0;
						V.state := S_SETUP;
					end if;
				-- If there is no new depth value read from the depth buffer, then
				-- setup the necessary fragment processing variables.    
				when S_SETUP =>
					if( R.buffered = '1' )
					then
						-- Pipeline the depth read request since it takes a cycle extra
						V.o.depth_en  := '1';
						V.o.depth_W_r := '0';

						-- Pipeline fragment enable as well
						V.o.fr_en  := '1';
						V.o.fr_W_r := '0';

						-- If the fragment lies within the triangle
						if( ( std_logic( R.w0( 31 ) ) or
							  std_logic( R.w1( 31 ) ) or
							  std_logic( R.w2( 31 ) ) ) = '0' )
						then
							-- Calculate barycentric coordinates
							b0      := resize( unsigned( R.w0 ) * R.bd0, 64 );
							b1      := resize( unsigned( R.w1 ) * R.bd1, 64 );
							b2      := resize( unsigned( R.w2 ) * R.bd2, 64 );
							h_w     := resize( b0( 63 downto 32 ) + b1( 63 downto 32 ) + b2( 63 downto 32 ), 32 );
							dp      := MAX_32 - h_w;
							V.state := S_DEPTH_CHECK;
						else
							V.state := S_STALL;
						end if;
					else
						V.state := S_SETUP;
					end if;
				-- To make sure that every core in the tile finishes at the same
				-- time, we stall here for one clock cycle.
				when S_STALL =>
					V.state := S_ADVANCE;
				when S_DEPTH_CHECK =>
					-- We received a depth value from the depth buffer.

					-- If the fragment lies in front of whatever was drawn before
					if( dp < i.cur_depth )
					then
						-- Request a write to the frame buffer (takes 1 clock cycle).
						V.o.fr_en  := '1';
						V.o.fr_W_r := '1';
						V.o.fr_val := x"DEADBEEF";--( others => '1' );
						V.o.fr_msk := ( others => '0' );

						-- Request a write to the depth buffer (takes 1 clock cycle).
						V.o.depth_en  := '1';
						V.o.depth_W_r := '1';
						V.o.depth_val := std_logic_vector( dp );
						V.o.depth_msk := ( others => '0' );
					end if;

					V.state := S_ADVANCE;
				when S_ADVANCE =>
					-- Clear the write requests
					V.o.fr_en  := '1';
					V.o.fr_W_r := '0';
					V.o.fr_val := ( others => '0' );
					V.o.fr_msk := ( others => '1' );
					
					V.o.depth_en  := '1';
					V.o.depth_W_r := '0';
					V.o.depth_val := ( others => '0' );
					V.o.depth_msk := ( others => '1' );
					
					-- Setup next edge function values
					V.w0 := R.w0 + i.B12;
					V.w1 := R.w1 + i.B20;
					V.w2 := R.w2 + i.B01;

					-- Finally update the counter
					if( R.o.row < ( TILE_SIZE_Y - 1 ) )
					then
						V.o.row  := R.o.row + 1;
						V.o.done := '0';
						V.state  := S_SETUP;
					else
						V.row      := 0;
						V.o.row    := 0;
						V.o.done   := '1';
						V.buffered := '0';
						V.state    := S_FINISHED;
					end if;
				when S_FINISHED =>
					V.state := S_FINISHED;
				when others => null;
			end case;
		end if;

        o   <= V.o;
        Rin <= V;
    end process proc_comb;
    
end Behavioral;
