-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.fp_cons.all;

package fp_func is

	function to_std_logic(
		condition : in boolean
	)
	return std_logic;

	function nan_boxing(
		data   : in std_logic_vector(63 downto 0);
		enable : in std_logic
	)
	return std_logic_vector;

end fp_func;

package body fp_func is

	function to_std_logic(
		condition : in boolean
	)
	return std_logic is
	begin
		if condition then
			return '1';
		else
			return '0';
		end if;
	end function to_std_logic;

	function nan_boxing(
		data   : in std_logic_vector(63 downto 0);
		enable : in std_logic
	)
	return std_logic_vector is
	begin
		if enable = '1' then
			return X"FFFFFFFF" & data(31 downto 0);
		else
			return data;
		end if;
	end function nan_boxing;

end fp_func;
