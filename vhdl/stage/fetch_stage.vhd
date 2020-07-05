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
		btb_o    : in  btb_out_type;
		btb_i    : out btb_in_type;
		pfetch_o : in  prefetch_out_type;
		pfetch_i : out prefetch_in_type;
		imem_o   : in  mem_out_type;
		imem_i   : out mem_in_type;
		ipmp_o   : in  pmp_out_type;
		ipmp_i   : out pmp_in_type;
		d        : in  fetch_in_type;
		q        : out fetch_out_type
	);
end fetch_stage;

architecture behavior of fetch_stage is

	signal r   : fetch_reg_type;
	signal rin : fetch_reg_type;

begin

	combinational : process(d, r, csr_eo, btb_o, pfetch_o, imem_o, ipmp_o)

		variable v : fetch_reg_type;

	begin

		v := r;

		v.inc := "100";
		v.instr := nop;

		v.valid := not d.w.clear;
		v.stall := pfetch_o.stall or d.d.stall or d.e.stall or d.m.stall or d.w.stall or d.w.clear;
		v.clear := csr_eo.exc or csr_eo.mret or d.w.clear;

		if v.clear = '0' then
			v.instr := pfetch_o.instr;
		end if;

		if and_reduce(v.instr(1 downto 0)) = '0' then
			v.inc := "010";
		end if;

		btb_i.get_pc <= d.d.pc;
		btb_i.get_branch <= d.d.int_op.branch;
		btb_i.get_return <= d.d.return_pop;
		btb_i.get_uncond <= d.d.jump_uncond;
		btb_i.upd_pc <= d.e.pc;
		btb_i.upd_npc <= d.e.npc;
		btb_i.upd_addr <= d.e.address;
		btb_i.upd_branch <= d.e.int_op.branch;
		btb_i.upd_return <= d.e.return_push;
		btb_i.upd_uncond <= d.e.jump_uncond;
		btb_i.upd_jump <= d.e.jump;
		btb_i.stall <= v.stall;
		btb_i.clear <= v.clear;

		v.taken := '0';
		v.spec := '0';

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
		elsif btb_o.pred_return = '1' then
			v.taken := '1';
			v.spec := '1';
			v.pc :=  btb_o.pred_raddr;
		elsif btb_o.pred_uncond = '1' then
			v.taken := '1';
			v.spec := '1';
			v.pc :=  btb_o.pred_baddr;
		elsif btb_o.pred_branch = '1' and btb_o.pred_jump = '1' then
			v.taken := '1';
			v.spec := '1';
			v.pc :=  btb_o.pred_baddr;
		elsif v.stall = '0' then
			v.pc := std_logic_vector(unsigned(v.pc) + v.inc);
		end if;

		pfetch_i.pc <= r.pc;
		pfetch_i.npc <= v.pc;
		pfetch_i.jump <= v.spec;
		pfetch_i.fence <= d.d.fence;
		pfetch_i.mem_rdata <= imem_o.mem_rdata;
		pfetch_i.mem_ready <= imem_o.mem_ready;

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

		imem_i.mem_valid <= v.valid;
		imem_i.mem_instr <= '1';
		imem_i.mem_addr <= pfetch_o.fpc;
		imem_i.mem_wdata <= (others => '0');
		imem_i.mem_wstrb <= (others => '0');

		rin <= v;

		q.pc <= r.pc;
		q.instr <= v.instr;
		q.taken <= r.taken;
		q.exc <= r.exc;
		q.etval <= r.etval;
		q.ecause <= r.ecause;

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
