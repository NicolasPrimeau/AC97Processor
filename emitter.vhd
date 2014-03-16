----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:58:07 03/15/2014 
-- Design Name: 
-- Module Name:    emitter - Behavioral 
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

entity emitter is -- Emitter sends out on falling edge, everything must work on rising edge
port(
  dataIn: in std_logic_vector(19 downto 0);
  adr: out integer;
  sync,lineOut: out std_logic;
  clk,rst: in std_logic -- Clock is the 12.88 MHz
);
end emitter;

architecture Behavioral of emitter is
signal waste,AdrInc: std_logic;
signal stdCnt: std_logic_vector(4 downto 0);

component emitter_cu is
port(
	dataIn: in std_logic_vector(0 to 15);
	sync,AdrInc,Waste,stdCnt: out std_logic;
	clk,reset: in std_logic
);
end component;

entity emitter_datapath is
port(
	dataIn: in std_logic_vector(19 downto 0);
	waste: in std_logic;
	bitCnt: in std_logic_vector(4 downto 0);
	sendBit:out std_logic;
);
end emitter_datapath;

begin

cu: emitter_cu port map(dataIn(15 downto 0),sync,AdrInc,Waste,stdCnt);
data: emitter_datapath port map(dataIn,waste,stdCnt,lineOut);

emitterAddressRegister: process(clk,rst,AdrInc) 
variable address: integer :=0;
begin

if(rising_edge(clk)) then
  if(rst= '1') then
    address := 0;
  elsif (AdrInc) then
    address := addres +1;
  end if;
end if;
  adr <= address;
end process;

end Behavioral;

