-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;
use std.textio.all;

use work.configure.all;
use work.constants.all;
use work.wire.all;

entity top_cpu is
end entity top_cpu;

architecture behavior of top_cpu is

	component cpu
		port(
			reset : in  std_logic;
			clock : in  std_logic;
			rtc   : in  std_logic
		);
	end component;

	signal reset : std_logic := '0';
	signal clock : std_logic := '0';
	signal rtc   : std_logic := '0';

begin

	reset <= '1' after 10 ns;
	clock <= not clock after 1 ns;
	rtc <= not rtc after 30517578.125 ps;

	cpu_comp : cpu
		port map(
			reset => reset,
			clock => clock,
			rtc   => rtc
		);

end architecture;
