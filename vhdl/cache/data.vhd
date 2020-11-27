-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.configure.all;
use work.constants.all;
use work.wire.all;

entity data is
	generic(
		set_depth  : integer := set_depth
	);
	port(
		reset  : in  std_logic;
		clock  : in  std_logic;
		data_i : in  data_in_type;
		data_o : out data_out_type
	);
end data;

architecture behavior of data is

	type data_type is array (0 to 2**set_depth-1) of std_logic_vector(255 downto 0);

	signal data_array : data_type := (others => (others => '0'));

begin

	data_o.rdata <= data_array(data_i.raddr);

	process(clock)

	begin

	if rising_edge(clock) then

		if data_i.wen = '1' then
			data_array(data_i.waddr) <= data_i.wdata;
		end if;

	end if;

	end process;

end architecture;
