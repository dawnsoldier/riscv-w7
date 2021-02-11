-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.configure.all;
use work.wire.all;

entity arbiter is
	port(
		reset        : in  std_logic;
		clock        : in  std_logic;
		ibus_i       : in  mem_in_type;
		ibus_o       : out mem_out_type;
		dbus_i       : in  mem_in_type;
		dbus_o       : out mem_out_type;
		memory_valid : out std_logic;
		memory_ready : in  std_logic;
		memory_instr : out std_logic;
		memory_addr  : out std_logic_vector(63 downto 0);
		memory_wdata : out std_logic_vector(63 downto 0);
		memory_wstrb : out std_logic_vector(7 downto 0);
		memory_rdata : in  std_logic_vector(63 downto 0)
	);
end arbiter;

architecture behavior of arbiter is

constant instr_access : std_logic := '0';
constant data_access  : std_logic := '1';

signal access_type  : std_logic := instr_access;
signal release_type : std_logic := instr_access;

begin

	process(ibus_i,dbus_i,memory_ready,memory_rdata,access_type,release_type)

	begin

		if dbus_i.mem_valid = '1' then
			access_type <= data_access;
		else
			access_type <= instr_access;
		end if;

		if release_type = data_access and memory_ready = '0' then
			memory_valid <= '0';
			memory_instr <= '0';
			memory_addr <= (others => '0');
			memory_wdata <= (others => '0');
			memory_wstrb <= (others => '0');
		else
			if access_type = instr_access then
				memory_valid <= ibus_i.mem_valid;
				memory_instr <= ibus_i.mem_instr;
				memory_addr <= ibus_i.mem_addr;
				memory_wdata <= ibus_i.mem_wdata;
				memory_wstrb <= ibus_i.mem_wstrb;
			else
				memory_valid <= dbus_i.mem_valid;
				memory_instr <= dbus_i.mem_instr;
				memory_addr <= dbus_i.mem_addr;
				memory_wdata <= dbus_i.mem_wdata;
				memory_wstrb <= dbus_i.mem_wstrb;
			end if;
		end if;

		if release_type = instr_access then
			ibus_o.mem_busy  <= '0';
			ibus_o.mem_flush <= '0';
			ibus_o.mem_ready <= memory_ready;
			ibus_o.mem_rdata <= memory_rdata;
		else
			ibus_o.mem_busy  <= '0';
			ibus_o.mem_flush <= '0';
			ibus_o.mem_ready <= '0';
			ibus_o.mem_rdata <= (others => '0');
		end if;

		if release_type = data_access then
			dbus_o.mem_busy  <= '0';
			dbus_o.mem_flush <= '0';
			dbus_o.mem_ready <= memory_ready;
			dbus_o.mem_rdata <= memory_rdata;
		else
			dbus_o.mem_busy  <= '0';
			dbus_o.mem_flush <= '0';
			dbus_o.mem_ready <= '0';
			dbus_o.mem_rdata <= (others => '0');
		end if;

	end process;

	process(clock)

	begin

		if rising_edge(clock) then

			if reset = '0' then
				release_type <= instr_access;
			else
				if release_type = instr_access then
					if access_type = data_access then
						release_type <= data_access;
					end if;
				elsif release_type = data_access then
					if memory_ready = '1' and access_type = instr_access then
						release_type <= instr_access;
					end if;
				end if;

			end if;

		end if;

	end process;

end architecture;
