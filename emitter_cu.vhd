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
type state is (s0,s1,s2,s3);
signal cnt,slotChk: natural:=0;
signal s,n_s: state:=s0;
signal conf: std_logic_vector(15 downto 0);
signal updateConf,resetCnt:std_logic:='0';

begin

stdCnt <= std_logic_vector(to_unsigned((cnt),5));

process(s,n_s,clk,reset,dataIn,cnt) 
begin

--State selection
  if(reset = '1') then
    s<= s0;
    cnt<= 0;
  elsif(rising_edge(clk)) then
    s <= n_s;

--Configuration
  if(updateConf = '1') then
    conf <= dataIn;
  end if;

--Counter
  if(resetCnt = '1') then
    cnt <= 0;
  else
    cnt <= cnt +1;
  end if;

--Slot validity Check, necessary for address incrementation.
  if(s=s0 or s=s1 or s=s2) then
    slotChk <= 1;
  elsif(s = s3 and cnt = 19) then
    slotChk <= slotChk +1;
  end if;
  
end if;


case s is
  when s0 => if(conf(15) = '1') then  -- Valid frame
               n_s <= s1;
               AdrInc <= '0';
			       elsif(conf(15) = '0') then
				       AdrInc <= '1'; -- Not a valid frame, increment address, find a valid tag
				       n_s <= s0;
				     else
				       AdrInc <= '0';
			       end if;
			       Waste <= '1';
				     updateConf <= '1';
				     resetCnt <= '1';
				 --Outputs derived from s0
				 Sync <= '0';
				 
  when s1 => n_s <= s2; --Pre frame Sync signal
             AdrInc <= '0';
             --Derived outputs
             Sync <= '1';
				     Waste <= '1';
				     updateConf <= '0';
				     resetCnt <= '1';
  when s2 => if(cnt = 15) then -- If cnt is 15, prepare for next Slot at next rising edge
               n_s <= s3; --Tag is the only 16 bit slot, syncing is over
					     AdrInc <= '1';
					     Sync <= '0';
               resetCnt <= '1';
             elsif(cnt = 0) then
               updateConf <= '1';
               resetCnt <= '0';
               Sync <= '1';
               AdrInc <= '0';
					   else
					     updateConf <= '0';
					     resetCnt <= '0';
					     Sync <= '1';  -- Keep Sync up
					     AdrInc <= '0';
			       end if;
				     Waste <= '0';
  when s3 => 
    
        -- Next state is s2, we can skip 0,1
        if(slotChk = 12 and cnt = 19) then -- Maximum of slot for this board, for stereo outputs
                 n_s <= s2;
				 end if;
				
				 --Sync control
				 if(slotChk = 12 and cnt = 19) then
				   Sync <= '1';
				 else
				   Sync <= '0';
				 end if;
				 
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
end case;

end process;

end Behavioral;

