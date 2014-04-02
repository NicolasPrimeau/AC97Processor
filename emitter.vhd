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
  adr: out natural;
  sync,lineOut: out std_logic;
  clk,rst: in std_logic -- Clock is the 12.88 MHz
);
end emitter;

architecture Behavioral of emitter is
signal waste,AdrInc: std_logic;
signal stdCnt: std_logic_vector(4 downto 0);

component emitter_cu is
port(
	dataIn: in std_logic_vector(15 downto 0);
	sync,AdrInc,Waste: out std_logic;
	stdCnt: out std_logic_vector(4 downto 0);
	clk,reset: in std_logic
);
end component;

component emitter_datapath is
port(
	dataIn: in std_logic_vector(19 downto 0);
	waste: in std_logic;
	bitCnt: in std_logic_vector(4 downto 0);
	sendBit:out std_logic
);
end component;

begin

cu: emitter_cu port map(dataIn(19 downto 4),sync,AdrInc,Waste,stdCnt,clk,rst);
data: emitter_datapath port map(dataIn,waste,stdCnt,lineOut);

emitterAddressRegister: process(clk,rst,AdrInc) 
variable address: natural :=0;
begin

if(rst= '1') then
    address := 0;
elsif(rising_edge(clk)) then
  if (AdrInc = '1') then
    if(address < 14) then -- Testing purposes only
      address := address +1;
    elsif(address = 14) then -- Alternating 
	   address :=9;
    end if;
  end if;
end if;
  adr <= address;
end process;

end Behavioral;

