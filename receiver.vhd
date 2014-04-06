----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:00:06 03/15/2014 
-- Design Name: 
-- Module Name:    receiver - Behavioral 
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

entity receiver is
generic(numAddresses: natural:=16;startingAddress:natural:=1);
port(
  clk,rst: in std_logic;
  w: out std_logic;
  sync: in std_logic;
  lineIn: in std_logic;
  address: out natural;
  dataOut: out std_logic_vector(19 downto 0)
);
end receiver;

architecture Behavioral of receiver is
signal count: natural range 0 to 20;
signal waste: std_logic_vector(19 downto 0);
signal conf4cu: std_logic_vector(15 downto 0);
signal tdataOut: std_logic_vector(19 downto 0);
signal adr: natural range 0 to numAddresses-1;
signal incAdr: std_logic;

component receiver_cu is 
port(
  clk,rst: in std_logic;
  sync: in std_logic;
  count: out natural range 0 to 20;
  waste: out std_logic_vector(19 downto 0);
  dataIn: in std_logic_vector(15 downto 0);
  w: out std_logic;
  incAdr: out std_logic
);
end component;

component receiver_datapath is
port(
  clk,rst : in std_logic;
  lineIn: in std_logic;
  waste: in std_logic_vector(19 downto 0);
  cnt: in natural range 0 to 20;
  dataOut: out std_logic_vector(19 downto 0)
);
end component;

begin


conf4cu <= tdataOut(19 downto 4);
dataOut <= tdataOut;
address <= adr;

receiverController: receiver_cu port map(clk,rst,sync,count,waste,conf4cu,w,incAdr);
receiverDataPath: receiver_datapath port map(clk,rst,lineIn,waste,count,tdataOut);

receiverAddress: process(clk,rst,incAdr,adr) is

begin
if(rst = '1') then
  adr <= startingAddress;
elsif(falling_edge(clk)) then
  if(incAdr = '1' and adr < (numAddresses-1)) then
    adr <= adr +1;
  elsif(incAdr = '1' and adr = numAddresses-1) then
    adr <= 0;
  else
    adr <= adr;
  end if;
else
  adr <= adr;
end if;
end process;

end Behavioral;

