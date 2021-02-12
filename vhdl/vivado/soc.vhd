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
		rst           : in  std_logic;
		clk           : in  std_logic;
		rx            : in  std_logic;
		tx            : out std_logic;
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
		m_axi_bresp   : in  std_logic;
		-- Master interface read address
		m_axi_arvalid : out std_logic;
		m_axi_arready : in  std_logic;
		m_axi_araddr  : out std_logic_vector(63 downto 0);
		m_axi_arprot  : out std_logic_vector(2 downto 0);
		-- Master interface read data return
		m_axi_rvalid  : in  std_logic;
		m_axi_rready  : out std_logic;
		m_axi_rdata   : in  std_logic_vector(63 downto 0);
		m_axi_rresp   : in  std_logic
	);
end entity soc;

architecture behavior of soc is

	component cpu
		port(
			reset         : in  std_logic;
			clock         : in  std_logic;
			rtc           : in  std_logic;
			rx            : in  std_logic;
			tx            : out std_logic;
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
			m_axi_bresp   : in  std_logic;
			-- Master interface read address
			m_axi_arvalid : out std_logic;
			m_axi_arready : in  std_logic;
			m_axi_araddr  : out std_logic_vector(63 downto 0);
			m_axi_arprot  : out std_logic_vector(2 downto 0);
			-- Master interface read data return
			m_axi_rvalid  : in  std_logic;
			m_axi_rready  : out std_logic;
			m_axi_rdata   : in  std_logic_vector(63 downto 0);
			m_axi_rresp   : in  std_logic
		);
	end component;

	signal rtc   : std_logic := '0';
	signal count : unsigned(31 downto 0) := (others => '0');

	signal clk_pll   : std_logic := '0';
	signal count_pll : unsigned(31 downto 0) := (others => '0');

begin

	process (clk)

	begin

		if (rising_edge(clk)) then
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
			reset         => rst,
			clock         => clk_pll,
			rtc           => rtc,
			rx            => rx,
			tx            => tx,
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
			m_axi_bresp   => m_axi_bresp,
			-- Master interface read address
			m_axi_arvalid => m_axi_arvalid,
			m_axi_arready => m_axi_arready,
			m_axi_araddr  => m_axi_araddr,
			m_axi_arprot  => m_axi_arprot,
			-- Master interface read data return
			m_axi_rvalid  => m_axi_rvalid,
			m_axi_rready  => m_axi_rready,
			m_axi_rdata   => m_axi_rdata,
			m_axi_rresp   => m_axi_rresp
		);

end architecture;
