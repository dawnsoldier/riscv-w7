-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.configure.all;
use work.constants.all;
use work.wire.all;

entity tag is
	generic(
		set_depth  : integer := set_depth
	);
	port(
		reset : in  std_logic;
		clock : in  std_logic;
		tag_i : in  tag_in_type;
		tag_o : out tag_out_type
	);
end tag;

architecture behavior of tag is

	type tag_type is array (0 to 2**set_depth-1) of std_logic_vector(58-set_depth downto 0);

	signal tag_array : tag_type := (others => (others => '0'));

begin

	tag_o.rdata <= tag_array(tag_i.raddr);

	process(clock)

	begin

		if rising_edge(clock) then

			if tag_i.wen = '1' then
				tag_array(tag_i.waddr) <= tag_i.wdata;
			end if;

		end if;

	end process;

end architecture;
