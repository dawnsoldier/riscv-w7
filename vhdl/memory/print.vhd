-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.configure.all;
use work.wire.all;

library std;
use std.textio.all;
use std.env.all;

entity print is
	port(
		reset       : in  std_logic;
		clock       : in  std_logic;
		print_valid : in  std_logic;
		print_instr : in  std_logic;
		print_addr  : in  std_logic_vector(63 downto 0);
		print_wdata : in  std_logic_vector(63 downto 0);
		print_wstrb : in  std_logic_vector(7 downto 0)
	);
end print;

architecture behavior of print is

	signal complete : std_logic := '0';
	signal massage  : string(1 to 511) := (others => character'val(0));
	signal index    : natural range 1 to 511 := 1;

	procedure print_out(
		signal info        : inout string(1 to 511);
		signal counter     : inout natural range 1 to 511;
		signal data        : in std_logic_vector(7 downto 0)) is
		variable buf       : line;
	begin
		if data = X"0A" then
			write(buf, info);
			writeline(output, buf);
			write(buf,integer'image(now/ 1 ns) & " ns");
			writeline(output, buf);
			info <= (others => character'val(0));
			counter <= 1;
		else
			info(counter) <= character'val(to_integer(unsigned(data)));
			counter <= counter + 1;
		end if;
	end procedure print_out;

begin

	process (clock)

	begin

		if rising_edge(clock) then
			if complete = '0' and print_valid = '1' and or_reduce(print_addr) = '0' and or_reduce(print_wstrb) = '1' then
				print_out(massage,index,print_wdata(7 downto 0));
			end if;
			if print_valid = '1' then
				complete <= '1';
			else
				complete <= '0';
			end if;
		end if;

	end process;

end architecture;
