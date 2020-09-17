-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use ieee.std_logic_misc.all;

use work.configure.all;

library std;
use std.textio.all;

entity bram_mem is
	generic(
		bram_depth : integer := bram_depth
	);
	port(
		reset      : in  std_logic;
		clock      : in  std_logic;
		-- BRAM Interface
		bram_valid : in  std_logic;
		bram_ready : out std_logic;
		bram_instr : in  std_logic;
		bram_addr  : in  std_logic_vector(63 downto 0);
		bram_wdata : in  std_logic_vector(63 downto 0);
		bram_wstrb : in  std_logic_vector(7 downto 0);
		bram_rdata : out std_logic_vector(63 downto 0)
	);
end bram_mem;

architecture behavior of bram_mem is

	type memory_type is array (0 to 2**bram_depth-1) of std_logic_vector(63 downto 0);

	impure function init_memory(
		file_name : in string
	)
	return memory_type is
		file memory_file      : text open read_mode is file_name;
		variable memory_line  : line;
		variable memory_block : memory_type;
	begin
		for i in 0 to 2**bram_depth-1 loop
			readline(memory_file, memory_line);
			hread(memory_line, memory_block(i));
		end loop;
		return memory_block;
	end function;

	signal memory_block : memory_type := init_memory("bram_mem.dat");

	attribute ram_style : string;
	attribute ram_style of memory_block : signal is "block";

	signal rdata : std_logic_vector(63 downto 0) := (others => '0');
	signal ready : std_logic := '0';

begin

	bram_rdata <= rdata;
	bram_ready <= ready;

	process(clock)
		variable maddr : natural range 0 to 2**bram_depth-1;
	begin

		if rising_edge(clock) then

			if bram_valid = '1' then

				maddr := to_integer(unsigned(bram_addr(27 downto 3)));

				if bram_wstrb(7) = '1' then
					memory_block(maddr)(63 downto 56) <= bram_wdata(63 downto 56);
				end if;
				if bram_wstrb(6) = '1' then
					memory_block(maddr)(55 downto 48) <= bram_wdata(55 downto 48);
				end if;
				if bram_wstrb(5) = '1' then
					memory_block(maddr)(47 downto 40) <= bram_wdata(47 downto 40);
				end if;
				if bram_wstrb(4) = '1' then
					memory_block(maddr)(39 downto 32) <= bram_wdata(39 downto 32);
				end if;
				if bram_wstrb(3) = '1' then
					memory_block(maddr)(31 downto 24) <= bram_wdata(31 downto 24);
				end if;
				if bram_wstrb(2) = '1' then
					memory_block(maddr)(23 downto 16) <= bram_wdata(23 downto 16);
				end if;
				if bram_wstrb(1) = '1' then
					memory_block(maddr)(15 downto 8) <= bram_wdata(15 downto 8);
				end if;
				if bram_wstrb(0) = '1' then
					memory_block(maddr)(7 downto 0) <= bram_wdata(7 downto 0);
				end if;

				rdata <= memory_block(maddr);
				ready <= '1';

			else

				ready <= '0';

			end if;

		end if;

	end process;

end architecture;
