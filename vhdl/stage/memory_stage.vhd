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
		fpu_mem_i : out fpu_mem_in_type;
		dmem_o    : in  mem_out_type;
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

	combinational : process(a, d, r, csr_eo, dmem_o)

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
		v.valid := d.e.valid;
		v.byteenable := d.e.byteenable;

		if (d.m.stall or d.w.stall) = '1' then
			v := r;
		end if;

		v.stall := '0';

		v.clear := d.w.clear;

		if (v.load or v.fpu_load) = '1' then
			v.wdata := load_data(dmem_o.mem_rdata, v.byteenable, v.load_op);
			v.stall := not dmem_o.mem_ready;
			if v.int = '1' then
				v.istall := v.stall;
			elsif v.fpu = '1' then
				v.fstall := v.stall;
			end if;
		elsif (v.store or v.fpu_store) = '1' then
			v.stall := not dmem_o.mem_ready;
			if v.int = '1' then
				v.istall := v.stall;
			elsif v.fpu = '1' then
				v.fstall := v.stall;
			end if;
		end if;

		if dmem_o.mem_ready = '1' then
			if v.istall = '1' then
				v.istall := '0';
				v.int := '1';
				v.int_wren := v.load and or_reduce(v.waddr);
			elsif v.fstall = '1' then
				v.fstall := '0';
				v.fpu := '1';
				v.fpu_wren := v.fpu_load;
			end if;
		end if;

		fpu_mem_i.wdata <= v.wdata;
		fpu_mem_i.nbox <= v.load_op.mem_lw;

		fpu_mem_i.stall <= v.stall;
		fpu_mem_i.clear <= v.clear;

		if (v.stall or v.clear) = '1' then
			v.int_wren := '0';
			v.fpu_wren := '0';
			v.csr_wren := '0';
			v.int := '0';
			v.fpu := '0';
			v.csr := '0';
			v.exc := '0';
			v.mret := '0';
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
		y.load_op <= v.load_op;
		y.store_op <= v.store_op;
		y.int_op <= v.int_op;
		y.fpu_op <= v.fpu_op;
		y.byteenable <= v.byteenable;
		y.etval <= v.etval;
		y.ecause <= v.ecause;
		y.exc <= v.exc;
		y.ecall <= v.ecall;
		y.ebreak <= v.ebreak;
		y.mret <= v.mret;
		y.valid <= v.valid;
		y.stall <= v.stall;
		y.clear <= v.clear;

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
		q.load_op <= r.load_op;
		q.store_op <= r.store_op;
		q.int_op <= r.int_op;
		q.fpu_op <= r.fpu_op;
		q.byteenable <= r.byteenable;
		q.etval <= r.etval;
		q.ecause <= r.ecause;
		q.exc <= r.exc;
		q.ecall <= r.ecall;
		q.ebreak <= r.ebreak;
		q.mret <= r.mret;
		q.valid <= r.valid;
		q.stall <= r.stall;
		q.clear <= r.clear;

	end process;

	process(clock)
	begin
		if rising_edge(clock) then

			if reset = '0' then

				r <= init_memory_reg;

			else

				r <= rin;

			end if;

		end if;

	end process;

end architecture;
