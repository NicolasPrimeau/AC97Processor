----------------------------------------------------------------------------------
-- Nicolas Primeau
-- 
-- Create Date:    13:24:12 03/15/2014 
-- Design Name:    Asynchronous Generic Memory
-- Module Name:    Mem_Async - Behavioral 
-- Description: 
--
-- Asynchronous generic memory. CAREFUL, Do not write until the address has been
-- stablized or else you might write to an unpredictable place! This component is
-- much better when you only want to read from it with STABLE address bus. STABLE.
-- ADDRESS. BUS.
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
use ieee.numeric_std.all;
use ieee.math_real.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Mem_Async is
generic(memSize: integer:=8;
        numAdr: integer:=32);
port(
	dataIn: in std_logic_vector(memSize -1 downto 0);
	dataOut: out std_logic_vector(memSize-1 downto 0);
	addr: in natural;
	rd_wr: in std_logic; -- rd low, wr high
	reset: in std_logic
);
end Mem_Async;

architecture Behavioral of Mem_Async is
type RAM is array (0 to numAdr-1) of std_logic_vector(memSize -1 downto 0);
signal memory: RAM;
begin
process(reset,dataIn,addr,rd_wr,memory) begin
  if(reset = '1') then
-- write to master
    memory(0) <= "11100000000000000000";
    memory(1) <= "00000001000000000000";
    memory(2) <= "00100001000000000000";

-- write to hp
    memory(3) <= "11100000000000000000";
    memory(4) <= "00000010000000000000"; 
    memory(5) <= "00100001000000000000";	                               

-- Write to PCM
    memory(6) <= "11100000000000000000";
    memory(7) <= "00001100000000000000";                  
    memory(8) <= "00100001000000000000";
    
-- output data 1
    memory(9) <= "10011000000000000000";
    memory(10)<= "11111011111111111100";	         
    memory(11)<= "11111011111111111100";

--output data 2
    memory(12)<= "10011000000000000000";
    memory(13)<= "11111111111110111100";	         
    memory(14)<= "11111111111110111100";


    for i in 15 to numAdr-1 loop
        memory(i) <= std_logic_vector(to_unsigned(0,memSize));
    end loop; 
	 
	 dataOut <= (others => '0');
  elsif(rd_wr = '0') then
    dataOut <= memory(addr);
  elsif(rd_wr = '1') then
    memory(addr) <= dataIn;
    dataOut <= (others => '0');
  else
    dataOut <= (others=>'0');  
  end if;
end process;
end Behavioral;

