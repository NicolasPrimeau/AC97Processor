----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:00:34 03/15/2014 
-- Design Name: 
-- Module Name:    receiver_cu - Behavioral 
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

entity receiver_cu is 
port(
  clk,rst: in std_logic;
  sync: in std_logic;
  count: out natural range 0 to 20;
  waste: out std_logic_vector(19 downto 0);
  dataIn: in std_logic_vector(15 downto 0);
  w: out std_logic;
  incAdr: out std_logic
);
end receiver_cu;

architecture Behavioral of receiver_cu is
type state is (s0,s1,s2);
signal s,n_s: state;  
signal cnt: natural range 0 to 20;
signal conf: std_logic_vector(15 downto 0);
signal slotChk: natural range 0 to 13;
signal resetCnt,resetSlot: std_logic;
signal incSlot: std_logic;
signal updateConf: std_logic;

begin

count <= cnt;

controller: process(clk,rst,sync,dataIn,s,n_s,cnt,conf,slotchk) 


begin
if(rst='1') then
  s<=s0;
  cnt <= 0;
  conf <= (others=>'1');
  slotChk <= 0;
  
elsif(falling_edge(clk)) then
  s <= n_s;
 
  if(updateConf = '1') then
    conf <= dataIn;
  else
    conf <= conf;
  end if;  
  
  if(resetCnt = '1') then
    cnt <= 0;
  else 
    cnt <= cnt +1;
  end if;

  if(resetSlot = '1') then
    slotChk <= 0;
  elsif(incSlot = '1') then
    slotChk <= slotChk +1;
  else
    slotChk <= slotChk;
  end if;

else
  
end if;
  
case s is

when s0=> 
  if(sync <= '1' and rst = '0') then
    if(cnt =1) then
      n_s<= s1;
      resetCnt <= '1';
    else
      resetCnt <= '0';
      n_s <= s0;
    end if;
  else
    n_s <= s0;
    resetCnt <= '1';
  end if;
    
  waste <= (others=>'1');
  updateConf <= '0';
  resetSlot<= '1';
  w <= '0';
  incSlot <= '0';
  incAdr <= '0';

when s1=>
  if(cnt = 15) then
    n_s <= s2;
    updateConf <= '0';
    resetCnt <= '1';
    IncAdr <= dataIn(15-slotChk);
    w <= '0';
    incSlot <= '1';
  elsif( cnt = 14) then
    n_s <= s1;
    updateConf <= '1';
    resetCnt <= '0';
    IncAdr <= '0';
    w <= dataIn(15-slotChk);
    incSlot <= '0';
  else
    resetCnt <= '0';
    updateConf <= '0';
    n_s <= s1;
    w <= '0';
    incSlot <= '0';
    incAdr <= '0';
  end if;
  
  resetSlot <= '0';
  waste <= "00000111111111111111";

when s2=>
  if(cnt = 19 and slotChk = 12) then
    if(sync = '1') then
      n_s <= s1;
    else
      n_s <= s0;
    end if;
    
    resetSlot <= '1';
    w <= '0';
    IncAdr <= conf(15-slotChk) and conf(15);
    resetCnt <= '1';
    incSlot <= '0';
  elsif(cnt = 19) then
    resetCnt <= '1';
    incSlot <= '1';
    incAdr <= conf(15-slotChk) and conf(15);
    w <= '0';
    resetSlot <= '0';
    n_s <= s2;
  elsif( cnt = 18) then
    resetCnt <= '0';
    incSlot <= '0';
    incAdr <= '0';
    w <= conf(15-slotChk) and conf(15);
    resetSlot <= '0';
    n_s <= s2;
  else
    n_s <= s2;
    resetCnt <= '0';
    w <= '0';
    IncAdr <= '0';
    incSlot <= '0';
    resetSlot <= '0';
  end if;
  
  updateConf <= '0';
  waste <= (others=>not (conf(15-slotChk) and conf(15)));  
    
  
when others => 
  n_s <= s0;
  resetCnt <= '1';      
  waste <= (others=>'1');
  updateConf <= '0';
  resetSlot<= '1';
  w <= '0';
  incSlot <= '0';
  incAdr <= '0';

end case;    
end process;

end Behavioral;

