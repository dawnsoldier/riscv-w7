-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;
use work.constants.all;
use work.wire.all;
use work.functions.all;
use work.csr_wire.all;
use work.int_wire.all;
use work.fp_wire.all;

entity writeback_stage is
	port(
		reset      : in  std_logic;
		clock      : in  std_logic;
		int_reg_wi : out int_register_write_in_type;
		csr_wi     : out csr_write_in_type;
		csr_ci     : out csr_counter_in_type;
		csr_eo     : in  csr_exception_out_type;
		a          : in  writeback_in_type;
		d          : in  writeback_in_type;
		y          : out writeback_out_type;
		q          : out writeback_out_type
	);
end writeback_stage;

architecture behavior of writeback_stage is

	signal r   : writeback_reg_type;
	signal rin : writeback_reg_type;

begin

	combinational : process(a, d, r, csr_eo)

		variable v : writeback_reg_type;

	begin

		v := r;

		v.pc := d.m.pc;
		v.int_wren := d.m.int_wren;
		v.fpu_wren := d.m.fpu_wren;
		v.csr_wren := d.m.csr_wren;
		v.waddr := d.m.waddr;
		v.wdata := d.m.wdata;
		v.caddr := d.m.caddr;
		v.cdata := d.m.cdata;
		v.load := d.m.load;
		v.store := d.m.store;
		v.fpu_load := d.m.fpu_load;
		v.fpu_store := d.m.fpu_store;
		v.int := d.m.int;
		v.fpu := d.m.fpu;
		v.csr := d.m.csr;
		v.load_op := d.m.load_op;
		v.store_op := d.m.store_op;
		v.int_op := d.m.int_op;
		v.fpu_op := d.m.fpu_op;
		v.exc := d.m.exc;
		v.etval := d.m.etval;
		v.ecause := d.m.ecause;
		v.ecall := d.m.ecall;
		v.ebreak := d.m.ebreak;
		v.mret := d.m.mret;
		v.byteenable := d.m.byteenable;
		v.flags := d.m.flags;

		if d.w.stall = '1' then
			v := r;
		end if;

		v.stall := '0';

		v.clear := d.w.clear;

		if (v.stall or v.clear) = '1' then
			v.int_wren := '0';
			v.csr_wren := '0';
			v.int := '0';
			v.fpu := '0';
			v.csr := '0';
			v.load := '0';
			v.store := '0';
			v.exc := '0';
			v.mret := '0';
			v.clear := '0';
		end if;

		if v.clear = '1' then
			v.stall := '0';
		end if;

		int_reg_wi.wren <= v.int_wren;
		int_reg_wi.waddr <= v.waddr;
		int_reg_wi.wdata <= v.wdata;

		csr_wi.wren <= v.csr_wren;
		csr_wi.waddr <= v.caddr;
		csr_wi.wdata <= v.cdata;

		csr_ci.load <= v.load;
		csr_ci.store <= v.store;
		csr_ci.int <= v.int;
		csr_ci.fpu <= v.fpu;
		csr_ci.csr <= v.csr;
		csr_ci.int_op <= v.int_op;
		csr_ci.fpu_op <= v.fpu_op;
		csr_ci.flags <= v.flags;

		rin <= v;

		y.exc <= v.exc;
		y.ecall <= v.ecall;
		y.ebreak <= v.ebreak;
		y.mret <= v.mret;
		y.stall <= v.stall;
		y.clear <= v.clear;

		q.exc <= r.exc;
		q.ecall <= r.ecall;
		q.ebreak <= r.ebreak;
		q.mret <= r.mret;
		q.stall <= r.stall;
		q.clear <= r.clear;

	end process;

	process(clock)
	begin
		if rising_edge(clock) then

			if reset = '0' then

				r <= init_writeback_reg;

			else

				r <= rin;

			end if;

		end if;

	end process;

end architecture;
