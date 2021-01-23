-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.configure.all;
use work.constants.all;
use work.wire.all;

entity storram is
	generic(
		storbuffer_depth : integer := storbuffer_depth
	);
	port(
		reset     : in  std_logic;
		clock     : in  std_logic;
		storram_i : in  storram_in_type;
		storram_o : out storram_out_type
	);
end storram;

architecture behavior of storram is

	type ram_type is array (0 to 2**storbuffer_depth-1) of std_logic_vector(135 downto 0);

	signal storeram : ram_type := (others => (others => '0'));

begin

	storram_o.rdata <= storeram(storram_i.raddr);

	process(clock)

	begin

		if rising_edge(clock) then

			if storram_i.wren = '1' then
				storeram(storram_i.waddr) <= storram_i.wdata;
			end if;

		end if;

	end process;


end architecture;
