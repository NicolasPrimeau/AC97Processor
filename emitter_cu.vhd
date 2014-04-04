----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:58:33 03/15/2014 
-- Design Name: 
-- Module Name:    emitter_cu - Behavioral 
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
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity emitter_cu is
port(
	dataIn: in std_logic_vector(15 downto 0);
	sync,AdrInc,Waste: out std_logic;
	stdCnt: out std_logic_vector(4 downto 0);
	clk,reset: in std_logic
);
end emitter_cu;

architecture Behavioral of emitter_cu is
type state is (s0,s1,s2);
signal cnt,slotChk: natural;
signal s,n_s: state:=s0;
signal conf: std_logic_vector(15 downto 0);
signal updateConf,resetCnt:std_logic;
signal n_sync: std_logic;

begin

stdCnt <= std_logic_vector(to_unsigned((cnt),5));

controller: process(s,n_s,clk,reset,dataIn,cnt,n_sync,conf,slotchk) 
begin

--State selection
if(reset = '1') then
    s<= s0;
    cnt<= 0;
    sync <= '0';
	 conf<=(others=>'1');
	 slotChk <= 0;
elsif(rising_edge(clk)) then
  
  s <= n_s;

--Configuration
  if(updateConf = '1') then
    conf <= dataIn;
  else
    conf <= conf;
  end if;

--Counter
  if(resetCnt = '1') then
    cnt <= 0;
  else
    cnt <= cnt +1;
  end if;

--Slot validity Check, necessary for address incrementation.
  if(s=s0 or s=s1) then
    slotChk <= 1;
  elsif(s = s2 and cnt = 19) then
    slotChk <= slotChk +1;
  else
    slotChk <= slotChk;
  end if;
  
  Sync <= n_Sync;
else
  cnt <= cnt;
  slotChk <= slotChk;
end if;


case s is	 
  when s0 => 
      if(cnt = 1) then
        n_s <= s1; --Pre frame Sync signal
        resetCnt <= '1';
      else
        resetCnt <= '0';
		  n_s <= s0;
      end if; 
      AdrInc <= '0';
		
      --Derived outputs
		
      n_sync <= not reset;
	   Waste <= not reset;
	   updateConf <= not reset;
		
  when s1 => 
      if(cnt = 15) then -- If cnt is 15, prepare for next Slot at next rising edge
         n_s <= s2; --Tag is the only 16 bit slot, syncing is over
		   AdrInc <= '1';
         resetCnt <= '1';
			updateConf <= '0';
      elsif(cnt = 0) then
         updateConf <= '1';
         resetCnt <= '0';
         AdrInc <= '0';
			n_s <= s1;
		else
			updateConf <= '0';
			resetCnt <= '0';
		   AdrInc <= '0';
			n_s <= s1;
		 end if;
		 Waste <= '0';
				    
       --sync control
       if(cnt >= 14) then
         n_sync <= '0';
		 else
	      n_sync <= '1';
       end if;	
		 
  when s2 => 
    
       -- Next state is s2, we can skip 0,1
       if(slotChk = 12 and cnt = 19) then -- Maximum of slot for this board, for stereo outputs
         n_s <= s1;
		 else
		   n_s <= s2;
		 end if;
				
		 --Sync control
		 if(slotChk = 12 and cnt >= 18) then
			n_Sync <= '1';
	    else
		   n_Sync <= '0';
		 end if;
				

       --Don't update conf
       updateConf <= '0';		 
		 --Count control
		 if(cnt = 19) then
			resetCnt <= '1';
		 else
			resetCnt <= '0';
		 end if;
				 
		 --Waste control
       -- Waste not valid slots
		 Waste <= not conf(15-slotChk);
				 
		 -- adress control
		 -- We never increase address when we're processing slots over the max 5

		 if(slotChk <5 and cnt = 19 and conf(15-slotChk-1) = '1' and conf(15-slotChk) = '1') then 
		   AdrInc <= '1';
       elsif(slotChk = 12 and cnt = 19) then
         AdrInc <= '1';		
       else
         AdrInc <= '0';
	    end if;
								 
  when others => n_s <= s0;
                 AdrInc <= '0';
					  Waste <= '1';
					  updateConf <= '1';
					  resetCnt <= '1';
					  n_sync <= '0';
end case;

end process;

end Behavioral;
