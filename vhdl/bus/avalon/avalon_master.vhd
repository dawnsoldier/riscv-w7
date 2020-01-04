-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

entity avalon_master is
	port(
		reset             : in  std_logic;
		clock             : in  std_logic;
		-- Avalon Master Interface
		avm_address       : out std_logic_vector(63 downto 0);
		avm_burstcount    : out std_logic_vector(10 downto 0);
		avm_byteenable    : out std_logic_vector(7 downto 0);
		avm_read          : out std_logic;
		avm_readdata      : in  std_logic_vector(63 downto 0);
		avm_readdatavalid : in  std_logic;
		avm_write         : out std_logic;
		avm_writedata     : out std_logic_vector(63 downto 0);
		avm_waitrequest   : in  std_logic;
		-- Memory Interface
		bus_valid         : in  std_logic;
		bus_ready         : out std_logic;
		bus_instr         : in  std_logic;
		bus_addr          : in  std_logic_vector(63 downto 0);
		bus_wdata         : in  std_logic_vector(63 downto 0);
		bus_wstrb         : in  std_logic_vector(7 downto 0);
		bus_rdata         : out std_logic_vector(63 downto 0)
	);
end avalon_master;

architecture behavior of avalon_master is

	type bus_state_type is (idle, active, busy);

	type reg_type is record
		bus_state         : bus_state_type;
		bus_valid         : std_logic;
		bus_instr         : std_logic;
		bus_addr          : std_logic_vector(63 downto 0);
		bus_wdata         : std_logic_vector(63 downto 0);
		bus_wstrb         : std_logic_vector(7 downto 0);
		bus_we            : std_logic;
		bus_re            : std_logic;
	end record;

	constant init_reg  : reg_type := (
		bus_state => idle,
		bus_valid => '0',
		bus_instr => '0',
		bus_addr => (others => '0'),
		bus_wdata => (others => '0'),
		bus_wstrb => (others => '0'),
		bus_we => '0',
		bus_re => '0'
	);

	signal r, rin      : reg_type := init_reg;

begin

	process(avm_readdata,avm_readdatavalid,avm_waitrequest,
					bus_valid,bus_instr,bus_addr,bus_wdata,bus_wstrb)

		variable v        : reg_type;

	begin

		v := r;

		case r.bus_state is
			when idle =>
				if bus_valid = '1' then
					v.bus_state := active;
				end if;
			when active =>
				if avm_waitrequest = '1' then
					v.bus_state := busy;
				end if;
			when busy =>
				if avm_waitrequest = '0' then
					if bus_valid = '1' then
						v.bus_state := active;
					elsif bus_valid = '0' then
						v.bus_state := idle;
					end if;
				end if;
		end case;

		case r.bus_state is
			when idle =>
				avm_address <= bus_addr;
				avm_burstcount <= "00000000001";
				avm_byteenable <= bus_wstrb;
				avm_writedata <= bus_wdata;
				avm_write <= bus_valid and or_reduce(bus_wstrb);
				avm_read <= bus_valid and nor_reduce(bus_wstrb);
				----------------------------------------------------
				bus_rdata <= avm_readdata;
				bus_ready <= not(avm_waitrequest) or avm_readdatavalid;
			when active =>
				v.bus_valid := bus_valid;
				v.bus_instr := bus_instr;
				v.bus_addr := bus_addr;
				v.bus_wstrb := bus_wstrb;
				v.bus_wdata := bus_wdata;
				v.bus_we := bus_valid and or_reduce(bus_wstrb);
				v.bus_re := bus_valid and nor_reduce(bus_wstrb);
				----------------------------------------------------
				avm_address <= v.bus_addr;
				avm_burstcount <= "00000000001";
				avm_byteenable <= v.bus_wstrb;
				avm_writedata <= v.bus_wdata;
				avm_write <= v.bus_we;
				avm_read <= v.bus_re;
				----------------------------------------------------
				bus_rdata <= avm_readdata;
				bus_ready <= not(avm_waitrequest) or avm_readdatavalid;
			when busy =>
				avm_address <= r.bus_addr;
				avm_burstcount <= "00000000001";
				avm_byteenable <= r.bus_wstrb;
				avm_writedata <= r.bus_wdata;
				avm_write <= r.bus_we;
				avm_read <= r.bus_re;
				----------------------------------------------------
				bus_rdata <= avm_readdata;
				bus_ready <= not(avm_waitrequest) or avm_readdatavalid;
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
