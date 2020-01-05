-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.lzc_wire.all;
use work.fp_cons.all;
use work.fp_typ.all;
use work.fp_wire.all;
use work.fp_func.all;

entity fp_pipe is
	port(
		reset     : in  std_logic;
		clock     : in  std_logic;
		fpu_i     : in  fpu_in_type;
		fpu_o     : out fpu_out_type;
		fp_exe_o  : in  fp_exe_out_type;
		fp_exe_i  : out fp_exe_in_type;
		fp_reg_o  : in  fp_reg_out_type;
		fp_reg_ri : out fp_reg_read_in_type;
		fp_reg_wi : out fp_reg_write_in_type;
		fp_for_o  : in  fp_for_out_type;
		fp_for_i  : out fp_for_in_type
	);
end fp_pipe;

architecture behavior of fp_pipe is

signal r_dec   : fp_decode_reg_type := init_fp_decode_reg;
signal rin_dec : fp_decode_reg_type := init_fp_decode_reg;

signal r_exe   : fp_execute_reg_type := init_fp_execute_reg;
signal rin_exe : fp_execute_reg_type := init_fp_execute_reg;

signal r_mem   : fp_memory_reg_type := init_fp_memory_reg;
signal rin_mem : fp_memory_reg_type := init_fp_memory_reg;

signal r_wrb   : fp_writeback_reg_type := init_fp_writeback_reg;
signal rin_wrb : fp_writeback_reg_type := init_fp_writeback_reg;


