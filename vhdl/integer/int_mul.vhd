-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;
use work.lzc_wire.all;
use work.int_constants.all;
use work.int_wire.all;
use work.int_types.all;

entity int_mul is
	generic(
		mul_performance : boolean := mul_performance
	);
	port(
		reset     : in  std_logic;
		clock     : in  std_logic;
		int_mul_i : in  int_mul_in_type;
		int_mul_o : out int_mul_out_type;
		lzc_o     : in  lzc_64_out_type;
		lzc_i     : out lzc_64_in_type
	);
end int_mul;

architecture behavior of int_mul is

	signal r_1 : int_mul_reg_type_1 := init_int_mul_reg_1;
	signal r_2 : int_mul_reg_type_2 := init_int_mul_reg_2;

	signal rin_1 : int_mul_reg_type_1 := init_int_mul_reg_1;
	signal rin_2 : int_mul_reg_type_2 := init_int_mul_reg_2;

	signal r : int_mul_reg_type := init_int_mul_reg;

	signal rin : int_mul_reg_type := init_int_mul_reg;

begin

	FAST : if mul_performance = true generate

		process(int_mul_i)
			variable op    : mul_operation_type;
			variable word  : std_logic;
			variable neg   : std_logic;
			variable aa    : std_logic_vector(63 downto 0);
			variable bb    : std_logic_vector(63 downto 0);
			variable ready : std_logic;

		begin
			op    := int_mul_i.op;
			word  := int_mul_i.word;
			neg   := '0';
			ready := int_mul_i.enable and
								(int_mul_i.op.alu_mul or int_mul_i.op.alu_mulh or
								int_mul_i.op.alu_mulhu or int_mul_i.op.alu_mulhsu);

			if op.alu_mulhu = '1' then
				aa := int_mul_i.data1;
			else
				if int_mul_i.data1(63) = '1' then
					aa  := std_logic_vector(-signed(int_mul_i.data1));
					neg := not neg;
				else
					aa := int_mul_i.data1;
				end if;
			end if;

			if (op.alu_mulhu or op.alu_mulhsu) = '1' then
				bb := int_mul_i.data2;
			else
				if int_mul_i.data2(63) = '1' then
					bb  := std_logic_vector(-signed(int_mul_i.data2));
					neg := not neg;
				else
					bb := int_mul_i.data2;
				end if;
			end if;

			rin_1.op <= op;
			rin_1.word <= word;
			rin_1.neg <= neg;
			rin_1.aa <= aa;
			rin_1.bb <= bb;
			if int_mul_i.clear = '1' then
				rin_1.ready <= '0';
			else
				rin_1.ready <= ready;
			end if;

			lzc_i.a <= X"0000000000000000";

		end process;

		process(r_1, int_mul_i)
			variable op    : mul_operation_type;
			variable word  : std_logic;
			variable neg   : std_logic;
			variable aa    : std_logic_vector(63 downto 0);
			variable bb    : std_logic_vector(63 downto 0);
			variable rr    : std_logic_vector(127 downto 0);
			variable ready : std_logic;

		begin
			op    := r_1.op;
			word  := r_1.word;
			neg   := r_1.neg;
			aa    := r_1.aa;
			bb    := r_1.bb;
			ready := r_1.ready;

			rr := std_logic_vector(unsigned(aa) * unsigned(bb));

			rin_2.op <= op;
			rin_2.word <= word;
			rin_2.neg <= neg;
			rin_2.rr <= rr;
			if int_mul_i.clear = '1' then
				rin_2.ready <= '0';
			else
				rin_2.ready <= ready;
			end if;

		end process;

		process(r_2, int_mul_i)
			variable op     : mul_operation_type;
			variable word   : std_logic;
			variable neg    : std_logic;
			variable rr     : std_logic_vector(127 downto 0);
			variable result : std_logic_vector(63 downto 0);
			variable ready  : std_logic;

		begin
			op    := r_2.op;
			word  := r_2.word;
			neg   := r_2.neg;
			rr    := r_2.rr;
			ready := r_2.ready;

			if neg = '1' then
				rr := std_logic_vector(-signed(rr));
			end if;

			if op.alu_mul = '1' then
				result := rr(63 downto 0);
			else
				result := rr(127 downto 64);
			end if;

			if word = '1' then
				result(63 downto 32) := (others => result(31));
			end if;

			int_mul_o.result <= result;
			if int_mul_i.clear = '1' then
				int_mul_o.ready <= '0';
			else
				int_mul_o.ready <= ready;
			end if;

		end process;

		process(clock)
		begin
			if rising_edge(clock) then

				if reset = '0' then

					r_1 <= init_int_mul_reg_1;
					r_2 <= init_int_mul_reg_2;

				else

					r_1 <= rin_1;
					r_2 <= rin_2;

				end if;

			end if;

		end process;

	end generate FAST;

	SLOW : if mul_performance = false generate

		process(r, int_mul_i,lzc_o)
			variable v : int_mul_reg_type;

		begin
			v := r;

			case r.state is
				when MUL0 =>
					if (int_mul_i.enable and (int_mul_i.op.alu_mul or int_mul_i.op.alu_mulh or
							int_mul_i.op.alu_mulhu or int_mul_i.op.alu_mulhsu)) = '1' then
						v.state := MUL1;
					end if;
					v.ready := '0';
					if int_mul_i.clear = '1' then
						v.state := MUL0;
					end if;
				when MUL1 =>
					case r.counter is
						when 0 =>
							v.state := MUL2;
						when others =>
							v.counter := v.counter - 1;
					end case;
					v.ready := '0';
					if int_mul_i.clear = '1' then
						v.state := MUL0;
					end if;
				when others =>
					v.state := MUL0;
					v.ready := '1';
					if int_mul_i.clear = '1' then
						v.ready := '0';
					end if;
			end case;

			case r.state is
				when MUL0 =>
					v.op := int_mul_i.op;
					v.word := int_mul_i.word;
					v.neg := '0';
					if v.op.alu_mulhu = '1' then
						v.aa := int_mul_i.data1;
					else
						if int_mul_i.data1(63) = '1' then
							v.aa := std_logic_vector(-signed(int_mul_i.data1));
							v.neg := not v.neg;
						else
							v.aa := int_mul_i.data1;
						end if;
					end if;
					if (v.op.alu_mulhu or v.op.alu_mulhsu) = '1' then
						v.bb := int_mul_i.data2;
					else
						if int_mul_i.data2(63) = '1' then
							v.bb := std_logic_vector(-signed(int_mul_i.data2));
							v.neg := not v.neg;
						else
							v.bb := int_mul_i.data2;
						end if;
					end if;
					lzc_i.a <= v.aa;
					v.counter := to_integer(unsigned(not(lzc_o.c)));
					v.counter := 63 - v.counter;
					v.rr := (others => '0');
				when MUL1 =>
					lzc_i.a <= X"0000000000000000";
					v.rr := v.rr(126 downto 0) & '0';
					if v.aa(r.counter) = '1' then
						v.rr := std_logic_vector(unsigned(v.rr) + unsigned(v.bb));
					end if;
				when others =>
					lzc_i.a <= X"0000000000000000";
					if v.neg = '1' then
						v.rr := std_logic_vector(-signed(v.rr));
					end if;
					if v.op.alu_mul = '1' then
						v.result := v.rr(63 downto 0);
					else
						v.result := v.rr(127 downto 64);
					end if;
					if v.word = '1' then
						v.result(63 downto 32) := (others => v.result(31));
					end if;
			end case;

			int_mul_o.result <= v.result;
			int_mul_o.ready <= v.ready;

			rin <= v;

		end process;

		process(clock)
		begin
			if rising_edge(clock) then

				if reset = '0' then

					r <= init_int_mul_reg;

				else

					r <= rin;

				end if;

			end if;

		end process;

	end generate SLOW;

end architecture;
