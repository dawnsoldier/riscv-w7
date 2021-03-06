-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

entity testbench is
end entity testbench;

architecture behavior of testbench is

	component soc
		port(
			reset   : in  std_logic;
			clock   : in  std_logic;
			uart_rx : in  std_logic;
			uart_tx : out std_logic
		);
	end component;

	component gsr
		port(
			gsr : in std_ulogic
		);
	end component;

	component pur
		port(
			pur : in std_ulogic
		);
	end component;

	signal reset   : std_logic := '0';
	signal clock   : std_logic := '0';

	signal uart_rx : std_logic := '1';
	signal uart_tx : std_logic := '1';

begin

	reset <= '1' after 100 ns;
	clock <= not clock after 2.5 ns;

	soc_comp : soc
		port map(
			reset   => reset,
			clock   => clock,
			uart_rx => uart_rx,
			uart_tx => uart_tx
		);

	gsr_inst : gsr
		port map(
			gsr => '1'
		);

	pur_inst : pur
		port map(
			pur => '1'
		);

end architecture;
