-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.configure.all;
use work.constants.all;
use work.wire.all;

entity fetchctrl is
	generic(
		fetchbuffer_depth : integer := fetchbuffer_depth
	);
	port(
		reset       : in  std_logic;
		clock       : in  std_logic;
		fetchctrl_i : in  fetchbuffer_in_type;
		fetchctrl_o : out fetchbuffer_out_type;
		fetchram_i  : out fetchram_in_type;
		fetchram_o  : in  fetchram_out_type;
		imem_o      : in  mem_out_type;
		imem_i      : out mem_in_type
	);
end fetchctrl;

architecture behavior of fetchctrl is

	type reg_type is record
		pc     : std_logic_vector(63 downto 0);
		pc8    : std_logic_vector(63 downto 0);
		npc    : std_logic_vector(63 downto 0);
		fpc    : std_logic_vector(63 downto 0);
		instr  : std_logic_vector(31 downto 0);
		rdata  : std_logic_vector(63 downto 0);
		rdata1 : std_logic_vector(127 downto 0);
		rdata2 : std_logic_vector(127 downto 0);
		wdata  : std_logic_vector(127 downto 0);
		rden1  : std_logic;
		rden2  : std_logic;
		ready  : std_logic;
		flush  : std_logic;
		busy   : std_logic;
		wren   : std_logic;
		rden   : std_logic;
		valid  : std_logic;
		spec   : std_logic;
		fence  : std_logic;
		oflow  : std_logic;
		store  : std_logic;
		waddr  : natural range 0 to 2**fetchbuffer_depth-1;
		raddr1 : natural range 0 to 2**fetchbuffer_depth-1;
		raddr2 : natural range 0 to 2**fetchbuffer_depth-1;
		stall  : std_logic;
	end record;

	constant init_reg : reg_type := (
		pc     => bram_base_addr,
		pc8    => bram_base_addr,
		npc    => bram_base_addr,
		fpc    => bram_base_addr,
		instr  => nop,
		rdata  => (others => '0'),
		rdata1 => (others => '0'),
		rdata2 => (others => '0'),
		wdata  => (others => '0'),
		rden1  => '0',
		rden2  => '0',
		ready  => '0',
		flush  => '0',
		busy   => '0',
		wren   => '0',
		rden   => '0',
		valid  => '0',
		spec   => '0',
		fence  => '0',
		oflow  => '0',
		store  => '0',
		waddr  => 0,
		raddr1 => 0,
		raddr2 => 0,
		stall  => '0'
	);

	signal r, rin : reg_type := init_reg;

begin

	process(r,fetchctrl_i,fetchram_o,imem_o)

	variable v : reg_type;

	begin

		v := r;

		v.instr := nop;
		v.stall := '0';
		v.store := '0';
		v.wren := '0';
		v.rden1 := '0';
		v.rden2 := '0';

		v.valid := fetchctrl_i.valid;
		v.spec := fetchctrl_i.spec;
		v.fence := fetchctrl_i.fence;
		v.pc := fetchctrl_i.pc;
		v.npc := fetchctrl_i.npc;

		v.rdata := imem_o.mem_rdata;
		v.ready := imem_o.mem_ready;
		v.flush := imem_o.mem_flush;
		v.busy := imem_o.mem_busy;

		v.pc8 := std_logic_vector(unsigned(v.pc) + 8);

		if v.valid = '1' then
			v.raddr1 := to_integer(unsigned(v.pc(fetchbuffer_depth+2 downto 3)));
			v.raddr2 := to_integer(unsigned(v.pc8(fetchbuffer_depth+2 downto 3)));
		end if;

		if v.ready = '1' then
			v.store := '1';
			v.waddr := to_integer(unsigned(v.fpc(fetchbuffer_depth+2 downto 3)));
			v.wdata := v.fpc(63 downto 3) & "000" & v.rdata;
		end if;

		if v.oflow = '0' and r.waddr = 2**fetchbuffer_depth-1 and v.waddr = 0 then
			v.oflow := '1';
		end if;

		if v.oflow = '1' and r.raddr1 = 2**fetchbuffer_depth-1 and v.raddr1 = 0 then
			v.oflow := '0';
		end if;

		if v.store = '1' then
			if v.oflow = '1' and v.waddr < v.raddr1 then
				v.wren := '1';
			elsif v.oflow= '0' then
				v.wren := '1';
			end if;
		end if;

		fetchram_i.raddr1 <= v.raddr1;
		fetchram_i.raddr2 <= v.raddr2;

		v.rdata1 := fetchram_o.rdata1;
		v.rdata2 := fetchram_o.rdata2;

		if v.rdata1(127 downto 67) = v.pc(63 downto 3) then
			v.rden1 := '1';
		end if;
		if v.rdata2(127 downto 67) = v.pc8(63 downto 3) then
			v.rden2 := '1';
		end if;

		if v.pc(2 downto 1) = "00" then
			if v.rden1 = '1' then
				v.instr := v.rdata1(31 downto 0);
			else
				v.stall := '1';
			end if;
		elsif v.pc(2 downto 1) = "01" then
			if v.rden1 = '1' then
				v.instr := v.rdata1(47 downto 16);
			else
				v.stall := '1';
			end if;
		elsif v.pc(2 downto 1) = "10" then
			if v.rden1 = '1' then
				v.instr := v.rdata1(63 downto 32);
			else
				v.stall := '1';
			end if;
		elsif v.pc(2 downto 1) = "11" then
			if v.rden1 = '1' then
				v.instr(15 downto 0) := v.rdata1(63 downto 48);
				if v.rdata1(49 downto 48) = "11" then
					if v.rden2 = '1' then
						v.instr(31 downto 16) := v.rdata2(15 downto 0);
					else
						v.stall := '1';
					end if;
				end if;
			else
				v.stall := '1';
			end if;
		end if;

		if v.valid = '1' then
			if v.spec = '1' then
				v.fpc := v.npc(63 downto 3) & "000";
			elsif v.fence = '1' then
				v.fpc := v.pc(63 downto 3) & "000";
			elsif v.ready = '1' and v.wren = '1' then
				v.fpc := std_logic_vector(unsigned(v.fpc) + 8);
			end if;
		end if;

		fetchctrl_o.instr <= v.instr;
		fetchctrl_o.stall <= v.stall;
		fetchctrl_o.flush <= v.flush;

		imem_i.mem_valid <= v.valid;
		imem_i.mem_instr <= '1';
		imem_i.mem_spec <= v.spec;
		imem_i.mem_invalid <= v.fence;
		imem_i.mem_addr <= v.fpc;
		imem_i.mem_wdata <= (others => '0');
		imem_i.mem_wstrb <= (others => '0');

		fetchram_i.wren <= v.wren;
		fetchram_i.waddr <= v.waddr;
		fetchram_i.wdata <= v.wdata;

		rin <= v;

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
