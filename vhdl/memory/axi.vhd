-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.configure.all;
use work.wire.all;

entity axi is
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
end axi;

architecture behavior of axi is

	type state_type is (IDLE, SEND, GET);

	type register_type is record
		state       : state_type;
		axi_awvalid : std_logic;
		axi_awaddr  : std_logic_vector(63 downto 0);
		axi_awprot  : std_logic_vector(2 downto 0);
		axi_arvalid : std_logic;
		axi_araddr  : std_logic_vector(63 downto 0);
		axi_arprot  : std_logic_vector(2 downto 0);
		axi_wvalid  : std_logic;
		axi_wdata   : std_logic_vector(63 downto 0);
		axi_wstrb   : std_logic_vector(7 downto 0);
		axi_bready  : std_logic;
		axi_rready  : std_logic;
	end record;

	constant init_register : register_type := (
		state       => IDLE,
		axi_awvalid => '0',
		axi_awaddr  => (others => '0'),
		axi_awprot  => (others => '0'),
		axi_arvalid => '0',
		axi_araddr  => (others => '0'),
		axi_arprot  => (others => '0'),
		axi_wvalid  => '0',
		axi_wdata   => (others => '0'),
		axi_wstrb   => (others => '0'),
		axi_bready  => '0',
		axi_rready  => '0'
	);

	signal r,rin : register_type := init_register;

begin

	process(r,axi_valid,axi_instr,axi_addr,axi_wdata,axi_wstrb,
					m_axi_bvalid,m_axi_rvalid,m_axi_awready,m_axi_arready,m_axi_wready)

	variable v : register_type;

	begin

		v := r;

		case r.state is
			when IDLE =>
				if axi_valid = '1' then
					v.state := SEND;
				end if;
			when SEND =>
				if (m_axi_awready or m_axi_arready or m_axi_wready) = '1' then
					v.state := GET;
				end if;
			when GET =>
				if (m_axi_bvalid or m_axi_rvalid) = '1' then
					v.state := IDLE;
				end if;
			when others =>
				null;
		end case;

		case r.state is
			when IDLE =>
				v.axi_awvalid := axi_valid and or_reduce(axi_wstrb);
				v.axi_awaddr := axi_addr;
				v.axi_awprot := "000";

				v.axi_arvalid := axi_valid and nor_reduce(axi_wstrb);
				v.axi_araddr := axi_addr;
				v.axi_arprot := axi_instr & "00";

				v.axi_wvalid := axi_valid and or_reduce(axi_wstrb);
				v.axi_wdata := axi_wdata;
				v.axi_wstrb := axi_wstrb;

				v.axi_bready := axi_valid and or_reduce(axi_wstrb);
				v.axi_rready := axi_valid and nor_reduce(axi_wstrb);
			when GET =>
				v.axi_awvalid := '0';
				v.axi_awaddr := (others => '0');
				v.axi_awprot := (others => '0');

				v.axi_arvalid := '0';
				v.axi_araddr := (others => '0');
				v.axi_arprot := (others => '0');

				v.axi_wvalid := '0';
				v.axi_wdata := (others => '0');
				v.axi_wstrb := (others => '0');
			when others =>
				null;
		end case;

		m_axi_awvalid <= v.axi_awvalid;
		m_axi_awaddr <= v.axi_awaddr;
		m_axi_awprot <= v.axi_awprot;

		m_axi_arvalid <= v.axi_arvalid;
		m_axi_araddr <= v.axi_araddr;
		m_axi_arprot <= v.axi_arprot;

		m_axi_wvalid <= v.axi_wvalid;
		m_axi_wdata <= v.axi_wdata;
		m_axi_wstrb <= v.axi_wstrb;

		m_axi_bready <= v.axi_bready;
		m_axi_rready <= v.axi_rready;

		rin <= v;

	end process;

	axi_ready <= m_axi_bvalid or m_axi_rvalid;
	axi_rdata <= m_axi_rdata;

	ASYNCHRONOUS : if reset_async = true generate

		process(reset,clock)

		begin

			if (reset = reset_active) then

				r <= init_register;

			elsif (rising_edge(clock)) then

				r <= rin;

			end if;

		end process;

	end generate ASYNCHRONOUS;

	SYNCHRONOUS : if reset_async = false generate

		process(clock)

		begin

			if (rising_edge(clock)) then

				if (reset = reset_active) then
					r <= init_register;
				else
					r <= rin;
				end if;

			end if;

		end process;

	end generate SYNCHRONOUS;

end architecture;
