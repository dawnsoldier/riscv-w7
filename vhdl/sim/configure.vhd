-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package configure is

	constant bram_depth      : integer := 13;

	constant btb_depth       : integer := 6;
	constant bht_depth       : integer := 6;
	constant ras_depth       : integer := 2;

	constant pfetch_depth    : integer := 4;

	constant fpu_enable      : boolean := true;
	constant fpu_performance : boolean := true;
	constant mul_performance : boolean := true;

	constant pmp_enable      : boolean := true;
	constant pmp_regions     : integer := 8;

	constant start_addr      : std_logic_vector(63 downto 0) := X"0000000000000000";
	constant bus_base_addr   : std_logic_vector(63 downto 0) := X"0000000000100000";
	constant time_base_addr  : std_logic_vector(63 downto 0) := x"0000000000200000";
	constant bram_base_addr  : std_logic_vector(63 downto 0) := X"0000000000000000";
	constant bram_mask_addr  : std_logic_vector(63 downto 0) := X"0000000000080000";

end configure;
