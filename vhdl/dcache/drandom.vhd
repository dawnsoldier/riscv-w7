-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.configure.all;
use work.constants.all;
use work.dwire.all;

entity drandom is
	generic(
		cache_sets  : integer;
		cache_ways  : integer;
		cache_words : integer
	);
	port(
		reset     : in  std_logic;
		clock     : in  std_logic;
		drandom_i : in  drandom_in_type;
		drandom_o : out drandom_out_type
	);
end drandom;

architecture behavior of drandom is

	signal count : std_logic_vector(2**cache_ways-1 downto 0) := (others => '0');

	signal feedback : std_logic;

begin

	COUNT_2 : if cache_ways=1 generate

		feedback <= not(count(2**cache_ways-1) xor count(2**cache_ways-2));

	end generate COUNT_2;

	COUNT_4 : if cache_ways=2 generate

		feedback <= not(count(2**cache_ways-1) xor count(2**cache_ways-2));

	end generate COUNT_4;

	COUNT_8 : if cache_ways=3 generate

		feedback <= not(count(2**cache_ways-1) xor count(2**cache_ways-3) xor count(2**cache_ways-4) xor count(2**cache_ways-5));

	end generate COUNT_8;

	COUNT_16 : if cache_ways=4 generate

		feedback <= not(count(2**cache_ways-1) xor count(2**cache_ways-2) xor count(2**cache_ways-4) xor count(2**cache_ways-13));

	end generate COUNT_16;

	COUNT_32 : if cache_ways=5 generate

		feedback <= not(count(2**cache_ways-1) xor count(2**cache_ways-11) xor count(2**cache_ways-31) xor count(2**cache_ways-32));

	end generate COUNT_32;

	COUNT_64 : if cache_ways=6 generate

		feedback <= not(count(2**cache_ways-1) xor count(2**cache_ways-2) xor count(2**cache_ways-4) xor count(2**cache_ways-5));

	end generate COUNT_64;

	COUNT_128 : if cache_ways=7 generate

		feedback <= not(count(2**cache_ways-1) xor count(2**cache_ways-3) xor count(2**cache_ways-28) xor count(2**cache_ways-30));

	end generate COUNT_128;

	process(clock)

	begin

		if rising_edge(clock) then

			if reset = '0' then

				count <= (others => '0');

			else

				if drandom_i.miss = '1' then
					count <= count(2**cache_ways-2 downto 0) & feedback;
				end if;

			end if;

		end if;

	end process;

	drandom_o.wid <= to_integer(unsigned(count));

end architecture;
