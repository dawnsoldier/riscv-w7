-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package bit_functions is

	function clz(
		rs1 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector;

	function ctz(
		rs1 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector;

	function cpop(
		rs1 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector;

	function andn(
		rs1 : in std_logic_vector(63 downto 0);
		rs2 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector;

	function orn(
		rs1 : in std_logic_vector(63 downto 0);
		rs2 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector;

	function xorn(
		rs1 : in std_logic_vector(63 downto 0);
		rs2 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector;

	function pack(
		rs1 : in std_logic_vector(63 downto 0);
		rs2 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector;

	function packu(
		rs1 : in std_logic_vector(63 downto 0);
		rs2 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector;

	function packh(
		rs1 : in std_logic_vector(63 downto 0);
		rs2 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector;

	function min(
		rs1 : in std_logic_vector(63 downto 0);
		rs2 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector;

	function max(
		rs1 : in std_logic_vector(63 downto 0);
		rs2 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector;

	function minu(
		rs1 : in std_logic_vector(63 downto 0);
		rs2 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector;

	function maxu(
		rs1 : in std_logic_vector(63 downto 0);
		rs2 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector;

	function sextb(
		rs1 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector;

	function sexth(
		rs1 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector;

	function bset(
		rs1 : in std_logic_vector(63 downto 0);
		rs2 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector;

	function bclr(
		rs1 : in std_logic_vector(63 downto 0);
		rs2 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector;

	function binv(
		rs1 : in std_logic_vector(63 downto 0);
		rs2 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector;

	function bext(
		rs1 : in std_logic_vector(63 downto 0);
		rs2 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector;

	function slo(
		rs1 : in std_logic_vector(63 downto 0);
		rs2 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector;

	function sro(
		rs1 : in std_logic_vector(63 downto 0);
		rs2 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector;

	function rotl(
		rs1 : in std_logic_vector(63 downto 0);
		rs2 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector;

	function rotr(
		rs1 : in std_logic_vector(63 downto 0);
		rs2 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector;

	function grev(
		rs1 : in std_logic_vector(63 downto 0);
		rs2 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector;

	function shuffle_stage(
		src : in std_logic_vector(63 downto 0);
		maskL : in std_logic_vector(63 downto 0);
		maskR : in std_logic_vector(63 downto 0);
		N : in integer range 0 to 63
	)
	return std_logic_vector;

	function shfl(
		rs1 : in std_logic_vector(63 downto 0);
		rs2 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector;

	function unshfl(
		rs1 : in std_logic_vector(63 downto 0);
		rs2 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector;

end bit_functions;

package body bit_functions is

	function clz(
		rs1 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector is
		variable res : integer range 0 to 127;
	begin
		res := 0;
		for i in 63 downto 0 loop
			if (rs1(i) = '1') then
				exit;
			end if;
			res := res + 1;
		end loop;
		return std_logic_vector(to_unsigned(res,64));
	end function clz;

	function ctz(
		rs1 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector is
		variable res : integer range 0 to 127;
	begin
		res := 0;
		for i in 0 downto 63 loop
			if (rs1(i) = '1') then
				exit;
			end if;
			res := res + 1;
		end loop;
		return std_logic_vector(to_unsigned(res,64));
	end function ctz;

	function cpop(
		rs1 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector is
		variable res : integer range 0 to 127;
	begin
		res := 0;
		for i in 0 downto 63 loop
			if (rs1(i) = '1') then
				res := res + 1;
			end if;
		end loop;
		return std_logic_vector(to_unsigned(res,64));
	end function cpop;

	function andn(
		rs1 : in std_logic_vector(63 downto 0);
		rs2 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector is
	begin
		return rs1 and not(rs2);
	end function andn;

	function orn(
		rs1 : in std_logic_vector(63 downto 0);
		rs2 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector is
	begin
		return rs1 or not(rs2);
	end function orn;

	function xorn(
		rs1 : in std_logic_vector(63 downto 0);
		rs2 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector is
	begin
		return rs1 xor not(rs2);
	end function xorn;

	function pack(
		rs1 : in std_logic_vector(63 downto 0);
		rs2 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector is
	begin
		return rs2(31 downto 0) & rs1(31 downto 0);
	end function pack;

	function packu(
		rs1 : in std_logic_vector(63 downto 0);
		rs2 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector is
	begin
		return rs2(63 downto 32) & rs1(63 downto 32);
	end function packu;

	function packh(
		rs1 : in std_logic_vector(63 downto 0);
		rs2 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector is
	begin
		return X"000000" & rs2(7 downto 0) & rs1(7 downto 0);
	end function packh;

	function min(
		rs1 : in std_logic_vector(63 downto 0);
		rs2 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector is
	begin
		if (signed(rs1) < signed(rs2)) then
			return rs1;
		else
			return rs2;
		end if;
	end function min;

	function max(
		rs1 : in std_logic_vector(63 downto 0);
		rs2 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector is
	begin
		if (signed(rs1) > signed(rs2)) then
			return rs1;
		else
			return rs2;
		end if;
	end function max;

	function minu(
		rs1 : in std_logic_vector(63 downto 0);
		rs2 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector is
	begin
		if (unsigned(rs1) < unsigned(rs2)) then
			return rs1;
		else
			return rs2;
		end if;
	end function minu;

	function maxu(
		rs1 : in std_logic_vector(63 downto 0);
		rs2 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector is
	begin
		if (unsigned(rs1) > unsigned(rs2)) then
			return rs1;
		else
			return rs2;
		end if;
	end function maxu;

	function sextb(
		rs1 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector is
	begin
		return std_logic_vector(resize(signed(rs1(7 downto 0)), 64));
	end function sextb;

	function sexth(
		rs1 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector is
	begin
		return std_logic_vector(resize(signed(rs1(15 downto 0)), 64));
	end function sexth;

	function bset(
		rs1 : in std_logic_vector(63 downto 0);
		rs2 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector is
		variable res : std_logic_vector(63 downto 0);
	begin
		res := rs1;
		res(to_integer(unsigned(rs2(5 downto 0)))) := '1';
		return res;
	end function bset;

	function bclr(
		rs1 : in std_logic_vector(63 downto 0);
		rs2 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector is
		variable res : std_logic_vector(63 downto 0);
	begin
		res := rs1;
		res(to_integer(unsigned(rs2(5 downto 0)))) := '0';
		return res;
	end function bclr;

	function binv(
		rs1 : in std_logic_vector(63 downto 0);
		rs2 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector is
		variable res : std_logic_vector(63 downto 0);
	begin
		res := rs1;
		res(to_integer(unsigned(rs2(5 downto 0)))) := not(res(to_integer(unsigned(rs2(5 downto 0)))));
		return res;
	end function binv;

	function bext(
		rs1 : in std_logic_vector(63 downto 0);
		rs2 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector is
		variable res : std_logic_vector(63 downto 0);
	begin
		res := (others => '0');
		res(to_integer(unsigned(rs2(5 downto 0)))) := '1';
		return res;
	end function bext;

	function slo(
		rs1 : in std_logic_vector(63 downto 0);
		rs2 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector is
		variable res : std_logic_vector(63 downto 0);
	begin
		res := not(rs1);
		res := std_logic_vector(shift_left(unsigned(res), to_integer(unsigned(rs2(5 downto 0)))));
		return not(res);
	end function slo;

	function sro(
		rs1 : in std_logic_vector(63 downto 0);
		rs2 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector is
		variable res : std_logic_vector(63 downto 0);
	begin
		res := not(rs1);
		res := std_logic_vector(shift_right(unsigned(res), to_integer(unsigned(rs2(5 downto 0)))));
		return not(res);
	end function sro;

	function rotl(
		rs1 : in std_logic_vector(63 downto 0);
		rs2 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector is
		variable res : std_logic_vector(63 downto 0);
	begin
		res := std_logic_vector(shift_left(unsigned(rs1), to_integer(unsigned(rs2(5 downto 0)))));
		res := res or std_logic_vector(shift_right(unsigned(res), 64-to_integer(unsigned(rs2(5 downto 0)))));
		return res;
	end function rotl;

	function rotr(
		rs1 : in std_logic_vector(63 downto 0);
		rs2 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector is
		variable res : std_logic_vector(63 downto 0);
	begin
		res := std_logic_vector(shift_right(unsigned(rs1), to_integer(unsigned(rs2(5 downto 0)))));
		res := res or std_logic_vector(shift_left(unsigned(res), 64-to_integer(unsigned(rs2(5 downto 0)))));
		return res;
	end function rotr;

	function grev(
		rs1 : in std_logic_vector(63 downto 0);
		rs2 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector is
		variable res : std_logic_vector(63 downto 0);
	begin
		res := rs1;
		if rs2(0) = '1' then
			res := (res and std_logic_vector(shift_left(unsigned(res),1))) or (res and std_logic_vector(shift_right(unsigned(res),1)));
		end if;
		if rs2(1) = '1' then
			res := (res and std_logic_vector(shift_left(unsigned(res),2))) or (res and std_logic_vector(shift_right(unsigned(res),2)));
		end if;
		if rs2(2) = '1' then
			res := (res and std_logic_vector(shift_left(unsigned(res),4))) or (res and std_logic_vector(shift_right(unsigned(res),4)));
		end if;
		if rs2(3) = '1' then
			res := (res and std_logic_vector(shift_left(unsigned(res),8))) or (res and std_logic_vector(shift_right(unsigned(res),8)));
		end if;
		if rs2(4) = '1' then
			res := (res and std_logic_vector(shift_left(unsigned(res),16))) or (res and std_logic_vector(shift_right(unsigned(res),16)));
		end if;
		if rs2(5) = '1' then
			res := (res and std_logic_vector(shift_left(unsigned(res),32))) or (res and std_logic_vector(shift_right(unsigned(res),32)));
		end if;
		return res;
	end function grev;

	function shuffle_stage(
		src : in std_logic_vector(63 downto 0);
		maskL : in std_logic_vector(63 downto 0);
		maskR : in std_logic_vector(63 downto 0);
		N : in integer range 0 to 63
	)
	return std_logic_vector is
		variable res : std_logic_vector(63 downto 0);
	begin
		res := src and not(maskL or maskR);
		res := res or (std_logic_vector(shift_left(unsigned(src),N)) and maskL);
		res := res or (std_logic_vector(shift_right(unsigned(src),N)) and maskR);
		return res;
	end function shuffle_stage;

	function shfl(
		rs1 : in std_logic_vector(63 downto 0);
		rs2 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector is
		variable res : std_logic_vector(63 downto 0);
	begin
		res := rs1;
		if rs2(4) = '1' then
			res := shuffle_stage(res,X"0000ffff00000000",X"00000000ffff0000",16);
		end if;
		if rs2(3) = '1' then
			res := shuffle_stage(res,X"00ff000000ff0000",X"0000ff000000ff00",8);
		end if;
		if rs2(2) = '1' then
			res := shuffle_stage(res,X"0f000f000f000f00",X"00f000f000f000f0",4);
		end if;
		if rs2(1) = '1' then
			res := shuffle_stage(res,X"3030303030303030",X"0c0c0c0c0c0c0c0c",2);
		end if;
		if rs2(0) = '1' then
			res := shuffle_stage(res,X"4444444444444444",X"2222222222222222",1);
		end if;
		return res;
	end function shfl;

	function unshfl(
		rs1 : in std_logic_vector(63 downto 0);
		rs2 : in std_logic_vector(63 downto 0)
	)
	return std_logic_vector is
		variable res : std_logic_vector(63 downto 0);
	begin
		res := rs1;
		if rs2(0) = '1' then
			res := shuffle_stage(res,X"4444444444444444",X"2222222222222222",1);
		end if;
		if rs2(1) = '1' then
			res := shuffle_stage(res,X"3030303030303030",X"0c0c0c0c0c0c0c0c",2);
		end if;
		if rs2(2) = '1' then
			res := shuffle_stage(res,X"0f000f000f000f00",X"00f000f000f000f0",4);
		end if;
		if rs2(3) = '1' then
			res := shuffle_stage(res,X"00ff000000ff0000",X"0000ff000000ff00",8);
		end if;
		if rs2(4) = '1' then
			res := shuffle_stage(res,X"0000ffff00000000",X"00000000ffff0000",16);
		end if;
		return res;
	end function unshfl;

end bit_functions;
