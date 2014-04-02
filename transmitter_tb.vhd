library ieee;
use ieee.std_logic_1164.all;

entity transmitter_tb is
end entity;

architecture testbench of transmitter_tb is
  
component transmitter is 
port(
  clk1: in std_logic; -- The faster clock, must be a multiple of 2 of clk2, which is 12.88 MHz
  clk2: in std_logic; -- The codec clock
  rst: in std_logic; -- hard reset trigger
  sync: out std_logic; -- syncing signal
  lineOut: out std_logic; -- going to the codec, falling edge reading
  lineIn: in std_logic; --coming from the codec, rising edge sent
  hardReset: out std_logic --hard reset going to codec
);
end component;

-- Inputs
signal clk1,clk2,rst,lineIn: std_logic:='0';

-- Outputs
signal sync,lineOut,hardReset:std_logic:='0';

begin
  
-- 100 MHz clock
clock1: process begin
  clk1 <= not clk1 after 10 ns;
end process;

-- 12.288 MHz clock
clock2: process begin
  clk2 <= not clk2 after 81.38 ns;
end process;
  
-- rst signal
reset: process begin
  rst <= '1';
  wait for 100 ns;
  rst <= '0';
  wait;
end process;

--lineIn
lineIn <= '0'; --  For now until receiver
  
  
t1: transmitter port map(
  clk1, -- The faster clock, must be a multiple of 2 of clk2, which is 12.88 MHz
  clk2, -- The codec clock
  rst, -- hard reset trigger
  sync, -- syncing signal
  lineOut, -- going to the codec, falling edge reading
  lineIn, --coming from the codec, rising edge sent
  hardReset--hard reset going to codec
);

end testbench;
  
  
  