begin

	decode : process(r_dec,r_exe,r_mem,fpu_i)

		variable v : fp_decode_reg_type;

	begin

		v.instr := fpu_i.instr;

		v.stall := '0';

		v.raddr1 := v.instr(19 downto 15);
		v.raddr2 := v.instr(24 downto 20);
		v.raddr3 := v.instr(31 downto 27);
		v.waddr := v.instr(11 downto 7);
		v.fmt := v.instr(26 downto 25);
		v.rm := v.instr(14 downto 12);

		v.rden1 := fpu_i.rden1;
		v.rden2 := fpu_i.rden2;
		v.rden3 := fpu_i.rden3;
		v.wren := fpu_i.wren;
		v.load := fpu_i.load;
		v.op := fpu_i.op;

		if and_reduce(v.rm) = '1' then
			v.rm := fpu_i.frm;
		end if;

		if r_dec.load = '1' then
			if (v.rden1 and nor_reduce(r_dec.waddr xor v.raddr1)) = '1' then
				v.stall := '1';
			end if;
			if (v.rden2 and nor_reduce(r_dec.waddr xor v.raddr2)) = '1' then
				v.stall := '1';
			end if;
			if (v.rden3 and nor_reduce(r_dec.waddr xor v.raddr3)) = '1' then
				v.stall := '1';
			end if;
		elsif r_dec.op.fmcycle = '1' then
			v.stall := '1';
		end if;

		fpu_o.dstall <= v.stall;

		if fpu_i.dstall = '1' then
			v.stall := fpu_i.dstall;
		end if;

		if (v.stall or fpu_i.dclear) = '1' then
			v.wren := '0';
			v.load := '0';
			v.op := init_fp_operation;
		end if;

		if fpu_i.dclear = '1' then
			v.stall := '0';
		end if;

		rin_dec <= v;

	end process;

	execute : process(r_dec,r_exe,r_mem,fpu_i,fp_exe_o,fp_reg_o,fp_for_o)

		variable v : fp_execute_reg_type;

	begin

		v.fmt := r_dec.fmt;
		v.rm := r_dec.rm;

		v.waddr := r_dec.waddr;
		v.wren := r_dec.wren;
		v.load := r_dec.load;
		v.op := r_dec.op;

		fp_reg_ri.rden1 <= r_dec.rden1;
		fp_reg_ri.rden2 <= r_dec.rden2;
		fp_reg_ri.rden3 <= r_dec.rden3;

		fp_reg_ri.raddr1 <= r_dec.raddr1;
		fp_reg_ri.raddr2 <= r_dec.raddr2;
		fp_reg_ri.raddr3 <= r_dec.raddr3;

		fp_for_i.reg_en1 <= r_dec.rden1;
		fp_for_i.reg_en2 <= r_dec.rden2;
		fp_for_i.reg_en3 <= r_dec.rden3;
		fp_for_i.reg_addr1 <= r_dec.raddr1;
		fp_for_i.reg_addr2 <= r_dec.raddr2;
		fp_for_i.reg_addr3 <= r_dec.raddr3;
		fp_for_i.reg_data1 <= fp_reg_o.data1;
		fp_for_i.reg_data2 <= fp_reg_o.data2;
		fp_for_i.reg_data3 <= fp_reg_o.data3;
		fp_for_i.exe_en <= r_exe.wren;
		fp_for_i.mem_en <= r_mem.wren;
		fp_for_i.exe_addr <= r_exe.waddr;
		fp_for_i.mem_addr <= r_mem.waddr;
		fp_for_i.exe_data <= r_exe.wdata;
		fp_for_i.mem_data <= r_mem.wdata;

		v.rdata1 := fp_for_o.data1;
		v.rdata2 := fp_for_o.data2;
		v.rdata3 := fp_for_o.data3;

		v.sdata := v.rdata2;

		v.idata := fpu_i.idata;

		if (r_exe.stall or r_mem.stall) = '1' then
			v := r_exe;
		end if;

		v.stall := '0';

		v.enable := not(r_exe.stall or r_mem.stall);
		v.clear := fpu_i.eclear;

		fp_exe_i.idata <= v.idata;
		fp_exe_i.data1 <= v.rdata1;
		fp_exe_i.data2 <= v.rdata2;
		fp_exe_i.data3 <= v.rdata3;
		fp_exe_i.op <= v.op;
		fp_exe_i.fmt <= v.fmt;
		fp_exe_i.rm <= v.rm;
		fp_exe_i.enable <= v.enable;
		fp_exe_i.clear <= v.clear;

		v.wdata := fp_exe_o.result;
		v.flags := fp_exe_o.flags;
		v.ready := fp_exe_o.ready;

		if v.op.fmcycle = '1' then
			if v.ready = '0' then
				v.stall := '1';
			elsif v.ready = '1' then
				v.wren := '1';
			end if;
		end if;

		fpu_o.estall <= v.stall;

		if fpu_i.estall = '1' then
			v.stall := fpu_i.estall;
		end if;

		if (v.stall or fpu_i.eclear) = '1' then
			v.wren := '0';
			v.load := '0';
		end if;

		if fpu_i.eclear = '1' then
			v.stall := '0';
		end if;

		rin_exe <= v;

		fpu_o.wdata <= v.wdata;
		fpu_o.sdata <= v.sdata;
		fpu_o.flags <= v.flags;

	end process;

	memory : process(r_exe,r_mem,fpu_i)

		variable v : fp_memory_reg_type;

	begin

		v.waddr := r_exe.waddr;
		v.wdata := r_exe.wdata;

		v.wren := r_exe.wren;
		v.load := r_exe.load;

		if r_mem.stall = '1' then
			v := r_mem;
		end if;

		v.stall := '0';

		if v.load = '1' then
			v.wdata := nan_boxing(fpu_i.wdata,fpu_i.nbox);
		end if;

		if fpu_i.mstall = '1' then
			v.stall := fpu_i.mstall;
		end if;

		if (v.stall or fpu_i.mclear) = '1' then
			v.wren := '0';
		end if;

		if fpu_i.mclear = '1' then
			v.stall := '0';
		end if;

		rin_mem <= v;

	end process;

	writeback : process(r_mem)

		variable v : fp_writeback_reg_type;

	begin

		v.waddr := r_mem.waddr;
		v.wdata := r_mem.wdata;
		v.wren := r_mem.wren;

		rin_wrb <= v;

		fp_reg_wi.waddr <= v.waddr;
		fp_reg_wi.wdata <= v.wdata;
		fp_reg_wi.wren <= v.wren;

	end process;

	process(clock)

	begin

		if rising_edge(clock) then

			if reset = '0' then

				r_dec <= init_fp_decode_reg;
				r_exe <= init_fp_execute_reg;
				r_mem <= init_fp_memory_reg;
				r_wrb <= init_fp_writeback_reg;

			else

				r_dec <= rin_dec;
				r_exe <= rin_exe;
				r_mem <= rin_mem;
				r_wrb <= rin_wrb;

			end if;

		end if;

	end process;

end behavior;
