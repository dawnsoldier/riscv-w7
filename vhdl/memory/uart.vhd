-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.wire.all;

entity uart is
	port(
		reset      : in  std_logic;
		clock      : in  std_logic;
		rx         : in  std_logic;
		tx         : out std_logic;
		fifo_i     : out fifo_in_type;
		fifo_o     : in  fifo_out_type;
		uart_valid : in  std_logic;
		uart_instr : in  std_logic;
		uart_ready : out std_logic;
		uart_addr  : in  std_logic_vector(63 downto 0);
		uart_wdata : in  std_logic_vector(63 downto 0);
		uart_wstrb : in  std_logic_vector(7 downto 0);
		uart_rdata : out std_logic_vector(63 downto 0)
	);
end uart;

architecture behavior of uart is

	type reg_type is record
		state_rx   : natural range 0 to 15;
		state_tx   : natural range 0 to 15;
		state_re   : natural range 0 to 1;
		divider    : unsigned(31 downto 0);
		counter_rx : unsigned(31 downto 0);
		counter_tx : unsigned(31 downto 0);
		data_rx    : std_logic_vector(8 downto 0);
		data_tx    : std_logic_vector(9 downto 0);
		data_re    : std_logic_vector(7 downto 0);
		ready_rx   : std_logic;
		ready_tx   : std_logic;
		ready_ct   : std_logic;
		ready_re   : std_logic;
	end record;

	constant init_reg : reg_type := (
		state_rx   => 0,
		state_tx   => 0,
		state_re   => 0,
		divider    => 32X"0",
		counter_rx => 32X"0",
		counter_tx => 32X"0",
		data_rx    => 9X"1FF",
		data_tx    => 10X"3FF",
		data_re    => 8X"FF",
		ready_rx   => '0',
		ready_tx   => '0',
		ready_ct   => '0',
		ready_re   => '0'
	);

	signal r, rin : reg_type := init_reg;

begin

	process(r, rx, uart_valid, uart_addr, uart_wdata, uart_wstrb, fifo_o)
		variable v : reg_type;

	begin
		v := r;

		v.counter_rx := v.counter_rx + 1;
		v.counter_tx := v.counter_tx + 1;

		v.ready_rx := '0';
		v.ready_tx := '0';
		v.ready_ct := '0';
		v.ready_re := '0';

		fifo_i.wdata <= 8X"0";

		if uart_valid = '1' then
			if nor_reduce(uart_addr xor 64X"0") = '1' then
				if uart_wstrb(0) = '1' then
					v.divider(7 downto 0) := unsigned(uart_wdata(7 downto 0));
				end if;
				if uart_wstrb(1) = '1' then
					v.divider(15 downto 8) := unsigned(uart_wdata(15 downto 8));
				end if;
				if uart_wstrb(2) = '1' then
					v.divider(23 downto 16) := unsigned(uart_wdata(23 downto 16));
				end if;
				if uart_wstrb(3) = '1' then
					v.divider(31 downto 24) := unsigned(uart_wdata(31 downto 24));
				end if;
				v.ready_ct := '1';
			end if;
			if nor_reduce(uart_addr xor 64X"4") = '1' then
				if or(uart_wstrb) = '0' then
					v.state_re := 1;
				end if;
				if or(uart_wstrb) = '1' then
					v.data_tx := xor(uart_wdata) & uart_wdata(7 downto 0) & '0';
					v.state_tx := 1;
				end if;
			end if;
		end if;

		case r.state_rx is
			when 0 =>
				if rx = '0' then
					v.state_rx := 1;
				end if;
				v.counter_rx := 32X"0";
			when 10 =>
				if (r.counter_rx > r.divider) then
					v.state_rx := 0;
					v.counter_rx := 32X"0";
					v.ready_rx := '1';
				end if;
			when others =>
				if (r.counter_rx > r.divider) then
					v.data_rx := rx & v.data_rx(8 downto 1);
					v.state_rx := v.state_rx + 1;
					v.counter_rx := 32X"0";
				end if;
		end case;

		case r.state_tx is
			when 0 =>
				v.counter_tx := 32X"0";
			when 10 =>
				if (r.counter_tx > r.divider) then
					v.state_tx := 0;
					v.counter_tx := 32X"0";
					v.ready_tx := '1';
				end if;
			when others =>
				if (r.counter_tx > r.divider) then
					v.data_tx := '1' & v.data_tx(9 downto 1);
					v.state_tx := v.state_tx + 1;
					v.counter_tx := 32X"0";
				end if;
		end case;

		case r.state_re is
			when 0 =>
				fifo_i.re <= '0';
			when others =>
				fifo_i.re <= '1';
				if fifo_o.ready = '1' then
					v.state_re := 0;
					v.ready_re := '1';
					v.data_re := fifo_o.rdata;
				end if;
		end case;


		rin <= v;

		tx <= r.data_tx(0);

		fifo_i.we <= r.ready_rx;
		fifo_i.wdata <= r.data_rx(7 downto 0);

		uart_rdata <= 56X"0" & r.data_re;
		uart_ready <= r.ready_re or r.ready_tx or r.ready_ct;

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
