library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

use IEEE.std_logic_misc.ALL;

use work.types.all;
--use work.rasterizer_pkg.all;

entity rasterizer_top is
    Generic( NUM_TRIANGLES : integer := 16;
             TILE_SIZE_X   : integer := 8;
             TILE_SIZE_Y   : integer := 8 );
    Port ( tr_mem_read_en  : out std_logic;
           tr_mem_addr     : out std_logic_vector(   3 downto 0 );
           tr_mem_data     : in  std_logic_vector( 319 downto 0 );
           tr_mem_valid    : in  std_logic;
		   tr_cnt          : in  std_logic_vector(   4 downto 0 );
           fb_en           : out std_logic;
           fb_wen          : out std_logic;
           fb_addr         : out std_logic_vector(   2 downto 0 );
           fb_data_in      : in  std_logic_vector( 255 downto 0 );
           fb_data_out     : out std_logic_vector( 255 downto 0 );
           clk             : in  std_logic;
           rst             : in  std_logic;
           enable          : in  std_logic;
           done            : out std_logic );
end rasterizer_top;

architecture Behavioral of rasterizer_top is
    type state_t is ( S_REQUEST, S_PROCESS, S_FINISHED, S_SEND );
		
	type reg_t is record
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
		half_recp : u32_t; -- Q0.32 format!
		d0        : u32_t; -- Q8.24 format!
		d1        : u32_t;
		d2        : u32_t;
		tri_cnt   : integer range 0 to NUM_TRIANGLES - 1;
		rst_cores : std_logic;
	end record;

    constant REG_RESET : reg_t :=
    (
        state     => S_REQUEST,
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
        tri_cnt   => 0,
        rst_cores => '1'
    );
	
	signal R   : reg_t := REG_RESET;
	signal Rin : reg_t := REG_RESET;
    
    -- Handy sub types
    subtype core_vector    is std_logic_vector( TILE_SIZE_X - 1 downto 0 );
    subtype core_vector_32 is std_logic_vector( ( TILE_SIZE_X * 32 ) - 1 downto 0 );

   	signal reg_tr_en   : std_logic;
	signal reg_done    : std_logic;
    
    -- Frame buffer related
    signal fr_en_core   : core_vector := ( others => '0' );
    signal fr_en_any    : std_logic;
    signal fr_wen_core  : core_vector := ( others => '0' );
    signal fr_wen_any   : std_logic;
    signal data_from_fr : core_vector_32;
    signal data_to_fr   : core_vector_32;
    signal fr_mask      : core_vector_32;
    signal data_to_fr_m : core_vector_32;

    -- Depth buffer related
    signal db_en_core   : core_vector := ( others => '0' );
    signal db_en_any    : std_logic;
    signal db_wen_core  : core_vector := ( others => '0' );
    signal db_wen_any   : std_logic;
    signal data_to_db   : core_vector_32;
    signal data_from_db : core_vector_32;
    signal db_mask      : core_vector_32;
    signal data_to_db_m : core_vector_32;
    
    -- Rasterizer misc
    type row_addr_t is array ( 7 downto 0 ) of integer range 0 to 7;
    signal row_core     : row_addr_t;
    signal row_addr     : std_logic_vector( 2 downto 0 );
    signal rst_cores    : std_logic;
    signal done_core    : core_vector := ( others => '0' );
    signal all_done     : std_logic;
	signal core_enable  : std_logic;
	signal core_valid   : std_logic;
    
    type AXX_t is array ( 0 to TILE_SIZE_X - 1 ) of s32_t;
    signal A01_I        : AXX_t;
    signal A12_I        : AXX_t;
    signal A20_I        : AXX_t;
    
begin

    ----------------------------------
    -- Instantiate rasterizer cores --
    ----------------------------------
