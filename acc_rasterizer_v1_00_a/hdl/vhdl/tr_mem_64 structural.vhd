--------------------------------------------------------------------------------
-- Copyright (c) 1995-2013 Xilinx, Inc.  All rights reserved.
--------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor: Xilinx
-- \   \   \/     Version: P.20131013
--  \   \         Application: netgen
--  /   /         Filename: tr_mem_64.vhd
-- /___/   /\     Timestamp: Thu Sep 15 17:20:27 2016
-- \   \  /  \ 
--  \___\/\___\
--             
-- Command	: -w -sim -ofmt vhdl /home/oguz/Projects/Rasterizer/ipcore_dir/tmp/_cg/tr_mem_64.ngc /home/oguz/Projects/Rasterizer/ipcore_dir/tmp/_cg/tr_mem_64.vhd 
-- Device	: 7vx485tffg1761-2
-- Input file	: /home/oguz/Projects/Rasterizer/ipcore_dir/tmp/_cg/tr_mem_64.ngc
-- Output file	: /home/oguz/Projects/Rasterizer/ipcore_dir/tmp/_cg/tr_mem_64.vhd
-- # of Entities	: 1
-- Design Name	: tr_mem_64
-- Xilinx	: /opt/Xilinx/14.7/ISE_DS/ISE/
--             
-- Purpose:    
--     This VHDL netlist is a verification model and uses simulation 
--     primitives which may not represent the true implementation of the 
--     device, however the netlist is functionally correct and should not 
--     be modified. This file cannot be synthesized and should only be used 
--     with supported simulation tools.
--             
-- Reference:  
--     Command Line Tools User Guide, Chapter 23
--     Synthesis and Simulation Design Guide, Chapter 6
--             
--------------------------------------------------------------------------------


-- synthesis translate_off
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
use UNISIM.VPKG.ALL;

entity tr_mem_64 is
  port (
    clka : in STD_LOGIC := 'X'; 
    clkb : in STD_LOGIC := 'X'; 
    rstb : in STD_LOGIC := 'X'; 
    enb : in STD_LOGIC := 'X'; 
    wea : in STD_LOGIC_VECTOR ( 0 downto 0 ); 
    addra : in STD_LOGIC_VECTOR ( 4 downto 0 ); 
    dina : in STD_LOGIC_VECTOR ( 31 downto 0 ); 
    addrb : in STD_LOGIC_VECTOR ( 3 downto 0 ); 
    doutb : out STD_LOGIC_VECTOR ( 63 downto 0 ) 
  );
end tr_mem_64;

architecture STRUCTURE of tr_mem_64 is
  signal N0 : STD_LOGIC; 
  signal N1 : STD_LOGIC; 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_CASCADEOUTA_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_CASCADEOUTB_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DBITERR_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_SBITERR_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_31_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_30_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_29_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_28_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_27_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_26_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_25_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_24_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_23_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_22_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_21_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_20_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_19_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_18_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_17_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_16_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_15_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_14_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_13_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_12_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_11_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_10_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_9_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_8_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_7_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_6_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_5_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_4_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_3_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_2_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_1_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_0_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOPADOP_3_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOPADOP_2_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOPADOP_1_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOPADOP_0_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_ECCPARITY_7_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_ECCPARITY_6_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_ECCPARITY_5_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_ECCPARITY_4_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_ECCPARITY_3_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_ECCPARITY_2_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_ECCPARITY_1_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_ECCPARITY_0_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_RDADDRECC_8_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_RDADDRECC_7_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_RDADDRECC_6_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_RDADDRECC_5_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_RDADDRECC_4_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_RDADDRECC_3_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_RDADDRECC_2_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_RDADDRECC_1_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_RDADDRECC_0_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_CASCADEOUTA_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_CASCADEOUTB_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DBITERR_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_SBITERR_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_31_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_30_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_29_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_28_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_27_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_26_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_25_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_24_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_23_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_22_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_21_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_20_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_19_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_18_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_17_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_16_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_15_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_14_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_13_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_12_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_11_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_10_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_9_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_8_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_7_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_6_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_5_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_4_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_3_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_2_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_1_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_0_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOBDO_31_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOBDO_23_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOBDO_15_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOBDO_7_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOPADOP_3_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOPADOP_2_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOPADOP_1_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOPADOP_0_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOPBDOP_3_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOPBDOP_2_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOPBDOP_1_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOPBDOP_0_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_ECCPARITY_7_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_ECCPARITY_6_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_ECCPARITY_5_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_ECCPARITY_4_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_ECCPARITY_3_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_ECCPARITY_2_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_ECCPARITY_1_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_ECCPARITY_0_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_RDADDRECC_8_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_RDADDRECC_7_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_RDADDRECC_6_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_RDADDRECC_5_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_RDADDRECC_4_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_RDADDRECC_3_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_RDADDRECC_2_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_RDADDRECC_1_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_RDADDRECC_0_UNCONNECTED : STD_LOGIC;
 
