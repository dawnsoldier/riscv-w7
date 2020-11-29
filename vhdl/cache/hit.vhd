-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.configure.all;
use work.constants.all;
use work.wire.all;

entity hit is
	generic(
		icache_set_depth : integer := icache_set_depth
	);
	port(
		reset : in  std_logic;
		clock : in  std_logic;
		hit_i : in  hit_in_type;
		hit_o : out hit_out_type
	);
end hit;

architecture behavior of hit is

	signal valid : std_logic_vector(7 downto 0) := (others => '0');

begin

	valid(0) <= hit_i.valid(0) and and_reduce(hit_i.tag xnor hit_i.tag0);
	valid(1) <= hit_i.valid(1) and and_reduce(hit_i.tag xnor hit_i.tag1);
	valid(2) <= hit_i.valid(2) and and_reduce(hit_i.tag xnor hit_i.tag2);
	valid(3) <= hit_i.valid(3) and and_reduce(hit_i.tag xnor hit_i.tag3);
	valid(4) <= hit_i.valid(4) and and_reduce(hit_i.tag xnor hit_i.tag4);
	valid(5) <= hit_i.valid(5) and and_reduce(hit_i.tag xnor hit_i.tag5);
	valid(6) <= hit_i.valid(6) and and_reduce(hit_i.tag xnor hit_i.tag6);
	valid(7) <= hit_i.valid(7) and and_reduce(hit_i.tag xnor hit_i.tag7);

	hit_o.hit <= or_reduce(valid);
	hit_o.miss <= nor_reduce(valid);
	hit_o.wid <= 0 when valid(0) = '1' else
	             1 when valid(1) = '1' else
	             2 when valid(2) = '1' else
	             3 when valid(3) = '1' else
	             4 when valid(4) = '1' else
	             5 when valid(5) = '1' else
	             6 when valid(6) = '1' else
	             7 when valid(7) = '1' else 0;

end architecture;
