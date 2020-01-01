-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;
use work.wire.all;

entity interconnect is
	generic(
		bram_base_addr  : std_logic_vector(63 downto 0) := bram_base_addr;
		bram_mask_addr  : std_logic_vector(63 downto 0) := bram_mask_addr;
		time_base_addr  : std_logic_vector(63 downto 0) := time_base_addr;
		bus_base_addr   : std_logic_vector(63 downto 0) := bus_base_addr
	);
	port(
		reset           : in  std_logic;
		clock           : in  std_logic;
		-- memory
		imem_i          : in  mem_iface_in_type;
		imem_o          : out mem_iface_out_type;
		dmem_i          : in  mem_iface_in_type;
		dmem_o          : out mem_iface_out_type;
		-- blockram
		bram_mem_valid  : out std_logic;
		bram_mem_ready  : in  std_logic;
		bram_mem_instr  : out std_logic;
		bram_mem_addr   : out std_logic_vector(63 downto 0);
		bram_mem_wdata  : out std_logic_vector(63 downto 0);
		bram_mem_wstrb  : out std_logic_vector(7 downto 0);
		bram_mem_rdata  : in  std_logic_vector(63 downto 0);
		-- plic
		plic_mem_valid  : out std_logic;
		plic_mem_instr  : out std_logic;
		plic_mem_ready  : in  std_logic;
		plic_mem_addr   : out std_logic_vector(63 downto 0);
		plic_mem_wdata  : out std_logic_vector(63 downto 0);
		plic_mem_wstrb  : out std_logic_vector(7 downto 0);
		plic_mem_rdata  : in  std_logic_vector(63 downto 0);
		-- timer
		time_mem_valid  : out std_logic;
		time_mem_instr  : out std_logic;
		time_mem_ready  : in  std_logic;
		time_mem_addr   : out std_logic_vector(63 downto 0);
		time_mem_wdata  : out std_logic_vector(63 downto 0);
		time_mem_wstrb  : out std_logic_vector(7 downto 0);
		time_mem_rdata  : in  std_logic_vector(63 downto 0);
		-- bus
		bus_mem_valid   : out std_logic;
		bus_mem_ready   : in  std_logic;
		bus_mem_instr   : out std_logic;
		bus_mem_addr    : out std_logic_vector(63 downto 0);
		bus_mem_wdata   : out std_logic_vector(63 downto 0);
		bus_mem_wstrb   : out std_logic_vector(7 downto 0);
		bus_mem_rdata   : in  std_logic_vector(63 downto 0)
	);
end interconnect;

architecture behavior of interconnect is

signal access_type : std_logic;
signal data_type   : std_logic;

signal imem_valid : std_logic;
signal imem_ready : std_logic;
signal imem_instr : std_logic;
signal imem_addr  : std_logic_vector(63 downto 0);
signal imem_wdata : std_logic_vector(63 downto 0);
signal imem_wstrb : std_logic_vector(7 downto 0);
signal imem_rdata : std_logic_vector(63 downto 0);

signal dmem_valid : std_logic;
signal dmem_ready : std_logic;
signal dmem_instr : std_logic;
signal dmem_addr  : std_logic_vector(63 downto 0);
signal dmem_wdata : std_logic_vector(63 downto 0);
signal dmem_wstrb : std_logic_vector(7 downto 0);
signal dmem_rdata : std_logic_vector(63 downto 0);

signal bram_valid : std_logic;
signal bram_instr : std_logic;
signal bram_addr  : std_logic_vector(63 downto 0);
signal bram_wdata : std_logic_vector(63 downto 0);
signal bram_wstrb : std_logic_vector(7 downto 0);

begin

	imem_valid <= imem_i.mem_valid when imem_i.mem_valid = '1' else '0';
	imem_instr <= imem_i.mem_instr when imem_i.mem_valid = '1' else '0';
	imem_addr  <= imem_i.mem_addr  when imem_i.mem_valid = '1' else X"0000000000000000";
	imem_wdata <= imem_i.mem_wdata when imem_i.mem_valid = '1' else X"0000000000000000";
	imem_wstrb <= imem_i.mem_wstrb when imem_i.mem_valid = '1' else X"00";

	dmem_valid <= dmem_i.mem_valid when dmem_i.mem_valid = '1' else '0';
	dmem_instr <= dmem_i.mem_instr when dmem_i.mem_valid = '1' else '0';
	dmem_addr  <= dmem_i.mem_addr  when dmem_i.mem_valid = '1' else X"0000000000000000";
	dmem_wdata <= dmem_i.mem_wdata when dmem_i.mem_valid = '1' else X"0000000000000000";
	dmem_wstrb <= dmem_i.mem_wstrb when dmem_i.mem_valid = '1' else X"00";

	access_type <= dmem_valid when unsigned(dmem_addr xor bram_base_addr) < unsigned(bram_mask_addr) else '0';

	bram_valid <= imem_valid when access_type = '0' else dmem_valid when access_type = '1' else '0';
	bram_instr <= imem_instr when access_type = '0' else dmem_instr when access_type = '1' else '0';
	bram_addr  <= imem_addr  when access_type = '0' else dmem_addr  when access_type = '1' else X"0000000000000000";
	bram_wdata <= imem_wdata when access_type = '0' else dmem_wdata when access_type = '1' else X"0000000000000000";
	bram_wstrb <= imem_wstrb when access_type = '0' else dmem_wstrb when access_type = '1' else X"00";

	bram_mem_valid <= bram_valid;
	bram_mem_instr <= bram_instr;
	bram_mem_addr  <= bram_addr xor bram_base_addr;
	bram_mem_wdata <= bram_wdata;
	bram_mem_wstrb <= bram_wstrb;

	time_mem_valid <= dmem_valid;
	time_mem_instr <= dmem_instr;
	time_mem_addr  <= dmem_addr xor time_base_addr;
	time_mem_wdata <= dmem_wdata;
	time_mem_wstrb <= dmem_wstrb;

	bus_mem_valid <= dmem_valid;
	bus_mem_instr <= dmem_instr;
	bus_mem_addr  <= dmem_addr xor bus_base_addr;
	bus_mem_wdata <= dmem_wdata;
	bus_mem_wstrb <= dmem_wstrb;

	imem_rdata <= bram_mem_rdata when (bram_mem_ready and not(data_type)) = '1' else X"0000000000000000";
	imem_ready <= bram_mem_ready when (bram_mem_ready and not(data_type)) = '1' else '0';

	dmem_rdata <= bus_mem_rdata when bus_mem_ready = '1' else
								time_mem_rdata when time_mem_ready = '1' else
								bram_mem_rdata when (bram_mem_ready and data_type) = '1' else X"0000000000000000";
	dmem_ready <= bus_mem_ready when bus_mem_ready = '1' else
								time_mem_ready when time_mem_ready = '1' else
								bram_mem_ready when (bram_mem_ready and data_type) = '1' else '0';

	imem_o.mem_ready <= imem_ready;
	imem_o.mem_rdata <= imem_rdata;

	dmem_o.mem_ready <= dmem_ready;
	dmem_o.mem_rdata <= dmem_rdata;

	process(clock)

	begin

		if rising_edge(clock) then

			if reset = '0' then
				data_type <= '0';
			else
				data_type <= access_type;
			end if;

		end if;

	end process;

end architecture;
