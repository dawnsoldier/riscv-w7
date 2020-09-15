-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;
use work.constants.all;
use work.wire.all;

entity cpu is
	port(
		reset : in  std_logic;
		clock : in  std_logic;
		rtc   : in  std_logic;
		rx    : in  std_logic;
		tx    : out std_logic
	);
end entity cpu;

architecture behavior of cpu is

	component pipeline
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
	end component;

	component pmp
		port(
			reset  : in  std_logic;
			clock  : in  std_logic;
			pmp_i  : in  pmp_in_type;
			pmp_o  : out pmp_out_type
		);
	end component;

	component arbiter
		port(
			reset        : in  std_logic;
			clock        : in  std_logic;
			imem_i       : in  mem_in_type;
			imem_o       : out mem_out_type;
			dmem_i       : in  mem_in_type;
			dmem_o       : out mem_out_type;
			memory_valid : out std_logic;
			memory_ready : in  std_logic;
			memory_instr : out std_logic;
			memory_addr  : out std_logic_vector(63 downto 0);
			memory_wdata : out std_logic_vector(63 downto 0);
			memory_wstrb : out std_logic_vector(7 downto 0);
			memory_rdata : in  std_logic_vector(63 downto 0)
		);
	end component;

	component bram_mem
		port(
			reset      : in  std_logic;
			clock      : in  std_logic;
			bram_valid : in  std_logic;
			bram_ready : out std_logic;
			bram_instr : in  std_logic;
			bram_addr  : in  std_logic_vector(63 downto 0);
			bram_wdata : in  std_logic_vector(63 downto 0);
			bram_wstrb : in  std_logic_vector(7 downto 0);
			bram_rdata : out std_logic_vector(63 downto 0)
		);
	end component;

	component timer
		port(
			reset       : in  std_logic;
			clock       : in  std_logic;
			rtc         : in  std_logic;
			timer_valid : in  std_logic;
			timer_ready : out std_logic;
			timer_instr : in  std_logic;
			timer_addr  : in  std_logic_vector(63 downto 0);
			timer_wdata : in  std_logic_vector(63 downto 0);
			timer_wstrb : in  std_logic_vector(7 downto 0);
			timer_rdata : out std_logic_vector(63 downto 0);
			timer_irpt  : out std_logic
		);
	end component;

	component uart
		generic(
			clks_per_bit : integer := clks_per_bit
		);
		port(
			reset      : in  std_logic;
			clock      : in  std_logic;
			uart_valid : in  std_logic;
			uart_ready : out std_logic;
			uart_instr : in  std_logic;
			uart_addr  : in  std_logic_vector(63 downto 0);
			uart_wdata : in  std_logic_vector(63 downto 0);
			uart_wstrb : in  std_logic_vector(7 downto 0);
			uart_rdata : out std_logic_vector(63 downto 0);
			uart_rx    : in  std_logic;
			uart_tx    : out std_logic
		);
	end component;

	signal imem_i : mem_in_type;
	signal imem_o : mem_out_type;

	signal dmem_i : mem_in_type;
	signal dmem_o : mem_out_type;

	signal ipmp_i : pmp_in_type;
	signal ipmp_o : pmp_out_type;
	signal dpmp_i : pmp_in_type;
	signal dpmp_o : pmp_out_type;

	signal memory_valid : std_logic;
	signal memory_ready : std_logic;
	signal memory_instr : std_logic;
	signal memory_addr  : std_logic_vector(63 downto 0);
	signal memory_wdata : std_logic_vector(63 downto 0);
	signal memory_wstrb : std_logic_vector(7 downto 0);
	signal memory_rdata : std_logic_vector(63 downto 0);

	signal bram_valid : std_logic;
	signal bram_ready : std_logic;
	signal bram_instr : std_logic;
	signal bram_addr  : std_logic_vector(63 downto 0);
	signal bram_wdata : std_logic_vector(63 downto 0);
	signal bram_wstrb : std_logic_vector(7 downto 0);
	signal bram_rdata : std_logic_vector(63 downto 0);

	signal uart_valid : std_logic;
	signal uart_ready : std_logic;
	signal uart_instr : std_logic;
	signal uart_addr  : std_logic_vector(63 downto 0);
	signal uart_wdata : std_logic_vector(63 downto 0);
	signal uart_wstrb : std_logic_vector(7 downto 0);
	signal uart_rdata : std_logic_vector(63 downto 0);

	signal timer_valid : std_logic;
	signal timer_ready : std_logic;
	signal timer_instr : std_logic;
	signal timer_addr  : std_logic_vector(63 downto 0);
	signal timer_wdata : std_logic_vector(63 downto 0);
	signal timer_wstrb : std_logic_vector(7 downto 0);
	signal timer_rdata : std_logic_vector(63 downto 0);

	signal timer_irpt : std_logic;

