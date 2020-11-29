-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.configure.all;
use work.constants.all;
use work.wire.all;

entity prefetch is
	generic(
		pfetch_depth : integer := pfetch_depth
	);
	port(
		reset     : in  std_logic;
		clock     : in  std_logic;
		pfetch_i  : in  prefetch_in_type;
		pfetch_o  : out prefetch_out_type
	);
end prefetch;

architecture behavior of prefetch is

	component prebuffer
		port(
			reset     : in  std_logic;
			clock     : in  std_logic;
			pbuffer_i : in  prebuffer_in_type;
			pbuffer_o : out prebuffer_out_type
		);
	end component;

	component prectrl
		port(
			reset     : in  std_logic;
			clock     : in  std_logic;
			pctrl_i   : in  prefetch_in_type;
			pctrl_o   : out prefetch_out_type;
			pbuffer_i : out prebuffer_in_type;
			pbuffer_o : in  prebuffer_out_type
		);
	end component;

	signal pbuffer_i : prebuffer_in_type;
	signal pbuffer_o : prebuffer_out_type;

begin

	prebuffer_comp : prebuffer
		port map(
			reset     => reset,
			clock     => clock,
			pbuffer_i => pbuffer_i,
			pbuffer_o => pbuffer_o
		);

	prectrl_comp : prectrl
		port map(
			reset     => reset,
			clock     => clock,
			pctrl_i   => pfetch_i,
			pctrl_o   => pfetch_o,
			pbuffer_i => pbuffer_i,
			pbuffer_o => pbuffer_o
		);

end architecture;
