-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package configure is

	constant bram_depth        : integer := 15;

	constant icache_enable     : boolean := true;
	constant icache_sets       : integer := 10;
	constant icache_ways       : integer := 1;
	constant icache_words      : integer := 2;

	constant dcache_enable     : boolean := true;
	constant dcache_sets       : integer := 9;
	constant dcache_ways       : integer := 2;
	constant dcache_words      : integer := 2;

	constant bp_enable         : boolean := true;
	constant btb_depth         : integer := 6;
	constant bht_depth         : integer := 6;
	constant ras_depth         : integer := 2;

	constant fetchbuffer_depth : integer := 4;
	constant storebuffer_depth : integer := 4;

	constant fpu_enable        : boolean := true;
	constant fpu_performance   : boolean := true;
	constant mul_performance   : boolean := true;

	constant pmp_enable        : boolean := true;
	constant pmp_regions       : integer := 8;

	constant bram_base_addr    : std_logic_vector(63 downto 0) := X"0000000000000000";
	constant bram_top_addr     : std_logic_vector(63 downto 0) := X"0000000000040000";

	constant uart_base_addr    : std_logic_vector(63 downto 0) := X"0000000000100000";
	constant uart_top_addr     : std_logic_vector(63 downto 0) := X"0000000000100004";

	constant timer_base_addr   : std_logic_vector(63 downto 0) := X"0000000000200000";
	constant timer_top_addr    : std_logic_vector(63 downto 0) := X"0000000000200010";

	constant qspi_base_addr    : std_logic_vector(63 downto 0) := X"0000000001000000";
	constant qspi_top_addr     : std_logic_vector(63 downto 0) := X"0000000002000000";

	constant sram_base_addr    : std_logic_vector(63 downto 0) := X"0000000008000000";
	constant sram_top_addr     : std_logic_vector(63 downto 0) := X"0000000010000000";

	constant axi_base_addr     : std_logic_vector(63 downto 0) := X"0000000010000000";
	constant axi_top_addr      : std_logic_vector(63 downto 0) := X"0000000100000000";

	constant cache_base_addr   : std_logic_vector(63 downto 0) := X"0000000010000000";
	constant cache_top_addr    : std_logic_vector(63 downto 0) := X"0000000100000000";

	constant clk_divider_pll   : integer := 1;
	constant clk_divider_rtc   : integer := 1;
	constant clks_per_bit      : integer := 1;

	constant ram_read_divider  : integer := 1;
	constant ram_write_divider : integer := 1;

	constant spi_read_divider  : integer := 1;
	constant spi_write_divider : integer := 1;

end configure;
