-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package configure is

	constant bram_depth       : integer := 12;

	constant icache_enable    : boolean := true;
	constant icache_type      : integer := 0;
	constant icache_set_depth : integer := 6;

	constant bp_enable        : boolean := true;
	constant btb_depth        : integer := 6;
	constant bht_depth        : integer := 6;
	constant ras_depth        : integer := 2;

	constant pfetch_depth     : integer := 4;

	constant fpu_enable       : boolean := true;
	constant fpu_performance  : boolean := true;
	constant mul_performance  : boolean := true;

	constant pmp_enable       : boolean := true;
	constant pmp_regions      : integer := 8;

	constant start_base_addr  : std_logic_vector(63 downto 0) := X"0000000000000000";

	constant uart_base_addr   : std_logic_vector(63 downto 0) := X"0000000000100000";
	constant uart_top_addr    : std_logic_vector(63 downto 0) := X"0000000000100004";

	constant timer_base_addr  : std_logic_vector(63 downto 0) := X"0000000000200000";
	constant timer_top_addr   : std_logic_vector(63 downto 0) := X"0000000000200010";

	constant clk_freq         : integer := 100000000;
	constant clk_pll          : integer := 25000000;
	constant rtc_freq         : integer := 32768;
	constant baudrate         : integer := 115200;

	constant clk_divider_pll  : integer := (clk_freq/clk_pll)/2-1;
	constant clk_divider_rtc  : integer := (clk_freq/rtc_freq)/2-1;
	constant clks_per_bit     : integer := clk_pll/baudrate-1;

end configure;
