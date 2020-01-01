-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;
use work.constants.all;
use work.wire.all;

entity cpu is
	port(
		reset             : in  std_logic;
		clock             : in  std_logic;
		clock_t           : in  std_logic;
		-- Wishbone Master Interface
		wbm_dat_i         : in  std_logic_vector(63 downto 0);
		wbm_dat_o         : out std_logic_vector(63 downto 0);
		wbm_ack_i         : in  std_logic;
		wbm_adr_o         : out std_logic_vector(63 downto 0);
		wbm_cyc_o         : out std_logic;
		wbm_stall_i       : in  std_logic;
		wbm_err_i         : in  std_logic;
		wbm_lock_o        : out std_logic;
		wbm_rty_i         : in  std_logic;
		wbm_sel_o         : out std_logic_vector(7 downto 0);
		wbm_stb_o         : out std_logic;
		wbm_we_o          : out std_logic
	);
end entity cpu;

architecture behavior of cpu is

	component pipeline
		port(
			reset    : in  std_logic;
			clock    : in  std_logic;
			pfetch_o : in  prefetch_out_type;
			pfetch_i : out prefetch_in_type;
			imem_o   : in  mem_iface_out_type;
			imem_i   : out mem_iface_in_type;
			dmem_o   : in  mem_iface_out_type;
			dmem_i   : out mem_iface_in_type
		);
	end component;

	component prefetch
		port(
			reset    : in  std_logic;
			clock    : in  std_logic;
			pfetch_i : in  prefetch_in_type;
			pfetch_o : out prefetch_out_type
  	);
  end component;

	component pmp
		port(
			reset  : in  std_logic;
			clock  : in  std_logic;
			ipmp_i : in  pmp_in_type;
			ipmp_o : out pmp_out_type;
			dpmp_i : in  pmp_in_type;
			dpmp_o : out pmp_out_type
		);
	end component;

	component bram_mem
		port(
			reset     : in  std_logic;
			clock     : in  std_logic;
			-- Memory Interface
			mem_valid : in  std_logic;
			mem_ready : out std_logic;
			mem_instr : in  std_logic;
			mem_addr  : in  std_logic_vector(63 downto 0);
			mem_wdata : in  std_logic_vector(63 downto 0);
			mem_wstrb : in  std_logic_vector(7 downto 0);
			mem_rdata : out std_logic_vector(63 downto 0)
		);
	end component;

	component plic
		port(
			reset           : in  std_logic;
			clock           : in  std_logic;
			plic_mem_valid  : in  std_logic;
			plic_mem_instr  : in  std_logic;
			plic_mem_ready  : out std_logic;
			plic_mem_addr   : in  std_logic_vector(63 downto 0);
			plic_mem_wdata  : in  std_logic_vector(63 downto 0);
			plic_mem_wstrb  : in  std_logic_vector(7 downto 0);
			plic_mem_rdata  : out std_logic_vector(63 downto 0)
		);
	end component;

	component time
		port(
			reset      : in  std_logic;
			clock_t    : in  std_logic;
			time_valid : in  std_logic;
			time_instr : in  std_logic;
			time_ready : out std_logic;
			time_addr  : in  std_logic_vector(63 downto 0);
			time_wdata : in  std_logic_vector(63 downto 0);
			time_wstrb : in  std_logic_vector(7 downto 0);
			time_rdata : out std_logic_vector(63 downto 0)
		);
	end component;

	component interconnect
		port(
			reset           : in  std_logic;
			clock           : in  std_logic;
			-- MEMORY
			imem_i          : in  mem_iface_in_type;
			imem_o          : out mem_iface_out_type;
			dmem_i          : in  mem_iface_in_type;
			dmem_o          : out mem_iface_out_type;
			-- BRAM
			bram_mem_valid  : out std_logic;
			bram_mem_ready  : in  std_logic;
			bram_mem_instr  : out std_logic;
			bram_mem_addr   : out std_logic_vector(63 downto 0);
			bram_mem_wdata  : out std_logic_vector(63 downto 0);
			bram_mem_wstrb  : out std_logic_vector(7 downto 0);
			bram_mem_rdata  : in  std_logic_vector(63 downto 0);
			-- PLIC
			plic_mem_valid  : out std_logic;
			plic_mem_instr  : out std_logic;
			plic_mem_ready  : in  std_logic;
			plic_mem_addr   : out std_logic_vector(63 downto 0);
			plic_mem_wdata  : out std_logic_vector(63 downto 0);
			plic_mem_wstrb  : out std_logic_vector(7 downto 0);
			plic_mem_rdata  : in  std_logic_vector(63 downto 0);
			-- TIMER
			time_mem_valid  : out std_logic;
			time_mem_instr  : out std_logic;
			time_mem_ready  : in  std_logic;
			time_mem_addr   : out std_logic_vector(63 downto 0);
			time_mem_wdata  : out std_logic_vector(63 downto 0);
			time_mem_wstrb  : out std_logic_vector(7 downto 0);
			time_mem_rdata  : in  std_logic_vector(63 downto 0);
			-- BUS
			bus_mem_valid   : out std_logic;
			bus_mem_ready   : in  std_logic;
			bus_mem_instr   : out std_logic;
			bus_mem_addr    : out std_logic_vector(63 downto 0);
			bus_mem_wdata   : out std_logic_vector(63 downto 0);
			bus_mem_wstrb   : out std_logic_vector(7 downto 0);
			bus_mem_rdata   : in  std_logic_vector(63 downto 0)
		);
	end component;

	component wishbone_master
		port(
			reset            : in  std_logic;
			clock            : in  std_logic;
			wbm_dat_i        : in  std_logic_vector(63 downto 0);
			wbm_dat_o        : out std_logic_vector(63 downto 0);
			wbm_ack_i        : in  std_logic;
			wbm_adr_o        : out std_logic_vector(63 downto 0);
			wbm_cyc_o        : out std_logic;
			wbm_stall_i      : in  std_logic;
			wbm_err_i        : in  std_logic;
			wbm_lock_o       : out std_logic;
			wbm_rty_i        : in  std_logic;
			wbm_sel_o        : out std_logic_vector(7 downto 0);
			wbm_stb_o        : out std_logic;
			wbm_we_o         : out std_logic;
			mem_valid        : in  std_logic;
			mem_ready        : out std_logic;
			mem_instr        : in  std_logic;
			mem_addr         : in  std_logic_vector(63 downto 0);
			mem_wdata        : in  std_logic_vector(63 downto 0);
			mem_wstrb        : in  std_logic_vector(7 downto 0);
			mem_rdata        : out std_logic_vector(63 downto 0)
		);
	end component;

	signal imem_i : mem_iface_in_type;
	signal imem_o : mem_iface_out_type;

	signal dmem_i : mem_iface_in_type;
	signal dmem_o : mem_iface_out_type;

	signal pfetch_i : prefetch_in_type;
	signal pfetch_o : prefetch_out_type;

	signal ipmp_i : pmp_in_type;
	signal ipmp_o : pmp_out_type;

	signal dpmp_i : pmp_in_type;
	signal dpmp_o : pmp_out_type;

	signal mem_valid : std_logic;
	signal mem_ready : std_logic;
	signal mem_instr : std_logic;
	signal mem_addr  : std_logic_vector(63 downto 0);
	signal mem_wdata : std_logic_vector(63 downto 0);
	signal mem_wstrb : std_logic_vector(7 downto 0);
	signal mem_rdata : std_logic_vector(63 downto 0);

	signal bram_mem_valid : std_logic;
	signal bram_mem_ready : std_logic;
	signal bram_mem_instr : std_logic;
	signal bram_mem_addr  : std_logic_vector(63 downto 0);
	signal bram_mem_wdata : std_logic_vector(63 downto 0);
	signal bram_mem_wstrb : std_logic_vector(7 downto 0);
	signal bram_mem_rdata : std_logic_vector(63 downto 0);

	signal plic_mem_valid : std_logic;
	signal plic_mem_ready : std_logic;
	signal plic_mem_instr : std_logic;
	signal plic_mem_addr  : std_logic_vector(63 downto 0);
	signal plic_mem_wdata : std_logic_vector(63 downto 0);
	signal plic_mem_wstrb : std_logic_vector(7 downto 0);
	signal plic_mem_rdata : std_logic_vector(63 downto 0);

	signal time_mem_valid : std_logic;
	signal time_mem_instr : std_logic;
	signal time_mem_ready : std_logic;
	signal time_mem_addr  : std_logic_vector(63 downto 0);
	signal time_mem_wdata : std_logic_vector(63 downto 0);
	signal time_mem_wstrb : std_logic_vector(7 downto 0);
	signal time_mem_rdata : std_logic_vector(63 downto 0);

	signal bus_mem_valid : std_logic;
	signal bus_mem_ready : std_logic;
	signal bus_mem_instr : std_logic;
	signal bus_mem_addr  : std_logic_vector(63 downto 0);
	signal bus_mem_wdata : std_logic_vector(63 downto 0);
	signal bus_mem_wstrb : std_logic_vector(7 downto 0);
	signal bus_mem_rdata : std_logic_vector(63 downto 0);

