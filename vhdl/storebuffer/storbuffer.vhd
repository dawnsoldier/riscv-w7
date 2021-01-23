-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.configure.all;
use work.constants.all;
use work.wire.all;

entity storbuffer is
	generic(
		storbuffer_depth : integer := storbuffer_depth
	);
	port(
		reset     : in  std_logic;
		clock     : in  std_logic;
		sbuffer_i : in  storbuffer_in_type;
		sbuffer_o : out storbuffer_out_type;
		dmem_o    : in  mem_out_type;
		dmem_i    : out mem_in_type
	);
end storbuffer;

architecture behavior of storbuffer is

	component storram
		port(
			reset     : in  std_logic;
			clock     : in  std_logic;
			storram_i : in  storram_in_type;
			storram_o : out storram_out_type
		);
	end component;

	component storctrl
		port(
			reset      : in  std_logic;
			clock      : in  std_logic;
			storctrl_i : in  storbuffer_in_type;
			storctrl_o : out storbuffer_out_type;
			storram_i  : out storram_in_type;
			storram_o  : in  storram_out_type;
			dmem_o     : in  mem_out_type;
			dmem_i     : out mem_in_type
		);
	end component;

	signal storram_i : storram_in_type;
	signal storram_o : storram_out_type;

begin

	storam_comp : storram
		port map(
			reset     => reset,
			clock     => clock,
			storram_i => storram_i,
			storram_o => storram_o
		);

	storctrl_comp : storctrl
		port map(
			reset      => reset,
			clock      => clock,
			storctrl_i => sbuffer_i,
			storctrl_o => sbuffer_o,
			storram_i  => storram_i,
			storram_o  => storram_o,
			dmem_o     => dmem_o,
			dmem_i     => dmem_i
		);

end architecture;
