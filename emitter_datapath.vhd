----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:59:17 03/15/2014 
-- Design Name: 
-- Module Name:    emitter_datapath - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.math_real.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity emitter_datapath is
port(
	dataIn: in std_logic_vector(19 downto 0);
	waste: in std_logic;
	bitCnt: in std_logic_vector(4 downto 0);
	sendBit:out std_logic
);
end emitter_datapath;
Architecture structural of emitter_datapath is

signal f1,f2,f3,f4,f5: std_logic_vector(3 downto 0); -- 0-3,4-7,8-11,12-15,16-19, the inputs to each lower level mux4 to 1's
signal whichFour: std_logic_vector(7 downto 0); -- The input to the upper level 8 to 1 multiplexer
signal t1,t2,t3,t4,t5: std_logic_vector(0 downto 0); -- temporary output
signal tsendBit: std_logic_vector(0 downto 0);
signal notWaste: std_logic;
signal reverseCnt: std_logic_vector(1 downto 0); -- Reverse count is for the output muxes

component nbit_XtoY_mux is
	generic(
		bitPerInput: integer:=2;
		numInputs: integer:=4
	);
	port(
		enable: in std_logic;
		input:in std_logic_vector(bitPerInput*numInputs-1 downto 0);
		output:out std_logic_vector(bitPerInput-1 downto 0);
		selectors: in std_logic_vector(integer(log2(real(numInputs)))-1 downto 0)
	);
end component;

begin
f1 <= dataIn(19 downto 16); --Important! goes from little endian in memory to big endian
f2 <= dataIn(15 downto 12); -- In memory, 19 downto 0
f3 <= dataIn(11 downto 8);  -- In vector, 19 downto 0 -> 0 to 19
f4 <= dataIn(7 downto 4);   -- Or else we'll send the lower bits of the four first
f5 <= dataIn(3 downto 0); 
notWaste <= not waste;

reverseCnt <= not bitCnt(1 downto 0);
first_four_mux: nbit_XtoY_mux generic map(1,4) port map(notWaste,f1,t1,reverseCnt(1 downto 0)); -- 5f----Mux4to1------|0 Mux |
second_four_mux: nbit_XtoY_mux generic map(1,4) port map(notWaste,f2,t2,reverseCnt(1 downto 0));-- 4f----Mux4to1------|1  8  |
third_four_mux: nbit_XtoY_mux generic map(1,4) port map(notWaste,f3,t3,reverseCnt(1 downto 0));--  3f----Mux4to1------|2 to  |---Output bit
fourth_four_mux: nbit_XtoY_mux generic map(1,4) port map(notWaste,f4,t4,reverseCnt(1 downto 0));-- 2f----Mux4to1------|3  1  |
last_four_mux: nbit_XtoY_mux generic map(1,4) port map(notWaste,f5,t5,reverseCnt(1 downto 0)); --  1f----Mux4to1------|4     |

whichFour(0) <= t1(0);
whichFour(1) <= t2(0);
whichFour(2) <= t3(0);
whichFour(3) <= t4(0);
whichFour(4) <= t5(0);
whichFour(5) <= '0';
whichFour(6) <= '0';
whichFour(7) <= '0';

output_mux: nbit_XtoY_mux generic map(1,8) port map(notWaste,whichFour,tsendBit,bitCnt(4 downto 2));   --     This mux^                               
sendBit <= tsendBit(0);

end structural;

