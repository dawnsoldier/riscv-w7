-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;
use std.textio.all;

use work.configure.all;
use work.constants.all;
use work.wire.all;

entity soc is
	port(
		reset         : in    std_logic;
		clock         : in    std_logic;
		-- UART interface
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
end entity soc;

architecture behavior of soc is

	component cpu
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
	end component;

	signal rtc   : std_logic := '0';
	signal count : unsigned(31 downto 0) := (others => '0');

	signal clk_pll   : std_logic := '0';
	signal count_pll : unsigned(31 downto 0) := (others => '0');

begin

	process (clock)

	begin

		if (rising_edge(clock)) then
			if count = clk_divider_rtc then
				rtc <= not rtc;
				count <= (others => '0');
			else
				count <= count + 1;
			end if;

			if count_pll = clk_divider_pll then
				clk_pll <= not clk_pll;
				count_pll <= (others => '0');
			else
				count_pll <= count_pll + 1;
			end if;
		end if;

	end process;

	cpu_comp : cpu
		port map(
			reset         => reset,
			clock         => clk_pll,
			rtc           => rtc,
			-- UART interface
			uart_rx       => uart_rx,
			uart_tx       => uart_tx,
			-- QSPI Flash interface
			spi_cs        => spi_cs,
			spi_dq0       => spi_dq0,
			spi_dq1       => spi_dq1,
			spi_dq2       => spi_dq2,
			spi_dq3       => spi_dq3,
			spi_sck       => spi_sck,
			-- SRAM interface
			ram_a         => ram_a,
			ram_dq_i      => ram_dq_i,
			ram_dq_o      => ram_dq_o,
			ram_cen       => ram_cen,
			ram_oen       => ram_oen,
			ram_wen       => ram_wen,
			ram_ub        => ram_ub,
			ram_lb        => ram_lb,
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
