-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.configure.all;
use work.wire.all;

entity uart is
	generic(
		clks_per_bit : integer := clks_per_bit
	);
	port(
		reset      : in  std_logic;
		clock      : in  std_logic;
		uart_valid : in  std_logic;
		uart_ready : out std_logic;
		uart_instr : in  std_logic;
		uart_addr  : in  std_logic_vector(63 downto 0);
		uart_wdata : in  std_logic_vector(63 downto 0);
		uart_wstrb : in  std_logic_vector(7 downto 0);
		uart_rdata : out std_logic_vector(63 downto 0);
		uart_rx    : in  std_logic;
		uart_tx    : out std_logic
	);
end uart;

architecture behavior of uart is

	type register_tx_type is record
		state_tx   : unsigned(3 downto 0);
		data_tx    : std_logic_vector(9 downto 0);
		counter_tx : unsigned(31 downto 0);
		ready_tx   : std_logic;
	end record;

	type register_rx_type is record
		state_re   : std_logic;
		state_rx   : unsigned(3 downto 0);
		data_re    : std_logic_vector(7 downto 0);
		data_rx    : std_logic_vector(8 downto 0);
		counter_rx : unsigned(31 downto 0);
		ready_re   : std_logic;
		ready_rx   : std_logic;
	end record;

	constant init_register_tx : register_tx_type := (
		state_tx   => (others => '0'),
		data_tx    => (others => '1'),
		counter_tx => (others => '0'),
		ready_tx   => '0'
	);

	constant init_register_rx : register_rx_type := (
		state_re   => '0',
		state_rx   => (others => '0'),
		data_re    => (others => '0'),
		data_rx    => (others => '1'),
		counter_rx => (others => '0'),
		ready_re   => '0',
		ready_rx   => '0'
	);

	signal r_tx,rin_tx : register_tx_type := init_register_tx;
	signal r_rx,rin_rx : register_rx_type := init_register_rx;

begin

	process(r_tx,uart_valid,uart_instr,uart_addr,uart_wdata,uart_wstrb)

	variable v : register_tx_type;

	begin

		v := r_tx;

		v.counter_tx := v.counter_tx + 1;

		v.ready_tx := '0';

		if (uart_valid = '1' and or_reduce(uart_wstrb) = '1' and r_tx.state_tx = x"0") then
			v.data_tx := "1" & uart_wdata(7 downto 0) & "0";
			v.state_tx := x"1";
		end if;

		case r_tx.state_tx is
			when x"0" =>
				v.counter_tx := (others => '0');
			when x"A" =>
				if (r_tx.counter_tx > clks_per_bit) then
					v.state_tx := (others => '0');
					v.counter_tx := (others => '0');
					v.ready_tx := '1';
				end if;
			when others =>
				if (r_tx.counter_tx > clks_per_bit) then
					v.data_tx := "1" & v.data_tx(9 downto 1);
					v.state_tx := v.state_tx + 1;
					v.counter_tx := (others => '0');
				end if;
		end case;

		rin_tx <= v;

		uart_tx <= r_tx.data_tx(0);

	end process;

	process(r_rx,uart_valid,uart_instr,uart_addr,uart_wdata,uart_wstrb,uart_rx)

	variable v : register_rx_type;

	begin

		v := r_rx;

		v.counter_rx := v.counter_rx + 1;

		v.ready_re := '0';
		v.ready_rx := '0';

		if (uart_valid = '1' and or_reduce(uart_wstrb) = '0' and r_rx.state_rx = x"0") then
			v.state_re := '1';
		end if;

		case r_rx.state_rx is
			when x"0" =>
				if (uart_rx = '0') then
					v.state_rx := x"1";
				end if;
				v.counter_rx := (others => '0');
			when x"9" =>
				if (r_rx.counter_rx > clks_per_bit) then
					v.state_rx := (others => '0');
					v.counter_rx := (others => '0');
					v.ready_rx := '1';
				end if;
			when others =>
				if (r_rx.counter_rx > clks_per_bit) then
					v.data_rx := uart_rx & v.data_rx(8 downto 1);
					v.state_rx := v.state_rx + 1;
					v.counter_rx := (others => '0');
				end if;
		end case;

		if (r_rx.state_re = '1' and r_rx.ready_rx = '1') then
			v.state_re := '0';
			v.ready_re := '1';
			v.data_re := r_rx.data_rx(7 downto 0);
		end if;

		rin_rx <= v;

	end process;

	uart_rdata <= x"00000000000000" & r_rx.data_re;
	uart_ready <= r_tx.ready_tx or r_rx.ready_re;

	process(clock)

	begin

		if (rising_edge(clock)) then

			if (reset = '0') then
				r_tx <= init_register_tx;
				r_rx <= init_register_rx;
			else
				r_tx <= rin_tx;
				r_rx <= rin_rx;
			end if;

		end if;

	end process;

end architecture;
