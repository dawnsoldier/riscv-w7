-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.configure.all;
use work.bit_constants.all;
use work.bit_wire.all;

entity bit_decode is
	port(
		bit_decode_i : in  bit_decode_in_type;
		bit_decode_o : out bit_decode_out_type
	);
end bit_decode;

architecture behavior of bit_decode is

begin

	process(bit_decode_i)

		variable v : bit_decode_reg_type;

	begin
		v.instr := bit_decode_i.instr;

		v.imm := std_logic_vector(resize(unsigned(v.instr(24 downto 20)), 64));

		v.opcode := v.instr(6 downto 0);
		v.funct3 := v.instr(14 downto 12);
		v.funct5 := v.instr(24 downto 20);
		v.funct6 := v.instr(31 downto 26);
		v.funct7 := v.instr(31 downto 25);

		v.int_rden1 := '0';
		v.int_rden2 := '0';
		v.int_wren := '0';

		v.int := '0';
		v.bit_op := init_bit_operation;

		v.valid := '0';

		case v.opcode is

			when opcode_imm | opcode_reg | opcode_imm_32 | opcode_reg_32 =>

			when others =>

				null;

		end case;

		bit_decode_o.imm <= v.imm;
		bit_decode_o.int_rden1 <= v.int_rden1;
		bit_decode_o.int_rden2 <= v.int_rden2;
		bit_decode_o.int_wren <= v.int_wren;
		bit_decode_o.int <= v.int;
		bit_decode_o.bit_op <= v.bit_op;
		bit_decode_o.valid <= v.valid;

	end process;

end architecture;
