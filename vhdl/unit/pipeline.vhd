-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.wire.all;
use work.configure.all;
use work.comp_wire.all;
use work.csr_wire.all;
use work.int_wire.all;
use work.fp_wire.all;

entity pipeline is
	generic(
		fpu_enable      : boolean := fpu_enable;
		fpu_performance : boolean := fpu_performance
	);
	port(
		reset     : in  std_logic;
		clock     : in  std_logic;
		imem_o    : in  mem_out_type;
		imem_i    : out mem_in_type;
		dmem_o    : in  mem_out_type;
		dmem_i    : out mem_in_type;
		ipmp_o    : in  pmp_out_type;
		ipmp_i    : out pmp_in_type;
		dpmp_o    : in  pmp_out_type;
		dpmp_i    : out pmp_in_type;
		time_irpt : in  std_logic;
		ext_irpt  : in  std_logic
	);
end pipeline;

architecture behavior of pipeline is

	component fetch_stage
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
	end component;

	component decode_stage
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
			fpu_dec_o     : in  fpu_dec_out_type;
			fpu_dec_i     : out fpu_dec_in_type;
			a             : in  decode_in_type;
			d             : in  decode_in_type;
			y             : out decode_out_type;
			q             : out decode_out_type
		);
	end component;

	component execute_stage
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
			fpu_exe_o      : in  fpu_exe_out_type;
			fpu_exe_i      : out fpu_exe_in_type;
			dmem_i         : out mem_in_type;
			dpmp_o         : in  pmp_out_type;
			dpmp_i         : out pmp_in_type;
			time_irpt      : in  std_logic;
			ext_irpt       : in  std_logic;
			a              : in  execute_in_type;
			d              : in  execute_in_type;
			y              : out execute_out_type;
			q              : out execute_out_type
		);
	end component;

	component memory_stage
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
	end component;

	component writeback_stage
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
	end component;

	component comp_decode
		port(
			comp_decode_i : in  comp_decode_in_type;
			comp_decode_o : out comp_decode_out_type
		);
	end component;

	component csr_unit
		port(
			reset      : in  std_logic;
			clock      : in  std_logic;
			csr_unit_i : in  csr_unit_in_type;
			csr_unit_o : out csr_unit_out_type
		);
	end component;

	component int_unit
		port(
			reset      : in  std_logic;
			clock      : in  std_logic;
			int_unit_i : in  int_unit_in_type;
			int_unit_o : out int_unit_out_type
		);
	end component;

	component bp
		port(
			reset : in  std_logic;
			clock : in  std_logic;
			bp_i  : in  bp_in_type;
			bp_o  : out bp_out_type;
			bht_i : out bht_in_type;
			bht_o : in  bht_out_type;
			btb_i : out btb_in_type;
			btb_o : in  btb_out_type;
			ras_i : out ras_in_type;
			ras_o : in  ras_out_type
		);
	end component;

	component bht
		port(
			reset : in  std_logic;
			clock : in  std_logic;
			bht_i : in  bht_in_type;
			bht_o : out bht_out_type
		);
	end component;

	component btb
		port(
			reset : in  std_logic;
			clock : in  std_logic;
			btb_i : in  btb_in_type;
			btb_o : out btb_out_type
		);
	end component;

	component ras
		port(
			reset : in  std_logic;
			clock : in  std_logic;
			ras_i : in  ras_in_type;
			ras_o : out ras_out_type
		);
	end component;

	component prefetch
		port(
			reset     : in  std_logic;
			clock     : in  std_logic;
			pfetch_i  : in  prefetch_in_type;
			pfetch_o  : out prefetch_out_type
  	);
  end component;

	component cache
		port(
			reset   : in  std_logic;
			clock   : in  std_logic;
			cache_i : in  cache_in_type;
			cache_o : out cache_out_type;
			mem_o   : in  mem_out_type;
			mem_i   : out mem_in_type
		);
	end component;

	component fpu
		port(
			reset     : in  std_logic;
			clock     : in  std_logic;
			fpu_dec_i : in  fpu_dec_in_type;
			fpu_dec_o : out fpu_dec_out_type;
			fpu_exe_i : in  fpu_exe_in_type;
			fpu_exe_o : out fpu_exe_out_type;
			fpu_mem_i : in  fpu_mem_in_type;
			fp_dec_i  : in  fp_dec_in_type;
			fp_dec_o  : out fp_dec_out_type
		);
	end component;

	signal fetch_y     : fetch_out_type;
	signal decode_y    : decode_out_type;
	signal execute_y   : execute_out_type;
	signal memory_y    : memory_out_type;
	signal writeback_y : writeback_out_type;

	signal fetch_q     : fetch_out_type;
	signal decode_q    : decode_out_type;
	signal execute_q   : execute_out_type;
	signal memory_q    : memory_out_type;
	signal writeback_q : writeback_out_type;

	signal comp_decode_i : comp_decode_in_type;
	signal comp_decode_o : comp_decode_out_type;

	signal fp_dec_i : fp_dec_in_type;
	signal fp_dec_o : fp_dec_out_type;

	signal csr_unit_i : csr_unit_in_type;
	signal csr_unit_o : csr_unit_out_type;

	signal int_unit_i : int_unit_in_type;
	signal int_unit_o : int_unit_out_type;

	signal bp_i : bp_in_type;
	signal bp_o : bp_out_type;

	signal bht_i : bht_in_type;
	signal bht_o : bht_out_type;

	signal btb_i : btb_in_type;
	signal btb_o : btb_out_type;

	signal ras_i : ras_in_type;
	signal ras_o : ras_out_type;

	signal pfetch_i : prefetch_in_type;
	signal pfetch_o : prefetch_out_type;

	signal pbuffer_i : prebuffer_in_type;
	signal pbuffer_o : prebuffer_out_type;

	signal icache_i : cache_in_type;
	signal icache_o : cache_out_type;

	signal fpu_dec_i : fpu_dec_in_type;
	signal fpu_dec_o : fpu_dec_out_type;

	signal fpu_exe_i : fpu_exe_in_type;
	signal fpu_exe_o : fpu_exe_out_type;

	signal fpu_mem_i : fpu_mem_in_type;