begin

	pipeline_comp : pipeline
		port map(
			reset    => reset,
			clock    => clock,
			pfetch_o => pfetch_o,
			pfetch_i => pfetch_i,
			imem_o   => imem_o,
			imem_i   => imem_i,
			dmem_o   => dmem_o,
			dmem_i   => dmem_i
		);

	prefetch_comp : prefetch
		port map(
			reset    => reset,
			clock    => clock,
			pfetch_i => pfetch_i,
			pfetch_o => pfetch_o
		);

	pmp_comp : pmp
		port map(
			reset  => reset,
			clock  => clock,
			ipmp_i => ipmp_i,
			ipmp_o => ipmp_o,
			dpmp_i => dpmp_i,
			dpmp_o => dpmp_o
		);

	bram_comp : bram_mem
		port map(
			reset     => reset,
			clock     => clock,
			mem_valid => bram_mem_valid,
			mem_ready => bram_mem_ready,
			mem_instr => bram_mem_instr,
			mem_addr  => bram_mem_addr,
			mem_wdata => bram_mem_wdata,
			mem_wstrb => bram_mem_wstrb,
			mem_rdata => bram_mem_rdata
	);

	plic_comp : plic
		port map(
			reset           => reset,
			clock           => clock,
			plic_mem_valid  => plic_mem_valid,
			plic_mem_instr  => plic_mem_instr,
			plic_mem_ready  => plic_mem_ready,
			plic_mem_addr   => plic_mem_addr,
			plic_mem_wdata  => plic_mem_wdata,
			plic_mem_wstrb  => plic_mem_wstrb,
			plic_mem_rdata  => plic_mem_rdata
		);

	time_comp : time
		port map(
			reset      => reset,
			clock_t    => clock_t,
			time_valid => time_mem_valid,
			time_instr => time_mem_instr,
			time_ready => time_mem_ready,
			time_addr  => time_mem_addr,
			time_wdata => time_mem_wdata,
			time_wstrb => time_mem_wstrb,
			time_rdata => time_mem_rdata
		);

	interconnect_comp : interconnect
		port map(
			reset           => reset,
			clock           => clock,
			imem_i          => imem_i,
			imem_o          => imem_o,
			dmem_i          => dmem_i,
			dmem_o          => dmem_o,
			bram_mem_valid  => bram_mem_valid,
			bram_mem_ready  => bram_mem_ready,
			bram_mem_instr  => bram_mem_instr,
			bram_mem_addr   => bram_mem_addr,
			bram_mem_wdata  => bram_mem_wdata,
			bram_mem_wstrb  => bram_mem_wstrb,
			bram_mem_rdata  => bram_mem_rdata,
			plic_mem_valid  => plic_mem_valid,
			plic_mem_instr  => plic_mem_instr,
			plic_mem_ready  => plic_mem_ready,
			plic_mem_addr   => plic_mem_addr,
			plic_mem_wdata  => plic_mem_wdata,
			plic_mem_wstrb  => plic_mem_wstrb,
			plic_mem_rdata  => plic_mem_rdata,
			time_mem_valid  => time_mem_valid,
			time_mem_instr  => time_mem_instr,
			time_mem_ready  => time_mem_ready,
			time_mem_addr   => time_mem_addr,
			time_mem_wdata  => time_mem_wdata,
			time_mem_wstrb  => time_mem_wstrb,
			time_mem_rdata  => time_mem_rdata,
			bus_mem_valid   => bus_mem_valid,
			bus_mem_ready   => bus_mem_ready,
			bus_mem_instr   => bus_mem_instr,
			bus_mem_addr    => bus_mem_addr,
			bus_mem_wdata   => bus_mem_wdata,
			bus_mem_wstrb   => bus_mem_wstrb,
			bus_mem_rdata   => bus_mem_rdata
		);

	wishbone_master_comp : wishbone_master
		port map(
			reset            => reset,
			clock            => clock,
			wbm_dat_i        => wbm_dat_i,
			wbm_dat_o        => wbm_dat_o,
			wbm_ack_i        => wbm_ack_i,
			wbm_adr_o        => wbm_adr_o,
			wbm_cyc_o        => wbm_cyc_o,
			wbm_stall_i      => wbm_stall_i,
			wbm_err_i        => wbm_err_i,
			wbm_lock_o       => wbm_lock_o,
			wbm_rty_i        => wbm_rty_i,
			wbm_sel_o        => wbm_sel_o,
			wbm_stb_o        => wbm_stb_o,
			wbm_we_o         => wbm_we_o,
			mem_valid        => bus_mem_valid,
			mem_ready        => bus_mem_ready,
			mem_instr        => bus_mem_instr,
			mem_addr         => bus_mem_addr,
			mem_wdata        => bus_mem_wdata,
			mem_wstrb        => bus_mem_wstrb,
			mem_rdata        => bus_mem_rdata
		);

end architecture;
