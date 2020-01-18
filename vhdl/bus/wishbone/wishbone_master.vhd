-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

entity wishbone_master is
	port(
		reset       : in  std_logic;
		clock       : in  std_logic;
		-- Wishbone Master Interface
		wbm_dat_i   : in  std_logic_vector(63 downto 0);
		wbm_dat_o   : out std_logic_vector(63 downto 0);
		wbm_ack_i   : in  std_logic;
		wbm_adr_o   : out std_logic_vector(63 downto 0);
		wbm_cyc_o   : out std_logic;
		wbm_stall_i : in  std_logic;
		wbm_err_i   : in  std_logic;
		wbm_lock_o  : out std_logic;
		wbm_rty_i   : in  std_logic;
		wbm_sel_o   : out std_logic_vector(7 downto 0);
		wbm_stb_o   : out std_logic;
		wbm_we_o    : out std_logic;
		-- Memory Interface
		bus_valid   : in  std_logic;
		bus_ready   : out std_logic;
		bus_instr   : in  std_logic;
		bus_addr    : in  std_logic_vector(63 downto 0);
		bus_wdata   : in  std_logic_vector(63 downto 0);
		bus_wstrb   : in  std_logic_vector(7 downto 0);
		bus_rdata   : out std_logic_vector(63 downto 0)
	);
end wishbone_master;

architecture behavior of wishbone_master is

	type bus_state_type is (idle, busy, complete);

	type reg_type is record
		bus_state : bus_state_type;
		bus_valid : std_logic;
		bus_instr : std_logic;
		bus_addr  : std_logic_vector(63 downto 0);
		bus_wdata : std_logic_vector(63 downto 0);
		bus_wstrb : std_logic_vector(7 downto 0);
		bus_we    : std_logic;
	end record;

	constant init_reg : reg_type := (
		bus_state => idle,
		bus_valid => '0',
		bus_instr => '0',
		bus_addr  => (others => '0'),
		bus_wdata => (others => '0'),
		bus_wstrb => (others => '0'),
		bus_we    => '0'
	);

	signal r, rin : reg_type := init_reg;

begin

	process(wbm_dat_i,wbm_ack_i,wbm_stall_i,wbm_err_i,wbm_rty_i,
					bus_valid,bus_instr,bus_addr,bus_wdata,bus_wstrb)

		variable v : reg_type;

	begin

		v := r;

		case r.bus_state is
			when idle =>
				if bus_valid = '1' then
					v.bus_state := complete;
				end if;
			when busy =>
				if wbm_stall_i = '0' then
					v.bus_state := complete;
				end if;
			when complete =>
				if wbm_stall_i = '1' then
					v.bus_state := busy;
				else
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
				v.bus_we := bus_valid and or_reduce(bus_wstrb);
				----------------------------------------------------
				wbm_adr_o <= v.bus_addr;
				wbm_sel_o <= v.bus_wstrb;
				wbm_dat_o <= v.bus_wdata;
				wbm_cyc_o <= v.bus_valid;
				wbm_stb_o <= v.bus_valid;
				wbm_we_o <= v.bus_we;
				----------------------------------------------------
				bus_rdata <= (others => '0');
				bus_ready <= '0';
			when busy =>
				----------------------------------------------------
				wbm_adr_o <= r.bus_addr;
				wbm_sel_o <= r.bus_wstrb;
				wbm_dat_o <= r.bus_wdata;
				wbm_cyc_o <= r.bus_valid;
				wbm_stb_o <= r.bus_valid;
				wbm_we_o <= r.bus_we;
				----------------------------------------------------
				bus_rdata <= (others => '0');
				bus_ready <= '0';
			when complete =>
				----------------------------------------------------
				v.bus_valid := bus_valid;
				v.bus_instr := bus_instr;
				v.bus_addr := bus_addr;
				v.bus_wdata := bus_wdata;
				v.bus_wstrb := bus_wstrb;
				v.bus_we := bus_valid and or_reduce(bus_wstrb);
				----------------------------------------------------
				wbm_adr_o <= v.bus_addr;
				wbm_sel_o <= v.bus_wstrb;
				wbm_dat_o <= v.bus_wdata;
				wbm_cyc_o <= v.bus_valid;
				wbm_stb_o <= v.bus_valid;
				wbm_we_o <= v.bus_we;
				----------------------------------------------------
				bus_rdata <= wbm_dat_i;
				bus_ready <= wbm_ack_i;
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
