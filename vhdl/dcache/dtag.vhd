-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.configure.all;
use work.constants.all;
use work.dwire.all;

entity dtag is
	generic(
		cache_sets  : integer;
		cache_ways  : integer;
		cache_words : integer
	);
	port(
		reset : in  std_logic;
		clock : in  std_logic;
		tag_i : in  dtag_in_type;
		tag_o : out dtag_out_type
	);
end dtag;

architecture behavior of dtag is

	type tag_type is array (0 to 2**cache_sets-1) of std_logic_vector(60-(cache_sets+cache_words) downto 0);

	signal tag_array : tag_type := (others => (others => '0'));

	signal rdata : std_logic_vector(60-(cache_sets+cache_words) downto 0) := (others => '0');

begin

	tag_o.rdata <= rdata;

	process(clock)

	begin

		if rising_edge(clock) then

			if tag_i.wen = '1' then
				tag_array(tag_i.waddr) <= tag_i.wdata;
			end if;

			rdata <= tag_array(tag_i.raddr);

		end if;

	end process;

end architecture;
