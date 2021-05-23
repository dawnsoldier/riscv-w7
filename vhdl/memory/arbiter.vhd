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

type reg_type is record
	access_type  : std_logic;
	release_type : std_logic;
	imem_valid   : std_logic;
	imem_instr   : std_logic;
	imem_addr    : std_logic_vector(63 downto 0);
	imem_wdata   : std_logic_vector(63 downto 0);
	imem_wstrb   : std_logic_vector(7 downto 0);
	dmem_valid   : std_logic;
	dmem_instr   : std_logic;
	dmem_addr    : std_logic_vector(63 downto 0);
	dmem_wdata   : std_logic_vector(63 downto 0);
	dmem_wstrb   : std_logic_vector(7 downto 0);
	mem_valid    : std_logic;
	mem_instr    : std_logic;
	mem_addr     : std_logic_vector(63 downto 0);
	mem_wdata    : std_logic_vector(63 downto 0);
	mem_wstrb    : std_logic_vector(7 downto 0);
end record;

constant init_reg : reg_type := (
	access_type  => instr_access,
	release_type => instr_access,
	imem_valid   => '0',
	imem_instr   => '0',
	imem_addr    => (others => '0'),
	imem_wdata   => (others => '0'),
	imem_wstrb   => (others => '0'),
	dmem_valid   => '0',
	dmem_instr   => '0',
	dmem_addr    => (others => '0'),
	dmem_wdata   => (others => '0'),
	dmem_wstrb   => (others => '0'),
	mem_valid    => '1',
	mem_instr    => '1',
	mem_addr     => (others => '0'),
	mem_wdata    => (others => '0'),
	mem_wstrb    => (others => '0')
);

signal r,rin : reg_type := init_reg;

begin

	process(r,ibus_i,dbus_i,memory_ready,memory_rdata)

	variable v : reg_type;

	begin

		v := r;

		if memory_ready = '1' then
			if r.release_type = data_access then
				v.dmem_valid := '0';
			end if;
			if r.release_type = instr_access then
				v.imem_valid := '0';
			end if;
		end if;

		if dbus_i.mem_valid = '1' then
			v.dmem_valid := dbus_i.mem_valid;
			v.dmem_instr := dbus_i.mem_instr;
			v.dmem_addr := dbus_i.mem_addr;
			v.dmem_wdata := dbus_i.mem_wdata;
			v.dmem_wstrb := dbus_i.mem_wstrb;
		end if;

		if ibus_i.mem_valid = '1' then
			v.imem_valid := ibus_i.mem_valid;
			v.imem_instr := ibus_i.mem_instr;
			v.imem_addr := ibus_i.mem_addr;
			v.imem_wdata := ibus_i.mem_wdata;
			v.imem_wstrb := ibus_i.mem_wstrb;
		end if;

		if memory_ready = '1' then
			if v.dmem_valid = '1' then
				v.access_type := data_access;
				v.mem_valid := v.dmem_valid;
				v.mem_instr := v.dmem_instr;
				v.mem_addr := v.dmem_addr;
				v.mem_wdata := v.dmem_wdata;
				v.mem_wstrb := v.dmem_wstrb;
			elsif v.imem_valid = '1' then
				v.access_type := instr_access;
				v.mem_valid := v.imem_valid;
				v.mem_instr := v.imem_instr;
				v.mem_addr := v.imem_addr;
				v.mem_wdata := v.imem_wdata;
				v.mem_wstrb := v.imem_wstrb;
			end if;
		end if;

		if v.release_type = instr_access then
			if memory_ready = '1' and v.access_type = data_access then
				v.release_type := data_access;
			end if;
		elsif v.release_type = data_access then
			if memory_ready = '1' and v.access_type = instr_access then
				v.release_type := instr_access;
			end if;
		end if;

		memory_valid <= v.mem_valid;
		memory_instr <= v.mem_instr;
		memory_addr <= v.mem_addr;
		memory_wdata <= v.mem_wdata;
		memory_wstrb <= v.mem_wstrb;

		rin <= v;

		if r.release_type = instr_access then
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

		if r.release_type = data_access then
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

			if reset = reset_active then
				r <= init_reg;
			else
				r <= rin;
			end if;

		end if;

	end process;

end architecture;
