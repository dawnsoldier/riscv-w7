-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.configure.all;
use work.wire.all;

entity qspi is
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

	type state_type is (IDLE, ACTIVE);

	type register_type is record
		state   : state_type;
	end record;

	constant init_register : register_type := (
		state   => IDLE
	);

	signal r,rin : register_type := init_register;

begin

	process(r,qspi_valid,qspi_instr,qspi_addr,qspi_wdata,qspi_wstrb)

	variable v : register_type;

	begin

		v := r;

		rin <= v;

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
