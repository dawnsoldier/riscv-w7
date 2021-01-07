-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.configure.all;
use work.constants.all;
use work.wire.all;

entity lru is
	generic(
		cache_type      : integer;
		cache_set_depth : integer
	);
	port(
		reset   : in  std_logic;
		clock   : in  std_logic;
		lru_i : in  lru_in_type;
		lru_o : out lru_out_type
	);
end lru;

architecture behavior of lru is

	type lru_type is array (0 to 2**cache_set_depth-1) of std_logic_vector(7 downto 0);

	signal lru_array : lru_type := (others => (others => '0'));

	signal rdata : std_logic_vector(7 downto 0) := (others => '0');

begin

	lru_o.rdata <= lru_array(lru_i.raddr);

	process(clock)

	begin

		if rising_edge(clock) then

			if lru_i.wen = '1' then
				lru_array(lru_i.waddr) <= lru_i.wdata;
			end if;

		end if;

	end process;

end architecture;
