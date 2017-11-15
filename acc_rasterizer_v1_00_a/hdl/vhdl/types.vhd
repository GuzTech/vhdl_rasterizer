library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package types is
    -- Types
    subtype slv16_t  is std_logic_vector( 15 downto 0 );
    subtype slv32_t  is std_logic_vector( 31 downto 0 );
    subtype float_t  is std_logic_vector( 31 downto 0 );
    subtype int16_t  is std_logic_vector( 15 downto 0 );
    subtype int32_t  is std_logic_vector( 31 downto 0 );

    subtype s16_t    is signed( 15 downto 0 );
    subtype s32_t    is signed( 31 downto 0 );
    subtype u16_t    is unsigned( 15 downto 0 );
    subtype u32_t    is unsigned( 31 downto 0 );
	subtype u64_t    is unsigned( 63 downto 0 );

    type float2_t    is array ( 0 to 1 ) of slv32_t;
    type float3_t    is array ( 0 to 2 ) of slv32_t;
    type float4_t    is array ( 0 to 3 ) of slv32_t;
    type int2_t      is array ( 0 to 1 ) of slv32_t;
    type int3_t      is array ( 0 to 2 ) of slv32_t;
    type int16_2_t   is array ( 0 to 1 ) of slv16_t;
    type int16_3_t   is array ( 0 to 2 ) of slv16_t;
    type matrix3x3_t is array ( 0 to 2 ) of float3_t;
    type matrix4x4_t is array ( 0 to 3 ) of float4_t;

    -- Constants
    constant FLOAT_1F  : slv32_t := x"3F80_0000";
    constant FLOAT_05F : slv32_t := x"3F00_0000";

    -- Functions
    function edgeFunction( a0 : integer;
                           a1 : integer;
                           b0 : integer;
                           b1 : integer;
                           c0 : integer;
                           c1 : integer ) return signed;

    function minimum( left, right : s16_t ) return s16_t;
end types;

package body types is
    function edgeFunction( a0 : integer;
                           a1 : integer;
                           b0 : integer;
                           b1 : integer;
                           c0 : integer;
                           c1 : integer ) return signed is
    begin
        return to_signed( ( (b0 - a0) * (c1 - a1) ) - ( (b1 - a1) * (c0 - a0) ), 32 );
    end edgeFunction;

    function minimum( left, right: s16_t ) return s16_t is
    begin
        if( left < right )
        then
            return left;
        else
            return right;
        end if;
    end minimum;
end types;
