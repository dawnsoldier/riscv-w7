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

	signal pre_imem_access : access_type;
	signal pre_dmem_access : access_type;

	signal post_imem_access : access_type;
	signal post_dmem_access : access_type;

	signal icache_i : mem_in_type;
	signal icache_o : mem_out_type;
	signal dcache_i : mem_in_type;
	signal dcache_o : mem_out_type;

	signal imem_i : mem_in_type;
	signal imem_o : mem_out_type;
	signal dmem_i : mem_in_type;
	signal dmem_o : mem_out_type;

	signal io_mem_i : mem_in_type;
	signal do_mem_i : mem_in_type;

	signal ipmp_i : pmp_in_type;
	signal ipmp_o : pmp_out_type;
	signal dpmp_i : pmp_in_type;
	signal dpmp_o : pmp_out_type;

	signal fpu_o : fpu_out_type;
	signal fpu_i : fpu_in_type;

begin

	process(imem_i,io_mem_i,ibus_o,icache_i,icache_o,pre_imem_access,post_imem_access)

	begin

		if imem_i.mem_valid = '1' then
			if (unsigned(imem_i.mem_addr) >= unsigned(cache_base_addr) and
					unsigned(imem_i.mem_addr) < unsigned(cache_top_addr)) then
				icache_i.mem_valid <= '1';
				pre_imem_access <= CACHE_ACCESS;
			elsif imem_i.mem_invalid = '1' then
				icache_i.mem_valid <= '1';
				pre_imem_access <= CACHE_ACCESS;
			else
				icache_i.mem_valid <= '0';
				pre_imem_access <= IO_MEM_ACCESS;
			end if;
		else
			icache_i.mem_valid <= '0';
			pre_imem_access <= NO_ACCESS;
		end if;

		icache_i.mem_instr <= imem_i.mem_instr;
		icache_i.mem_spec <= imem_i.mem_spec;
		icache_i.mem_invalid <= imem_i.mem_invalid;
		icache_i.mem_addr <= imem_i.mem_addr;
		icache_i.mem_wdata <= imem_i.mem_wdata;
		icache_i.mem_wstrb <= imem_i.mem_wstrb;

		if icache_enable = false or pre_imem_access = IO_MEM_ACCESS then
			ibus_i <= imem_i;
		elsif icache_enable = true and post_imem_access = CACHE_ACCESS then
			ibus_i <= io_mem_i;
		else
			ibus_i <= init_mem_in;
		end if;

		if icache_enable = false or post_imem_access = IO_MEM_ACCESS then
			imem_o <= ibus_o;
		elsif icache_enable = true and post_imem_access = CACHE_ACCESS then
			imem_o <= icache_o;
		else
			imem_o <= init_mem_out;
		end if;

	end process;

	process (clock)

	begin

		if rising_edge(clock) then
			if reset = '0' then
				post_imem_access <= NO_ACCESS;
			else
				if imem_i.mem_valid = '1' then
					post_imem_access <= pre_imem_access;
				end if;
			end if;
		end if;

	end process;

	process(dmem_i,do_mem_i,dbus_o,dcache_i,dcache_o,pre_dmem_access,post_dmem_access)

	begin

		if dmem_i.mem_valid = '1' then
			if (unsigned(dmem_i.mem_addr) >= unsigned(cache_base_addr) and
					unsigned(dmem_i.mem_addr) < unsigned(cache_top_addr)) then
				dcache_i.mem_valid <= '1';
				pre_dmem_access <= CACHE_ACCESS;
			elsif dmem_i.mem_invalid = '1' then
				dcache_i.mem_valid <= '1';
				pre_dmem_access <= CACHE_ACCESS;
			else
				dcache_i.mem_valid <= '0';
				pre_dmem_access <= IO_MEM_ACCESS;
			end if;
		else
			dcache_i.mem_valid <= '0';
			pre_dmem_access <= NO_ACCESS;
		end if;

		dcache_i.mem_instr <= dmem_i.mem_instr;
		dcache_i.mem_spec <= dmem_i.mem_spec;
		dcache_i.mem_invalid <= dmem_i.mem_invalid;
		dcache_i.mem_addr <= dmem_i.mem_addr;
		dcache_i.mem_wdata <= dmem_i.mem_wdata;
		dcache_i.mem_wstrb <= dmem_i.mem_wstrb;

		if dcache_enable = false or pre_dmem_access = IO_MEM_ACCESS then
			dbus_i <= dmem_i;
		elsif dcache_enable = true and post_dmem_access = CACHE_ACCESS then
			dbus_i <= do_mem_i;
		else
			dbus_i <= init_mem_in;
		end if;

		if dcache_enable = false or post_dmem_access = IO_MEM_ACCESS then
			dmem_o <= dbus_o;
		elsif dcache_enable = true and post_dmem_access = CACHE_ACCESS then
			dmem_o <= dcache_o;
		else
			dmem_o <= init_mem_out;
		end if;

	end process;

	process (clock)

	begin

		if rising_edge(clock) then
			if reset = '0' then
				post_dmem_access <= NO_ACCESS;
			else
				if dmem_i.mem_valid = '1' then
					post_dmem_access <= pre_dmem_access;
				end if;
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
			mem_o   => ibus_o,
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
			mem_o   => dbus_o,
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