--    RASTERIZER_CORES:
--    for i in 0 to ( TILE_SIZE_X - 1 ) generate
--
--        A01_I( i ) <= to_signed( to_integer( R.e2 ) + ( i * to_integer( R.A01 ) ), 32 );
--        A12_I( i ) <= to_signed( to_integer( R.e0 ) + ( i * to_integer( R.A12 ) ), 32 );
--        A20_I( i ) <= to_signed( to_integer( R.e1 ) + ( i * to_integer( R.A20 ) ), 32 );
--        
--        rast_core : entity work.rast_core
--        port map( i.e0        => A12_I( i ),
--				  i.e1        => A20_I( i ),
--				  i.e2        => A01_I( i ),
--				  i.B01       => R.B01,
--				  i.B12       => R.B12,
--				  i.B20       => R.B20,
--				  i.half_recp => R.half_recp, -- beware, Q8.24 format!!!
--				  i.d0        => R.d0,
--				  i.d1        => R.d1,
--				  i.d2        => R.d2,
--				  i.valid_in  => core_valid,
--				  i.cur_depth => unsigned( data_from_db( ((i + 1) * 32 - 1) downto i * 32 ) ),
--				  i.enable    => core_enable,
--				  o.depth_en  => db_en_core( i ),
--				  o.depth_W_r => db_wen_core( i ),
--				  o.depth_val => data_to_db( ((i + 1) * 32 - 1) downto i * 32 ),
--				  o.depth_msk => db_mask( ((i + 1) * 32 - 1) downto i * 32 ),
--				  o.fr_en     => fr_en_core( i ),
--				  o.fr_W_r    => fr_wen_core( i ),
--				  o.fr_val    => data_to_fr( ((i + 1) * 32 - 1) downto i * 32 ),
--				  o.fr_msk    => fr_mask( ((i + 1) * 32 - 1) downto i * 32 ),
--				  o.row       => row_core( i ),
--				  o.done      => done_core( i ),				  
--                  clk         => clk,
--                  rst         => rst_cores );
--    end generate RASTERIZER_CORES;
	
	RASTERIZER_CORES:
    for i in 0 to ( TILE_SIZE_X - 1 ) generate

        A01_I( i ) <= to_signed( to_integer( R.e2 ) + ( i * to_integer( R.A01 ) ), 32 );
        A12_I( i ) <= to_signed( to_integer( R.e0 ) + ( i * to_integer( R.A12 ) ), 32 );
        A20_I( i ) <= to_signed( to_integer( R.e1 ) + ( i * to_integer( R.A20 ) ), 32 );
        
        rast_core : entity work.rasterizer_core
        generic map( TILE_SIZE_X => TILE_SIZE_X,
                     TILE_SIZE_Y => TILE_SIZE_Y )
        port map( e0         => A12_I( i ),
                  e1         => A20_I( i ),
                  e2         => A01_I( i ),
                  B01        => R.B01,
                  B12        => R.B12,
                  B20        => R.B20,
                  half_recp  => R.half_recp, -- beware, Q8.24 format!!!
                  d0         => R.d0,
                  d1         => R.d1,
                  d2         => R.d2,
				  valid_in   => core_valid,
                  depth_en   => db_en_core( i ),
                  depth_W_r  => db_wen_core( i ),
                  cur_depth  => unsigned( data_from_db( ((i + 1) * 32 - 1) downto i * 32 ) ),
                  depth      => data_to_db( ((i + 1) * 32 - 1) downto i * 32 ),
                  depth_mask => db_mask( ((i + 1) * 32 - 1) downto i * 32 ),
                  fr_en      => fr_en_core( i ),
                  fr_W_r     => fr_wen_core( i ),
                  fragment   => data_to_fr( ((i + 1) * 32 - 1) downto i * 32 ),
                  frag_mask  => fr_mask( ((i + 1) * 32 - 1) downto i * 32 ),
                  row        => row_core( i ),
                  done       => done_core( i ),
				  enable     => core_enable,
                  clk        => clk,
                  rst        => rst_cores );
    end generate RASTERIZER_CORES;
        
    row_addr <= std_logic_vector( to_unsigned( row_core( 0 ), 3 ) );

    --------------------------
    -- Frame buffer related --
    --------------------------
    data_from_fr <= fb_data_in;
    data_to_fr_m <= data_to_fr or ( fr_mask and data_from_fr );
    fr_en_any    <= or_reduce( fr_en_core );
    fr_wen_any   <= or_reduce( fr_wen_core );
    fb_en        <= fr_en_any;
    fb_wen       <= fr_wen_any;
    fb_data_out  <= data_to_fr_m;
    fb_addr      <= row_addr;

    -------------------------------
    -- All rasterizer cores done --
    -------------------------------
    all_done <= or_reduce( done_core );
    
    --------------------------
    -- Depth buffer related --
    --------------------------
    db_en_any    <= or_reduce( db_en_core );
    db_wen_any   <= or_reduce( db_wen_core );
    data_to_db_m <= data_to_db or ( db_mask and data_from_db );
    
    depth_buffer : entity work.Depth_BRAM
    port map( clka   => clk,
              rsta   => rst,
              ena    => db_en_any,
              wea(0) => db_wen_any,
              addra  => row_addr,
              dina   => data_to_db_m,
              douta  => data_from_db );

    ---------------------------------
    -- Triangle setup data related --
    ---------------------------------
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
	
	proc_comb : process( R, tr_mem_valid, tr_mem_data, tr_cnt, fb_data_in, enable, all_done )
        variable V : reg_t;
	begin
		V := R;
		
		-- Default values
		reg_tr_en   <= '0';
        reg_done    <= '0';
		core_valid  <= '0';
        core_enable <= '0';
		rst_cores   <= R.rst_cores;

		if( enable = '1' )
		then
			case R.state is
				when S_REQUEST =>
					reg_tr_en   <= '1';
					V.rst_cores := '0';
					core_enable <= '1';
					
					if( tr_mem_valid = '1' )
					then
						V.state     := S_PROCESS;
						core_valid  <= '0';
						
						V.e0        := signed( tr_mem_data(  31 downto   0 ) );
						V.e1        := signed( tr_mem_data(  63 downto  32 ) );
						V.e2        := signed( tr_mem_data(  95 downto  64 ) );
						V.A01       := signed( tr_mem_data( 111 downto  96 ) );
						V.A12       := signed( tr_mem_data( 127 downto 112 ) );
						V.A20       := signed( tr_mem_data( 143 downto 128 ) );
						V.B01       := signed( tr_mem_data( 159 downto 144 ) );
						V.B12       := signed( tr_mem_data( 175 downto 160 ) );
						V.B20       := signed( tr_mem_data( 191 downto 176 ) );
						V.half_recp := unsigned( tr_mem_data( 223 downto 192 ) );
						V.d0        := unsigned( tr_mem_data( 255 downto 224 ) );
						V.d1        := unsigned( tr_mem_data( 287 downto 256 ) );
						V.d2        := unsigned( tr_mem_data( 319 downto 288 ) );
					end if;
                when S_PROCESS =>
                    core_valid  <= '1';
                    core_enable <= '1';
                    reg_tr_en   <= '0';
                    
                    if( all_done = '1' )
                    then
                        -- The cores are done processing the current triangle.
                        core_valid <= '0';

                        -- If we have processed all (or the maximum allowed
                        -- amount of) triangles, then we're finished.
                        if( R.tri_cnt = ( to_integer( unsigned( tr_cnt ) ) - 1 ) or
                            R.tri_cnt = ( NUM_TRIANGLES - 1 ) )
                        then
                            V.state     := S_FINISHED;
                            V.tri_cnt   := 0;
                            V.rst_cores := '1';

                            reg_done    <= '1';
                        else
                            -- We still have other triangles to process.
                            V.state   := S_REQUEST;
                            V.tri_cnt := R.tri_cnt + 1;
                        end if;
                    else
                        V.state := S_PROCESS;
                    end if;
                when S_FINISHED =>
                    core_enable <= '1';
					reg_tr_en   <= '0';
                    V.state     := S_SEND;
				when S_SEND =>
                    reg_done    <= '1';
                    core_enable <= '0';
					V.state     := S_SEND;                
				when others => null;
			end case;
			
			if( R.tri_cnt = to_integer( unsigned( tr_cnt ) ) or
				R.tri_cnt = NUM_TRIANGLES )
			then
				-- If we have processed all triangles, then just reset all rasterizer cores.
				V.tri_cnt   := 0;
				V.rst_cores := '1';
				
				-- We're done
				reg_done    <= '1';
				core_enable <= '0';
			else
				-- We still have triangles to process.
				
				-- Wait for the tile processing to be done before we point to the next triangle.
				if( all_done = '1' )
				then
					V.tri_cnt := R.tri_cnt + 1;
				end if;
			end if;
		end if;

        Rin <= V;
	end process proc_comb;
	
	tr_mem_read_en <= reg_tr_en;
	tr_mem_addr    <= std_logic_vector( to_unsigned( R.tri_cnt, 4 ) );
	done           <= reg_done;
end Behavioral;