begin

	process(memory_valid,memory_instr,memory_addr,memory_wdata,memory_wstrb,
					bram_rdata,bram_ready,uart_rdata,uart_ready,timer_rdata,timer_ready)

	begin

		if memory_valid = '1' then
			if (unsigned(memory_addr) >= unsigned(timer_base_addr) and
					unsigned(memory_addr) < unsigned(timer_top_addr)) then
				bram_valid <= '0';
				uart_valid <= '0';
				timer_valid <= memory_valid;
			elsif (unsigned(memory_addr) >= unsigned(uart_base_addr) and
					unsigned(memory_addr) < unsigned(uart_top_addr)) then
				bram_valid <= '0';
				uart_valid <= memory_valid;
				timer_valid <= '0';
			else
				bram_valid <= memory_valid;
				uart_valid <= '0';
				timer_valid <= '0';
			end if;
		else
			bram_valid <= '0';
			uart_valid <= '0';
			timer_valid <= '0';
		end if;

		bram_instr <= memory_instr;
		bram_addr <= memory_addr;
		bram_wdata <= memory_wdata;
		bram_wstrb <= memory_wstrb;

		uart_instr <= memory_instr;
		uart_addr <= memory_addr xor uart_base_addr;
		uart_wdata <= memory_wdata;
		uart_wstrb <= memory_wstrb;

		timer_instr <= memory_instr;
		timer_addr <= memory_addr xor timer_base_addr;
		timer_wdata <= memory_wdata;
		timer_wstrb <= memory_wstrb;

		if (bram_ready = '1') then
			memory_rdata <= bram_rdata;
			memory_ready <= bram_ready;
		elsif (uart_ready = '1') then
			memory_rdata <= uart_rdata;
			memory_ready <= uart_ready;
		elsif (timer_ready = '1') then
			memory_rdata <= timer_rdata;
			memory_ready <= timer_ready;
		else
			memory_rdata <= (others => '0');
			memory_ready <= '0';
		end if;

	end process;

	pipeline_comp : pipeline
		port map(
			reset     => reset,
			clock     => clock,
			imem_o    => imem_o,
			imem_i    => imem_i,
			dmem_o    => dmem_o,
			dmem_i    => dmem_i,
			ipmp_o    => ipmp_o,
			ipmp_i    => ipmp_i,
			dpmp_o    => dpmp_o,
			dpmp_i    => dpmp_i,
			time_irpt => timer_irpt,
			ext_irpt  => '0'
		);

	ipmp_comp : pmp
		port map(
			reset  => reset,
			clock  => clock,
			pmp_i  => ipmp_i,
			pmp_o  => ipmp_o
		);

	dpmp_comp : pmp
		port map(
			reset  => reset,
			clock  => clock,
			pmp_i  => dpmp_i,
			pmp_o  => dpmp_o
		);

	arbiter_comp : arbiter
		port map(
			reset         => reset,
			clock         => clock,
			imem_i        => imem_i,
			imem_o        => imem_o,
			dmem_i        => dmem_i,
			dmem_o        => dmem_o,
			memory_valid  => memory_valid,
			memory_ready  => memory_ready,
			memory_instr  => memory_instr,
			memory_addr   => memory_addr,
			memory_wdata  => memory_wdata,
			memory_wstrb  => memory_wstrb,
			memory_rdata  => memory_rdata
		);

	bram_comp : bram_mem
		port map(
			reset      => reset,
			clock      => clock,
			bram_valid => bram_valid,
			bram_ready => bram_ready,
			bram_instr => bram_instr,
			bram_addr  => bram_addr,
			bram_wdata => bram_wdata,
			bram_wstrb => bram_wstrb,
			bram_rdata => bram_rdata
		);

	uart_comp : uart
		port map(
			reset      => reset,
			clock      => clock,
			uart_valid => uart_valid,
			uart_ready => uart_ready,
			uart_instr => uart_instr,
			uart_addr  => uart_addr,
			uart_wdata => uart_wdata,
			uart_wstrb => uart_wstrb,
			uart_rdata => uart_rdata,
			uart_rx    => rx,
			uart_tx    => tx
		);

	timer_comp : timer
		port map(
			reset       => reset,
			clock       => clock,
			rtc         => rtc,
			timer_valid => timer_valid,
			timer_ready => timer_ready,
			timer_instr => timer_instr,
			timer_addr  => timer_addr,
			timer_wdata => timer_wdata,
			timer_wstrb => timer_wstrb,
			timer_rdata => timer_rdata,
			timer_irpt  => timer_irpt
		);

end architecture;
