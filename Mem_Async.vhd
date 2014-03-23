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
        numAdr: integer:=512);
port(
	dataIn: in std_logic_vector(memSize -1 downto 0);
	dataOut: out std_logic_vector(memSize-1 downto 0);
	addr: in integer;
	rd_wr: in std_logic; -- rd low, wr high
	reset: in std_logic
);
end Mem_Async;

architecture Behavioral of Mem_Async is
type RAM is array (numAdr-1 downto 0) of std_logic_vector(memSize -1);
signal memory: RAM;
begin
process(reset,dataIn,addr,rd_wr,memory) begin
  if(reset = '1') then
    memory(0)(255 downto 240) <= "1110000000000000"; -- slot 1 and 2 valid
	 memory(0)(239 downto 220) <= "00000001000000000000"; -- write to master
	 memory(0)(219 downto 200) <= "00100001000000000000"; --clear mute, sound medium

    memory(1)(255 downto 240) <= "1110000000000000"; -- slot 1 and 2 valid
	 memory(1)(239 downto 220) <= "00000010000000000000"; -- write to headphone
	 memory(1)(219 downto 200) <= "00100001000000000000"; --clear mute, sound medium
	 
    memory(2)(255 downto 240) <= "1110000000000000"; -- slot 1 and 2 valid
	 memory(2)(239 downto 220) <= "00001100000000000000"; -- write to PCM gain
	 memory(2)(219 downto 200) <= "00100001000000000000"; --clear mute, sound medium

    memory(3)(255 downto 240) <= "1001100000000000"; -- slot 3 and 4 valid
	 memory(3)(199 downto 180) <= "11111011111111111100"; -- Write out some data to right
	 memory(3)(179 downto 160) <= "11111011111111111100"; -- Write out some data to left
	 
    memory(4)(255 downto 240) <= "1001100000000000"; -- slot 3 and 4 valid
	 memory(4)(199 downto 180) <= "11111111111110111100"; -- Write out some data to right
	 memory(4)(179 downto 160) <= "11111111111110111100"; -- Write out some data to left

    for i in 5 to numAdr-1 loop -- For testing the emitter
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

