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
	sendBit:out std_logic;
);
end emitter_datapath;
Architecture structural of emitter_datapath is
signal 1f,2f,3f,4f,5f: std_logic_vector(0 to 3); -- 0-3,4-7,8-11,12-15,16-19, the inputs to each lower level mux4 to 1's
signal whichFour: std_logic_vector(4 downto 0); -- The input to the upper level 8 to 1 multiplexer

entity nbit_XtoY_mux is
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
end entity;

begin
1f <= dataIn(19 downto 16); --Important! goes from little endian in memory to big endian
2f <= dataIn(15 downto 12); -- In memory, 19 downto 0
3f <= dataIn(11 downto 8);  -- In vector, 19 downto 0 -> 0 to 19
4f <= dataIn(7 downto 4);   -- Or else we'll send the lower bits of the four first
5f <= dataIn(3 downto 0); 

first_four_mux: nbit_XtoY_mux generic map(1,4) port map(waste,1f,whichFour(0),bitCnt(1 downto 0)); -- 5f----Mux4to1------|0 Mux |
second_four_mux: nbit_XtoY_mux generic map(1,4) port map(waste,2f,whichFour(1),bitCnt(1 downto 0));-- 4f----Mux4to1------|1  8  |
third_four_mux: nbit_XtoY_mux generic map(1,4) port map(waste,3f,whichFour(2),bitCnt(1 downto 0));--  3f----Mux4to1------|2 to  |---Output bit
fourth_four_mux: nbit_XtoY_mux generic map(1,4) port map(waste,4f,whichFour(3),bitCnt(1 downto 0));-- 2f----Mux4to1------|3  1  |
last_four_mux: nbit_XtoY_mux generic map(1,4) port map(waste,5f,whichFour(4),bitCnt(1 downto 0)); --  1f----Mux4to1------|4     |
output_mux: nbit_XtoY_mux generic map(1,8) port map(waste,whichFour,sendBit,bitCnt(4 downto 2));   --                 This mux^                               


end structural;

