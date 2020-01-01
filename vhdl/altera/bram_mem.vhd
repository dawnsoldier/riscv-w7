-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;

entity bram_mem is
	generic(
		bram_depth : integer := bram_depth
	);
	port(
		reset     : in  std_logic;
		clock     : in  std_logic;
		-- Memory Interface
		mem_valid : in  std_logic;
		mem_ready : out std_logic;
		mem_instr : in  std_logic;
		mem_addr  : in  std_logic_vector(63 downto 0);
		mem_wdata : in  std_logic_vector(63 downto 0);
		mem_wstrb : in  std_logic_vector(7 downto 0);
		mem_rdata : out std_logic_vector(63 downto 0)
	);
end bram_mem;

architecture behavior of bram_mem is

	type memory_type is array (0 to 2**bram_depth-1) of std_logic_vector(63 downto 0);

	signal memory_block : memory_type := (others => (others => '0'));

	attribute ram_style : string;

	signal rdata : std_logic_vector(63 downto 0) := (others => '0');
	signal ready : std_logic := '0';

begin

	mem_rdata <= rdata;
	mem_ready <= ready;

	process(clock)
	begin

		if rising_edge(clock) then

			if mem_valid = '1' then

				rdata <= memory_block(to_integer(unsigned(mem_addr(27 downto 3))));
				ready <= '1';

			else

				ready <= '0';

			end if;

		end if;

	end process;

end architecture;
