-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.int_wire.all;
use work.fp_wire.all;

package csr_wire is

	type csr_pmp_type is record
		L : std_logic_vector(7 downto 7);
		A : std_logic_vector(4 downto 3);
		X : std_logic_vector(2 downto 2);
		W : std_logic_vector(1 downto 1);
		R : std_logic_vector(0 downto 0);
	end record;

	constant init_csr_pmp_reg : csr_pmp_type := (
		L => (others => '0'),
		A => (others => '0'),
		X => (others => '0'),
		W => (others => '0'),
		R => (others => '0')
	);

	type csr_pmpcfg_type is array (0 to 15) of csr_pmp_type;

	constant init_csr_pmpcfg_reg : csr_pmpcfg_type := (others => init_csr_pmp_reg);

	type csr_pmpaddr_type is array (0 to 15) of std_logic_vector(63 downto 0);

	constant init_csr_pmpaddr_reg : csr_pmpaddr_type := (others => (others => '0'));

	type csr_read_in_type is record
		rden  : std_logic;
		raddr : std_logic_vector(11 downto 0);
	end record;

	type csr_write_in_type is record
		wren  : std_logic;
		waddr : std_logic_vector(11 downto 0);
		wdata : std_logic_vector(63 downto 0);
	end record;

	type csr_out_type is record
		data : std_logic_vector(63 downto 0);
	end record;

	type csr_exception_in_type is record
		epc       : std_logic_vector(63 downto 0);
		etval     : std_logic_vector(63 downto 0);
		ecause    : std_logic_vector(3 downto 0);
		exc       : std_logic;
		ecall     : std_logic;
		ebreak    : std_logic;
		mret      : std_logic;
		flags     : std_logic_vector(4 downto 0);
		int_op    : int_operation_type;
		fpu_op    : fp_operation_type;
		int       : std_logic;
		fpu       : std_logic;
		csr       : std_logic;
		load      : std_logic;
		store     : std_logic;
		time_irpt : std_logic;
		ext_irpt  : std_logic;
	end record;

	type csr_exception_out_type is record
		fs        : std_logic_vector(1 downto 0);
		tvec      : std_logic_vector(63 downto 0);
		epc       : std_logic_vector(63 downto 0);
		frm       : std_logic_vector(2 downto 0);
		pmpcfg    : csr_pmpcfg_type;
		pmpaddr   : csr_pmpaddr_type;
		priv_mode : std_logic_vector(1 downto 0);
		exc       : std_logic;
		mret      : std_logic;
	end record;

	type csr_alu_in_type is record
		rs1   : std_logic_vector(63 downto 0);
		imm   : std_logic_vector(63 downto 0);
		data  : std_logic_vector(63 downto 0);
		funct : std_logic_vector(2 downto 0);
	end record;

	type csr_alu_out_type is record
		result : std_logic_vector(63 downto 0);
	end record;

	type csr_unit_in_type is record
		csr_ri       : csr_read_in_type;
		csr_wi       : csr_write_in_type;
		csr_ei       : csr_exception_in_type;
		csr_alu_i    : csr_alu_in_type;
	end record;

	type csr_unit_out_type is record
		csr_o        : csr_out_type;
		csr_eo       : csr_exception_out_type;
		csr_alu_o    : csr_alu_out_type;
	end record;

	type csr_isa_type is record
		a   : std_logic_vector(0 downto 0);
		b   : std_logic_vector(1 downto 1);
		c   : std_logic_vector(2 downto 2);
		d   : std_logic_vector(3 downto 3);
		e   : std_logic_vector(4 downto 4);
		f   : std_logic_vector(5 downto 5);
		g   : std_logic_vector(6 downto 6);
		h   : std_logic_vector(7 downto 7);
		i   : std_logic_vector(8 downto 8);
		k   : std_logic_vector(9 downto 9);
		j   : std_logic_vector(10 downto 10);
		l   : std_logic_vector(11 downto 11);
		m   : std_logic_vector(12 downto 12);
		n   : std_logic_vector(13 downto 13);
		o   : std_logic_vector(14 downto 14);
		p   : std_logic_vector(15 downto 15);
		q   : std_logic_vector(16 downto 16);
		r   : std_logic_vector(17 downto 17);
		s   : std_logic_vector(18 downto 18);
		t   : std_logic_vector(19 downto 19);
		u   : std_logic_vector(20 downto 20);
		v   : std_logic_vector(21 downto 21);
		w   : std_logic_vector(22 downto 22);
		x   : std_logic_vector(23 downto 23);
		y   : std_logic_vector(24 downto 24);
		z   : std_logic_vector(25 downto 25);
		mxl : std_logic_vector(63 downto 62);
	end record;

	constant init_csr_isa_reg : csr_isa_type := (
		a   => "0",
		b   => "0",
		c   => "1",
		d   => "1",
		e   => "0",
		f   => "1",
		g   => "0",
		h   => "0",
		i   => "1",
		k   => "0",
		j   => "0",
		l   => "0",
		m   => "1",
		n   => "0",
		o   => "0",
		p   => "0",
		q   => "0",
		r   => "0",
		s   => "0",
		t   => "0",
		u   => "0",
		v   => "0",
		w   => "0",
		x   => "0",
		y   => "0",
		z   => "0",
		mxl => "10"
	);

	type csr_status_type is record
		sd   : std_logic_vector(63 downto 63);
		uxl  : std_logic_vector(33 downto 32);
		mprv : std_logic_vector(17 downto 17);
		fs   : std_logic_vector(14 downto 13);
		mpp  : std_logic_vector(12 downto 11);
		mpie : std_logic_vector(7 downto 7);
		upie : std_logic_vector(4 downto 4);
		mie  : std_logic_vector(3 downto 3);
		uie  : std_logic_vector(0 downto 0);
	end record;

	constant init_csr_status_reg : csr_status_type := (
		sd   => "0",
		uxl  => "10",
		mprv => "0",
		fs   => "00",
		mpp  => "00",
		mpie => "0",
		upie => "0",
		mie  => "0",
		uie  => "0"
	);

	type csr_ip_type is record
		meip : std_logic_vector(11 downto 11);
		ueip : std_logic_vector(8 downto 8);
		mtip : std_logic_vector(7 downto 7);
		utip : std_logic_vector(4 downto 4);
		msip : std_logic_vector(3 downto 3);
		usip : std_logic_vector(0 downto 0);
	end record;

	constant init_csr_ip_reg : csr_ip_type := (
		meip => "0",
		ueip => "0",
		mtip => "0",
		utip => "0",
		msip => "0",
		usip => "0"
	);

	type csr_ie_type is record
		meie : std_logic_vector(11 downto 11);
		ueie : std_logic_vector(8 downto 8);
		mtie : std_logic_vector(7 downto 7);
		utie : std_logic_vector(4 downto 4);
		msie : std_logic_vector(3 downto 3);
		usie : std_logic_vector(0 downto 0);
	end record;

	constant init_csr_ie_reg : csr_ie_type := (
		meie => "0",
		ueie => "0",
		mtie => "0",
		utie => "0",
		msie => "0",
		usie => "0"
	);

	type csr_cause_type is record
		irpt : std_logic_vector(63 downto 63);
		code : std_logic_vector(62 downto 0);
	end record;

	constant init_csr_cause_reg : csr_cause_type := (
		irpt => "0",
		code => (others => '0')
	);

	type csr_tvec_type is record
		base : std_logic_vector(63 downto 2);
		mode : std_logic_vector(1 downto 0);
	end record;

	constant init_csr_tvec_reg : csr_tvec_type := (
		base => (others => '0'),
		mode => (others => '0')
	);

	type csr_machine_register is record
		misa       : csr_isa_type;
		mstatus    : csr_status_type;
		mip        : csr_ip_type;
		mie        : csr_ie_type;
		mcause     : csr_cause_type;
		mtvec      : csr_tvec_type;
		mtval      : std_logic_vector(63 downto 0);
		mepc       : std_logic_vector(63 downto 0);
		mscratch   : std_logic_vector(63 downto 0);
		mideleg    : std_logic_vector(63 downto 0);
		medeleg    : std_logic_vector(63 downto 0);
		mcounteren : std_logic_vector(63 downto 0);
		mcycle     : std_logic_vector(63 downto 0);
		minstret   : std_logic_vector(63 downto 0);
		pmpcfg     : csr_pmpcfg_type;
		pmpaddr    : csr_pmpaddr_type;
	end record;

	constant init_csr_machine_reg : csr_machine_register := (
		misa       => init_csr_isa_reg,
		mstatus    => init_csr_status_reg,
		mip        => init_csr_ip_reg,
		mie        => init_csr_ie_reg,
		mcause     => (others => (others => '0')),
		mtvec      => (others => (others => '0')),
		mtval      => (others => '0'),
		mepc       => (others => '0'),
		mscratch   => (others => '0'),
		mideleg    => (others => '0'),
		medeleg    => (others => '0'),
		mcounteren => (others => '0'),
		mcycle     => (others => '0'),
		minstret   => (others => '0'),
		pmpcfg     => init_csr_pmpcfg_reg,
		pmpaddr    => init_csr_pmpaddr_reg
	);

	type csr_user_register is record
		fflags   : std_logic_vector(4 downto 0);
		frm      : std_logic_vector(2 downto 0);
	end record;

	constant init_csr_user_reg : csr_user_register := (
		fflags   => (others => '0'),
		frm      => (others => '0')
	);

end package;
