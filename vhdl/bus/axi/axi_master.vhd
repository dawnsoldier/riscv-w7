-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

entity axi_master is
	port(
		reset       : in  std_logic;
		clock       : in  std_logic;
		-- AXI Master Interface
		------------------------------------------------
		-- Read Address Channel
		axi_araddr  : out std_logic_vector(63 downto 0);
		axi_arprot  : out std_logic_vector(2 downto 0);
		axi_arready : in  std_logic;
		axi_arvalid : out std_logic;
		-- Write Address Channel
		axi_awaddr  : out std_logic_vector(63 downto 0);
		axi_awprot  : out std_logic_vector(2 downto 0);
		axi_awready : in  std_logic;
		axi_awvalid : out std_logic;
		-- Write Response Channel
		axi_bready  : out std_logic;
		axi_bvalid  : in  std_logic;
		-- Read Data Channel
		axi_rdata   : in  std_logic_vector(63 downto 0);
		axi_rready  : out std_logic;
		axi_rvalid  : in  std_logic;
		-- Write Data Channel
		axi_wdata   : out std_logic_vector(63 downto 0);
		axi_wready  : in  std_logic;
		axi_wstrb   : out std_logic_vector(7 downto 0);
		axi_wvalid  : out std_logic;
		-- Memory Interface
		bus_valid   : in  std_logic;
		bus_ready   : out std_logic;
		bus_instr   : in  std_logic;
		bus_addr    : in  std_logic_vector(63 downto 0);
		bus_wdata   : in  std_logic_vector(63 downto 0);
		bus_wstrb   : in  std_logic_vector(7 downto 0);
		bus_rdata   : out std_logic_vector(63 downto 0)
	);
end axi_master;

architecture behavior of axi_master is

	type bus_state_type is (idle, busy, complete);

	type reg_type is record
		bus_state : bus_state_type;
		bus_valid : std_logic;
		bus_instr : std_logic;
		bus_addr  : std_logic_vector(63 downto 0);
		bus_wdata : std_logic_vector(63 downto 0);
		bus_wstrb : std_logic_vector(7 downto 0);
		bus_wren  : std_logic;
		bus_rden  : std_logic;
	end record;

	constant init_reg : reg_type := (
		bus_state => idle,
		bus_valid => '0',
		bus_instr => '0',
		bus_addr  => (others => '0'),
		bus_wdata => (others => '0'),
		bus_wstrb => (others => '0'),
		bus_wren  => '0',
		bus_rden  => '0'
	);

	signal r, rin : reg_type := init_reg;

begin

	process(axi_arready,axi_awready,axi_bvalid,axi_rdata,axi_rready,axi_wready,
					bus_valid,bus_instr,bus_addr,bus_wdata,bus_wstrb)

		variable v : reg_type;

	begin

		v := r;

		case r.bus_state is
			when idle =>
				if bus_valid = '1' then
					v.bus_state := busy;
				end if;
			when busy =>
				if (axi_arready or (axi_awready and axi_wready)) = '1' then
					v.bus_state := complete;
				end if;
			when complete =>
				if (axi_rvalid or axi_bvalid) = '1' then
					v.bus_state := idle;
				end if;
		end case;

		case r.bus_state is
			when idle =>
				----------------------------------------------------
				v.bus_valid := bus_valid;
				v.bus_instr := bus_instr;
				v.bus_addr := bus_addr;
				v.bus_wdata := bus_wdata;
				v.bus_wstrb := bus_wstrb;
				v.bus_wren := or_reduce(bus_wstrb);
				v.bus_rden := nor_reduce(bus_wstrb);
				----------------------------------------------------
				axi_araddr <= v.bus_addr;
				axi_arprot <= v.bus_instr & "00";
				axi_arvalid <= v.bus_valid and v.bus_rden;
				----------------------------------------------------
				axi_awaddr <= v.bus_addr;
				axi_awprot <= "000";
				axi_awvalid <= v.bus_valid and v.bus_wren;
				----------------------------------------------------
				axi_bready <= v.bus_valid and v.bus_wren;
				----------------------------------------------------
				axi_rready <= v.bus_valid and v.bus_rden;
				----------------------------------------------------
				axi_wdata <= v.bus_wdata;
				axi_wstrb <= v.bus_wstrb;
				axi_wvalid <= v.bus_valid and v.bus_wren;
				----------------------------------------------------
				bus_rdata <= (others => '0');
				bus_ready <= '0';
				----------------------------------------------------
			when busy =>
				----------------------------------------------------
				axi_araddr <= r.bus_addr;
				axi_arprot <= r.bus_instr & "00";
				axi_arvalid <= r.bus_valid and r.bus_rden;
				----------------------------------------------------
				axi_awaddr <= r.bus_addr;
				axi_awprot <= "000";
				axi_awvalid <= r.bus_valid and r.bus_wren;
				----------------------------------------------------
				axi_bready <= r.bus_valid and r.bus_wren;
				----------------------------------------------------
				axi_rready <= r.bus_valid and r.bus_rden;
				----------------------------------------------------
				axi_wdata <= r.bus_wdata;
				axi_wstrb <= r.bus_wstrb;
				axi_wvalid <= r.bus_valid and r.bus_wren;
				----------------------------------------------------
				bus_rdata <= (others => '0');
				bus_ready <= '0';
				----------------------------------------------------
			when complete =>
				----------------------------------------------------
				axi_araddr <= (others => '0');
				axi_arprot <= (others => '0');
				axi_arvalid <= '0';
				----------------------------------------------------
				axi_awaddr <= (others => '0');
				axi_awprot <= "000";
				axi_awvalid <= '0';
				----------------------------------------------------
				axi_bready <= r.bus_valid and r.bus_wren;
				----------------------------------------------------
				axi_rready <= r.bus_valid and r.bus_rden;
				----------------------------------------------------
				axi_wdata <= (others => '0');
				axi_wstrb <= (others => '0');
				axi_wvalid <= '0';
				----------------------------------------------------
				bus_rdata <= axi_rdata;
				bus_ready <= axi_rvalid or axi_bvalid;
				----------------------------------------------------
		end case;

		rin <= v;

	end process;

	process(clock)
	begin

		if rising_edge(clock) then

			if reset = '0' then

				r <= init_reg;

			else

				r <= rin;

			end if;

		end if;

	end process;

end architecture;
