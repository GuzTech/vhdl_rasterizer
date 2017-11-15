library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.types.all;
--use work.rasterizer_pkg.all;

entity rasterizer_core is
    Generic( TILE_SIZE_X : integer := 8;
             TILE_SIZE_Y : integer := 8 );
    Port ( e0        : in  s32_t;     -- Edge function 0
           e1        : in  s32_t;     -- Edge function 1
           e2        : in  s32_t;     -- Edge function 2
           B01       : in  s16_t;     -- V1.x - V0.x
           B12       : in  s16_t;     -- V2.x - V1.x
           B20       : in  s16_t;     -- V0.x - V2.x
           half_recp : in  u32_t;     -- Half reciprocal of the triangle area
           d0        : in  u32_t;     -- Reciprocal of w-coordinates (depth) of vertex 0
           d1        : in  u32_t;     -- Reciprocal of w-coordinates (depth) of vertex 1
           d2        : in  u32_t;     -- Reciprocal of w-coordinates (depth) of vertex 2
		   valid_in  : in  std_logic; -- Indicates whether the values above a valid
            
           depth_en  : out std_logic; -- Enable depth buffer action request
           depth_W_r : out std_logic; -- Depth buffer action (1 = write, 0 = read)
           cur_depth : in  u32_t;     -- Value of the requested depth buffer read
           depth     : out slv32_t;   -- Fragment depth to write
           depth_mask: out slv32_t;   -- Depth mask (0xFFFFFFFF when point in triangle and in front, else 0)
            
           fr_en     : out std_logic; -- Enable frame buffer action request
           fr_W_r    : out std_logic; -- Frame buffer action (1 = write, 0 = read)
           fragment  : out slv32_t;   -- Fragment (pixel) color
           frag_mask : out slv32_t;   -- Fragment mask (0xFFFFFFFF when point in triangle, else 0)
           
           row       : out integer range 0 to TILE_SIZE_Y - 1;  -- Which row are we processing
           
           done      : out std_logic; -- Done processing tile flag
		   enable    : in  std_logic; -- Indicates whether we sould enable this core
           clk       : in  std_logic;
           rst       : in  std_logic );
end rasterizer_core;

