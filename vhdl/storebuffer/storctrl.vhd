-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.configure.all;
use work.constants.all;
use work.wire.all;

entity storctrl is
	generic(
		storbuffer_depth : integer := storbuffer_depth
	);
	port(
		reset      : in  std_logic;
		clock      : in  std_logic;
		storctrl_i : in  storbuffer_in_type;
		storctrl_o : out storbuffer_out_type;
		storram_i  : out storram_in_type;
		storram_o  : in  storram_out_type;
		dmem_o     : in  mem_out_type;
		dmem_i     : out mem_in_type
	);
end storctrl;

architecture behavior of storctrl is

	type reg_type is record
		saddr   : std_logic_vector(63 downto 0);
		sdata   : std_logic_vector(63 downto 0);
		sstrb   : std_logic_vector(7 downto 0);
		addr    : std_logic_vector(63 downto 0);
		wdata   : std_logic_vector(63 downto 0);
		wstrb   : std_logic_vector(7 downto 0);
		wid     : integer range 0 to 2**storbuffer_depth-1;
		rid     : integer range 0 to 2**storbuffer_depth-1;
		wren    : std_logic;
		rden    : std_logic;
		oflow   : std_logic;
		inv     : std_logic;
		st      : std_logic;
		ld      : std_logic;
		store   : std_logic;
		load    : std_logic;
		full    : std_logic;
		flush   : std_logic;
		invalid : std_logic;
	end record;

	constant init_reg : reg_type := (
		saddr   => (others => '0'),
		sdata   => (others => '0'),
		sstrb   => (others => '0'),
		addr    => (others => '0'),
		wdata   => (others => '0'),
		wstrb   => (others => '0'),
		wid     => 0,
		rid     => 0,
		wren    => '0',
		rden    => '0',
		oflow   => '0',
		inv     => '0',
		st      => '0',
		ld      => '0',
		store   => '0',
		load    => '0',
		full    => '0',
		flush   => '0',
		invalid => '0'
	);

	signal r, rin : reg_type := init_reg;

begin

	process(r,storctrl_i,storram_o,dmem_o)

	variable v : reg_type;

	variable ready : std_logic;
	variable rdata : std_logic_vector(63 downto 0);

	begin

		v := r;

		if r.wren = '1' then
			ready := '1';
			rdata := (others => '0');
		elsif r.load = '1' then
			ready := dmem_o.mem_ready;
			rdata := dmem_o.mem_rdata;
		else
			ready := '0';
			rdata := (others => '0');
		end if;

		if r.invalid = '1' then
			v.invalid := '0';
			v.flush := '0';
		elsif r.load = '1' then
			if ready = '1' then
				v.load := '0';
				v.flush := '0';
			end if;
		end if;

		storctrl_o.mem_flush <= dmem_o.mem_flush or r.flush;
		storctrl_o.mem_ready <= ready;
		storctrl_o.mem_rdata <= rdata;

		v.store := '0';

		if storctrl_i.mem_valid = '1' then
			v.flush := '0';
			v.inv := storctrl_i.mem_invalid;
			v.st := or_reduce(storctrl_i.mem_wstrb);
			v.ld := nor_reduce(storctrl_i.mem_wstrb);
			v.saddr := storctrl_i.mem_addr;
			v.sdata := storctrl_i.mem_wdata;
			v.sstrb := storctrl_i.mem_wstrb;
			if v.inv = '1' then
				v.flush := '1';
			elsif v.ld = '1' then
				v.flush := '1';
			elsif v.st = '1' then
				v.store := '1';
			end if;
		end if;

		if r.full = '1' and r.store = '1' then
			v.store := '1';
		end if;

		v.wren := '0';
		v.full := '1';
		if v.store = '1' then
			if v.oflow = '1' and v.wid < v.rid then
				v.wren := '1';
				v.full := '0';
			elsif v.oflow = '0' then
				v.wren := '1';
				v.full := '0';
			end if;
		end if;

		if dmem_o.mem_ready = '1' then
			if v.rden = '1' then
				if v.rid = 2**storbuffer_depth-1 then
					v.oflow := '0';
					v.rid := 0;
				else
					v.rid := v.rid+1;
				end if;
			end if;
		end if;

		v.rden := '0';
		if v.oflow = '0' and v.rid < v.wid then
			v.rden := '1';
		elsif v.oflow = '1' then
			v.rden := '1';
		end if;

		storram_i.wren <= v.wren;
		storram_i.waddr <= v.wid;
		storram_i.wdata <= v.saddr & v.sdata & v.sstrb;

		storram_i.raddr <= v.rid;

		if v.wren = '1' then
			if v.wid = 2**storbuffer_depth-1 then
				v.oflow := '1';
				v.wid := 0;
			else
				v.wid := v.wid+1;
			end if;
		end if;

		if (v.rden or v.wren) = '0' then
			if v.inv = '1' then
				v.invalid := '1';
			elsif v.ld = '1' then
				v.load := '1';
			end if;
			v.inv := '0';
		end if;

		if v.rden = '1' then
			v.addr := storram_o.rdata(135 downto 72);
			v.wdata := storram_o.rdata(71 downto 8);
			v.wstrb := storram_o.rdata(7 downto 0);
		elsif v.load = '1' then
			v.addr := v.saddr;
			v.wdata := (others => '0');
			v.wstrb := (others => '0');
		end if;

		dmem_i.mem_valid <= v.rden or v.load or v.invalid;
		dmem_i.mem_instr <= '0';
		dmem_i.mem_spec <= '0';
		dmem_i.mem_invalid <= v.invalid;
		dmem_i.mem_addr <= v.addr;
		dmem_i.mem_wdata <= v.wdata;
		dmem_i.mem_wstrb <= v.wstrb;

		rin <= v;

	end process;

	process(clock)

	begin

		if rising_edge(clock) then

			if reset = '0' then

				r <= init_reg;

			else

				r <= rin;

			end if;

		end if;

	end process;

end architecture;
