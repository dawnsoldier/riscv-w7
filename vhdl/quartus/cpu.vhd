-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use ieee.std_logic_misc.all;

use work.configure.all;
use work.constants.all;
use work.fp_wire.all;
use work.wire.all;

entity cpu is
	generic(
		bram_depth : integer := bram_depth
	);
	port(
		reset         : in    std_logic;
		clock         : in    std_logic;
		rtc           : in    std_logic;
		uart_rx       : in    std_logic;
		uart_tx       : out   std_logic;
		-- QSPI Flash interface
		spi_cs        : out   std_logic;
		spi_dq0       : inout std_logic;
		spi_dq1       : inout std_logic;
		spi_dq2       : inout std_logic;
		spi_dq3       : inout std_logic;
		spi_sck       : out   std_logic;
		-- SRAM interface
		ram_a         : out   std_logic_vector(26 downto 0);
		ram_dq_i      : out   std_logic_vector(15 downto 0);
		ram_dq_o      : in    std_logic_vector(15 downto 0);
		ram_cen       : out   std_logic;
		ram_oen       : out   std_logic;
		ram_wen       : out   std_logic;
		ram_ub        : out   std_logic;
		ram_lb        : out   std_logic;
		-- Master interface write address
		m_axi_awvalid : out   std_logic;
		m_axi_awready : in    std_logic;
		m_axi_awaddr  : out   std_logic_vector(63 downto 0);
		m_axi_awprot  : out   std_logic_vector(2 downto 0);
		-- Master interface write data
		m_axi_wvalid  : out   std_logic;
		m_axi_wready  : in    std_logic;
		m_axi_wdata   : out   std_logic_vector(63 downto 0);
		m_axi_wstrb   : out   std_logic_vector(7 downto 0);
		-- Master interface write response
		m_axi_bvalid  : in    std_logic;
		m_axi_bready  : out   std_logic;
		-- Master interface read address
		m_axi_arvalid : out   std_logic;
		m_axi_arready : in    std_logic;
		m_axi_araddr  : out   std_logic_vector(63 downto 0);
		m_axi_arprot  : out   std_logic_vector(2 downto 0);
		-- Master interface read data return
		m_axi_rvalid  : in    std_logic;
		m_axi_rready  : out   std_logic;
		m_axi_rdata   : in    std_logic_vector(63 downto 0)
	);
end entity cpu;

