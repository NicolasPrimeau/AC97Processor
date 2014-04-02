----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:53:01 03/08/2014 
-- Design Name: 
-- Module Name:    sound - Behavioral 
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
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use IEEE.math_real.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity transmitter is
port(
  clk1: in std_logic; -- The faster clock, must be a multiple of 2 of clk2, which is 12.88 MHz
  clk2: in std_logic; -- The codec clock
  rst: in std_logic; -- hard reset trigger
  sync: out std_logic; -- syncing signal
  lineOut: out std_logic; -- going to the codec, falling edge reading
  lineIn: in std_logic; --coming from the codec, rising edge sent
  hardReset: out std_logic --hard reset going to codec
);
end transmitter;

architecture Behavioral of transmitter is

component emitter is -- Emitter sends out on falling edge, everything must work on rising edge
port(
  dataIn: in std_logic_vector(19 downto 0);
  adr: out natural;
  sync,lineOut: out std_logic;
  clk,rst: in std_logic -- Clock is the 12.288 MHz
);
end component;

component Mem_Async is -- Single memory buffer between emitter and receiver, address must be stable
generic(memSize: integer:=8;
        numAdr: integer:=32);
port(
	dataIn: in std_logic_vector(memSize -1 downto 0);
	dataOut: out std_logic_vector(memSize-1 downto 0);
	addr: in natural;
	rd_wr: in std_logic; -- rd low, wr high
	reset: in std_logic
);
end component;

component debounce is
generic(timeOut: integer:=2000000);
port(
	input: in std_logic;
	clk: in std_logic;
	output: out std_logic
);
end component;

--Missing receiver

--Memory signals
signal mDataIn,mDataOut: std_logic_vector(19 downto 0); -- data output of memory
signal emit_rcv: std_logic:='0';
signal curAdr: natural:=0; -- Current address

--Emitter signals
signal eAdr: natural:=0; -- Emitter address

--Receiver signals
signal rAdr: natural:=0; --  Receiver address

--Debounce
signal reset:std_logic:='0';
signal resetFlag: std_logic:='0';

--Temp testing
--signal trst: std_logic:='0'; 

begin
  
--rst1: process begin
--  trst <= '1';
--  wait for 100 ns;
--  trst <= '0';
--  wait;
--end process;

curAdr <= eAdr; -- For now
hardReset <= reset;

mDataIn(19 downto 0) <= (others=>'0');
emit_rcv <= '0';

--testing
--reset <= trst;

time: process (clk2,reset) is 
      variable cnt: natural:=0;
      begin
   if(reset = '1') then
     resetFlag <= '1';
   elsif(reset = '0' and resetFlag = '1') then 
     if(rising_edge(clk2)) then
       if(cnt = 20) then
         cnt := 0;
         resetFlag <= '0';
       else
         cnt := cnt +1;
       end if;
     end if;
    elsif(resetFlag = '0') then
        cnt := 0;
  end if;
end process;

rst_debounce: debounce port map(rst,clk1,reset);
memory: Mem_Async generic map(20,32) port map(mDataIn,mDataOut,curAdr,emit_rcv,resetFlag);
emitter1: emitter port map(mDataOut,eAdr,sync,lineOut,clk2,resetFlag);
--receiver

--take care of allocating mandatory resources to emitter and receiver every second clock2 cycle

end Behavioral;