architecture Behavioral of rasterizer_core is
    type state_t is ( S_CLEAR_BUFFERS, S_SETUP, S_DEPTH_REQUEST, S_STALL, S_DEPTH_CHECK, S_ADVANCE );

    signal reg_depth_en  : std_logic;
    signal reg_depth_wen : std_logic;
    signal reg_depth_val : slv32_t;
    signal reg_depth_msk : slv32_t;
    signal reg_fr_en     : std_logic;
    signal reg_fr_wen    : std_logic;
    signal reg_fr_val    : slv32_t;
    signal reg_fr_msk    : slv32_t;
    signal reg_row       : integer range 0 to TILE_SIZE_Y - 1;
    signal reg_done      : std_logic;
        
    constant MAX_32      : u32_t := ( others => '1' );

    type reg_t is record
        state    : state_t;
        row_cnt  : integer range 0 to TILE_SIZE_Y - 1;
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
    end record;
    
    constant REG_RESET : reg_t := (
        state    => S_CLEAR_BUFFERS,
        row_cnt  => 0,
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
        buffered => '0'
    );

    signal R   : reg_t;
    signal Rin : reg_t;
    
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

    proc_comb : process( R, e0, e1, e2, B01, B12, B20, half_recp, d0, d1, d2, cur_depth, enable, valid_in )
        variable V   : reg_t;
		variable b0  : u64_t;
		variable b1  : u64_t;
		variable b2  : u64_t;
		variable h_w : u32_t;
		variable dp  : u32_t;
    begin
        V := R;

        -- Set default values
        reg_depth_en  <= '1';
        reg_depth_wen <= '0';
        reg_depth_val <= ( others => '0' );
        reg_depth_msk <= ( others => '1' );
        reg_fr_en     <= '1';
        reg_fr_wen    <= '0';
        reg_fr_val    <= ( others => '0' );
        reg_fr_msk    <= ( others => '1' );
        reg_row       <= R.row_cnt;
        reg_done      <= '0';

		if( enable = '1' )
		then
			if( valid_in = '1' and R.buffered = '0' )
			then
				V.w0       := e0;
				V.w1       := e1;
				V.w2       := e2;
				V.bd0      := half_recp * d0;
				V.bd1      := half_recp * d1;
				V.bd2      := half_recp * d2;
				V.buffered := '1';
			end if;
			
			case R.state is
				when S_CLEAR_BUFFERS =>
					-- Check if we have cleared every row
					if( R.row_cnt < TILE_SIZE_Y )
					then
						-- We're not done clearing yet

						-- Clear the frame buffer to black
						reg_fr_en  <= '1';
						reg_fr_wen <= '1';
						reg_fr_val <= ( others => '0' );
						reg_fr_msk <= ( others => '0' );

						-- Clear the depth buffer to max value
						reg_depth_en  <= '1';
						reg_depth_wen <= '1';
						reg_depth_val <= ( others => '1' );
						reg_depth_msk <= ( others => '0' );

						-- Update the row counter
						if( R.row_cnt = TILE_SIZE_Y - 1 )
						then
							V.row_cnt := 0;
							V.state   := S_SETUP;
						else
							V.row_cnt := R.row_cnt + 1;
							V.state   := S_CLEAR_BUFFERS;
						end if;
					else
						-- We are done clearing the buffers

						-- Disable frame buffer writes
						reg_fr_en  <= '1';
						reg_fr_wen <= '0';
						reg_fr_val <= ( others => '0' );
						reg_fr_msk <= ( others => '1' );

						-- Disable depth buffer writes
						reg_depth_en  <= '1';
						reg_depth_wen <= '0';
						reg_depth_val <= ( others => '0' );
						reg_depth_msk <= ( others => '1' );

						-- Reset row counter
						V.row_cnt := 0;
						reg_row   <= 0;
						V.state   := S_SETUP;
					end if;
				-- If there is no new depth value read from the depth buffer, then
				-- setup the necessary fragment processing variables.    
				when S_SETUP =>
					if( R.buffered = '1' )
					then
						-- Pipeline the depth read request since it takes a cycle extra
						reg_depth_en  <= '1';
						reg_depth_wen <= '0';

						-- Pipeline fragment enable as well
						reg_fr_en  <= '1';
						reg_fr_wen <= '0';

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
					if( dp < cur_depth )
					then
						-- Request a write to the frame buffer (takes 1 clock cycle).
						reg_fr_en  <= '1';
						reg_fr_wen <= '1';
						reg_fr_val <= x"DEADBEEF";--( others => '1' );
						reg_fr_msk <= ( others => '0' );

						-- Request a write to the depth buffer (takes 1 clock cycle).
						reg_depth_en  <= '1';
						reg_depth_wen <= '1';
						reg_depth_val <= std_logic_vector( dp );
						reg_depth_msk <= ( others => '0' );
					end if;

					V.state := S_ADVANCE;
				when S_ADVANCE =>
					-- Setup next edge function values
					V.w0 := R.w0 + B12;
					V.w1 := R.w1 + B20;
					V.w2 := R.w2 + B01;

					-- Finally update the counter
					if( R.row_cnt < ( TILE_SIZE_Y - 1 ) )
					then
						V.row_cnt  := R.row_cnt + 1;
						reg_row    <= R.row_cnt + 1;
						reg_done   <= '0';
						V.state    := S_SETUP;
					else
						V.row_cnt  := 0;
						reg_row    <= 0;
						reg_done   <= '1';
						V.buffered := '0';
						V.state    := S_SETUP;
					end if;
				when others => null;
			end case;
		end if;

        Rin <= V;
    end process proc_comb;

    fr_en      <= reg_fr_en;
    fr_W_r     <= reg_fr_wen;
    fragment   <= reg_fr_val;
    frag_mask  <= reg_fr_msk;
    depth_en   <= reg_depth_en;
    depth_W_r  <= reg_depth_wen;
    depth      <= reg_depth_val;
    depth_mask <= reg_depth_msk;
    row        <= reg_row;
    done       <= reg_done;
end Behavioral;
