-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use ieee.std_logic_misc.all;

use work.configure.all;
use work.constants.all;
use work.fp_wire.all;
use work.wire.all;

library std;
use std.textio.all;
use std.env.all;

entity core is
	generic(
		fpu_enable      : boolean := fpu_enable;
		fpu_performance : boolean := fpu_performance
	);
	port(
		reset     : in  std_logic;
		clock     : in  std_logic;
		ibus_o    : in  mem_out_type;
		ibus_i    : out mem_in_type;
		dbus_o    : in  mem_out_type;
		dbus_i    : out mem_in_type;
		time_irpt : in  std_logic;
		ext_irpt  : in  std_logic
	);
end entity core;

architecture behavior of core is

	component pipeline
		port(
			reset     : in  std_logic;
			clock     : in  std_logic;
			imem_o    : in  mem_out_type;
			imem_i    : out mem_in_type;
			dmem_o    : in  mem_out_type;
			dmem_i    : out mem_in_type;
			ipmp_o    : in  pmp_out_type;
			ipmp_i    : out pmp_in_type;
			dpmp_o    : in  pmp_out_type;
			dpmp_i    : out pmp_in_type;
			fpu_o     : in  fpu_out_type;
			fpu_i     : out fpu_in_type;
			time_irpt : in  std_logic;
			ext_irpt  : in  std_logic
		);
	end component;

	component icache
		generic(
			cache_enable : boolean;
			cache_sets   : integer;
			cache_ways   : integer;
			cache_words  : integer
		);
		port(
			reset   : in  std_logic;
			clock   : in  std_logic;
			cache_i : in  mem_in_type;
			cache_o : out mem_out_type;
			mem_o   : in  mem_out_type;
			mem_i   : out mem_in_type
		);
	end component;

	component dcache
		generic(
			cache_enable : boolean;
			cache_sets   : integer;
			cache_ways   : integer;
			cache_words  : integer
		);
		port(
			reset   : in  std_logic;
			clock   : in  std_logic;
			cache_i : in  mem_in_type;
			cache_o : out mem_out_type;
			mem_o   : in  mem_out_type;
			mem_i   : out mem_in_type
		);
	end component;

	component pmp
		port(
			reset  : in  std_logic;
			clock  : in  std_logic;
			pmp_i  : in  pmp_in_type;
			pmp_o  : out pmp_out_type
		);
	end component;

	component fpu
		port(
			reset     : in  std_logic;
			clock     : in  std_logic;
			fpu_i     : in  fpu_in_type;
			fpu_o     : out fpu_out_type
		);
	end component;

	type access_type is (CACHE_ACCESS, IO_MEM_ACCESS, NO_ACCESS);
	type mode_type is (FREE,BUSY);

	type ireg_type is record
		acc_t    : access_type;
		mod_t    : mode_type;
		io_mem_o : mem_out_type;
		icache_i : mem_in_type;
		imem_o   : mem_out_type;
		ibus_i   : mem_in_type;
	end record;

	constant init_ireg : ireg_type := (
		acc_t    => CACHE_ACCESS,
		mod_t    => BUSY,
		io_mem_o => init_mem_out,
		icache_i => init_mem_in,
		imem_o   => init_mem_out,
		ibus_i   => init_mem_in
	);

	type dreg_type is record
		acc_t    : access_type;
		mod_t    : mode_type;
		do_mem_o : mem_out_type;
		dcache_i : mem_in_type;
		dmem_o   : mem_out_type;
		dbus_i   : mem_in_type;
	end record;

	constant init_dreg : dreg_type := (
		acc_t    => CACHE_ACCESS,
		mod_t    => BUSY,
		do_mem_o => init_mem_out,
		dcache_i => init_mem_in,
		dmem_o   => init_mem_out,
		dbus_i   => init_mem_in
	);

	signal icache_i : mem_in_type;
	signal icache_o : mem_out_type;
	signal dcache_i : mem_in_type;
	signal dcache_o : mem_out_type;

	signal imem_i : mem_in_type;
	signal imem_o : mem_out_type;
	signal dmem_i : mem_in_type;
	signal dmem_o : mem_out_type;

	signal io_mem_i : mem_in_type;
	signal io_mem_o : mem_out_type;
	signal do_mem_i : mem_in_type;
	signal do_mem_o : mem_out_type;

	signal ipmp_i : pmp_in_type;
	signal ipmp_o : pmp_out_type;
	signal dpmp_i : pmp_in_type;
	signal dpmp_o : pmp_out_type;

	signal fpu_o : fpu_out_type;
	signal fpu_i : fpu_in_type;

	signal ir, irin : ireg_type := init_ireg;
	signal dr, drin : dreg_type := init_dreg;

