-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.configure.all;
use work.constants.all;
use work.dwire.all;

entity dlru is
	generic(
		cache_sets  : integer;
		cache_ways  : integer;
		cache_words : integer
	);
	port(
		reset : in  std_logic;
		clock : in  std_logic;
		lru_i : in  dlru_in_type;
		lru_o : out dlru_out_type
	);
end dlru;

architecture behavior of dlru is

	type lru_type is array (0 to 2**cache_sets-1) of std_logic_vector(2**icache_ways-1 downto 0);

	signal lru_array : lru_type := (others => (others => '0'));

	signal rdata : std_logic_vector(2**icache_ways-1 downto 0) := (others => '0');

begin

	lru_o.rdata <= rdata;

	process(clock)

	begin

		if rising_edge(clock) then

			if lru_i.wen = '1' then
				lru_array(lru_i.waddr) <= lru_i.wdata;
			end if;

			rdata <= lru_array(lru_i.raddr);

		end if;

	end process;

end architecture;
