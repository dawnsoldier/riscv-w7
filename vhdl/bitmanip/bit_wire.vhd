-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package bit_wire is

	type bit_decode_in_type is record
		instr : std_logic_vector(31 downto 0);
	end record;

	type bit_decode_out_type is record
		int_rden1 : std_logic;
		int_rden2 : std_logic;
		int_wren  : std_logic;
		int       : std_logic;
		valid     : std_logic;
	end record;

end bit_wire;