begin

	process(ir,imem_i,io_mem_i,icache_o,ibus_o)

	variable v : ireg_type;

	begin

		v := ir;

		if v.mod_t = BUSY then
			if v.acc_t = CACHE_ACCESS then
				if icache_o.mem_ready = '1' then
					v.mod_t := FREE;
				end if;
				v.imem_o := icache_o;
				v.ibus_i := io_mem_i;
				v.io_mem_o := ibus_o;
			elsif v.acc_t = IO_MEM_ACCESS then
				if ibus_o.mem_ready = '1' then
					v.mod_t := FREE;
				end if;
				v.imem_o := ibus_o;
				v.ibus_i := imem_i;
				v.io_mem_o := init_mem_out;
			else
				v.imem_o := init_mem_out;
				v.ibus_i := init_mem_in;
				v.io_mem_o := init_mem_out;
			end if;
		else
			v.imem_o := init_mem_out;
			v.ibus_i := init_mem_in;
			v.io_mem_o := init_mem_out;
		end if;

		if v.mod_t = FREE then
			if imem_i.mem_valid = '1' then
				if (unsigned(imem_i.mem_addr) >= unsigned(cache_base_addr) and
						unsigned(imem_i.mem_addr) < unsigned(cache_top_addr)) then
					v.acc_t := CACHE_ACCESS;
					v.mod_t := BUSY;
					v.icache_i := imem_i;
					v.ibus_i := init_mem_in;
				elsif imem_i.mem_invalid = '1' then
					v.acc_t := CACHE_ACCESS;
					v.mod_t := BUSY;
					v.icache_i := imem_i;
					v.ibus_i := init_mem_in;
				else
					v.acc_t := IO_MEM_ACCESS;
					v.mod_t := BUSY;
					v.icache_i := init_mem_in;
					v.ibus_i := imem_i;
				end if;
			else
				v.acc_t := NO_ACCESS;
				v.mod_t := FREE;
				v.icache_i := init_mem_in;
				v.ibus_i := init_mem_in;
			end if;
		else
			v.icache_i := init_mem_in;
		end if;

		icache_i <= v.icache_i;
		ibus_i <= v.ibus_i;
		imem_o <= v.imem_o;
		io_mem_o <= v.io_mem_o;


		irin <= v;

	end process;

	process (clock)

	begin

		if rising_edge(clock) then
			if reset = '0' then
				ir <= init_ireg;
			else
				ir <= irin;
			end if;
		end if;

	end process;

	process(dr,dmem_i,do_mem_i,dcache_o,dbus_o)

	variable v : dreg_type;

	begin

		v := dr;

		if v.mod_t = BUSY then
			if v.acc_t = CACHE_ACCESS then
				if dcache_o.mem_ready = '1' then
					v.mod_t := FREE;
				end if;
				v.dmem_o := dcache_o;
				v.dbus_i := do_mem_i;
				v.do_mem_o := dbus_o;
			elsif v.acc_t = IO_MEM_ACCESS then
				if dbus_o.mem_ready = '1' then
					v.mod_t := FREE;
				end if;
				v.dmem_o := dbus_o;
				v.dbus_i := dmem_i;
				v.do_mem_o := init_mem_out;
			else
				v.dmem_o := init_mem_out;
				v.dbus_i := init_mem_in;
				v.do_mem_o := init_mem_out;
			end if;
		else
			v.dmem_o := init_mem_out;
			v.dbus_i := init_mem_in;
			v.do_mem_o := init_mem_out;
		end if;

		if v.mod_t = FREE then
			if dmem_i.mem_valid = '1' then
				if (unsigned(dmem_i.mem_addr) >= unsigned(cache_base_addr) and
						unsigned(dmem_i.mem_addr) < unsigned(cache_top_addr)) then
					v.acc_t := CACHE_ACCESS;
					v.mod_t := BUSY;
					v.dcache_i := dmem_i;
					v.dbus_i := init_mem_in;
				elsif dmem_i.mem_invalid = '1' then
					v.acc_t := CACHE_ACCESS;
					v.mod_t := BUSY;
					v.dcache_i := dmem_i;
					v.dbus_i := init_mem_in;
				else
					v.acc_t := IO_MEM_ACCESS;
					v.mod_t := BUSY;
					v.dcache_i := init_mem_in;
					v.dbus_i := dmem_i;
				end if;
			else
				v.acc_t := NO_ACCESS;
				v.mod_t := FREE;
				v.dcache_i := init_mem_in;
				v.dbus_i := init_mem_in;
			end if;
		else
			v.dcache_i := init_mem_in;
		end if;

		dcache_i <= v.dcache_i;
		dbus_i <= v.dbus_i;
		dmem_o <= v.dmem_o;
		do_mem_o <= v.do_mem_o;

		drin <= v;

	end process;

	process (clock)

	begin

		if rising_edge(clock) then
			if reset = '0' then
				dr <= init_dreg;
			else
				dr <= drin;
			end if;
		end if;

	end process;

	pipeline_comp : pipeline
		port map(
			reset     => reset,
			clock     => clock,
			imem_o    => imem_o,
			imem_i    => imem_i,
			dmem_o    => dmem_o,
			dmem_i    => dmem_i,
			ipmp_o    => ipmp_o,
			ipmp_i    => ipmp_i,
			dpmp_o    => dpmp_o,
			dpmp_i    => dpmp_i,
			fpu_o     => fpu_o,
			fpu_i     => fpu_i,
			time_irpt => time_irpt,
			ext_irpt  => '0'
		);

	icache_comp : icache
		generic map(
			cache_enable => icache_enable,
			cache_sets   => icache_sets,
			cache_ways   => icache_ways,
			cache_words  => icache_words
		)
		port map(
			reset   => reset,
			clock   => clock,
			cache_i => icache_i,
			cache_o => icache_o,
			mem_o   => io_mem_o,
			mem_i   => io_mem_i
		);

	dcache_comp : dcache
		generic map(
			cache_enable => dcache_enable,
			cache_sets   => dcache_sets,
			cache_ways   => dcache_ways,
			cache_words  => dcache_words
		)
		port map(
			reset   => reset,
			clock   => clock,
			cache_i => dcache_i,
			cache_o => dcache_o,
			mem_o   => do_mem_o,
			mem_i   => do_mem_i
		);

	ipmp_comp : pmp
		port map(
			reset  => reset,
			clock  => clock,
			pmp_i  => ipmp_i,
			pmp_o  => ipmp_o
		);

	dpmp_comp : pmp
		port map(
			reset  => reset,
			clock  => clock,
			pmp_i  => dpmp_i,
			pmp_o  => dpmp_o
		);

	FP_Unit : if fpu_enable = true generate

		fpu_comp : fpu
			port map(
				reset => reset,
				clock => clock,
				fpu_i => fpu_i,
				fpu_o => fpu_o
			);

	end generate FP_Unit;

end architecture;
