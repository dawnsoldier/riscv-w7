-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.configure.all;
use work.constants.all;
use work.wire.all;
use work.functions.all;
use work.csr_wire.all;
use work.int_wire.all;
use work.fp_wire.all;

entity fetch_stage is
	port(
		reset    : in  std_logic;
		clock    : in  std_logic;
		csr_eo   : in  csr_exception_out_type;
		bp_o     : in  bp_out_type;
		bp_i     : out bp_in_type;
		pfetch_o : in  prefetch_out_type;
		pfetch_i : out prefetch_in_type;
		icache_o : in  cache_out_type;
		icache_i : out cache_in_type;
		ipmp_o   : in  pmp_out_type;
		ipmp_i   : out pmp_in_type;
		a        : in  fetch_in_type;
		d        : in  fetch_in_type;
		y        : out fetch_out_type;
		q        : out fetch_out_type
	);
end fetch_stage;

architecture behavior of fetch_stage is

	signal r   : fetch_reg_type := init_fetch_reg;
	signal rin : fetch_reg_type := init_fetch_reg;

begin

	combinational : process(a, d, r, csr_eo, bp_o, pfetch_o, icache_o, ipmp_o)

		variable v : fetch_reg_type;

	begin

		v := r;

		v.valid := not d.w.clear;
		v.stall := pfetch_o.stall or d.d.stall or d.e.stall or d.m.stall or d.w.stall or d.w.clear;
		v.clear := csr_eo.exc or csr_eo.mret or d.w.clear;

		v.instr := pfetch_o.instr;

		if and_reduce(v.instr(1 downto 0)) = '0' then
			v.inc := "010";
		else
			v.inc := "100";
		end if;

		bp_i.get_pc <= d.d.pc;
		bp_i.get_branch <= d.d.int_op.branch;
		bp_i.get_return <= d.d.return_pop;
		bp_i.get_uncond <= d.d.jump_uncond;
		bp_i.upd_pc <= d.e.pc;
		bp_i.upd_npc <= d.e.npc;
		bp_i.upd_addr <= d.e.address;
		bp_i.upd_branch <= d.e.int_op.branch;
		bp_i.upd_return <= d.e.return_push;
		bp_i.upd_uncond <= d.e.jump_uncond;
		bp_i.upd_jump <= d.e.jump;
		bp_i.stall <= v.stall;
		bp_i.clear <= v.clear;

		if csr_eo.exc = '1' then
			v.taken := '0';
			v.spec := '1';
			v.pc := csr_eo.tvec;
		elsif csr_eo.mret = '1' then
			v.taken := '0';
			v.spec := '1';
			v.pc := csr_eo.epc;
		elsif d.e.jump = '1' and d.f.taken = '0' then
			v.taken := '0';
			v.spec := '1';
			v.pc := d.e.address;
		elsif d.e.jump = '0' and d.f.taken = '1' then
			v.taken := '0';
			v.spec := '1';
			v.pc := d.d.npc;
		elsif d.e.jump = '1' and d.f.taken = '1' and or_reduce(d.e.address xor d.f.pc) = '1' then
			v.taken := '0';
			v.spec := '1';
			v.pc := d.e.address;
		elsif bp_o.pred_return = '1' then
			v.taken := '1';
			v.spec := '1';
			v.pc :=  bp_o.pred_raddr;
		elsif bp_o.pred_uncond = '1' then
			v.taken := '1';
			v.spec := '1';
			v.pc :=  bp_o.pred_baddr;
		elsif bp_o.pred_branch = '1' and bp_o.pred_jump = '1' then
			v.taken := '1';
			v.spec := '1';
			v.pc :=  bp_o.pred_baddr;
		elsif v.stall = '0' then
			v.taken := '0';
			v.spec := '0';
			v.pc := std_logic_vector(unsigned(v.pc) + v.inc);
		else
			v.taken := '0';
			v.spec := '0';
		end if;

		pfetch_i.pc <= r.pc;
		pfetch_i.npc <= v.pc;
		pfetch_i.jump <= v.spec;
		pfetch_i.fence <= d.d.fence;
		pfetch_i.valid <= v.valid;
		pfetch_i.mem_rdata <= icache_o.mem_rdata;
		pfetch_i.mem_ready <= icache_o.mem_ready;

		ipmp_i.mem_valid <= v.valid;
		ipmp_i.mem_instr <= '1';
		ipmp_i.mem_addr <= pfetch_o.fpc;
		ipmp_i.mem_wstrb <= (others => '0');
		ipmp_i.priv_mode <= csr_eo.priv_mode;
		ipmp_i.pmpcfg <= csr_eo.pmpcfg;
		ipmp_i.pmpaddr <= csr_eo.pmpaddr;

		v.exc := ipmp_o.exc;
		v.etval := ipmp_o.etval;
		v.ecause := ipmp_o.ecause;

		if v.exc = '1' then
			v.valid := '0';
		end if;

		icache_i.mem_valid <= v.valid;
		icache_i.mem_instr <= '1';
		icache_i.mem_spec <= v.spec;
		icache_i.mem_invalid <= d.d.fence;
		icache_i.mem_addr <= pfetch_o.fpc;
		icache_i.mem_wdata <= (others => '0');
		icache_i.mem_wstrb <= (others => '0');

		rin <= v;

		y.pc <= v.pc;
		y.instr <= v.instr;
		y.taken <= v.taken;
		y.exc <= v.exc;
		y.etval <= v.etval;
		y.ecause <= v.ecause;
		y.clear <= v.clear;

		q.pc <= r.pc;
		q.instr <= v.instr;
		q.taken <= r.taken;
		q.exc <= r.exc;
		q.etval <= r.etval;
		q.ecause <= r.ecause;
		q.clear <= r.clear;

	end process;

	process(clock)
	begin
		if rising_edge(clock) then

			if reset = '0' then

				r <= init_fetch_reg;

			else

				r <= rin;

			end if;

		end if;

	end process;

end architecture;
