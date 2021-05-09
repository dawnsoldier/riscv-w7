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
end entity soc;

architecture behavior of soc is

	component cpu
		port(
			reset         : in    std_logic;
			clock         : in    std_logic;
			rtc           : in    std_logic;
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
	end component;

	signal reset         : std_logic := '0';
	signal clock         : std_logic := '0';
	signal rtc           : std_logic := '0';
	signal count         : unsigned(31 downto 0) := (others => '0');
	-- UART interface
	signal uart_rx       : std_logic := '1';
	signal uart_tx       : std_logic := '1';
	-- QSPI Flash interface
	signal spi_cs        : std_logic := '0';
	signal spi_dq0       : std_logic := '0';
	signal spi_dq1       : std_logic := '0';
	signal spi_dq2       : std_logic := '0';
	signal spi_dq3       : std_logic := '0';
	signal spi_sck       : std_logic := '0';
	-- SRAM interface
	signal ram_a         : std_logic_vector(26 downto 0) := (others => '0');
	signal ram_dq_i      : std_logic_vector(15 downto 0) := (others => '0');
	signal ram_dq_o      : std_logic_vector(15 downto 0) := (others => '0');
	signal ram_cen       : std_logic := '0';
	signal ram_oen       : std_logic := '0';
	signal ram_wen       : std_logic := '0';
	signal ram_ub        : std_logic := '0';
	signal ram_lb        : std_logic := '0';
	-- Master interface write address
	signal m_axi_awvalid : std_logic := '0';
	signal m_axi_awready : std_logic := '0';
	signal m_axi_awaddr  : std_logic_vector(63 downto 0) := (others => '0');
	signal m_axi_awprot  : std_logic_vector(2 downto 0) := (others => '0');
	-- Master interface write data
	signal m_axi_wvalid  : std_logic := '0';
	signal m_axi_wready  : std_logic := '0';
	signal m_axi_wdata   : std_logic_vector(63 downto 0) := (others => '0');
	signal m_axi_wstrb   : std_logic_vector(7 downto 0) := (others => '0');
	-- Master interface write response
	signal m_axi_bvalid  : std_logic := '0';
	signal m_axi_bready  : std_logic := '0';
	-- Master interface read address
	signal m_axi_arvalid : std_logic := '0';
	signal m_axi_arready : std_logic := '0';
	signal m_axi_araddr  : std_logic_vector(63 downto 0) := (others => '0');
	signal m_axi_arprot  : std_logic_vector(2 downto 0) := (others => '0');
	-- Master interface read data return
	signal m_axi_rvalid  : std_logic := '0';
	signal m_axi_rready  : std_logic := '0';
	signal m_axi_rdata   : std_logic_vector(63 downto 0) := (others => '0');

begin

	reset <= '1' after 100 ns;
	clock <= not clock after 20 ns;

	process (clock)

	begin

		if rising_edge(clock) then

			if count = clk_divider_rtc then
				rtc <= not rtc;
				count <= (others => '0');
			else
				count <= count + 1;
			end if;

		end if;

	end process;

	cpu_comp : cpu
		port map(
			reset         => reset,
			clock         => clock,
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
