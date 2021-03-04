-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.configure.all;
use work.wire.all;

entity qspi is
	generic(
		spi_read_divider  : integer := spi_read_divider;
		spi_write_divider : integer := spi_write_divider
	);
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
end qspi;

architecture behavior of qspi is

	-- Supported commands:
	----------------------------------------------------
	--     0x03 Read Data byte
	--     0x0B Read Data bytes at Fast Speed
	--     0x3B Dual Output Read
	--     0x6B Quad Output Read
	--     0xBB Dual I/O High Performance Read
	--     0xEB Quad I/O High Performance Read
	----------------------------------------------------
	--     0x06 Write Enable
	--     0x04 Write Disable
	----------------------------------------------------
	--     0x60 Bulk Erase
	----------------------------------------------------
	--     0x02 Page Programming
	--     0x32 Quad Page Programming
	----------------------------------------------------
	--     0x05 Read Status Register
	--     0x01 Write (Status & Configuration) Register
	--     0x35 Read Configuration Register (CFG)
	--     0x30 Reset the Erase and Program Fail Flag (SR5 and SR6) and restore normal operation
	----------------------------------------------------
	--     0xAB Deep Power-Down
	--     0xB9 Release from Deep Power-Down Mode

	type state_type is (IDLE, LOAD, STORE, ERASE, CONFIGURE);

	type mode_type is (IDLE, INSTR, ADDR, MODE, DUMMY, LD, SD);

	type register_type is record
		state : state_type;
		smode : mode_type;
		instr : std_logic_vector(7 downto 0);
		addr  : std_logic_vector(23 downto 0);
		mode  : std_logic_vector(7 downto 0);
		data  : std_logic_vector(63 downto 0);
		strb  : std_logic_vector(7 downto 0);
		count : integer range 0 to 31;
		iter  : integer range 0 to 127;
		inc   : integer range 0 to 7;
		cs    : std_logic;
		dq0   : std_logic;
		dq1   : std_logic;
		dq2   : std_logic;
		dq3   : std_logic;
		sck   : std_logic;
	end record;

	constant init_register : register_type := (
		state => IDLE,
		smode => IDLE,
		instr => (others => '0'),
		addr  => (others => '0'),
		mode  => (others => '0'),
		data  => (others => '0'),
		strb  => (others => '0'),
		count => 0,
		iter  => 0,
		inc   => 0,
		cs    => '1',
		dq0   => 'Z',
		dq1   => 'Z',
		dq2   => 'Z',
		dq3   => 'Z',
		sck   => '1'
	);

	signal r,rin : register_type := init_register;

