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
		npc    : std_logic_vector(63 downto 0);
		fpc    : std_logic_vector(63 downto 0);
		instr  : std_logic_vector(31 downto 0);
		wren   : std_logic;
		rden   : std_logic;
		wrdis  : std_logic;
		wrbuf  : std_logic;
		equal  : std_logic;
		full   : std_logic;
		wid    : natural range 0 to 2**fetchbuffer_depth-1;
		rid    : natural range 0 to 2**fetchbuffer_depth-1;
		stall  : std_logic;
	end record;

	constant init_reg : reg_type := (
		pc     => bram_base_addr,
		npc    => bram_base_addr,
		fpc    => bram_base_addr,
		instr  => nop,
		wren   => '0',
		rden   => '0',
		wrdis  => '0',
		wrbuf  => '0',
		equal  => '0',
		full   => '0',
		wid    => 0,
		rid    => 0,
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
		v.wrdis := '0';
		v.wrbuf := '0';

		v.pc := fetchctrl_i.pc;
		v.npc := fetchctrl_i.npc;

		if fetchctrl_i.fence = '1' then
			v.fpc := v.pc(63 downto 3) & "000";
		end if;

		if fetchctrl_i.valid = '1' then
			v.wid := to_integer(unsigned(v.fpc(fetchbuffer_depth downto 1)));
			v.rid := to_integer(unsigned(v.pc(fetchbuffer_depth downto 1)));
		end if;

		v.equal := nor_reduce(v.fpc(63 downto 3) xor v.pc(63 downto 3));
		v.full := nor_reduce(v.fpc(fetchbuffer_depth downto 3) xor v.pc(fetchbuffer_depth downto 3));

		if v.equal = '1' then
			v.wren := '1';
			v.rden := '0';
		elsif v.full = '1' then
			v.wren := '0';
		elsif v.full = '0' then
			v.wren := '1';
			v.rden := '1';
		end if;

		if imem_o.mem_ready = '1' then
			if v.wren = '1' then
				v.wrbuf := '1';
				v.fpc := std_logic_vector(unsigned(v.fpc) + 8);
			end if;
		elsif imem_o.mem_ready = '0' then
			if v.wren = '1' then
				v.wrdis := '1';
			end if;
		end if;

		if fetchctrl_i.spec = '1' then
			v.fpc := v.npc(63 downto 3) & "000";
		end if;

		fetchram_i.raddr <= v.rid;

		if v.rden = '1' then
			if v.rid = 2**fetchbuffer_depth-1 then
				if (v.wid = 0) then
					if v.wrdis = '1' then
						v.stall := '1';
					else
						v.instr := imem_o.mem_rdata(15 downto 0) & fetchram_o.rdata(15 downto 0);
					end if;
				else
					v.instr := fetchram_o.rdata;
				end if;
			else
				if v.wid = (v.rid+1) then
					if v.wrdis = '1' then
						v.stall := '1';
					else
						v.instr := imem_o.mem_rdata(15 downto 0) & fetchram_o.rdata(15 downto 0);
					end if;
				else
					v.instr := fetchram_o.rdata;
				end if;
			end if;
		elsif imem_o.mem_ready = '1' then
			if v.pc(2 downto 1) = "00" then
				v.instr := imem_o.mem_rdata(31 downto 0);
			elsif v.pc(2 downto 1) = "01" then
				v.instr := imem_o.mem_rdata(47 downto 16);
			elsif v.pc(2 downto 1) = "10" then
				v.instr := imem_o.mem_rdata(63 downto 32);
			elsif v.pc(2 downto 1) = "11" then
				if and_reduce(imem_o.mem_rdata(49 downto 48)) = '0' then
					v.instr := X"0000" & imem_o.mem_rdata(63 downto 48);
				else
					v.stall := '1';
				end if;
			end if;
		elsif imem_o.mem_ready = '0' then
			v.stall := '1';
		end if;

		fetchctrl_o.instr <= v.instr;
		fetchctrl_o.stall <= v.stall;
		fetchctrl_o.flush <= imem_o.mem_flush;

		imem_i.mem_valid <= fetchctrl_i.valid;
		imem_i.mem_instr <= '1';
		imem_i.mem_spec <= fetchctrl_i.spec;
		imem_i.mem_invalid <= fetchctrl_i.fence;
		imem_i.mem_addr <= v.fpc;
		imem_i.mem_wdata <= (others => '0');
		imem_i.mem_wstrb <= (others => '0');

		fetchram_i.wren <= v.wrbuf;
		fetchram_i.waddr <= v.wid;
		fetchram_i.wdata <= imem_o.mem_rdata;

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
