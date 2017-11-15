library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;

package rasterizer_pkg is
    constant TILE_SIZE_X : integer := 8;
    constant TILE_SIZE_Y : integer := 8;
    constant MAX_32      : unsigned( 31 downto 0 ) := x"FFFFFFFF";

    type tr_mem_in_t is record
        clr       : std_logic;
        data      : slv32_t;
        write_en  : std_logic;
        last      : std_logic;
        addr      : std_logic_vector( 3 downto 0 );
        read_en   : std_logic;
    end record;

    type tr_mem_out_t is record
        accept    : std_logic;
        data      : std_logic_vector( 223 downto 0 );
        valid     : std_logic;
        ready     : std_logic;
        num_tr    : std_logic_vector( 3 downto 0 );
    end record;
        
    type rasterizer_core_in_t is record
        e0        : s32_t;      -- Edge function 0                                
        e1        : s32_t;      -- Edge function 1                                
        e2        : s32_t;      -- Edge function 2                                
        B01       : s16_t;  	-- V1.x - V0.x                                    
        B12       : s16_t;  	-- V2.x - V1.x                                    
        B20       : s16_t;  	-- V0.x - V2.x                                    
        half_recp : u32_t;  	-- Half reciprocal of the triangle area           
        d0        : u32_t;  	-- Reciprocal of w-coordinates (depth) of vertex 0
        d1        : u32_t;  	-- Reciprocal of w-coordinates (depth) of vertex 1
        d2        : u32_t;  	-- Reciprocal of w-coordinates (depth) of vertex 2
        valid_in  : std_logic;  -- Indicates whether the values above are valid
        cur_depth : u32_t;      -- Value of the requested depth buffer read
        enable    : std_logic;  -- Indicates whether this core should be enabled
    end record;

    type rasterizer_core_out_t is record
        depth_en  : std_logic;  -- Enable depth buffer action request
        depth_W_r : std_logic;  -- Depth buffer action (1 = write, 0 = read)
        depth_val : slv32_t;    -- Fragment depth to write
        depth_msk : slv32_t;    -- Depth mask (0xFFFFFFFF when point in
                                -- triangle and in front of other, else 0)
        fr_en     : std_logic;  -- Enable frame buffer action request
        fr_W_r    : std_logic;  -- Frame buffer action (1 = write, 0 = read)
        fr_val    : slv32_t;    -- Fragment (pixel) color
        fr_msk    : slv32_t;    -- Fragment mask (0xFFFFFFFF when point in
                                -- triangle, else 0)
        row       : integer range 0 to TILE_SIZE_Y - 1; -- Which row we are processing
        done      : std_logic;  -- Done processing tile flag
    end record;
end rasterizer_pkg;