begin

	process(r,qspi_valid,qspi_instr,qspi_addr,qspi_wdata,qspi_wstrb,
					spi_dq0,spi_dq1,spi_dq2,spi_dq3)

	variable v : register_type;

	begin

		v := r;

		case r.state is
			when CONFIGURE =>

			when ERASE =>

			when IDLE =>
				v.state := IDLE;
				v.smode := IDLE;
				v.cs := '1';
				v.dq0 := 'Z';
				v.dq1 := 'Z';
				v.dq2 := 'Z';
				v.dq3 := 'Z';
				v.sck := '1';
				v.count := 0;
				v.iter := 0;
				if qspi_valid = '1' and nor_reduce(qspi_addr(63 downto 24)) = '1' then
					if or_reduce(qspi_wstrb) = '0' then
						v.state := LOAD;
						v.instr := X"6C"; -- 4QOR
					elsif or_reduce(qspi_wstrb) = '1' then
						v.state := STORE;
						v.instr := X"34"; -- 4QPP
					end if;
					v.smode := INSTR;
					v.iter := 8;
					v.inc := 1;
					v.addr := qspi_addr(23 downto 0);
					v.data := qspi_wdata;
					v.strb := qspi_wstrb;
					v.cs := '0';
					v.sck := '1';
				end if;
				spi_dq0 <= v.dq0;
				spi_dq1 <= v.dq1;
				spi_dq2 <= v.dq2;
				spi_dq3 <= v.dq3;
			when LOAD =>
				if v.count = spi_read_divider then
					v.count := 0;
					v.sck := not(v.sck);
					if v.sck = '0' then
						if v.iter = 0 then
							case v.smode is
								when INSTR =>
									v.smode := ADDR;
									v.iter := 24;
									v.inc := 4;
								when ADDR =>
									v.smode := MODE;
									v.iter := 8;
									v.inc := 4;
								when MODE =>
									v.smode := DUMMY;
									v.iter := 4;
									v.inc := 1;
								when DUMMY =>
									v.smode := LD;
									v.iter := 64;
									v.inc := 4;
								when LD =>
									v.state := IDLE;
									v.smode := IDLE;
									v.iter := 0;
									v.inc := 0;
								when others =>
									null;
							end case;
						else
							v.iter := v.iter - v.inc;
						end if;
						case v.smode is
							when INSTR =>
								v.dq0 := v.instr(v.iter);
								v.dq1 := 'Z';
								v.dq2 := 'Z';
								v.dq3 := 'Z';
							when ADDR =>
								v.dq0 := v.addr(v.iter-3);
								v.dq1 := v.addr(v.iter-2);
								v.dq2 := v.addr(v.iter-1);
								v.dq3 := v.addr(v.iter);
							when MODE =>
								v.dq0 := v.mode(v.iter-3);
								v.dq1 := v.mode(v.iter-2);
								v.dq2 := v.mode(v.iter-1);
								v.dq3 := v.mode(v.iter);
							when DUMMY =>
								v.dq0 := 'Z';
								v.dq1 := 'Z';
								v.dq2 := 'Z';
								v.dq3 := 'Z';
							when LD =>
								v.data(v.iter-3) := spi_dq0;
								v.data(v.iter-2) := spi_dq1;
								v.data(v.iter-1) := spi_dq2;
								v.data(v.iter) := spi_dq3;
							when others =>
								v.dq0 := 'Z';
								v.dq1 := 'Z';
								v.dq2 := 'Z';
								v.dq3 := 'Z';
						end case;
					end if;
				else
					v.count := v.count + 1;
				end if;
			when STORE =>
				if v.count = spi_write_divider then
					v.count := 0;
					v.sck := not(v.sck);
					if v.sck = '0' then
						if v.iter = 0 then
							if v.iter = 0 then
								case v.smode is
									when INSTR =>
										v.smode := ADDR;
										v.iter := 24;
										v.inc := 4;
									when ADDR =>
										v.smode := MODE;
										v.iter := 8;
										v.inc := 4;
									when MODE =>
										v.smode := DUMMY;
										v.iter := 4;
										v.inc := 1;
									when DUMMY =>
										v.smode := SD;
										v.iter := 64;
										v.inc := 4;
									when SD =>
										v.state := IDLE;
										v.smode := IDLE;
										v.iter := 0;
										v.inc := 0;
									when others =>
										null;
								end case;
							else
								v.iter := v.iter - v.inc;
							end if;
							case v.smode is
								when INSTR =>
									v.dq0 := v.instr(v.iter);
									v.dq1 := 'Z';
									v.dq2 := 'Z';
									v.dq3 := 'Z';
								when ADDR =>
									v.dq0 := v.addr(v.iter-3);
									v.dq1 := v.addr(v.iter-2);
									v.dq2 := v.addr(v.iter-1);
									v.dq3 := v.addr(v.iter);
								when MODE =>
									v.dq0 := v.mode(v.iter-3);
									v.dq1 := v.mode(v.iter-2);
									v.dq2 := v.mode(v.iter-1);
									v.dq3 := v.mode(v.iter);
								when DUMMY =>
									v.dq0 := 'Z';
									v.dq1 := 'Z';
									v.dq2 := 'Z';
									v.dq3 := 'Z';
								when SD =>
									if v.strb(to_integer(shift_right(to_unsigned(v.iter,7),3))) = '1' then
										v.dq0 := v.data(v.iter-3);
										v.dq1 := v.data(v.iter-2);
										v.dq2 := v.data(v.iter-1);
										v.dq3 := v.data(v.iter);
									else
										v.dq0 := 'Z';
										v.dq1 := 'Z';
										v.dq2 := 'Z';
										v.dq3 := 'Z';
									end if;
								when others =>
									v.dq0 := 'Z';
									v.dq1 := 'Z';
									v.dq2 := 'Z';
									v.dq3 := 'Z';
							end case;
						end if;
					end if;
				else
					v.count := v.count + 1;
				end if;
		end case;

		rin <= v;

		spi_cs <= v.cs;
		spi_sck <= v.sck;
		spi_dq0 <= v.dq0;
		spi_dq1 <= v.dq1;
		spi_dq2 <= v.dq2;
		spi_dq3 <= v.dq3;

	end process;

	process(clock)

	begin

		if (rising_edge(clock)) then

			if (reset = '0') then
				r <= init_register;
			else
				r <= rin;
			end if;

		end if;

	end process;

end architecture;
