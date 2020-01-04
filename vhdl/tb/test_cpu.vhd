-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;
use std.textio.all;

use work.configure.all;
use work.constants.all;
use work.wire.all;

entity test_cpu is
end entity test_cpu;

architecture behavior of test_cpu is

	component cpu
		port(
			reset       : in  std_logic;
			clock       : in  std_logic;
			clock_rtc   : in  std_logic;
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
			wbm_we_o    : out std_logic
		);
	end component;

	signal reset     : std_logic := '0';
	signal clock     : std_logic := '0';
	signal clock_rtc : std_logic := '0';

	-- WishBone Master Interface
	signal wbm_dat_i   : std_logic_vector(63 downto 0);
	signal wbm_dat_o   : std_logic_vector(63 downto 0);
	signal wbm_ack_i   : std_logic;
	signal wbm_adr_o   : std_logic_vector(63 downto 0);
	signal wbm_cyc_o   : std_logic;
	signal wbm_stall_i : std_logic;
	signal wbm_err_i   : std_logic;
	signal wbm_lock_o  : std_logic;
	signal wbm_rty_i   : std_logic;
	signal wbm_sel_o   : std_logic_vector(7 downto 0);
	signal wbm_stb_o   : std_logic;
	signal wbm_we_o    : std_logic;

	procedure print(
		signal info        : inout string(1 to 255);
		signal counter     : inout natural range 1 to 255;
		signal data        : in std_logic_vector(7 downto 0)) is
		variable buf       : line;
	begin
		if data = X"0A" then
			write(buf, info);
			writeline(output, buf);
			info <= (others => character'val(0));
			counter <= 1;
		else
			info(counter) <= character'val(to_integer(unsigned(data)));
			counter <= counter + 1;
		end if;
	end procedure print;

	signal massage      : string(1 to 255) := (others => character'val(0));
	signal index        : natural range 1 to 255 := 1;

begin

	reset <= '1' after 10 ns;
	clock <= not clock after 1 ns;
	clock_rtc <= not clock_rtc after 30517578125 fs; --32.768 KHz

	process(clock)
	begin
		if rising_edge(clock) then

			if reset = '0' then

				massage <= (others => character'val(0));
				index <= 1;

				wbm_ack_i <= '0';

			else

				if (wbm_we_o and wbm_stb_o and wbm_cyc_o and
						nor_reduce(wbm_adr_o xor X"0000000000000000") and or_reduce(wbm_sel_o)) = '1' then
					--------------------------------------------------------------------
					-- TEXT OUTPUT
					--------------------------------------------------------------------
					print(massage,index,wbm_dat_o(7 downto 0));
					--------------------------------------------------------------------
					wbm_ack_i <= '1';
				else
					wbm_ack_i <= '0';
				end if;

			end if;

		end if;

	end process;

	cpu_comp : cpu
		port map(
			reset       => reset,
			clock       => clock,
			clock_rtc   => clock_rtc,
			-- Wishbone Master Interface
			wbm_dat_i   => wbm_dat_i,
			wbm_dat_o   => wbm_dat_o,
			wbm_ack_i   => wbm_ack_i,
			wbm_adr_o   => wbm_adr_o,
			wbm_cyc_o   => wbm_cyc_o,
			wbm_stall_i => wbm_stall_i,
			wbm_err_i   => wbm_err_i,
			wbm_lock_o  => wbm_lock_o,
			wbm_rty_i   => wbm_rty_i,
			wbm_sel_o   => wbm_sel_o,
			wbm_stb_o   => wbm_stb_o,
			wbm_we_o    => wbm_we_o
		);

end architecture;
