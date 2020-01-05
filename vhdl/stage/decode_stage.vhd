-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.configure.all;
use work.constants.all;
use work.wire.all;
use work.functions.all;
use work.comp_wire.all;
use work.csr_wire.all;
use work.int_wire.all;
use work.fp_wire.all;

entity decode_stage is
	port(
		reset         : in  std_logic;
		clock         : in  std_logic;
		int_decode_i  : out int_decode_in_type;
		int_decode_o  : in  int_decode_out_type;
		comp_decode_i : out comp_decode_in_type;
		comp_decode_o : in  comp_decode_out_type;
		fp_dec_i      : out fp_dec_in_type;
		fp_dec_o      : in  fp_dec_out_type;
		csr_eo        : in  csr_exception_out_type;
		fpu_o         : in  fpu_out_type;
		fpu_i         : out fpu_in_type;
		d             : in  decode_in_type;
		q             : out decode_out_type
	);
end decode_stage;

architecture behavior of decode_stage is

	signal r   : decode_reg_type;
	signal rin : decode_reg_type;

begin

	combinational : process(d, r, int_decode_o, comp_decode_o, fp_dec_o, csr_eo, fpu_o)

		variable v : decode_reg_type;

	begin

		v := r;

		v.fpu := '0';
		v.fpu_op := init_fp_operation;

		v.pc := d.f.pc;
		v.instr := d.f.instr;
		v.taken := d.f.taken;
		v.exc := d.f.exc;
		v.etval := d.f.etval;
		v.ecause := d.f.ecause;

		if (d.d.stall or d.e.stall or d.m.stall or d.w.stall) = '1' then
			v := r;
		end if;

		if d.f.exc = '1' then
			v.instr := nop;
		end if;

		v.inc := "100";
		if and_reduce(v.instr(1 downto 0)) = '0' then
			v.inc := "010";
		end if;

		v.npc := std_logic_vector(unsigned(v.pc) + v.inc);

		v.stall := '0';

		v.clear := csr_eo.exc or csr_eo.mret or d.w.clear;

		if d.e.jump = '1' and d.f.taken = '0' then
			v.clear := '1';
		elsif d.e.jump = '0' and d.f.taken = '1' then
			v.clear := '1';
		end if;

		v.opcode := v.instr(6 downto 0);
		v.funct3 := v.instr(14 downto 12);
		v.funct7 := v.instr(31 downto 25);
		v.fmt := v.instr(26 downto 25);
		v.rm := v.instr(14 downto 12);

		v.raddr1 := v.instr(19 downto 15);
		v.raddr2 := v.instr(24 downto 20);
		v.raddr3 := v.instr(31 downto 27);
		v.waddr := v.instr(11 downto 7);
		v.caddr := v.instr(31 downto 20);

		int_decode_i.instr <= v.instr;

		v.imm := int_decode_o.imm;
		v.int_rden1 := int_decode_o.int_rden1;
		v.int_rden2 := int_decode_o.int_rden2;
		v.int_wren := int_decode_o.int_wren;
		v.csr_rden := int_decode_o.csr_rden;
		v.csr_wren := int_decode_o.csr_wren;
		v.load := int_decode_o.load;
		v.store := int_decode_o.store;
		v.int := int_decode_o.int;
		v.int_op := int_decode_o.int_op;
		v.load_op := int_decode_o.load_op;
		v.store_op := int_decode_o.store_op;
		v.csr := int_decode_o.csr;
		v.ecall := int_decode_o.ecall;
		v.ebreak := int_decode_o.ebreak;
		v.mret := int_decode_o.mret;
		v.wfi := int_decode_o.wfi;
		v.fence := int_decode_o.fence;
		v.valid := int_decode_o.valid;

		v.fpu_rden1 := '0';
		v.fpu_rden2 := '0';
		v.fpu_rden3 := '0';
		v.fpu_wren := '0';
		v.fpu_load := '0';
		v.fpu_store := '0';
		v.fpu := '0';
		v.fpu_op := init_fp_operation;

		comp_decode_i.instr <= v.instr;

		if comp_decode_o.valid = '1' then
			v.imm := comp_decode_o.imm;
			v.raddr1 := comp_decode_o.raddr1;
			v.raddr2 := comp_decode_o.raddr2;
			v.waddr := comp_decode_o.waddr;
			v.int_rden1 := comp_decode_o.int_rden1;
			v.int_rden2 := comp_decode_o.int_rden2;
			v.int_wren := comp_decode_o.int_wren;
			v.fpu_rden2 := comp_decode_o.fpu_rden2;
			v.fpu_wren := comp_decode_o.fpu_wren;
			v.load := comp_decode_o.load;
			v.store := comp_decode_o.store;
			v.int := comp_decode_o.int;
			v.fpu := comp_decode_o.fpu;
			v.csr := comp_decode_o.csr;
			v.ebreak := comp_decode_o.ebreak;
			v.int_op := comp_decode_o.int_op;
			v.load_op := comp_decode_o.load_op;
			v.store_op := comp_decode_o.store_op;
			v.valid := comp_decode_o.valid;
		end if;

		v.comp := comp_decode_o.valid;

		fp_dec_i.instr <= v.instr;

		if fp_dec_o.valid = '1' then
			v.imm := fp_dec_o.imm;
			v.int_rden1 := fp_dec_o.int_rden1;
			v.int_wren := fp_dec_o.int_wren;
			v.fpu_rden1 := fp_dec_o.fpu_rden1;
			v.fpu_rden2 := fp_dec_o.fpu_rden2;
			v.fpu_rden3 := fp_dec_o.fpu_rden3;
			v.fpu_wren := fp_dec_o.fpu_wren;
			v.fpu_load := fp_dec_o.fpu_load;
			v.fpu_store := fp_dec_o.fpu_store;
			v.fpu := fp_dec_o.fpu;
			v.fpu_op := fp_dec_o.fpu_op;
			v.load_op := fp_dec_o.load_op;
			v.store_op := fp_dec_o.store_op;
			v.valid := fp_dec_o.valid;
		end if;

		fpu_i.instr <= v.instr;
		fpu_i.rden1 <= v.fpu_rden1;
		fpu_i.rden2 <= v.fpu_rden2;
		fpu_i.rden3 <= v.fpu_rden3;
		fpu_i.wren <= v.fpu_wren;
		fpu_i.load <= v.fpu_load;
		fpu_i.op <= v.fpu_op;
		fpu_i.frm <= csr_eo.frm;

		v.link_waddr := (v.waddr = "00001") or (v.waddr = "00101");
		v.link_raddr1 := (v.raddr1 = "00001") or (v.raddr1 = "00101");
		v.raddr1_eq_waddr := v.raddr1 = v.waddr;
		v.zero_waddr := (v.waddr = "00000");

		if v.waddr = "00000" then
			v.int_wren := '0';
		end if;

		v.return_pop := '0';
		v.return_push := '0';
		v.jump_uncond := '0';
		v.jump_rest := '0';

		if v.int_op.jal ='1' then
			if v.link_waddr then
				v.return_push := '1';
			elsif v.zero_waddr then
				v.jump_uncond := '1';
			else
				v.jump_rest := '1';
			end if;
		end if;

		if v.int_op.jalr ='1' then
			if not(v.link_waddr) and v.link_raddr1 then
				v.return_pop := '1';
			elsif v.link_waddr and not(v.link_raddr1) then
				v.return_push := '1';
			elsif v.link_waddr and v.link_raddr1 then
				if v.raddr1_eq_waddr then
					v.return_push := '1';
				elsif not(v.raddr1_eq_waddr) then
					v.return_pop := '1';
					v.return_push := '1';
				end if;
			else
				v.jump_rest := '1';
			end if;
		end if;

		if v.int_op.jal = '1' then
		end if;

		if v.exc = '0' then
			if v.valid = '0' then
				v.exc := '1';
				v.etval := X"00000000" & v.instr;
				v.ecause := except_illegal_instruction;
			elsif v.ecall = '1' then
				v.exc := '1';
				if csr_eo.priv_mode = u_mode then
					v.ecause := except_env_call_user;
				elsif csr_eo.priv_mode = m_mode then
					v.ecause := except_env_call_mach;
				end if;
			elsif v.ebreak = '1' then
				v.exc := '1';
				v.ecause := except_breakpoint;
			end if;
		end if;

		case v.funct3 is
			when "001" | "101" =>
				v.csr_rden := v.csr_rden and (or_reduce(v.waddr));
			when "010" | "110" =>
				v.csr_wren := v.csr_wren and (or_reduce(v.raddr1));
			when "011" | "111" =>
				v.csr_wren := v.csr_wren and (or_reduce(v.raddr1));
			when others => null;
		end case;

		if (d.d.csr_wren or d.e.csr_wren) = '1' then
			v.stall := '1';
		elsif (d.d.load) = '1' then
			if (nor_reduce(d.d.waddr xor v.raddr1) and ((d.d.int_wren and v.int_rden1))) = '1' then
				v.stall := '1';
			end if;
			if (nor_reduce(d.d.waddr xor v.raddr2) and ((d.d.int_wren and v.int_rden2))) = '1' then
				v.stall := '1';
			end if;
		elsif (v.csr_rden) = '1' then
			if (nor_reduce(v.caddr xor csr_fflags) and (d.d.fpu or d.e.fpu)) = '1' then
				v.stall := '1';
			end if;
		elsif (d.d.int_op.mcycle) = '1' then
			v.stall := '1';
		end if;

		fpu_i.dstall <= v.stall;
		fpu_i.dclear <= v.clear;

		if (fpu_o.dstall) = '1' then
			v.stall := '1';
		end if;

		if (v.stall or v.clear) = '1' then
			v.int_wren := '0';
			v.fpu_wren := '0';
			v.csr_wren := '0';
			v.int := '0';
			v.fpu := '0';
			v.csr := '0';
			v.comp := '0';
			v.int_op := init_int_operation;
			v.fpu_op := init_fp_operation;
			v.return_pop := '0';
			v.return_push := '0';
			v.jump_uncond := '0';
			v.jump_rest := '0';
			v.load := '0';
			v.store := '0';
			v.fpu_load := '0';
			v.fpu_store := '0';
			v.taken := '0';
			v.exc := '0';
			v.mret := '0';
			v.fence := '0';
		end if;

		if v.clear = '1' then
			v.stall := '0';
		end if;

		rin <= v;

		q.pc <= r.pc;
		q.npc <= r.npc;
		q.funct3 <= r.funct3;
		q.funct7 <= r.funct7;
		q.fmt <= r.fmt;
		q.rm <= r.rm;
		q.imm <= r.imm;
		q.int_rden1 <= r.int_rden1;
		q.int_rden2 <= r.int_rden2;
		q.csr_rden <= r.csr_rden;
		q.int_wren <= r.int_wren;
		q.fpu_wren <= r.fpu_wren;
		q.csr_wren <= r.csr_wren;
		q.raddr1 <= r.raddr1;
		q.raddr2 <= r.raddr2;
		q.raddr3 <= r.raddr3;
		q.waddr <= r.waddr;
		q.caddr <= r.caddr;
		q.load <= r.load;
		q.store <= r.store;
		q.fpu_load <= r.fpu_load;
		q.fpu_store <= r.fpu_store;
		q.int <= r.int;
		q.fpu <= r.fpu;
		q.csr <= r.csr;
		q.comp <= r.comp;
		q.load_op <= r.load_op;
		q.store_op <= r.store_op;
		q.int_op <= r.int_op;
		q.fpu_op <= r.fpu_op;
		q.return_pop <= r.return_pop;
		q.return_push <= r.return_push;
		q.jump_uncond <= r.jump_uncond;
		q.jump_rest <= r.jump_rest;
		q.taken <= r.taken;
		q.etval <= r.etval;
		q.ecause <= r.ecause;
		q.exc <= r.exc;
		q.ecall <= r.ecall;
		q.ebreak <= r.ebreak;
		q.mret <= r.mret;
		q.wfi <= r.wfi;
		q.fence <= r.fence;
		q.stall <= r.stall;

	end process;

	process(clock)
	begin
		if rising_edge(clock) then

			if reset = '0' then

				r <= init_decode_reg;

			else

				r <= rin;

			end if;

		end if;

	end process;

end architecture;
