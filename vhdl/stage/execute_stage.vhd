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

entity execute_stage is
	port(
		reset          : in  std_logic;
		clock          : in  std_logic;
		int_reg_ri     : out int_register_read_in_type;
		int_for_i      : out int_forward_in_type;
		int_for_o      : in  int_forward_out_type;
		int_reg_o      : in  int_register_out_type;
		csr_ri         : out csr_read_in_type;
		csr_ei         : out csr_exception_in_type;
		csr_o          : in  csr_out_type;
		int_pipeline_i : out int_pipeline_in_type;
		int_pipeline_o : in  int_pipeline_out_type;
		csr_alu_i      : out csr_alu_in_type;
		csr_alu_o      : in  csr_alu_out_type;
		csr_eo         : in  csr_exception_out_type;
		fpu_o          : in  fpu_out_type;
		fpu_i          : out fpu_in_type;
		dmem_i         : out mem_in_type;
		dpmp_o         : in  pmp_out_type;
		dpmp_i         : out pmp_in_type;
		time_irpt      : in  std_logic;
		ext_irpt       : in  std_logic;
		d              : in  execute_in_type;
		q              : out execute_out_type
	);
end execute_stage;

architecture behavior of execute_stage is

	signal r   : execute_reg_type;
	signal rin : execute_reg_type;

