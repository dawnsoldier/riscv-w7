-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.configure.all;
use work.constants.all;
use work.wire.all;

entity prefetch is
	generic(
		pfetch_depth : integer := pfetch_depth
	);
	port(
		reset    : in  std_logic;
		clock    : in  std_logic;
		pfetch_i : in  prefetch_in_type;
		pfetch_o : out prefetch_out_type
	);
end prefetch;

architecture behavior of prefetch is

	type buffer_type is array (0 to 2**pfetch_depth-1) of std_logic_vector(15 downto 0);

	signal prefetch_buffer : buffer_type := (others => (others => '0'));

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
		wid    : natural range 0 to 2**pfetch_depth-1;
		rid    : natural range 0 to 2**pfetch_depth-1;
		stall  : std_logic;
	end record;

	constant init_reg : reg_type := (
		pc     => start_base_addr,
		npc    => start_base_addr,
		fpc    => start_base_addr,
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

	process(r,pfetch_i,prefetch_buffer)

	variable v : reg_type;

	begin

		v := r;

		v.instr := nop;
		v.stall := '0';
		v.wrdis := '0';
		v.wrbuf := '0';

		v.pc := pfetch_i.pc;
		v.npc := pfetch_i.npc;

		if pfetch_i.fence = '1' then
			v.fpc := v.pc(63 downto 3) & "000";
		end if;

		if pfetch_i.valid = '1' then
			v.wid := to_integer(unsigned(v.fpc(pfetch_depth downto 1)));
			v.rid := to_integer(unsigned(v.pc(pfetch_depth downto 1)));
		end if;

		v.equal := nor_reduce(v.fpc(63 downto 3) xor v.pc(63 downto 3));
		v.full := nor_reduce(v.fpc(pfetch_depth downto 3) xor v.pc(pfetch_depth downto 3));

		if v.equal = '1' then
			v.wren := '1';
			v.rden := '0';
		elsif v.full = '1' then
			v.wren := '0';
		elsif v.full = '0' then
			v.wren := '1';
			v.rden := '1';
		end if;

		if pfetch_i.mem_ready = '1' then
			if v.wren = '1' then
				v.wrbuf := '1';
				v.fpc := std_logic_vector(unsigned(v.fpc) + 8);
			end if;
		elsif pfetch_i.mem_ready = '0' then
			if v.wren = '1' then
				v.wrdis := '1';
			end if;
		end if;

		if pfetch_i.jump = '1' then
			v.fpc := v.npc(63 downto 3) & "000";
		end if;

		if v.rden = '1' then
			if v.rid = 2**pfetch_depth-1 then
				if (v.wid = 0) then
					if v.wrdis = '1' then
						v.stall := '1';
					else
						v.instr := pfetch_i.mem_rdata(15 downto 0) & prefetch_buffer(v.rid);
					end if;
				else
					v.instr := prefetch_buffer(0) & prefetch_buffer(v.rid);
				end if;
			else
				if v.wid = (v.rid+1) then
					if v.wrdis = '1' then
						v.stall := '1';
					else
						v.instr := pfetch_i.mem_rdata(15 downto 0) & prefetch_buffer(v.rid);
					end if;
				else
					v.instr := prefetch_buffer(v.rid+1) & prefetch_buffer(v.rid);
				end if;
			end if;
		elsif pfetch_i.mem_ready = '1' then
			if v.pc(2 downto 1) = "00" then
				v.instr := pfetch_i.mem_rdata(31 downto 0);
			elsif v.pc(2 downto 1) = "01" then
				v.instr := pfetch_i.mem_rdata(47 downto 16);
			elsif v.pc(2 downto 1) = "10" then
				v.instr := pfetch_i.mem_rdata(63 downto 32);
			elsif v.pc(2 downto 1) = "11" then
				if and_reduce(pfetch_i.mem_rdata(49 downto 48)) = '0' then
					v.instr := X"0000" & pfetch_i.mem_rdata(63 downto 48);
				else
					v.stall := '1';
				end if;
			end if;
		elsif pfetch_i.mem_ready = '0' then
			v.stall := '1';
		end if;

		pfetch_o.fpc <= v.fpc;
		pfetch_o.instr <= v.instr;
		pfetch_o.stall <= v.stall;

		rin <= v;

	end process;

	process(clock)

	begin

		if rising_edge(clock) then

			if reset = '0' then

				r <= init_reg;

			else

				if rin.wrbuf = '1' then
					prefetch_buffer(rin.wid) <= pfetch_i.mem_rdata(15 downto 0);
					prefetch_buffer(rin.wid+1) <= pfetch_i.mem_rdata(31 downto 16);
					prefetch_buffer(rin.wid+2) <= pfetch_i.mem_rdata(47 downto 32);
					prefetch_buffer(rin.wid+3) <= pfetch_i.mem_rdata(63 downto 48);
				end if;

				r <= rin;

			end if;

		end if;

	end process;

end architecture;
