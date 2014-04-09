----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:42:49 04/09/2014 
-- Design Name: 
-- Module Name:    receiver_synth - Behavioral 
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

entity receiver_synth is
port(
  lineOut: out std_logic;
  clock,rst: in std_logic
);
end receiver_synth;


architecture Behavioral of receiver_synth is
signal cnt: natural range 0 to 300;
signal freq: natural range 0 to 40560;
signal timeout: natural range 0 to 6145;
signal level,rstCnt: std_logic;
signal o: std_logic_vector(256 downto 0);

begin

process(clock,rst,cnt) begin
if(rst = '1') then
  cnt <= 0;
  freq <= 0;
  o(256) <= '0';
  timeout <= 0;
  level <= '0';
  o(255 downto 240) <= "1001100000000000";
  o(239 downto 220) <= "00000000000000000000";
  o(219 downto 200) <= "00000000000000000000";
  o(199 downto 180) <= "00000000000000000000";
  o(179 downto 160) <= "00000000000000000000";
  o(159 downto 0)    <=  (others => '0');
elsif(falling_edge(clock)) then
  if(timeout < 6144) then
    timeout <= timeout +1;
    lineOut <= '0';
	 cnt <= 0;
	 freq <= 0;
	 level <= '0';
	 o <= o;
  else
    timeout <= timeout;
     lineOut <= o(256-cnt);
  
  if(level = '1') then
  o(255 downto 240) <= "1001100000000000";
  o(239 downto 220) <= "00000000000000000000";
  o(219 downto 200) <= "00000000000000000000";
  o(199 downto 180) <= "11111111111111111100";
	o(179 downto 160) <= "11111111111111111100";
	o(159 downto 0)    <=  (others => '0');
  else
  o(255 downto 240) <= "1001100000000000";
  o(239 downto 220) <= "00000000000000000000";
  o(219 downto 200) <= "00000000000000000000";
  o(199 downto 180) <= "00000000000000000000";
	o(179 downto 160) <= "00000000000000000000";
	o(159 downto 0)    <=  (others => '0');
	end if;
  
  if(freq >= 20480) then
    freq <= 0;
	 level <= not level;
  else
    freq <= freq +1;
  end if;
  
  
  if(rstCnt <= '0') then
    cnt <= cnt+1;
  else
    cnt <= 0;
  end if;
	 
  	 
end if;

end if;

if(cnt = 255) then rstCnt <= '1';
else rstCnt <= '0';
end if;


end process;


end Behavioral;

