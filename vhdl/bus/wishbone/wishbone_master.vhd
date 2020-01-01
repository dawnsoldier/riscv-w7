-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

entity wishbone_master is
	port(
		reset            : in  std_logic;
		clock            : in  std_logic;
		-- Wishbone Master Interface
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
		-- Memory Interface
		mem_valid        : in  std_logic;
		mem_ready        : out std_logic;
		mem_instr        : in  std_logic;
		mem_addr         : in  std_logic_vector(63 downto 0);
		mem_wdata        : in  std_logic_vector(63 downto 0);
		mem_wstrb        : in  std_logic_vector(7 downto 0);
		mem_rdata        : out std_logic_vector(63 downto 0)
	);
end wishbone_master;

architecture behavior of wishbone_master is

	type bus_state_type is (idle, active, busy);

	type reg_type is record
		bus_state        : bus_state_type;
		mem_valid        : std_logic;
		mem_instr        : std_logic;
		mem_addr         : std_logic_vector(63 downto 0);
		mem_wdata        : std_logic_vector(63 downto 0);
		mem_wstrb        : std_logic_vector(7 downto 0);
	end record;

	constant init_reg : reg_type := (
		bus_state => idle,
		mem_valid => '0',
		mem_instr => '0',
		mem_addr => (others => '0'),
		mem_wdata => (others => '0'),
		mem_wstrb => (others => '0')
	);

	signal r, rin     : reg_type := init_reg;

begin

	process(wbm_dat_i,wbm_ack_i,wbm_stall_i,wbm_err_i,wbm_rty_i,
					mem_valid,mem_instr,mem_addr,mem_wdata,mem_wstrb)

		variable v       : reg_type;

	begin

		v := r;

		case r.bus_state is
			when idle =>
				if mem_valid = '1' then
					v.bus_state := active;
				end if;
			when active =>
				if wbm_ack_i = '0' then
					v.bus_state := busy;
				end if;
			when busy =>
				if wbm_ack_i = '1' then
					if mem_valid = '1' then
						v.bus_state := active;
					elsif mem_valid = '0' then
						v.bus_state := idle;
					end if;
				end if;
		end case;

		v.mem_valid := mem_valid;
		v.mem_instr := mem_instr;
		v.mem_addr := mem_addr;
		v.mem_wdata := mem_wdata;
		v.mem_wstrb := mem_wstrb;

		case r.bus_state is
			when idle =>
				wbm_adr_o <= mem_addr;
				wbm_sel_o <= mem_wstrb;
				wbm_dat_o <= mem_wdata;
				wbm_cyc_o <= mem_valid;
				wbm_stb_o <= mem_valid;
				wbm_we_o <= mem_valid and or_reduce(mem_wstrb);
				----------------------------------------------------
				mem_rdata <= wbm_dat_i;
				mem_ready <= wbm_ack_i;
			when active =>
				v.mem_valid := mem_valid;
				v.mem_instr := mem_instr;
				v.mem_addr := mem_addr;
				v.mem_wstrb := mem_wstrb;
				v.mem_wdata := mem_wdata;
				----------------------------------------------------
				wbm_adr_o <= v.mem_addr;
				wbm_sel_o <= v.mem_wstrb;
				wbm_dat_o <= v.mem_wdata;
				wbm_cyc_o <= v.mem_valid;
				wbm_stb_o <= v.mem_valid;
				wbm_we_o <= v.mem_valid and or_reduce(v.mem_wstrb);
				----------------------------------------------------
				mem_rdata <= wbm_dat_i;
				mem_ready <= wbm_ack_i;
			when busy =>
				wbm_adr_o <= r.mem_addr;
				wbm_sel_o <= r.mem_wstrb;
				wbm_dat_o <= r.mem_wdata;
				wbm_cyc_o <= r.mem_valid;
				wbm_stb_o <= r.mem_valid;
				wbm_we_o <= r.mem_valid and or_reduce(r.mem_wstrb);
				----------------------------------------------------
				mem_rdata <= wbm_dat_i;
				mem_ready <= wbm_ack_i;
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