begin

	combinational : process(d, r, int_for_o, int_reg_o, csr_o, csr_eo, int_pipeline_o, csr_alu_o, fpu_o, dpmp_o, time_irpt, ext_irpt)

		variable v : execute_reg_type;

	begin

		v := r;

		v.pc := d.d.pc;
		v.npc := d.d.npc;
		v.funct3 := d.d.funct3;
		v.funct7 := d.d.funct7;
		v.fmt := d.d.fmt;
		v.rm := d.d.rm;
		v.imm := d.d.imm;
		v.csr_rden := d.d.csr_rden;
		v.int_wren := d.d.int_wren;
		v.fpu_wren := d.d.fpu_wren;
		v.csr_wren := d.d.csr_wren;
		v.raddr1 := d.d.raddr1;
		v.waddr := d.d.waddr;
		v.caddr := d.d.caddr;
		v.load := d.d.load;
		v.store := d.d.store;
		v.fpu_load := d.d.fpu_load;
		v.fpu_store := d.d.fpu_store;
		v.int := d.d.int;
		v.fpu := d.d.fpu;
		v.csr := d.d.csr;
		v.comp := d.d.comp;
		v.load_op := d.d.load_op;
		v.store_op := d.d.store_op;
		v.int_op := d.d.int_op;
		v.fpu_op := d.d.fpu_op;
		v.return_pop := d.d.return_pop;
		v.return_push := d.d.return_push;
		v.jump_uncond := d.d.jump_uncond;
		v.jump_rest := d.d.jump_rest;
		v.taken := d.d.taken;
		v.exc := d.d.exc;
		v.etval := d.d.etval;
		v.ecause := d.d.ecause;
		v.ecall := d.d.ecall;
		v.ebreak := d.d.ebreak;
		v.mret := d.d.mret;

		int_reg_ri.rden1 <= d.d.int_rden1;
		int_reg_ri.rden2 <= d.d.int_rden2;
		int_reg_ri.raddr1 <= d.d.raddr1;
		int_reg_ri.raddr2 <= d.d.raddr2;

		csr_ri.rden <= d.d.csr_rden;
		csr_ri.raddr <= d.d.caddr;

		int_for_i.reg_en1 <= d.d.int_rden1;
		int_for_i.reg_en2 <= d.d.int_rden2;
		int_for_i.reg_addr1 <= d.d.raddr1;
		int_for_i.reg_addr2 <= d.d.raddr2;
		int_for_i.reg_data1 <= int_reg_o.data1;
		int_for_i.reg_data2 <= int_reg_o.data2;
		int_for_i.exe_en <= d.e.int_wren;
		int_for_i.mem_en <= d.m.int_wren;
		int_for_i.exe_addr <= d.e.waddr;
		int_for_i.mem_addr <= d.m.waddr;
		int_for_i.exe_data <= d.e.wdata;
		int_for_i.mem_data <= d.m.wdata;

		v.cdata := csr_o.data;

		v.rdata1 := int_for_o.data1;
		v.rdata2 := int_for_o.data2;

		if (d.e.stall or d.m.stall or d.w.stall) = '1' then
			v := r;
		end if;

		v.stall := '0';

		v.clear := csr_eo.exc or csr_eo.mret or d.e.jump or d.w.clear;

		v.enable := not(d.e.stall or d.m.stall or d.w.stall);

		fpu_i.idata <= v.rdata1;

		if v.fpu_store = '1' then
			v.sdata := fpu_o.sdata;
		else
			v.sdata := v.rdata2;
		end if;

		v.flags := fpu_o.flags;

		int_pipeline_i.pc <= v.pc;
		int_pipeline_i.npc <= v.npc;
		int_pipeline_i.rs1 <= v.rdata1;
		int_pipeline_i.rs2 <= v.rdata2;
		int_pipeline_i.imm <= v.imm;
		int_pipeline_i.funct <= v.funct3;
		int_pipeline_i.comp <= v.comp;
		int_pipeline_i.load <= v.load or v.fpu_load;
		int_pipeline_i.store <= v.store or v.fpu_store;
		int_pipeline_i.load_op <= v.load_op;
		int_pipeline_i.store_op <= v.store_op;
		int_pipeline_i.int_op <= v.int_op;
		int_pipeline_i.enable <= v.enable;
		int_pipeline_i.clear <= v.clear;

		v.idata := int_pipeline_o.result;
		v.jump := int_pipeline_o.jump;
		v.address := int_pipeline_o.mem_addr;
		v.byteenable := int_pipeline_o.mem_byte;
		v.ready := int_pipeline_o.ready;

		if v.csr = '1' then
			v.wdata := v.cdata;
		elsif v.int = '1' then
			v.wdata := v.idata;
		elsif v.fpu = '1' then
			v.wdata := fpu_o.wdata;
		end if;

		csr_alu_i.rs1 <= v.rdata1;
		csr_alu_i.imm <= v.imm;
		csr_alu_i.data <= v.cdata;
		csr_alu_i.funct <= v.funct3;

		v.cdata := csr_alu_o.result;

		if (v.store or v.fpu_store)  = '1' then
			v.strobe := v.byteenable;
		else
			v.strobe := (others => '0');
		end if;

		dpmp_i.mem_valid <= v.load or v.fpu_load or v.store or v.fpu_store;
		dpmp_i.mem_instr <= '0';
		dpmp_i.mem_addr <= v.address;
		dpmp_i.mem_wstrb <= v.strobe;
		dpmp_i.priv_mode <= csr_eo.priv_mode;
		dpmp_i.pmpcfg <= csr_eo.pmpcfg;
		dpmp_i.pmpaddr <= csr_eo.pmpaddr;

		if v.exc = '0' then
			if int_pipeline_o.exc = '1' then
				if (v.jump or v.load or v.fpu_load or v.store or v.fpu_store) = '1' then
					v.exc := int_pipeline_o.exc;
					v.etval := int_pipeline_o.etval;
					v.ecause := int_pipeline_o.ecause;
					v.jump := '0';
					v.load := '0';
					v.store := '0';
					v.fpu_load := '0';
					v.fpu_store := '0';
					v.int := '0';
					if v.ecause /= x"1" then
						v.int_wren := '0';
					end if;
				end if;
			elsif dpmp_o.exc = '1' then
				v.exc := dpmp_o.exc;
				v.etval := dpmp_o.etval;
				v.ecause := dpmp_o.ecause;
			end if;
		end if;

		if v.int_op.mcycle = '1' then
			if v.ready = '0' then
				v.stall := '1';
			elsif v.ready = '1' then
				v.int := '1';
				v.int_wren := or_reduce(v.waddr);
				v.wdata := v.idata;
			end if;
		end if;

		fpu_i.estall <= v.stall;
		fpu_i.eclear <= v.clear;

		if v.fpu_op.fmcycle = '1' then
			if fpu_o.estall = '0' then
				v.stall := '0';
				v.fpu := '1';
			elsif fpu_o.estall = '1' then
				v.stall := '1';
			end if;
		end if;

		if (v.stall or v.clear) = '1' then
			v.int_wren := '0';
			v.fpu_wren := '0';
			v.csr_wren := '0';
			v.int := '0';
			v.fpu := '0';
			v.csr := '0';
			v.comp := '0';
			v.load := '0';
			v.store := '0';
			v.fpu_load := '0';
			v.fpu_store := '0';
			v.return_pop := '0';
			v.return_push := '0';
			v.jump_uncond := '0';
			v.jump_rest := '0';
			v.taken := '0';
			v.exc := '0';
			v.mret := '0';
			v.jump := '0';
		end if;

		if v.clear = '1' then
			v.stall := '0';
		end if;

		dmem_i.mem_valid <= v.load or v.fpu_load or v.store or v.fpu_store;
		dmem_i.mem_instr <= '0';
		dmem_i.mem_addr <= v.address;
		dmem_i.mem_wdata <= store_data(v.sdata, v.store_op);
		dmem_i.mem_wstrb <= v.strobe;

		if r.jump = '1' then
			csr_ei.epc <= r.pc;
		else
			csr_ei.epc <= v.pc;
		end if;
		csr_ei.exc <= v.exc;
		csr_ei.etval <= v.etval;
		csr_ei.ecause <= v.ecause;
		csr_ei.ecall <= v.ecall;
		csr_ei.ebreak <= v.ebreak;
		csr_ei.mret <= v.mret;

		csr_ei.time_irpt <= time_irpt;
		csr_ei.ext_irpt <= ext_irpt;

		rin <= v;

		q.pc <= r.pc;
		q.npc <= r.npc;
		q.funct3 <= r.funct3;
		q.int_wren <= r.int_wren;
		q.fpu_wren <= r.fpu_wren;
		q.csr_wren <= r.csr_wren;
		q.waddr <= r.waddr;
		q.caddr <= r.caddr;
		q.wdata <= r.wdata;
		q.cdata <= r.cdata;
		q.sdata <= r.sdata;
		q.flags <= r.flags;
		q.load <= r.load;
		q.store <= r.store;
		q.fpu_load <= r.fpu_load;
		q.fpu_store <= r.fpu_store;
		q.int <= r.int;
		q.fpu <= r.fpu;
		q.csr <= r.csr;
		q.load_op <= r.load_op;
		q.store_op <= r.store_op;
		q.int_op <= r.int_op;
		q.fpu_op <= r.fpu_op;
		q.return_pop <= r.return_pop;
		q.return_push <= r.return_push;
		q.jump_uncond <= r.jump_uncond;
		q.jump_rest <= r.jump_rest;
		q.taken <= r.taken;
		q.jump <= r.jump;
		q.address <= r.address;
		q.byteenable <= r.byteenable;
		q.strobe <= r.strobe;
		q.etval <= r.etval;
		q.ecause <= r.ecause;
		q.exc <= r.exc;
		q.ecall <= r.ecall;
		q.ebreak <= r.ebreak;
		q.mret <= r.mret;
		q.stall <= r.stall;

	end process;

	process(clock)
	begin
		if rising_edge(clock) then

			if reset = '0' then

				r <= init_execute_reg;

			else

				r <= rin;

			end if;

		end if;

	end process;

end architecture;
