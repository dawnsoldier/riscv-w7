-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.configure.all;
use work.wire.all;

entity timer is
	port(
		reset       : in  std_logic;
		clock       : in  std_logic;
		rtc         : in  std_logic;
		timer_valid : in  std_logic;
		timer_ready : out std_logic;
		timer_instr : in  std_logic;
		timer_addr  : in  std_logic_vector(63 downto 0);
		timer_wdata : in  std_logic_vector(63 downto 0);
		timer_wstrb : in  std_logic_vector(7 downto 0);
		timer_rdata : out std_logic_vector(63 downto 0);
		timer_irpt  : out std_logic
	);
end timer;

architecture behavior of timer is

	signal mtime    : std_logic_vector(63 downto 0) := (others => '0');
	signal mtimecmp : std_logic_vector(63 downto 0) := (others => '0');

	signal rdata : std_logic_vector(63 downto 0) := (others => '0');
	signal ready : std_logic := '0';

	signal irpt : std_logic := '0';

begin

	process(clock)

	begin

		if (rising_edge(clock)) then

			if (reset = '0') then
				mtimecmp <= (others => '0');
				rdata <= (others => '0');
				ready <= '0';
			else
				ready <= '0';
				if (timer_valid = '1') then
					if (unsigned(timer_addr) = 0) then
						if (or_reduce(timer_wstrb) = '0') then
							rdata <= mtimecmp;
							ready <= '1';
						else
							if (timer_wstrb(0) = '1') then
								mtimecmp(7 downto 0) <= timer_wdata(7 downto 0);
								ready <= '1';
							end if;
							if (timer_wstrb(1) = '1') then
								mtimecmp(15 downto 8) <= timer_wdata(15 downto 8);
								ready <= '1';
							end if;
							if (timer_wstrb(2) = '1') then
								mtimecmp(23 downto 16) <= timer_wdata(23 downto 16);
								ready <= '1';
							end if;
							if (timer_wstrb(3) = '1') then
								mtimecmp(31 downto 24) <= timer_wdata(31 downto 24);
								ready <= '1';
							end if;
							if (timer_wstrb(4) = '1') then
								mtimecmp(39 downto 32) <= timer_wdata(39 downto 32);
								ready <= '1';
							end if;
							if (timer_wstrb(5) = '1') then
								mtimecmp(47 downto 40) <= timer_wdata(47 downto 40);
								ready <= '1';
							end if;
							if (timer_wstrb(6) = '1') then
								mtimecmp(55 downto 48) <= timer_wdata(55 downto 48);
								ready <= '1';
							end if;
							if (timer_wstrb(7) = '1') then
								mtimecmp(63 downto 56) <= timer_wdata(63 downto 56);
								ready <= '1';
							end if;
						end if;
					elsif (unsigned(timer_addr) = 8) then
						if (or_reduce(timer_wstrb) = '0') then
							rdata <= mtime;
							ready <= '1';
						end if;
					end if;
				end if;
			end if;

		end if;

	end process;

	timer_rdata <= rdata;
	timer_ready <= ready;
	timer_irpt <= irpt;

	process(clock)

	begin

		if (rising_edge(clock)) then

			if (reset = '0') then
				irpt <= '0';
			else
				if (unsigned(mtime) >= unsigned(mtimecmp)) then
					irpt <= '1';
				else
					irpt <= '0';
				end if;
			end if;

		end if;

	end process;

	process(rtc)

	begin

		if (rising_edge(rtc)) then

			if (reset = '0') then
				mtime <= (others => '0');
			else
				mtime <= std_logic_vector(unsigned(mtime) + 1);
			end if;

		end if;

	end process;

end architecture;
