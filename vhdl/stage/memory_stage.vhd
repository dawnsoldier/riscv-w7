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

entity memory_stage is
	port(
		reset     : in  std_logic;
		clock     : in  std_logic;
		csr_eo    : in  csr_exception_out_type;
		sbuffer_o : in  storebuffer_out_type;
		a         : in  memory_in_type;
		d         : in  memory_in_type;
		y         : out memory_out_type;
		q         : out memory_out_type
	);
end memory_stage;

architecture behavior of memory_stage is

	signal r   : memory_reg_type := init_memory_reg;
	signal rin : memory_reg_type := init_memory_reg;

begin

	combinational : process(a, d, r, csr_eo, sbuffer_o)

		variable v : memory_reg_type;

	begin

		v := r;

		v.pc := d.e.pc;
		v.funct3 := d.e.funct3;
		v.int_wren := d.e.int_wren;
		v.fpu_wren := d.e.fpu_wren;
		v.csr_wren := d.e.csr_wren;
		v.waddr := d.e.waddr;
		v.caddr := d.e.caddr;
		v.wdata := d.e.wdata;
		v.cdata := d.e.cdata;
		v.flags := d.e.flags;
		v.load := d.e.load;
		v.store := d.e.store;
		v.fpu_load := d.e.fpu_load;
		v.fpu_store := d.e.fpu_store;
		v.int := d.e.int;
		v.fpu := d.e.fpu;
		v.csr := d.e.csr;
		v.comp := d.e.comp;
		v.load_op := d.e.load_op;
		v.store_op := d.e.store_op;
		v.int_op := d.e.int_op;
		v.fpu_op := d.e.fpu_op;
		v.exc := d.e.exc;
		v.etval := d.e.etval;
		v.ecause := d.e.ecause;
		v.ecall := d.e.ecall;
		v.ebreak := d.e.ebreak;
		v.mret := d.e.mret;
		v.fence := d.e.fence;
		v.valid := d.e.valid;
		v.byteenable := d.e.byteenable;

		if (d.m.stall or d.w.stall) = '1' then
			v := r;
			v.int_wren := v.int_wren_n;
			v.fpu_wren := v.fpu_wren_n;
			v.csr_wren := v.csr_wren_n;
			v.int := v.int_n;
			v.fpu := v.fpu_n;
			v.csr := v.csr_n;
			v.comp := v.comp_n;
			v.load := v.load_n;
			v.store := v.store_n;
			v.fpu_load := v.fpu_load_n;
			v.fpu_store := v.fpu_store_n;
			v.exc := v.exc_n;
			v.ecall := v.ecall_n;
			v.ebreak := v.ebreak_n;
			v.mret := v.mret_n;
			v.fence := v.fence_n;
			v.valid := v.valid_n;
		end if;

		v.stall := sbuffer_o.mem_flush;

		v.flush := sbuffer_o.mem_flush;

		v.clear := d.w.clear;

		if (v.load or v.fpu_load) = '1' then
			v.wdata := load_data(sbuffer_o.mem_rdata, v.byteenable, v.load_op);
			v.stall := not sbuffer_o.mem_ready;
		elsif (v.store or v.fpu_store) = '1' then
			v.stall := not sbuffer_o.mem_ready;
		end if;

		if v.fpu_load = '1' then
			v.wdata := nan_boxing(v.wdata,v.load_op.mem_lw);
		end if;

		v.int_wren_n := v.int_wren;
		v.fpu_wren_n := v.fpu_wren;
		v.csr_wren_n := v.csr_wren;
		v.int_n := v.int;
		v.fpu_n := v.fpu;
		v.csr_n := v.csr;
		v.comp_n := v.comp;
		v.load_n := v.load;
		v.store_n := v.store;
		v.fpu_load_n := v.fpu_load;
		v.fpu_store_n := v.fpu_store;
		v.exc_n := v.exc;
		v.ecall_n := v.ecall;
		v.ebreak_n := v.ebreak;
		v.mret_n := v.mret;
		v.fence_n := v.fence;
		v.valid_n := v.valid;

		if (v.stall or a.w.stall or v.clear) = '1' then
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
			v.exc := '0';
			v.ecall := '0';
			v.ebreak := '0';
			v.mret := '0';
			v.fence := '0';
			v.valid := '0';
		end if;

		if v.clear = '1' then
			v.stall := '0';
		end if;

		rin <= v;

		y.pc <= v.pc;
		y.int_wren <= v.int_wren;
		y.fpu_wren <= v.fpu_wren;
		y.csr_wren <= v.csr_wren;
		y.waddr <= v.waddr;
		y.caddr <= v.caddr;
		y.wdata <= v.wdata;
		y.cdata <= v.cdata;
		y.flags <= v.flags;
		y.load <= v.load;
		y.store <= v.store;
		y.fpu_load <= v.fpu_load;
		y.fpu_store <= v.fpu_store;
		y.int <= v.int;
		y.fpu <= v.fpu;
		y.csr <= v.csr;
		y.comp <= v.comp;
		y.load_op <= v.load_op;
		y.store_op <= v.store_op;
		y.int_op <= v.int_op;
		y.fpu_op <= v.fpu_op;
		y.etval <= v.etval;
		y.ecause <= v.ecause;
		y.exc <= v.exc;
		y.ecall <= v.ecall;
		y.ebreak <= v.ebreak;
		y.mret <= v.mret;
		y.fence <= v.fence;
		y.valid <= v.valid;
		y.stall <= v.stall;
		y.flush <= v.flush;
		y.clear <= v.clear;

		y.int_wren_n <= v.int_wren_n;
		y.fpu_wren_n <= v.fpu_wren_n;
		y.csr_wren_n <= v.csr_wren_n;
		y.int_n <= v.int_n;
		y.fpu_n <= v.fpu_n;
		y.csr_n <= v.csr_n;
		y.comp_n <= v.comp_n;
		y.load_n <= v.load_n;
		y.store_n <= v.store_n;
		y.fpu_load_n <= v.fpu_load_n;
		y.fpu_store_n <= v.fpu_store_n;
		y.exc_n <= v.exc_n;
		y.ecall_n <= v.ecall_n;
		y.ebreak_n <= v.ebreak_n;
		y.mret_n <= v.mret_n;
		y.fence_n <= v.fence_n;
		y.valid_n <= v.valid_n;

		q.pc <= r.pc;
		q.int_wren <= r.int_wren;
		q.fpu_wren <= r.fpu_wren;
		q.csr_wren <= r.csr_wren;
		q.waddr <= r.waddr;
		q.caddr <= r.caddr;
		q.wdata <= r.wdata;
		q.cdata <= r.cdata;
		q.flags <= r.flags;
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
		q.etval <= r.etval;
		q.ecause <= r.ecause;
		q.exc <= r.exc;
		q.ecall <= r.ecall;
		q.ebreak <= r.ebreak;
		q.mret <= r.mret;
		q.fence <= r.fence;
		q.valid <= r.valid;
		q.stall <= r.stall;
		q.flush <= r.flush;
		q.clear <= r.clear;

		q.int_wren_n <= r.int_wren_n;
		q.fpu_wren_n <= r.fpu_wren_n;
		q.csr_wren_n <= r.csr_wren_n;
		q.int_n <= r.int_n;
		q.fpu_n <= r.fpu_n;
		q.csr_n <= r.csr_n;
		q.comp_n <= r.comp_n;
		q.load_n <= r.load_n;
		q.store_n <= r.store_n;
		q.fpu_load_n <= r.fpu_load_n;
		q.fpu_store_n <= r.fpu_store_n;
		q.exc_n <= r.exc_n;
		q.ecall_n <= r.ecall_n;
		q.ebreak_n <= r.ebreak_n;
		q.mret_n <= r.mret_n;
		q.fence_n <= r.fence_n;
		q.valid_n <= r.valid_n;

	end process;

	ASYNCHRONOUS : if reset_async = true generate

		process(reset,clock)
		begin

			if reset = reset_active then

				r <= init_memory_reg;

			elsif rising_edge(clock) then

				r <= rin;

			end if;

		end process;

	end generate ASYNCHRONOUS;

	SYNCHRONOUS : if reset_async = false generate

		process(clock)

		begin

			if rising_edge(clock) then

				if reset = reset_active then

					r <= init_memory_reg;

				else

					r <= rin;

				end if;

			end if;

		end process;

	end generate SYNCHRONOUS;

end architecture;
