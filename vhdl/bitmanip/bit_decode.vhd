-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.configure.all;
use work.bit_wire.all;

entity bit_decode is
	port(
		bit_decode_i : in  bit_decode_in_type;
		bit_decode_o : out bit_decode_out_type
	);
end bit_decode;

architecture behavior of bit_decode is

begin

end architecture;
