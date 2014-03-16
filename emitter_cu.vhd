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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity emitter_cu is
port(
	dataIn: in std_logic_vector(0 to 15);
	sync,AdrInc,Waste,stdCnt: out std_logic;
	clk,reset: in std_logic
);
end emitter_cu;

architecture Behavioral of emitter_cu is
type state is (s0,s1,s2,s3);
signal cnt: integer;

begin

stdCnt <= std_logic_vector(to_unsigned((cnt),5));

process(clk,reset,dataIn,cnt) 
variable s,n_s: state:=state0;
variable conf: std_logic_vector(0 to 15);
variable slotChk: integer :=0;
begin

if(rising_edge(clk)) then

--State selection
  if(reset = '0') then
    s := n_s;
  else
    s:= s0;
  end if;

--Configuration
  if(s = s0) then
    conf := dataIn;
  end if;

--Counter
  if(((s = s2 )and cnt < 15) or ((s=s3) and cnt <19)) then
    cnt <= cnt +1;
  else
    cnt <= 0;
  end if;

--Slot validity Check, necessary for address incrementation.
  if(s=s0 or s=s1) then
    slotChk := 1;
  elsif((s = s3 and cnt = 19) or (s=s2 and cnt = 15)) then
    slotChk := slotChk +1;
  end if;
  
end if;


case s is
  when s0 => if(conf(0) = '1') then  -- Valid frame
               n_s := s_1;
			    else
				   AdrInc <= '1'; -- Not a valid frame, increment address, find a valid tag
				   n_s := s_0;
			    end if;
				 
				 --Outputs derived from s0
				 Sync <= '0';
				 
  when s1 => n_s := s_2; --Pre frame Sync signal
  
             --Derived outputs
             Sync <= '1';
				 
  when s2 => if(cnt = 15) then -- If cnt is 15, prepare for next Slot at next rising edge
               n_s := s3; --Tag is the only 16 bit slot, syncing is over
					AdrInc <= '1';
			    end if;
				 Sync <= '1';  -- Keep Sync up
				 
  when s3 => if(slotChk = 12 and cnt = 19) then -- Maximum of slot for this board, for stereo outputs
                     n_s := s0;
				 elsif(((conf AND "0111100000000000") = "0111000000000000") and slotChk = 4) then -- not very elegant, I know
				         n_s := s0;
				 elsif(((conf AND "0111100000000000") = "0110000000000000") and slotChk = 3) then -- But it's simple, easy to understand
				         n_s := s0;
				 elsif(((conf AND "0111100000000000") = "0100000000000000") and slotChk = 2) then -- Basically, if current slot is not valid, and none are valid after
                     n_s := s0;
				 elsif(((conf AND "0111100000000000") = "0000000000000000") and slotChk = 1) then -- Go back to State 0
				         n_s := s0;
				 end if;
				 
				 --Derived outputs
				 Sync <= '0';
				 
				 if(conf(slotChk) = '0' or slotChk > 4) then -- If the current slot is invalid, waste it
				   Waste <= '1';
			    else 
				   Waste <= '0';
			    end if;
				 
				 if(slotChk <5 and cnt = 19) then -- We never increase address when we're processing slots over the max 5
					 if(conf(slotChk+1) = '1') then -- End of slot, process next valid slot, which is in memmory
						 AdrInc <= '1';
					 end if;
				 elsif(slotChk = 12 and cnt = 19) then -- Last wasted slot, increase address for next tag
				    AdrInc<='1';
             else
                AdrInc <= '0';				 
				 end if;
								 
  when others => n_s := s0;
end case;

end process;

end Behavioral;

