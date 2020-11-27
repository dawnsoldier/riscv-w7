-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.configure.all;
use work.constants.all;
use work.wire.all;

entity valid is
	generic(
		set_depth  : integer := set_depth
	);
	port(
		reset   : in  std_logic;
		clock   : in  std_logic;
		valid_i : in  valid_in_type;
		valid_o : out valid_out_type
	);
end valid;

architecture behavior of valid is

	type valid_type is array (0 to 2**set_depth-1) of std_logic_vector(7 downto 0);

	signal valid_array : valid_type := (others => (others => '0'));

begin

	valid_o.rdata <= valid_array(valid_i.raddr);

	process(clock)

	begin

		if rising_edge(clock) then

			if valid_i.wen = '1' then
				valid_array(valid_i.waddr) <= valid_i.wdata;
			end if;

		end if;

	end process;

end architecture;