begin

	fetch_stage_comp : fetch_stage
		port map(
			reset    => reset,
			clock    => clock,
			csr_eo   => csr_unit_o.csr_eo,
			bp_o     => bp_o,
			bp_i     => bp_i,
			pfetch_o => pfetch_o,
			pfetch_i => pfetch_i,
			icache_o => icache_o,
			icache_i => icache_i,
			ipmp_o   => ipmp_o,
			ipmp_i   => ipmp_i,
			a.f      => fetch_y,
			a.d      => decode_y,
			a.e      => execute_y,
			a.m      => memory_y,
			a.w      => writeback_y,
			d.f      => fetch_q,
			d.d      => decode_q,
			d.e      => execute_q,
			d.m      => memory_q,
			d.w      => writeback_q,
			y        => fetch_y,
			q        => fetch_q
		);

	decode_stage_comp : decode_stage
		port map(
			reset         => reset,
			clock         => clock,
			int_decode_i  => int_unit_i.int_decode_i,
			int_decode_o  => int_unit_o.int_decode_o,
			comp_decode_i => comp_decode_i,
			comp_decode_o => comp_decode_o,
			fp_dec_i      => fp_dec_i,
			fp_dec_o      => fp_dec_o,
			csr_eo        => csr_unit_o.csr_eo,
			fpu_dec_o     => fpu_dec_o,
			fpu_dec_i     => fpu_dec_i,
			a.f           => fetch_y,
			a.d           => decode_y,
			a.e           => execute_y,
			a.m           => memory_y,
			a.w           => writeback_y,
			d.f           => fetch_q,
			d.d           => decode_q,
			d.e           => execute_q,
			d.m           => memory_q,
			d.w           => writeback_q,
			y             => decode_y,
			q             => decode_q
		);

	execute_stage_comp : execute_stage
		port map(
			reset          => reset,
			clock          => clock,
			int_reg_ri     => int_unit_i.int_reg_ri,
			int_for_i      => int_unit_i.int_for_i,
			int_for_o      => int_unit_o.int_for_o,
			int_reg_o      => int_unit_o.int_reg_o,
			csr_ri         => csr_unit_i.csr_ri,
			csr_ei         => csr_unit_i.csr_ei,
			csr_o          => csr_unit_o.csr_o,
			int_pipeline_i => int_unit_i.int_pipeline_i,
			int_pipeline_o => int_unit_o.int_pipeline_o,
			csr_alu_i      => csr_unit_i.csr_alu_i,
			csr_alu_o      => csr_unit_o.csr_alu_o,
			csr_eo         => csr_unit_o.csr_eo,
			fpu_exe_o      => fpu_exe_o,
			fpu_exe_i      => fpu_exe_i,
			dmem_i         => dmem_i,
			dpmp_o         => dpmp_o,
			dpmp_i         => dpmp_i,
			time_irpt      => time_irpt,
			ext_irpt       => ext_irpt,
			a.f            => fetch_y,
			a.d            => decode_y,
			a.e            => execute_y,
			a.m            => memory_y,
			a.w            => writeback_y,
			d.f            => fetch_q,
			d.d            => decode_q,
			d.e            => execute_q,
			d.m            => memory_q,
			d.w            => writeback_q,
			y              => execute_y,
			q              => execute_q
		);

	memory_stage_comp : memory_stage
		port map(
			reset     => reset,
			clock     => clock,
			csr_eo    => csr_unit_o.csr_eo,
			fpu_mem_i => fpu_mem_i,
			dmem_o    => dmem_o,
			a.f       => fetch_y,
			a.d       => decode_y,
			a.e       => execute_y,
			a.m       => memory_y,
			a.w       => writeback_y,
			d.f       => fetch_q,
			d.d       => decode_q,
			d.e       => execute_q,
			d.m       => memory_q,
			d.w       => writeback_q,
			y         => memory_y,
			q         => memory_q
		);

	writeback_stage_comp : writeback_stage
		port map(
			reset      => reset,
			clock      => clock,
			int_reg_wi => int_unit_i.int_reg_wi,
			csr_wi     => csr_unit_i.csr_wi,
			csr_ci     => csr_unit_i.csr_ci,
			csr_eo     => csr_unit_o.csr_eo,
			a.f        => fetch_y,
			a.d        => decode_y,
			a.e        => execute_y,
			a.m        => memory_y,
			a.w        => writeback_y,
			d.f        => fetch_q,
			d.d        => decode_q,
			d.e        => execute_q,
			d.m        => memory_q,
			d.w        => writeback_q,
			y          => writeback_y,
			q          => writeback_q
		);

	comp_decode_comp : comp_decode
		port map(
			comp_decode_i => comp_decode_i,
			comp_decode_o => comp_decode_o
		);

	csr_unit_comp : csr_unit
		port map(
			reset      => reset,
			clock      => clock,
			csr_unit_i => csr_unit_i,
			csr_unit_o => csr_unit_o
		);

	int_unit_comp : int_unit
		port map(
			reset      => reset,
			clock      => clock,
			int_unit_i => int_unit_i,
			int_unit_o => int_unit_o
		);

	bp_comp : bp
		port map(
			reset => reset,
			clock => clock,
			bp_i  => bp_i,
			bp_o  => bp_o,
			bht_i => bht_i,
			bht_o => bht_o,
			btb_i => btb_i,
			btb_o => btb_o,
			ras_i => ras_i,
			ras_o => ras_o
		);

	bht_comp : bht
		port map(
			reset => reset,
			clock => clock,
			bht_i => bht_i,
			bht_o => bht_o
		);

	btb_comp : btb
		port map(
			reset => reset,
			clock => clock,
			btb_i => btb_i,
			btb_o => btb_o
		);

	ras_comp : ras
		port map(
			reset => reset,
			clock => clock,
			ras_i => ras_i,
			ras_o => ras_o
		);

	prefetch_comp : prefetch
		port map(
			reset     => reset,
			clock     => clock,
			pfetch_i  => pfetch_i,
			pfetch_o  => pfetch_o
		);

	icache_comp : cache
		port map(
			reset   => reset,
			clock   => clock,
			cache_i => icache_i,
			cache_o => icache_o,
			mem_o   => imem_o,
			mem_i   => imem_i
		);

	FP_Unit : if fpu_enable = true generate

		fpu_comp : fpu
			port map(
				reset     => reset,
				clock     => clock,
				fpu_dec_i => fpu_dec_i,
				fpu_dec_o => fpu_dec_o,
				fpu_exe_i => fpu_exe_i,
				fpu_exe_o => fpu_exe_o,
				fpu_mem_i => fpu_mem_i,
				fp_dec_i  => fp_dec_i,
				fp_dec_o  => fp_dec_o
			);

	end generate FP_Unit;

end architecture;
