----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:00:57 03/15/2014 
-- Design Name: 
-- Module Name:    receiver_datapath - Structural 
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

entity receiver_datapath is
port(
  clk,rst : in std_logic;
  lineIn: in std_logic;
  waste: in std_logic_vector(19 downto 0);
  cnt: in natural range 0 to 20;
  dataOut: out std_logic_vector(19 downto 0)
);
end receiver_datapath;

architecture behavioral of receiver_datapath is
signal slot: std_logic_vector(19 downto 1);

begin

dataOut <= slot(19 downto 1) & (lineIn and not waste(0));

datapath:  process(clk,rst,lineIn,waste,cnt,slot) is

begin
  
if(rst= '1') then
  slot <= (others=>'0');
elsif(falling_edge(clk)) then
  if(cnt = 0) then
    slot(18 downto 1) <= not waste(18 downto 1);
	 slot(19) <= lineIn and not waste(19);
  elsif(cnt < 18) then
    slot(19-cnt) <= lineIn and not waste(19-cnt);  
  else
    slot <= slot;
  end if;
else
  slot <= slot;
end if;

end process;

end behavioral;

