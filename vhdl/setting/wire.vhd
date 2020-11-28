-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;
use work.constants.all;
use work.int_wire.all;
use work.fp_wire.all;
use work.csr_wire.all;

package wire is

	type fetch_out_type is record
		pc     : std_logic_vector(63 downto 0);
		instr  : std_logic_vector(31 downto 0);
		taken  : std_logic;
		etval  : std_logic_vector(63 downto 0);
		ecause : std_logic_vector(3 downto 0);
		exc    : std_logic;
		clear  : std_logic;
	end record;

	type fetch_reg_type is record
		pc     : std_logic_vector(63 downto 0);
		instr  : std_logic_vector(31 downto 0);
		taken  : std_logic;
		spec   : std_logic;
		valid  : std_logic;
		clear  : std_logic;
		etval  : std_logic_vector(63 downto 0);
		ecause : std_logic_vector(3 downto 0);
		exc    : std_logic;
		stall  : std_logic;
		inc    : unsigned(2 downto 0);
	end record;

	constant init_fetch_reg : fetch_reg_type := (
		pc     => start_base_addr,
		instr  => (others => '0'),
		taken  => '0',
		spec   => '0',
		valid  => '0',
		clear  => '0',
		etval  => (others => '0'),
		ecause => (others => '0'),
		exc    => '0',
		stall  => '0',
		inc    => (others => '0')
	);

	type decode_out_type is record
		pc          : std_logic_vector(63 downto 0);
		npc         : std_logic_vector(63 downto 0);
		funct3      : std_logic_vector(2 downto 0);
		funct7      : std_logic_vector(6 downto 0);
		fmt         : std_logic_vector(1 downto 0);
		rm          : std_logic_vector(2 downto 0);
		imm         : std_logic_vector(63 downto 0);
		int_rden1   : std_logic;
		int_rden2   : std_logic;
		csr_rden    : std_logic;
		int_wren    : std_logic;
		fpu_wren    : std_logic;
		csr_wren    : std_logic;
		raddr1      : std_logic_vector(4 downto 0);
		raddr2      : std_logic_vector(4 downto 0);
		raddr3      : std_logic_vector(4 downto 0);
		waddr       : std_logic_vector(4 downto 0);
		caddr       : std_logic_vector(11 downto 0);
		load        : std_logic;
		store       : std_logic;
		fpu_load    : std_logic;
		fpu_store   : std_logic;
		int         : std_logic;
		fpu         : std_logic;
		csr         : std_logic;
		comp        : std_logic;
		load_op     : load_operation_type;
		store_op    : store_operation_type;
		int_op      : int_operation_type;
		fpu_op      : fp_operation_type;
		return_pop  : std_logic;
		return_push : std_logic;
		jump_uncond : std_logic;
		jump_rest   : std_logic;
		taken       : std_logic;
		etval       : std_logic_vector(63 downto 0);
		ecause      : std_logic_vector(3 downto 0);
		exc         : std_logic;
		ecall       : std_logic;
		ebreak      : std_logic;
		mret        : std_logic;
		wfi         : std_logic;
		fence       : std_logic;
		valid       : std_logic;
		stall       : std_logic;
		clear       : std_logic;
	end record;

	type decode_reg_type is record
		pc              : std_logic_vector(63 downto 0);
		npc             : std_logic_vector(63 downto 0);
		instr           : std_logic_vector(31 downto 0);
		opcode          : std_logic_vector(6 downto 0);
		funct3          : std_logic_vector(2 downto 0);
		funct7          : std_logic_vector(6 downto 0);
		fmt             : std_logic_vector(1 downto 0);
		rm              : std_logic_vector(2 downto 0);
		imm             : std_logic_vector(63 downto 0);
		int_rden1       : std_logic;
		int_rden2       : std_logic;
		fpu_rden1       : std_logic;
		fpu_rden2       : std_logic;
		fpu_rden3       : std_logic;
		csr_rden        : std_logic;
		int_wren        : std_logic;
		fpu_wren        : std_logic;
		csr_wren        : std_logic;
		raddr1          : std_logic_vector(4 downto 0);
		raddr2          : std_logic_vector(4 downto 0);
		raddr3          : std_logic_vector(4 downto 0);
		waddr           : std_logic_vector(4 downto 0);
		caddr           : std_logic_vector(11 downto 0);
		load            : std_logic;
		store           : std_logic;
		fpu_load        : std_logic;
		fpu_store       : std_logic;
		int             : std_logic;
		fpu             : std_logic;
		csr             : std_logic;
		comp            : std_logic;
		csr_mode        : std_logic_vector(1 downto 0);
		load_op         : load_operation_type;
		store_op        : store_operation_type;
		int_op          : int_operation_type;
		fpu_op          : fp_operation_type;
		return_pop      : std_logic;
		return_push     : std_logic;
		jump_uncond     : std_logic;
		jump_rest       : std_logic;
		link_waddr      : boolean;
		link_raddr1     : boolean;
		raddr1_eq_waddr : boolean;
		zero_waddr      : boolean;
		inc             : unsigned(2 downto 0);
		taken           : std_logic;
		etval           : std_logic_vector(63 downto 0);
		ecause          : std_logic_vector(3 downto 0);
		exc             : std_logic;
		ecall           : std_logic;
		ebreak          : std_logic;
		mret            : std_logic;
		wfi             : std_logic;
		fence           : std_logic;
		valid           : std_logic;
		clear           : std_logic;
		stall           : std_logic;
	end record;

	constant init_decode_reg : decode_reg_type := (
		pc              => (others => '0'),
		npc             => (others => '0'),
		instr           => (others => '0'),
		opcode          => (others => '0'),
		funct3          => (others => '0'),
		funct7          => (others => '0'),
		fmt             => (others => '0'),
		rm              => (others => '0'),
		imm             => (others => '0'),
		int_rden1       => '0',
		int_rden2       => '0',
		fpu_rden1       => '0',
		fpu_rden2       => '0',
		fpu_rden3       => '0',
		csr_rden        => '0',
		int_wren        => '0',
		fpu_wren        => '0',
		csr_wren        => '0',
		raddr1          => (others => '0'),
		raddr2          => (others => '0'),
		raddr3          => (others => '0'),
		waddr           => (others => '0'),
		caddr           => (others => '0'),
		load            => '0',
		store           => '0',
		fpu_load        => '0',
		fpu_store       => '0',
		int             => '0',
		fpu             => '0',
		csr             => '0',
		comp            => '0',
		csr_mode        => (others => '0'),
		load_op         => init_load_operation,
		store_op        => init_store_operation,
		int_op          => init_int_operation,
		fpu_op          => init_fp_operation,
		return_pop      => '0',
		return_push     => '0',
		jump_uncond     => '0',
		jump_rest       => '0',
		link_waddr      => false,
		link_raddr1     => false,
		raddr1_eq_waddr => false,
		zero_waddr      => false,
		inc             => (others => '0'),
		taken           => '0',
		etval           => (others => '0'),
		ecause          => (others => '0'),
		exc             => '0',
		ecall           => '0',
		ebreak          => '0',
		mret            => '0',
		wfi             => '0',
		fence           => '0',
		valid           => '0',
		clear           => '0',
		stall           => '0'
	);

	type execute_out_type is record
		pc          : std_logic_vector(63 downto 0);
		npc         : std_logic_vector(63 downto 0);
		funct3      : std_logic_vector(2 downto 0);
		int_wren    : std_logic;
		fpu_wren    : std_logic;
		csr_wren    : std_logic;
		waddr       : std_logic_vector(4 downto 0);
		caddr       : std_logic_vector(11 downto 0);
		wdata       : std_logic_vector(63 downto 0);
		cdata       : std_logic_vector(63 downto 0);
		sdata       : std_logic_vector(63 downto 0);
		flags       : std_logic_vector(4 downto 0);
		load        : std_logic;
		store       : std_logic;
		fpu_load    : std_logic;
		fpu_store   : std_logic;
		int         : std_logic;
		fpu         : std_logic;
		csr         : std_logic;
		load_op     : load_operation_type;
		store_op    : store_operation_type;
		int_op      : int_operation_type;
		fpu_op      : fp_operation_type;
		return_pop  : std_logic;
		return_push : std_logic;
		jump_uncond : std_logic;
		jump_rest   : std_logic;
		taken       : std_logic;
		jump        : std_logic;
		address     : std_logic_vector(63 downto 0);
		byteenable  : std_logic_vector(7 downto 0);
		strobe      : std_logic_vector(7 downto 0);
		etval       : std_logic_vector(63 downto 0);
		ecause      : std_logic_vector(3 downto 0);
		exc         : std_logic;
		ecall       : std_logic;
		ebreak      : std_logic;
		mret        : std_logic;
		valid       : std_logic;
		stall       : std_logic;
		clear       : std_logic;
	end record;

	type execute_reg_type is record
		pc          : std_logic_vector(63 downto 0);
		npc         : std_logic_vector(63 downto 0);
		funct3      : std_logic_vector(2 downto 0);
		funct7      : std_logic_vector(6 downto 0);
		imm         : std_logic_vector(63 downto 0);
		fmt         : std_logic_vector(1 downto 0);
		rm          : std_logic_vector(2 downto 0);
		csr_rden    : std_logic;
		int_wren    : std_logic;
		fpu_wren    : std_logic;
		csr_wren    : std_logic;
		raddr1      : std_logic_vector(4 downto 0);
		waddr       : std_logic_vector(4 downto 0);
		caddr       : std_logic_vector(11 downto 0);
		rdata1      : std_logic_vector(63 downto 0);
		rdata2      : std_logic_vector(63 downto 0);
		wdata       : std_logic_vector(63 downto 0);
		sdata       : std_logic_vector(63 downto 0);
		idata       : std_logic_vector(63 downto 0);
		cdata       : std_logic_vector(63 downto 0);
		flags       : std_logic_vector(4 downto 0);
		load        : std_logic;
		store       : std_logic;
		fpu_load    : std_logic;
		fpu_store   : std_logic;
		int         : std_logic;
		fpu         : std_logic;
		csr         : std_logic;
		comp        : std_logic;
		load_op     : load_operation_type;
		store_op    : store_operation_type;
		int_op      : int_operation_type;
		fpu_op      : fp_operation_type;
		return_pop  : std_logic;
		return_push : std_logic;
		jump_uncond : std_logic;
		jump_rest   : std_logic;
		taken       : std_logic;
		jump        : std_logic;
		address     : std_logic_vector(63 downto 0);
		byteenable  : std_logic_vector(7 downto 0);
		strobe      : std_logic_vector(7 downto 0);
		enable      : std_logic;
		ready       : std_logic;
		etval       : std_logic_vector(63 downto 0);
		ecause      : std_logic_vector(3 downto 0);
		exc         : std_logic;
		ecall       : std_logic;
		ebreak      : std_logic;
		mret        : std_logic;
		valid       : std_logic;
		clear       : std_logic;
		stall       : std_logic;
	end record;

	constant init_execute_reg : execute_reg_type := (
		pc          => (others => '0'),
		npc         => (others => '0'),
		funct3      => (others => '0'),
		funct7      => (others => '0'),
		imm         => (others => '0'),
		fmt         => (others => '0'),
		rm          => (others => '0'),
		csr_rden    => '0',
		int_wren    => '0',
		fpu_wren    => '0',
		csr_wren    => '0',
		raddr1      => (others => '0'),
		waddr       => (others => '0'),
		caddr       => (others => '0'),
		rdata1      => (others => '0'),
		rdata2      => (others => '0'),
		wdata       => (others => '0'),
		sdata       => (others => '0'),
		idata       => (others => '0'),
		cdata       => (others => '0'),
		flags       => (others => '0'),
		load        => '0',
		store       => '0',
		fpu_load    => '0',
		fpu_store   => '0',
		int         => '0',
		fpu         => '0',
		csr         => '0',
		comp        => '0',
		load_op     => init_load_operation,
		store_op    => init_store_operation,
		int_op      => init_int_operation,
		fpu_op      => init_fp_operation,
		return_pop  => '0',
		return_push => '0',
		jump_uncond => '0',
		jump_rest   => '0',
		taken       => '0',
		jump        => '0',
		address     => (others => '0'),
		byteenable  => (others => '0'),
		strobe      => (others => '0'),
		enable      => '0',
		ready       => '0',
		etval       => (others => '0'),
		ecause      => (others => '0'),
		exc         => '0',
		ecall       => '0',
		ebreak      => '0',
		mret        => '0',
		valid       => '0',
		clear       => '0',
		stall       => '0'
	);

	type memory_out_type is record
		pc         : std_logic_vector(63 downto 0);
		int_wren   : std_logic;
		fpu_wren   : std_logic;
		csr_wren   : std_logic;
		waddr      : std_logic_vector(4 downto 0);
		caddr      : std_logic_vector(11 downto 0);
		wdata      : std_logic_vector(63 downto 0);
		cdata      : std_logic_vector(63 downto 0);
		flags      : std_logic_vector(4 downto 0);
		load       : std_logic;
		store      : std_logic;
		fpu_load   : std_logic;
		fpu_store  : std_logic;
		int        : std_logic;
		fpu        : std_logic;
		csr        : std_logic;
		load_op    : load_operation_type;
		store_op   : store_operation_type;
		int_op     : int_operation_type;
		fpu_op     : fp_operation_type;
		byteenable : std_logic_vector(7 downto 0);
		etval      : std_logic_vector(63 downto 0);
		ecause     : std_logic_vector(3 downto 0);
		exc        : std_logic;
		ecall      : std_logic;
		ebreak     : std_logic;
		mret       : std_logic;
		valid      : std_logic;
		stall      : std_logic;
		clear      : std_logic;
	end record;

	type memory_reg_type is record
		pc         : std_logic_vector(63 downto 0);
		funct3     : std_logic_vector(2 downto 0);
		int_wren   : std_logic;
		fpu_wren   : std_logic;
		csr_wren   : std_logic;
		waddr      : std_logic_vector(4 downto 0);
		caddr      : std_logic_vector(11 downto 0);
		wdata      : std_logic_vector(63 downto 0);
		cdata      : std_logic_vector(63 downto 0);
		flags      : std_logic_vector(4 downto 0);
		load       : std_logic;
		store      : std_logic;
		fpu_load   : std_logic;
		fpu_store  : std_logic;
		int        : std_logic;
		fpu        : std_logic;
		csr        : std_logic;
		load_op    : load_operation_type;
		store_op   : store_operation_type;
		int_op     : int_operation_type;
		fpu_op     : fp_operation_type;
		byteenable : std_logic_vector(7 downto 0);
		etval      : std_logic_vector(63 downto 0);
		ecause     : std_logic_vector(3 downto 0);
		exc        : std_logic;
		ecall      : std_logic;
		ebreak     : std_logic;
		mret       : std_logic;
		valid      : std_logic;
		clear      : std_logic;
		fstall     : std_logic;
		istall     : std_logic;
		stall      : std_logic;
	end record;

	constant init_memory_reg : memory_reg_type := (
		pc         => (others => '0'),
		funct3     => (others => '0'),
		int_wren   => '0',
		fpu_wren   => '0',
		csr_wren   => '0',
		waddr      => (others => '0'),
		caddr      => (others => '0'),
		wdata      => (others => '0'),
		cdata      => (others => '0'),
		flags      => (others => '0'),
		load       => '0',
		store      => '0',
		fpu_load   => '0',
		fpu_store  => '0',
		int        => '0',
		fpu        => '0',
		csr        => '0',
		load_op    => init_load_operation,
		store_op   => init_store_operation,
		int_op     => init_int_operation,
		fpu_op     => init_fp_operation,
		byteenable => (others => '0'),
		etval      => (others => '0'),
		ecause     => (others => '0'),
		exc        => '0',
		ecall      => '0',
		ebreak     => '0',
		mret       => '0',
		valid      => '0',
		clear      => '0',
		fstall     => '0',
		istall     => '0',
		stall      => '0'
	);

	type writeback_out_type is record
		pc     : std_logic_vector(63 downto 0);
		exc    : std_logic;
		ecall  : std_logic;
		ebreak : std_logic;
		mret   : std_logic;
		valid  : std_logic;
		stall  : std_logic;
		clear  : std_logic;
	end record;

	type writeback_reg_type is record
		pc         : std_logic_vector(63 downto 0);
		int_wren   : std_logic;
		fpu_wren   : std_logic;
		csr_wren   : std_logic;
		waddr      : std_logic_vector(4 downto 0);
		caddr      : std_logic_vector(11 downto 0);
		wdata      : std_logic_vector(63 downto 0);
		cdata      : std_logic_vector(63 downto 0);
		flags      : std_logic_vector(4 downto 0);
		load       : std_logic;
		store      : std_logic;
		fpu_load   : std_logic;
		fpu_store  : std_logic;
		int        : std_logic;
		fpu        : std_logic;
		csr        : std_logic;
		load_op    : load_operation_type;
		store_op   : store_operation_type;
		int_op     : int_operation_type;
		fpu_op     : fp_operation_type;
		byteenable : std_logic_vector(7 downto 0);
		etval      : std_logic_vector(63 downto 0);
		ecause     : std_logic_vector(3 downto 0);
		exc        : std_logic;
		ecall      : std_logic;
		ebreak     : std_logic;
		mret       : std_logic;
		valid      : std_logic;
		clear      : std_logic;
		stall      : std_logic;
	end record;

	constant init_writeback_reg : writeback_reg_type := (
		pc         => (others => '0'),
		int_wren   => '0',
		fpu_wren   => '0',
		csr_wren   => '0',
		waddr      => (others => '0'),
		caddr      => (others => '0'),
		wdata      => (others => '0'),
		cdata      => (others => '0'),
		flags      => (others => '0'),
		load       => '0',
		store      => '0',
		fpu_load   => '0',
		fpu_store  => '0',
		int        => '0',
		fpu        => '0',
		csr        => '0',
		load_op    => init_load_operation,
		store_op   => init_store_operation,
		int_op     => init_int_operation,
		fpu_op     => init_fp_operation,
		byteenable => (others => '0'),
		etval      => (others => '0'),
		ecause     => (others => '0'),
		exc        => '0',
		ecall      => '0',
		ebreak     => '0',
		mret       => '0',
		valid      => '0',
		clear      => '1',
		stall      => '0'
	);

	type fetch_in_type is record
		f : fetch_out_type;
		d : decode_out_type;
		e : execute_out_type;
		m : memory_out_type;
		w : writeback_out_type;
	end record;

	type decode_in_type is record
		f : fetch_out_type;
		d : decode_out_type;
		e : execute_out_type;
		m : memory_out_type;
		w : writeback_out_type;
	end record;

	type execute_in_type is record
		f : fetch_out_type;
		d : decode_out_type;
		e : execute_out_type;
		m : memory_out_type;
		w : writeback_out_type;
	end record;

	type memory_in_type is record
		f : fetch_out_type;
		d : decode_out_type;
		e : execute_out_type;
		m : memory_out_type;
		w : writeback_out_type;
	end record;

	type writeback_in_type is record
		f : fetch_out_type;
		d : decode_out_type;
		e : execute_out_type;
		m : memory_out_type;
		w : writeback_out_type;
	end record;

	type pmp_in_type is record
		mem_valid : std_logic;
		mem_instr : std_logic;
		mem_addr  : std_logic_vector(63 downto 0);
		mem_wstrb : std_logic_vector(7 downto 0);
		priv_mode : std_logic_vector(1 downto 0);
		pmpcfg    : csr_pmpcfg_type;
		pmpaddr   : csr_pmpaddr_type;
	end record;

	type pmp_out_type is record
		exc    : std_logic;
		ecause : std_logic_vector(3 downto 0);
		etval  : std_logic_vector(63 downto 0);
	end record;

	type prefetch_in_type is record
		pc        : std_logic_vector(63 downto 0);
		npc       : std_logic_vector(63 downto 0);
		jump      : std_logic;
		fence     : std_logic;
		valid     : std_logic;
		mem_rdata : std_logic_vector(63 downto 0);
		mem_ready : std_logic;
	end record;

	type prefetch_out_type is record
		fpc   : std_logic_vector(63 downto 0);
		instr : std_logic_vector(31 downto 0);
		stall : std_logic;
	end record;

	type prebuffer_in_type is record
		raddr : integer range 0 to 2**pfetch_depth-1;
		wren  : std_logic;
		waddr : integer range 0 to 2**pfetch_depth-1;
		wdata : std_logic_vector(63 downto 0);
	end record;

	type prebuffer_out_type is record
		rdata : std_logic_vector(31 downto 0);
	end record;

	type bp_in_type is record
		get_pc     : std_logic_vector(63 downto 0);
		get_branch : std_logic;
		get_return : std_logic;
		get_uncond : std_logic;
		upd_pc     : std_logic_vector(63 downto 0);
		upd_npc    : std_logic_vector(63 downto 0);
		upd_addr   : std_logic_vector(63 downto 0);
		upd_branch : std_logic;
		upd_return : std_logic;
		upd_uncond : std_logic;
		upd_jump   : std_logic;
		stall      : std_logic;
		clear      : std_logic;
	end record;

	type bp_out_type is record
		pred_baddr  : std_logic_vector(63 downto 0);
		pred_branch : std_logic;
		pred_jump   : std_logic;
		pred_raddr  : std_logic_vector(63 downto 0);
		pred_return : std_logic;
		pred_uncond : std_logic;
	end record;

	type bht_in_type is record
		raddr1 : integer range 0 to 2**bht_depth-1;
		raddr2 : integer range 0 to 2**bht_depth-1;
		wen    : std_logic;
		waddr  : integer range 0 to 2**bht_depth-1;
		wdata  : unsigned(1 downto 0);
	end record;

	type bht_out_type is record
		rdata1 : unsigned(1 downto 0);
		rdata2 : unsigned(1 downto 0);
	end record;

	type btb_in_type is record
		raddr : integer range 0 to 2**btb_depth-1;
		wen   : std_logic;
		waddr : integer range 0 to 2**btb_depth-1;
		wdata : std_logic_vector(126-btb_depth downto 0);
	end record;

	type btb_out_type is record
		rdata : std_logic_vector(126-btb_depth downto 0);
	end record;

	type ras_in_type is record
		raddr : integer range 0 to 2**ras_depth-1;
		wen   : std_logic;
		waddr : integer range 0 to 2**ras_depth-1;
		wdata : std_logic_vector(63 downto 0);
	end record;

	type ras_out_type is record
		rdata : std_logic_vector(63 downto 0);
	end record;

	type data_in_type is record
		raddr : integer range 0 to 2**set_depth-1;
		wen   : std_logic;
		waddr : integer range 0 to 2**set_depth-1;
		wdata : std_logic_vector(255 downto 0);
	end record;

	type data_out_type is record
		rdata : std_logic_vector(255 downto 0);
	end record;

	type tag_in_type is record
		raddr : integer range 0 to 2**set_depth-1;
		wen   : std_logic;
		waddr : integer range 0 to 2**set_depth-1;
		wdata : std_logic_vector(58-set_depth downto 0);
	end record;

	type tag_out_type is record
		rdata :  std_logic_vector(58-set_depth downto 0);
	end record;

	type valid_in_type is record
		raddr : integer range 0 to 2**set_depth-1;
		wen   : std_logic;
		waddr : integer range 0 to 2**set_depth-1;
		wdata : std_logic_vector(7 downto 0);
	end record;

	type valid_out_type is record
		rdata :  std_logic_vector(7 downto 0);
	end record;

	type lru_in_type is record
		sid   : integer range 0 to 2**set_depth-1;
		wid   : integer range 0 to 7;
		hit   : std_logic;
		miss  : std_logic;
	end record;

	type lru_out_type is record
		wid   : integer range 0 to 7;
	end record;

	type hit_in_type is record
		tag   : std_logic_vector(58-set_depth downto 0);
		tag0  : std_logic_vector(58-set_depth downto 0);
		tag1  : std_logic_vector(58-set_depth downto 0);
		tag2  : std_logic_vector(58-set_depth downto 0);
		tag3  : std_logic_vector(58-set_depth downto 0);
		tag4  : std_logic_vector(58-set_depth downto 0);
		tag5  : std_logic_vector(58-set_depth downto 0);
		tag6  : std_logic_vector(58-set_depth downto 0);
		tag7  : std_logic_vector(58-set_depth downto 0);
		valid : std_logic_vector(7 downto 0);
	end record;

	type hit_out_type is record
		hit   : std_logic;
		miss  : std_logic;
		wid   : integer range 0 to 7;
	end record;

	type ctrl_in_type is record
		data0_o : data_out_type;
		data1_o : data_out_type;
		data2_o : data_out_type;
		data3_o : data_out_type;
		data4_o : data_out_type;
		data5_o : data_out_type;
		data6_o : data_out_type;
		data7_o : data_out_type;
		tag0_o  : tag_out_type;
		tag1_o  : tag_out_type;
		tag2_o  : tag_out_type;
		tag3_o  : tag_out_type;
		tag4_o  : tag_out_type;
		tag5_o  : tag_out_type;
		tag6_o  : tag_out_type;
		tag7_o  : tag_out_type;
		valid_o : valid_out_type;
		lru_o   : lru_out_type;
		hit_o   : hit_out_type;
	end record;

	type ctrl_out_type is record
		data0_i : data_in_type;
		data1_i : data_in_type;
		data2_i : data_in_type;
		data3_i : data_in_type;
		data4_i : data_in_type;
		data5_i : data_in_type;
		data6_i : data_in_type;
		data7_i : data_in_type;
		tag0_i  : tag_in_type;
		tag1_i  : tag_in_type;
		tag2_i  : tag_in_type;
		tag3_i  : tag_in_type;
		tag4_i  : tag_in_type;
		tag5_i  : tag_in_type;
		tag6_i  : tag_in_type;
		tag7_i  : tag_in_type;
		valid_i : valid_in_type;
		lru_i   : lru_in_type;
		hit_i   : hit_in_type;
	end record;

	type cache_in_type is record
		mem_valid   : std_logic;
		mem_instr   : std_logic;
		mem_spec    : std_logic;
		mem_invalid : std_logic;
		mem_addr    : std_logic_vector(63 downto 0);
		mem_wdata   : std_logic_vector(63 downto 0);
		mem_wstrb   : std_logic_vector(7 downto 0);
	end record;

	type cache_out_type is record
		mem_stall : std_logic;
		mem_ready : std_logic;
		mem_rdata : std_logic_vector(63 downto 0);
	end record;

	type mem_in_type is record
		mem_valid : std_logic;
		mem_instr : std_logic;
		mem_addr  : std_logic_vector(63 downto 0);
		mem_wdata : std_logic_vector(63 downto 0);
		mem_wstrb : std_logic_vector(7 downto 0);
	end record;

	type mem_out_type is record
		mem_ready : std_logic;
		mem_rdata : std_logic_vector(63 downto 0);
	end record;

	type fifo_in_type is record
		we    : std_logic;
		re    : std_logic;
		wdata : std_logic_vector(7 downto 0);
	end record;

	type fifo_out_type is record
		rdata : std_logic_vector(7 downto 0);
		ready : std_logic;
	end record;

end package;