begin
  XST_VCC : VCC
    port map (
      P => N0
    );
  XST_GND : GND
    port map (
      G => N1
    );
  U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram : RAMB36E1
    generic map(
      DOA_REG => 0,
      DOB_REG => 0,
      EN_ECC_READ => FALSE,
      EN_ECC_WRITE => FALSE,
      INITP_00 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_01 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_02 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_03 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_04 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_05 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_06 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_07 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_08 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_09 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_0A => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_0B => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_0C => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_0D => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_0E => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_0F => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_00 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_01 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_02 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_03 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_04 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_05 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_06 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_07 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_08 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_09 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_0A => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_0B => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_0C => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_0D => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_0E => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_0F => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_10 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_11 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_12 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_13 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_14 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_15 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_16 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_17 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_18 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_19 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_1A => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_1B => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_1C => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_1D => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_1E => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_1F => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_20 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_21 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_22 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_23 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_24 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_25 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_26 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_27 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_28 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_29 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_2A => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_2B => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_2C => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_2D => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_2E => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_2F => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_30 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_31 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_32 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_33 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_34 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_35 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_36 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_37 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_38 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_39 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_3A => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_3B => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_3C => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_3D => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_3E => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_3F => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_40 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_41 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_42 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_43 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_44 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_45 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_46 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_47 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_48 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_49 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_4A => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_4B => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_4C => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_4D => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_4E => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_4F => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_50 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_51 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_52 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_53 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_54 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_55 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_56 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_57 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_58 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_59 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_5A => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_5B => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_5C => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_5D => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_5E => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_5F => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_60 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_61 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_62 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_63 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_64 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_65 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_66 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_67 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_68 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_69 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_6A => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_6B => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_6C => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_6D => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_6E => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_6F => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_70 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_71 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_72 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_73 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_74 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_75 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_76 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_77 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_78 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_79 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_7A => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_7B => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_7C => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_7D => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_7E => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_7F => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_A => X"000000000",
      INIT_B => X"000000000",
      INIT_FILE => "NONE",
      RAM_EXTENSION_A => "NONE",
      RAM_EXTENSION_B => "NONE",
      RAM_MODE => "TDP",
      RDADDR_COLLISION_HWCONFIG => "DELAYED_WRITE",
      READ_WIDTH_A => 36,
      READ_WIDTH_B => 36,
      RSTREG_PRIORITY_A => "REGCE",
      RSTREG_PRIORITY_B => "REGCE",
      SIM_COLLISION_CHECK => "ALL",
      SIM_DEVICE => "7SERIES",
      SRVAL_A => X"000000000",
      SRVAL_B => X"000000000",
      WRITE_MODE_A => "READ_FIRST",
      WRITE_MODE_B => "READ_FIRST",
      WRITE_WIDTH_A => 18,
      WRITE_WIDTH_B => 18
    )
    port map (
      CASCADEINA => N1,
      CASCADEINB => N1,
      CASCADEOUTA => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_CASCADEOUTA_UNCONNECTED
,
      CASCADEOUTB => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_CASCADEOUTB_UNCONNECTED
,
      CLKARDCLK => clka,
      CLKBWRCLK => clkb,
      DBITERR => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DBITERR_UNCONNECTED
,
      ENARDEN => N0,
      ENBWREN => enb,
      INJECTDBITERR => N1,
      INJECTSBITERR => N1,
      REGCEAREGCE => N1,
      REGCEB => N1,
      RSTRAMARSTRAM => N1,
      RSTRAMB => rstb,
      RSTREGARSTREG => N1,
      RSTREGB => N1,
      SBITERR => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_SBITERR_UNCONNECTED
,
      ADDRARDADDR(15) => N0,
      ADDRARDADDR(14) => N1,
      ADDRARDADDR(13) => N1,
      ADDRARDADDR(12) => N1,
      ADDRARDADDR(11) => N1,
      ADDRARDADDR(10) => N1,
      ADDRARDADDR(9) => N1,
      ADDRARDADDR(8) => addra(4),
      ADDRARDADDR(7) => addra(3),
      ADDRARDADDR(6) => addra(2),
      ADDRARDADDR(5) => addra(1),
      ADDRARDADDR(4) => addra(0),
      ADDRARDADDR(3) => N1,
      ADDRARDADDR(2) => N1,
      ADDRARDADDR(1) => N1,
      ADDRARDADDR(0) => N1,
      ADDRBWRADDR(15) => N0,
      ADDRBWRADDR(14) => N1,
      ADDRBWRADDR(13) => N1,
      ADDRBWRADDR(12) => N1,
      ADDRBWRADDR(11) => N1,
      ADDRBWRADDR(10) => N1,
      ADDRBWRADDR(9) => N1,
      ADDRBWRADDR(8) => addrb(3),
      ADDRBWRADDR(7) => addrb(2),
      ADDRBWRADDR(6) => addrb(1),
      ADDRBWRADDR(5) => addrb(0),
      ADDRBWRADDR(4) => N1,
      ADDRBWRADDR(3) => N1,
      ADDRBWRADDR(2) => N1,
      ADDRBWRADDR(1) => N1,
      ADDRBWRADDR(0) => N1,
      DIADI(31) => N1,
      DIADI(30) => N1,
      DIADI(29) => N1,
      DIADI(28) => N1,
      DIADI(27) => N1,
      DIADI(26) => N1,
      DIADI(25) => N1,
      DIADI(24) => N1,
      DIADI(23) => N1,
      DIADI(22) => N1,
      DIADI(21) => N1,
      DIADI(20) => N1,
      DIADI(19) => N1,
      DIADI(18) => N1,
      DIADI(17) => N1,
      DIADI(16) => N1,
      DIADI(15) => dina(16),
      DIADI(14) => dina(15),
      DIADI(13) => dina(14),
      DIADI(12) => dina(13),
      DIADI(11) => dina(12),
      DIADI(10) => dina(11),
      DIADI(9) => dina(10),
      DIADI(8) => dina(9),
      DIADI(7) => dina(7),
      DIADI(6) => dina(6),
      DIADI(5) => dina(5),
      DIADI(4) => dina(4),
      DIADI(3) => dina(3),
      DIADI(2) => dina(2),
      DIADI(1) => dina(1),
      DIADI(0) => dina(0),
      DIBDI(31) => N1,
      DIBDI(30) => N1,
      DIBDI(29) => N1,
      DIBDI(28) => N1,
      DIBDI(27) => N1,
      DIBDI(26) => N1,
      DIBDI(25) => N1,
      DIBDI(24) => N1,
      DIBDI(23) => N1,
      DIBDI(22) => N1,
      DIBDI(21) => N1,
      DIBDI(20) => N1,
      DIBDI(19) => N1,
      DIBDI(18) => N1,
      DIBDI(17) => N1,
      DIBDI(16) => N1,
      DIBDI(15) => N1,
      DIBDI(14) => N1,
      DIBDI(13) => N1,
      DIBDI(12) => N1,
      DIBDI(11) => N1,
      DIBDI(10) => N1,
      DIBDI(9) => N1,
      DIBDI(8) => N1,
      DIBDI(7) => N1,
      DIBDI(6) => N1,
      DIBDI(5) => N1,
      DIBDI(4) => N1,
      DIBDI(3) => N1,
      DIBDI(2) => N1,
      DIBDI(1) => N1,
      DIBDI(0) => N1,
      DIPADIP(3) => N1,
      DIPADIP(2) => N1,
      DIPADIP(1) => dina(17),
      DIPADIP(0) => dina(8),
      DIPBDIP(3) => N1,
      DIPBDIP(2) => N1,
      DIPBDIP(1) => N1,
      DIPBDIP(0) => N1,
      DOADO(31) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_31_UNCONNECTED
,
      DOADO(30) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_30_UNCONNECTED
,
      DOADO(29) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_29_UNCONNECTED
,
      DOADO(28) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_28_UNCONNECTED
,
      DOADO(27) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_27_UNCONNECTED
,
      DOADO(26) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_26_UNCONNECTED
,
      DOADO(25) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_25_UNCONNECTED
,
      DOADO(24) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_24_UNCONNECTED
,
      DOADO(23) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_23_UNCONNECTED
,
      DOADO(22) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_22_UNCONNECTED
,
      DOADO(21) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_21_UNCONNECTED
,
      DOADO(20) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_20_UNCONNECTED
,
      DOADO(19) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_19_UNCONNECTED
,
      DOADO(18) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_18_UNCONNECTED
,
      DOADO(17) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_17_UNCONNECTED
,
      DOADO(16) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_16_UNCONNECTED
,
      DOADO(15) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_15_UNCONNECTED
,
      DOADO(14) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_14_UNCONNECTED
,
      DOADO(13) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_13_UNCONNECTED
,
      DOADO(12) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_12_UNCONNECTED
,
      DOADO(11) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_11_UNCONNECTED
,
      DOADO(10) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_10_UNCONNECTED
,
      DOADO(9) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_9_UNCONNECTED
,
      DOADO(8) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_8_UNCONNECTED
,
      DOADO(7) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_7_UNCONNECTED
,
      DOADO(6) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_6_UNCONNECTED
,
      DOADO(5) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_5_UNCONNECTED
,
      DOADO(4) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_4_UNCONNECTED
,
      DOADO(3) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_3_UNCONNECTED
,
      DOADO(2) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_2_UNCONNECTED
,
      DOADO(1) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_1_UNCONNECTED
,
      DOADO(0) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_0_UNCONNECTED
,
      DOBDO(31) => doutb(48),
      DOBDO(30) => doutb(47),
      DOBDO(29) => doutb(46),
      DOBDO(28) => doutb(45),
      DOBDO(27) => doutb(44),
      DOBDO(26) => doutb(43),
      DOBDO(25) => doutb(42),
      DOBDO(24) => doutb(41),
      DOBDO(23) => doutb(39),
      DOBDO(22) => doutb(38),
      DOBDO(21) => doutb(37),
      DOBDO(20) => doutb(36),
      DOBDO(19) => doutb(35),
      DOBDO(18) => doutb(34),
      DOBDO(17) => doutb(33),
      DOBDO(16) => doutb(32),
      DOBDO(15) => doutb(16),
      DOBDO(14) => doutb(15),
      DOBDO(13) => doutb(14),
      DOBDO(12) => doutb(13),
      DOBDO(11) => doutb(12),
      DOBDO(10) => doutb(11),
      DOBDO(9) => doutb(10),
      DOBDO(8) => doutb(9),
      DOBDO(7) => doutb(7),
      DOBDO(6) => doutb(6),
      DOBDO(5) => doutb(5),
      DOBDO(4) => doutb(4),
      DOBDO(3) => doutb(3),
      DOBDO(2) => doutb(2),
      DOBDO(1) => doutb(1),
      DOBDO(0) => doutb(0),
      DOPADOP(3) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOPADOP_3_UNCONNECTED
,
      DOPADOP(2) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOPADOP_2_UNCONNECTED
,
      DOPADOP(1) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOPADOP_1_UNCONNECTED
,
      DOPADOP(0) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOPADOP_0_UNCONNECTED
,
      DOPBDOP(3) => doutb(49),
      DOPBDOP(2) => doutb(40),
      DOPBDOP(1) => doutb(17),
      DOPBDOP(0) => doutb(8),
      ECCPARITY(7) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_ECCPARITY_7_UNCONNECTED
,
      ECCPARITY(6) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_ECCPARITY_6_UNCONNECTED
,
      ECCPARITY(5) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_ECCPARITY_5_UNCONNECTED
,
      ECCPARITY(4) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_ECCPARITY_4_UNCONNECTED
,
      ECCPARITY(3) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_ECCPARITY_3_UNCONNECTED
,
      ECCPARITY(2) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_ECCPARITY_2_UNCONNECTED
,
      ECCPARITY(1) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_ECCPARITY_1_UNCONNECTED
,
      ECCPARITY(0) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_ECCPARITY_0_UNCONNECTED
,
      RDADDRECC(8) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_RDADDRECC_8_UNCONNECTED
,
      RDADDRECC(7) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_RDADDRECC_7_UNCONNECTED
,
      RDADDRECC(6) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_RDADDRECC_6_UNCONNECTED
,
      RDADDRECC(5) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_RDADDRECC_5_UNCONNECTED
,
      RDADDRECC(4) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_RDADDRECC_4_UNCONNECTED
,
      RDADDRECC(3) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_RDADDRECC_3_UNCONNECTED
,
      RDADDRECC(2) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_RDADDRECC_2_UNCONNECTED
,
      RDADDRECC(1) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_RDADDRECC_1_UNCONNECTED
,
      RDADDRECC(0) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_0_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_RDADDRECC_0_UNCONNECTED
,
      WEA(3) => wea(0),
      WEA(2) => wea(0),
      WEA(1) => wea(0),
      WEA(0) => wea(0),
      WEBWE(7) => N1,
      WEBWE(6) => N1,
      WEBWE(5) => N1,
      WEBWE(4) => N1,
      WEBWE(3) => N1,
      WEBWE(2) => N1,
      WEBWE(1) => N1,
      WEBWE(0) => N1
    );
  U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram : RAMB36E1
    generic map(
      DOA_REG => 0,
      DOB_REG => 0,
      EN_ECC_READ => FALSE,
      EN_ECC_WRITE => FALSE,
      INITP_00 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_01 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_02 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_03 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_04 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_05 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_06 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_07 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_08 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_09 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_0A => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_0B => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_0C => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_0D => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_0E => X"0000000000000000000000000000000000000000000000000000000000000000",
      INITP_0F => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_00 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_01 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_02 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_03 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_04 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_05 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_06 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_07 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_08 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_09 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_0A => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_0B => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_0C => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_0D => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_0E => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_0F => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_10 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_11 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_12 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_13 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_14 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_15 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_16 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_17 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_18 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_19 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_1A => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_1B => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_1C => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_1D => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_1E => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_1F => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_20 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_21 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_22 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_23 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_24 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_25 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_26 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_27 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_28 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_29 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_2A => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_2B => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_2C => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_2D => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_2E => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_2F => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_30 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_31 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_32 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_33 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_34 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_35 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_36 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_37 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_38 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_39 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_3A => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_3B => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_3C => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_3D => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_3E => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_3F => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_40 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_41 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_42 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_43 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_44 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_45 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_46 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_47 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_48 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_49 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_4A => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_4B => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_4C => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_4D => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_4E => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_4F => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_50 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_51 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_52 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_53 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_54 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_55 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_56 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_57 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_58 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_59 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_5A => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_5B => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_5C => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_5D => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_5E => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_5F => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_60 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_61 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_62 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_63 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_64 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_65 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_66 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_67 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_68 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_69 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_6A => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_6B => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_6C => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_6D => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_6E => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_6F => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_70 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_71 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_72 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_73 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_74 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_75 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_76 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_77 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_78 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_79 => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_7A => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_7B => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_7C => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_7D => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_7E => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_7F => X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_A => X"000000000",
      INIT_B => X"000000000",
      INIT_FILE => "NONE",
      RAM_EXTENSION_A => "NONE",
      RAM_EXTENSION_B => "NONE",
      RAM_MODE => "TDP",
      RDADDR_COLLISION_HWCONFIG => "DELAYED_WRITE",
      READ_WIDTH_A => 36,
      READ_WIDTH_B => 36,
      RSTREG_PRIORITY_A => "REGCE",
      RSTREG_PRIORITY_B => "REGCE",
      SIM_COLLISION_CHECK => "ALL",
      SIM_DEVICE => "7SERIES",
      SRVAL_A => X"000000000",
      SRVAL_B => X"000000000",
      WRITE_MODE_A => "READ_FIRST",
      WRITE_MODE_B => "READ_FIRST",
      WRITE_WIDTH_A => 18,
      WRITE_WIDTH_B => 18
    )
    port map (
      CASCADEINA => N1,
      CASCADEINB => N1,
      CASCADEOUTA => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_CASCADEOUTA_UNCONNECTED
,
      CASCADEOUTB => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_CASCADEOUTB_UNCONNECTED
,
      CLKARDCLK => clka,
      CLKBWRCLK => clkb,
      DBITERR => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DBITERR_UNCONNECTED
,
      ENARDEN => N0,
      ENBWREN => enb,
      INJECTDBITERR => N1,
      INJECTSBITERR => N1,
      REGCEAREGCE => N1,
      REGCEB => N1,
      RSTRAMARSTRAM => N1,
      RSTRAMB => rstb,
      RSTREGARSTREG => N1,
      RSTREGB => N1,
      SBITERR => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_SBITERR_UNCONNECTED
,
      ADDRARDADDR(15) => N0,
      ADDRARDADDR(14) => N1,
      ADDRARDADDR(13) => N1,
      ADDRARDADDR(12) => N1,
      ADDRARDADDR(11) => N1,
      ADDRARDADDR(10) => N1,
      ADDRARDADDR(9) => N1,
      ADDRARDADDR(8) => addra(4),
      ADDRARDADDR(7) => addra(3),
      ADDRARDADDR(6) => addra(2),
      ADDRARDADDR(5) => addra(1),
      ADDRARDADDR(4) => addra(0),
      ADDRARDADDR(3) => N1,
      ADDRARDADDR(2) => N1,
      ADDRARDADDR(1) => N1,
      ADDRARDADDR(0) => N1,
      ADDRBWRADDR(15) => N0,
      ADDRBWRADDR(14) => N1,
      ADDRBWRADDR(13) => N1,
      ADDRBWRADDR(12) => N1,
      ADDRBWRADDR(11) => N1,
      ADDRBWRADDR(10) => N1,
      ADDRBWRADDR(9) => N1,
      ADDRBWRADDR(8) => addrb(3),
      ADDRBWRADDR(7) => addrb(2),
      ADDRBWRADDR(6) => addrb(1),
      ADDRBWRADDR(5) => addrb(0),
      ADDRBWRADDR(4) => N1,
      ADDRBWRADDR(3) => N1,
      ADDRBWRADDR(2) => N1,
      ADDRBWRADDR(1) => N1,
      ADDRBWRADDR(0) => N1,
      DIADI(31) => N1,
      DIADI(30) => N1,
      DIADI(29) => N1,
      DIADI(28) => N1,
      DIADI(27) => N1,
      DIADI(26) => N1,
      DIADI(25) => N1,
      DIADI(24) => N1,
      DIADI(23) => N1,
      DIADI(22) => N1,
      DIADI(21) => N1,
      DIADI(20) => N1,
      DIADI(19) => N1,
      DIADI(18) => N1,
      DIADI(17) => N1,
      DIADI(16) => N1,
      DIADI(15) => N1,
      DIADI(14) => dina(31),
      DIADI(13) => dina(30),
      DIADI(12) => dina(29),
      DIADI(11) => dina(28),
      DIADI(10) => dina(27),
      DIADI(9) => dina(26),
      DIADI(8) => dina(25),
      DIADI(7) => N1,
      DIADI(6) => dina(24),
      DIADI(5) => dina(23),
      DIADI(4) => dina(22),
      DIADI(3) => dina(21),
      DIADI(2) => dina(20),
      DIADI(1) => dina(19),
      DIADI(0) => dina(18),
      DIBDI(31) => N1,
      DIBDI(30) => N1,
      DIBDI(29) => N1,
      DIBDI(28) => N1,
      DIBDI(27) => N1,
      DIBDI(26) => N1,
      DIBDI(25) => N1,
      DIBDI(24) => N1,
      DIBDI(23) => N1,
      DIBDI(22) => N1,
      DIBDI(21) => N1,
      DIBDI(20) => N1,
      DIBDI(19) => N1,
      DIBDI(18) => N1,
      DIBDI(17) => N1,
      DIBDI(16) => N1,
      DIBDI(15) => N1,
      DIBDI(14) => N1,
      DIBDI(13) => N1,
      DIBDI(12) => N1,
      DIBDI(11) => N1,
      DIBDI(10) => N1,
      DIBDI(9) => N1,
      DIBDI(8) => N1,
      DIBDI(7) => N1,
      DIBDI(6) => N1,
      DIBDI(5) => N1,
      DIBDI(4) => N1,
      DIBDI(3) => N1,
      DIBDI(2) => N1,
      DIBDI(1) => N1,
      DIBDI(0) => N1,
      DIPADIP(3) => N1,
      DIPADIP(2) => N1,
      DIPADIP(1) => N1,
      DIPADIP(0) => N1,
      DIPBDIP(3) => N1,
      DIPBDIP(2) => N1,
      DIPBDIP(1) => N1,
      DIPBDIP(0) => N1,
      DOADO(31) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_31_UNCONNECTED
,
      DOADO(30) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_30_UNCONNECTED
,
      DOADO(29) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_29_UNCONNECTED
,
      DOADO(28) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_28_UNCONNECTED
,
      DOADO(27) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_27_UNCONNECTED
,
      DOADO(26) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_26_UNCONNECTED
,
      DOADO(25) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_25_UNCONNECTED
,
      DOADO(24) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_24_UNCONNECTED
,
      DOADO(23) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_23_UNCONNECTED
,
      DOADO(22) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_22_UNCONNECTED
,
      DOADO(21) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_21_UNCONNECTED
,
      DOADO(20) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_20_UNCONNECTED
,
      DOADO(19) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_19_UNCONNECTED
,
      DOADO(18) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_18_UNCONNECTED
,
      DOADO(17) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_17_UNCONNECTED
,
      DOADO(16) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_16_UNCONNECTED
,
      DOADO(15) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_15_UNCONNECTED
,
      DOADO(14) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_14_UNCONNECTED
,
      DOADO(13) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_13_UNCONNECTED
,
      DOADO(12) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_12_UNCONNECTED
,
      DOADO(11) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_11_UNCONNECTED
,
      DOADO(10) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_10_UNCONNECTED
,
      DOADO(9) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_9_UNCONNECTED
,
      DOADO(8) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_8_UNCONNECTED
,
      DOADO(7) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_7_UNCONNECTED
,
      DOADO(6) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_6_UNCONNECTED
,
      DOADO(5) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_5_UNCONNECTED
,
      DOADO(4) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_4_UNCONNECTED
,
      DOADO(3) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_3_UNCONNECTED
,
      DOADO(2) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_2_UNCONNECTED
,
      DOADO(1) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_1_UNCONNECTED
,
      DOADO(0) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOADO_0_UNCONNECTED
,
      DOBDO(31) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOBDO_31_UNCONNECTED
,
      DOBDO(30) => doutb(63),
      DOBDO(29) => doutb(62),
      DOBDO(28) => doutb(61),
      DOBDO(27) => doutb(60),
      DOBDO(26) => doutb(59),
      DOBDO(25) => doutb(58),
      DOBDO(24) => doutb(57),
      DOBDO(23) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOBDO_23_UNCONNECTED
,
      DOBDO(22) => doutb(56),
      DOBDO(21) => doutb(55),
      DOBDO(20) => doutb(54),
      DOBDO(19) => doutb(53),
      DOBDO(18) => doutb(52),
      DOBDO(17) => doutb(51),
      DOBDO(16) => doutb(50),
      DOBDO(15) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOBDO_15_UNCONNECTED
,
      DOBDO(14) => doutb(31),
      DOBDO(13) => doutb(30),
      DOBDO(12) => doutb(29),
      DOBDO(11) => doutb(28),
      DOBDO(10) => doutb(27),
      DOBDO(9) => doutb(26),
      DOBDO(8) => doutb(25),
      DOBDO(7) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOBDO_7_UNCONNECTED
,
      DOBDO(6) => doutb(24),
      DOBDO(5) => doutb(23),
      DOBDO(4) => doutb(22),
      DOBDO(3) => doutb(21),
      DOBDO(2) => doutb(20),
      DOBDO(1) => doutb(19),
      DOBDO(0) => doutb(18),
      DOPADOP(3) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOPADOP_3_UNCONNECTED
,
      DOPADOP(2) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOPADOP_2_UNCONNECTED
,
      DOPADOP(1) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOPADOP_1_UNCONNECTED
,
      DOPADOP(0) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOPADOP_0_UNCONNECTED
,
      DOPBDOP(3) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOPBDOP_3_UNCONNECTED
,
      DOPBDOP(2) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOPBDOP_2_UNCONNECTED
,
      DOPBDOP(1) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOPBDOP_1_UNCONNECTED
,
      DOPBDOP(0) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_DOPBDOP_0_UNCONNECTED
,
      ECCPARITY(7) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_ECCPARITY_7_UNCONNECTED
,
      ECCPARITY(6) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_ECCPARITY_6_UNCONNECTED
,
      ECCPARITY(5) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_ECCPARITY_5_UNCONNECTED
,
      ECCPARITY(4) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_ECCPARITY_4_UNCONNECTED
,
      ECCPARITY(3) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_ECCPARITY_3_UNCONNECTED
,
      ECCPARITY(2) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_ECCPARITY_2_UNCONNECTED
,
      ECCPARITY(1) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_ECCPARITY_1_UNCONNECTED
,
      ECCPARITY(0) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_ECCPARITY_0_UNCONNECTED
,
      RDADDRECC(8) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_RDADDRECC_8_UNCONNECTED
,
      RDADDRECC(7) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_RDADDRECC_7_UNCONNECTED
,
      RDADDRECC(6) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_RDADDRECC_6_UNCONNECTED
,
      RDADDRECC(5) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_RDADDRECC_5_UNCONNECTED
,
      RDADDRECC(4) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_RDADDRECC_4_UNCONNECTED
,
      RDADDRECC(3) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_RDADDRECC_3_UNCONNECTED
,
      RDADDRECC(2) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_RDADDRECC_2_UNCONNECTED
,
      RDADDRECC(1) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_RDADDRECC_1_UNCONNECTED
,
      RDADDRECC(0) => 
NLW_U0_xst_blk_mem_generator_gnativebmg_native_blk_mem_gen_valid_cstr_ramloop_1_ram_r_v6_noinit_ram_NO_BMM_INFO_SDP_SIMPLE_PRIM36_ram_RDADDRECC_0_UNCONNECTED
,
      WEA(3) => wea(0),
      WEA(2) => wea(0),
      WEA(1) => wea(0),
      WEA(0) => wea(0),
      WEBWE(7) => N1,
      WEBWE(6) => N1,
      WEBWE(5) => N1,
      WEBWE(4) => N1,
      WEBWE(3) => N1,
      WEBWE(2) => N1,
      WEBWE(1) => N1,
      WEBWE(0) => N1
    );

end STRUCTURE;

-- synthesis translate_on
