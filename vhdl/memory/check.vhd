-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.configure.all;
use work.wire.all;

library std;
use std.textio.all;
use std.env.all;

entity check is
	port(
		reset       : in  std_logic;
		clock       : in  std_logic;
		check_valid : in  std_logic;
		check_ready : out std_logic;
		check_instr : in  std_logic;
		check_addr  : in  std_logic_vector(63 downto 0);
		check_wdata : in  std_logic_vector(63 downto 0);
		check_wstrb : in  std_logic_vector(7 downto 0);
		check_rdata : out std_logic_vector(63 downto 0)
	);
end check;

architecture behavior of check is

	type host_type is array (0 to 0) of std_logic_vector(63 downto 0);

	impure function init_host(
		file_name : in string
	)
	return host_type is
		file host_file      : text open read_mode is file_name;
		variable host_line  : line;
		variable host_block : host_type;
	begin
		readline(host_file, host_line);
		hread(host_line, host_block(0));
		return host_block;
	end function;

	procedure check_out(
		host : in std_logic_vector(63 downto 0);
		addr : in std_logic_vector(63 downto 0);
		strb : in std_logic_vector(7 downto 0);
		data : in std_logic_vector(63 downto 0)) is
		variable buf : line;
		variable ok : std_logic;
		constant succ : string := "TEST SUCCEEDED";
		constant fail : string := "TEST FAILED";
	begin
		ok := '0';
		if (addr = host) and (or_reduce(strb) = '1') then
			ok := '1';
		end if;
		if ok = '1' then
			if data(31 downto 0) = X"00000001" then
				write(buf, succ);
				writeline(output, buf);
				finish;
			elsif or_reduce(data(31 downto 0)) = '1' then
				write(buf, fail);
				writeline(output, buf);
				finish;
			end if;
		end if;
	end procedure check_out;

	procedure exceed is
		variable buf : line;
		constant exc : string := "ADDRESS EXCEEDS MEMORY";
	begin
		write(buf, exc);
		writeline(output, buf);
		finish;
	end procedure exceed;

	signal host_block : host_type := init_host("host.dat");

begin

	process (clock)

	begin

		if rising_edge(clock) then
		 	if check_valid = '1' then
				check_out(host_block(0),check_addr,check_wstrb,check_wdata);
			end if;
		end if;

	end process;

end architecture;
