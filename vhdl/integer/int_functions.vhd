-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.int_constants.all;
use work.int_types.all;

package int_functions is

	function to_std_logic(
		condition : in boolean
	)
	return std_logic;

	function multiplexer(
		data0 : in std_logic_vector(63 downto 0);
		data1 : in std_logic_vector(63 downto 0);
		sel   : in std_logic
	)
	return std_logic_vector;

end int_functions;

package body int_functions is

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

	function multiplexer(
		data0 : in std_logic_vector(63 downto 0);
		data1 : in std_logic_vector(63 downto 0);
		sel   : in std_logic
	)
	return std_logic_vector is
		variable res : std_logic_vector(63 downto 0);
	begin
		if sel = '0' then
			res := data0;
		else
			res := data1;
		end if;
		return res;
	end multiplexer;

end int_functions;