architecture behavior of cpu is

	component core
		port(
			reset     : in  std_logic;
			clock     : in  std_logic;
			ibus_o    : in  mem_out_type;
			ibus_i    : out mem_in_type;
			dbus_o    : in  mem_out_type;
			dbus_i    : out mem_in_type;
			time_irpt : in  std_logic;
			ext_irpt  : in  std_logic
		);
	end component;

	component arbiter
		port(
			reset        : in  std_logic;
			clock        : in  std_logic;
			ibus_i       : in  mem_in_type;
			ibus_o       : out mem_out_type;
			dbus_i       : in  mem_in_type;
			dbus_o       : out mem_out_type;
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
			clock      : in  std_logic;
			bram_wen   : in  std_logic;
			bram_waddr : in  std_logic_vector(bram_depth-1 downto 0);
			bram_raddr : in  std_logic_vector(bram_depth-1 downto 0);
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

	component qspi
		port(
			reset      : in    std_logic;
			clock      : in    std_logic;
			qspi_valid : in    std_logic;
			qspi_ready : out   std_logic;
			qspi_instr : in    std_logic;
			qspi_addr  : in    std_logic_vector(63 downto 0);
			qspi_wdata : in    std_logic_vector(63 downto 0);
			qspi_wstrb : in    std_logic_vector(7 downto 0);
			qspi_rdata : out   std_logic_vector(63 downto 0);
			spi_cs     : out   std_logic;
			spi_dq0    : inout std_logic;
			spi_dq1    : inout std_logic;
			spi_dq2    : inout std_logic;
			spi_dq3    : inout std_logic;
			spi_sck    : out   std_logic
		);
	end component;

	component sram
		port(
			reset      : in  std_logic;
			clock      : in  std_logic;
			sram_valid : in  std_logic;
			sram_ready : out std_logic;
			sram_instr : in  std_logic;
			sram_addr  : in  std_logic_vector(63 downto 0);
			sram_wdata : in  std_logic_vector(63 downto 0);
			sram_wstrb : in  std_logic_vector(7 downto 0);
			sram_rdata : out std_logic_vector(63 downto 0);
			ram_a      : out std_logic_vector(26 downto 0);
			ram_dq_i   : out std_logic_vector(15 downto 0);
			ram_dq_o   : in  std_logic_vector(15 downto 0);
			ram_cen    : out std_logic;
			ram_oen    : out std_logic;
			ram_wen    : out std_logic;
			ram_ub     : out std_logic;
			ram_lb     : out std_logic
		);
	end component;

	component axi
		port(
			reset         : in  std_logic;
			clock         : in  std_logic;
			axi_valid     : in  std_logic;
			axi_ready     : out std_logic;
			axi_instr     : in  std_logic;
			axi_addr      : in  std_logic_vector(63 downto 0);
			axi_wdata     : in  std_logic_vector(63 downto 0);
			axi_wstrb     : in  std_logic_vector(7 downto 0);
			axi_rdata     : out std_logic_vector(63 downto 0);
			-- Master interface write address
			m_axi_awvalid : out std_logic;
			m_axi_awready : in  std_logic;
			m_axi_awaddr  : out std_logic_vector(63 downto 0);
			m_axi_awprot  : out std_logic_vector(2 downto 0);
			-- Master interface write data
			m_axi_wvalid  : out std_logic;
			m_axi_wready  : in  std_logic;
			m_axi_wdata   : out std_logic_vector(63 downto 0);
			m_axi_wstrb   : out std_logic_vector(7 downto 0);
			-- Master interface write response
			m_axi_bvalid  : in  std_logic;
			m_axi_bready  : out std_logic;
			-- Master interface read address
			m_axi_arvalid : out std_logic;
			m_axi_arready : in  std_logic;
			m_axi_araddr  : out std_logic_vector(63 downto 0);
			m_axi_arprot  : out std_logic_vector(2 downto 0);
			-- Master interface read data return
			m_axi_rvalid  : in  std_logic;
			m_axi_rready  : out std_logic;
			m_axi_rdata   : in  std_logic_vector(63 downto 0)
		);
	end component;

	signal ibus_i : mem_in_type;
	signal ibus_o : mem_out_type;
	signal dbus_i : mem_in_type;
	signal dbus_o : mem_out_type;

	signal memory_valid : std_logic;
	signal memory_ready : std_logic;
	signal memory_instr : std_logic;
	signal memory_addr  : std_logic_vector(63 downto 0);
	signal memory_wdata : std_logic_vector(63 downto 0);
	signal memory_wstrb : std_logic_vector(7 downto 0);
	signal memory_rdata : std_logic_vector(63 downto 0);

	signal bram_valid : std_logic;
	signal bram_wen   : std_logic;
	signal bram_ready : std_logic;
	signal bram_instr : std_logic;
	signal bram_addr : std_logic_vector(bram_depth-1 downto 0);
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

	signal qspi_valid : std_logic;
	signal qspi_ready : std_logic;
	signal qspi_instr : std_logic;
	signal qspi_addr  : std_logic_vector(63 downto 0);
	signal qspi_wdata : std_logic_vector(63 downto 0);
	signal qspi_wstrb : std_logic_vector(7 downto 0);
	signal qspi_rdata : std_logic_vector(63 downto 0);

	signal sram_valid : std_logic;
	signal sram_ready : std_logic;
	signal sram_instr : std_logic;
	signal sram_addr  : std_logic_vector(63 downto 0);
	signal sram_wdata : std_logic_vector(63 downto 0);
	signal sram_wstrb : std_logic_vector(7 downto 0);
	signal sram_rdata : std_logic_vector(63 downto 0);

	signal axi_valid : std_logic;
	signal axi_ready : std_logic;
	signal axi_instr : std_logic;
	signal axi_addr  : std_logic_vector(63 downto 0);
	signal axi_wdata : std_logic_vector(63 downto 0);
	signal axi_wstrb : std_logic_vector(7 downto 0);
	signal axi_rdata : std_logic_vector(63 downto 0);

	signal timer_irpt : std_logic;

begin

	process(memory_valid,memory_instr,memory_addr,memory_wdata,memory_wstrb,
					bram_rdata,bram_ready,uart_rdata,uart_ready,timer_rdata,timer_ready,
					qspi_rdata,qspi_ready,sram_rdata,sram_ready,axi_rdata,axi_ready,
					bram_valid)

	begin

		if memory_valid = '1' then
			if (unsigned(memory_addr) >= unsigned(axi_base_addr) and
					unsigned(memory_addr) < unsigned(axi_top_addr)) then
				bram_valid <= '0';
				uart_valid <= '0';
				timer_valid <= '0';
				sram_valid <= '0';
				qspi_valid <= '0';
				axi_valid <= memory_valid;
			elsif (unsigned(memory_addr) >= unsigned(sram_base_addr) and
					unsigned(memory_addr) < unsigned(sram_top_addr)) then
				bram_valid <= '0';
				uart_valid <= '0';
				timer_valid <= '0';
				qspi_valid <= '0';
				sram_valid <= memory_valid;
				axi_valid <= '0';
			elsif (unsigned(memory_addr) >= unsigned(qspi_base_addr) and
					unsigned(memory_addr) < unsigned(qspi_top_addr)) then
				bram_valid <= '0';
				uart_valid <= '0';
				timer_valid <= '0';
				qspi_valid <= memory_valid;
				sram_valid <= '0';
				axi_valid <= '0';
			elsif (unsigned(memory_addr) >= unsigned(timer_base_addr) and
					unsigned(memory_addr) < unsigned(timer_top_addr)) then
				bram_valid <= '0';
				uart_valid <= '0';
				timer_valid <= memory_valid;
				qspi_valid <= '0';
				sram_valid <= '0';
				axi_valid <= '0';
			elsif (unsigned(memory_addr) >= unsigned(uart_base_addr) and
					unsigned(memory_addr) < unsigned(uart_top_addr)) then
				bram_valid <= '0';
				uart_valid <= memory_valid;
				timer_valid <= '0';
				qspi_valid <= '0';
				sram_valid <= '0';
				axi_valid <= '0';
			elsif (unsigned(memory_addr) >= unsigned(bram_base_addr) and
					unsigned(memory_addr) < unsigned(bram_top_addr)) then
				bram_valid <= memory_valid;
				uart_valid <= '0';
				timer_valid <= '0';
				qspi_valid <= '0';
				sram_valid <= '0';
				axi_valid <= '0';
			else
				bram_valid <= '0';
				uart_valid <= '0';
				timer_valid <= '0';
				qspi_valid <= '0';
				sram_valid <= '0';
				axi_valid <= '0';
			end if;
		else
			bram_valid <= '0';
			uart_valid <= '0';
			timer_valid <= '0';
			qspi_valid <= '0';
			sram_valid <= '0';
			axi_valid <= '0';
		end if;

		bram_wen <= bram_valid and or_reduce(memory_wstrb);
		bram_instr <= memory_instr;
		bram_addr <= memory_addr(bram_depth+2 downto 3) xor bram_base_addr(bram_depth+2 downto 3);
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

		qspi_instr <= memory_instr;
		qspi_addr <= memory_addr xor qspi_base_addr;
		qspi_wdata <= memory_wdata;
		qspi_wstrb <= memory_wstrb;

		sram_instr <= memory_instr;
		sram_addr <= memory_addr xor sram_base_addr;
		sram_wdata <= memory_wdata;
		sram_wstrb <= memory_wstrb;

		axi_instr <= memory_instr;
		axi_addr <= memory_addr xor axi_base_addr;
		axi_wdata <= memory_wdata;
		axi_wstrb <= memory_wstrb;

		if (bram_ready = '1') then
			memory_rdata <= bram_rdata;
			memory_ready <= bram_ready;
		elsif (uart_ready = '1') then
			memory_rdata <= uart_rdata;
			memory_ready <= uart_ready;
		elsif (timer_ready = '1') then
			memory_rdata <= timer_rdata;
			memory_ready <= timer_ready;
		elsif (qspi_ready = '1') then
			memory_rdata <= qspi_rdata;
			memory_ready <= qspi_ready;
		elsif (sram_ready = '1') then
			memory_rdata <= sram_rdata;
			memory_ready <= sram_ready;
		elsif (axi_ready = '1') then
			memory_rdata <= axi_rdata;
			memory_ready <= axi_ready;
		else
			memory_rdata <= (others => '0');
			memory_ready <= '0';
		end if;

	end process;

	process(clock)
	begin

		if rising_edge(clock) then

			if bram_valid = '1' then
				bram_ready <= '1';
			else
				bram_ready <= '0';
			end if;

		end if;

	end process;

	core_comp : core
		port map(
			reset     => reset,
			clock     => clock,
			ibus_o    => ibus_o,
			ibus_i    => ibus_i,
			dbus_o    => dbus_o,
			dbus_i    => dbus_i,
			time_irpt => timer_irpt,
			ext_irpt  => '0'
		);

	arbiter_comp : arbiter
		port map(
			reset         => reset,
			clock         => clock,
			ibus_i        => ibus_i,
			ibus_o        => ibus_o,
			dbus_i        => dbus_i,
			dbus_o        => dbus_o,
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
			clock      => clock,
			bram_wen   => bram_wen,
			bram_waddr => bram_addr,
			bram_raddr => bram_addr,
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
			uart_rx    => uart_rx,
			uart_tx    => uart_tx
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

	qspi_comp : qspi
		port map(
			reset      => reset,
			clock      => clock,
			qspi_valid => qspi_valid,
			qspi_ready => qspi_ready,
			qspi_instr => qspi_instr,
			qspi_addr  => qspi_addr,
			qspi_wdata => qspi_wdata,
			qspi_wstrb => qspi_wstrb,
			qspi_rdata => qspi_rdata,
			spi_cs     => spi_cs,
			spi_dq0    => spi_dq0,
			spi_dq1    => spi_dq1,
			spi_dq2    => spi_dq2,
			spi_dq3    => spi_dq3,
			spi_sck    => spi_sck
		);

	sram_comp : sram
		port map(
			reset      => reset,
			clock      => clock,
			sram_valid => sram_valid,
			sram_ready => sram_ready,
			sram_instr => sram_instr,
			sram_addr  => sram_addr,
			sram_wdata => sram_wdata,
			sram_wstrb => sram_wstrb,
			sram_rdata => sram_rdata,
			ram_a      => ram_a,
			ram_dq_i   => ram_dq_i,
			ram_dq_o   => ram_dq_o,
			ram_cen    => ram_cen,
			ram_oen    => ram_oen,
			ram_wen    => ram_wen,
			ram_ub     => ram_ub,
			ram_lb     => ram_lb
		);

	axi_comp : axi
		port map(
			reset         => reset,
			clock         => clock,
			axi_valid     => axi_valid,
			axi_ready     => axi_ready,
			axi_instr     => axi_instr,
			axi_addr      => axi_addr,
			axi_wdata     => axi_wdata,
			axi_wstrb     => axi_wstrb,
			axi_rdata     => axi_rdata,
			-- Master interface write address
			m_axi_awvalid => m_axi_awvalid,
			m_axi_awready => m_axi_awready,
			m_axi_awaddr  => m_axi_awaddr,
			m_axi_awprot  => m_axi_awprot,
			-- Master interface write data
			m_axi_wvalid  => m_axi_wvalid,
			m_axi_wready  => m_axi_wready,
			m_axi_wdata   => m_axi_wdata,
			m_axi_wstrb   => m_axi_wstrb,
			-- Master interface write response
			m_axi_bvalid  => m_axi_bvalid,
			m_axi_bready  => m_axi_bready,
			-- Master interface read address
			m_axi_arvalid => m_axi_arvalid,
			m_axi_arready => m_axi_arready,
			m_axi_araddr  => m_axi_araddr,
			m_axi_arprot  => m_axi_arprot,
			-- Master interface read data return
			m_axi_rvalid  => m_axi_rvalid,
			m_axi_rready  => m_axi_rready,
			m_axi_rdata   => m_axi_rdata
		);

end architecture;
