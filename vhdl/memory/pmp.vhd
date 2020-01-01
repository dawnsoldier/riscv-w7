-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.configure.all;
use work.constants.all;
use work.wire.all;
use work.functions.all;

use work.csr_wire.all;

entity pmp is
	port(
		reset  : in  std_logic;
		clock  : in  std_logic;
		ipmp_i : in  pmp_in_type;
		ipmp_o : out pmp_out_type;
		dpmp_i : in  pmp_in_type;
		dpmp_o : out pmp_out_type
	);
end pmp;

architecture behavior of pmp is

begin

	process(ipmp_i,dpmp_i)

	variable iexc      : std_logic;
	variable ietval    : std_logic_vector(63 downto 0);
	variable iecause   : std_logic_vector(3 downto 0);
	variable ilowaddr  : std_logic_vector(63 downto 0);
	variable ihighaddr : std_logic_vector(63 downto 0);
	variable imask     : std_logic_vector(63 downto 0);

	variable dexc      : std_logic;
	variable detval    : std_logic_vector(63 downto 0);
	variable decause   : std_logic_vector(3 downto 0);
	variable dlowaddr  : std_logic_vector(63 downto 0);
	variable dhighaddr : std_logic_vector(63 downto 0);
	variable dmask     : std_logic_vector(63 downto 0);


	begin

		iexc := '0';
		ietval := (others => '0');
		iecause := (others => '0');
		ilowaddr := (others => '0');
		ihighaddr := (others => '0');
		imask := (others => '0');

		if ipmp_i.mem_valid = '1' then
			if or_reduce(ipmp_i.mem_addr(63 downto 56)) = '1' then
				iexc := '1';
			else
				for i in 0 to 15 loop
					if ipmp_i.pmpcfg(i).A = "01" then
						if i = 0 then
							ilowaddr := (others => '0');
						else
							ilowaddr := ipmp_i.pmpaddr(i-1);
						end if;
						ihighaddr := ipmp_i.pmpaddr(i);
						if unsigned(ipmp_i.mem_addr(55 downto 2)) < unsigned(ihighaddr(53 downto 0)) and
								unsigned(ipmp_i.mem_addr(55 downto 2)) >= unsigned(ilowaddr(53 downto 0)) then
							if ipmp_i.pmpcfg(i).L = "1" or ipmp_i.mode = "00" then
								if ipmp_i.pmpcfg(i).X = "0" then
									iexc := '1';
								end if;
							end if;
							exit;
						end if;
					elsif ipmp_i.pmpcfg(i).A = "10" then
						if nor_reduce(ipmp_i.mem_addr(55 downto 2) xor ipmp_i.pmpaddr(i)(53 downto 0)) = '1' then
							if ipmp_i.pmpcfg(i).L = "1" or ipmp_i.mode = "00" then
								if ipmp_i.pmpcfg(i).X = "0" then
									iexc := '1';
								end if;
							end if;
							exit;
						end if;
					elsif ipmp_i.pmpcfg(i).A = "11" then
						case ipmp_i.pmpaddr(i)(53 downto 0) is
							when "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX0" => imask := X"FFFFFFFFFFFFFFFE";
							when "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX01" => imask := X"FFFFFFFFFFFFFFFC";
							when "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX011" => imask := X"FFFFFFFFFFFFFFF8";
							when "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX0111" => imask := X"FFFFFFFFFFFFFFF0";
							when "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX01111" => imask := X"FFFFFFFFFFFFFFE0";
							when "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX011111" => imask := X"FFFFFFFFFFFFFFC0";
							when "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX0111111" => imask := X"FFFFFFFFFFFFFF80";
							when "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX01111111" => imask := X"FFFFFFFFFFFFFF00";
							when "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX011111111" => imask := X"FFFFFFFFFFFFFE00";
							when "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX0111111111" => imask := X"FFFFFFFFFFFFFC00";
							when "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX01111111111" => imask := X"FFFFFFFFFFFFF800";
							when "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX011111111111" => imask := X"FFFFFFFFFFFFF000";
							when "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX0111111111111" => imask := X"FFFFFFFFFFFFE000";
							when "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX01111111111111" => imask := X"FFFFFFFFFFFFC000";
							when "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX011111111111111" => imask := X"FFFFFFFFFFFF8000";
							when "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX0111111111111111" => imask := X"FFFFFFFFFFFF0000";
							when "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX01111111111111111" => imask := X"FFFFFFFFFFFE0000";
							when "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX011111111111111111" => imask := X"FFFFFFFFFFFC0000";
							when "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX0111111111111111111" => imask := X"FFFFFFFFFFF80000";
							when "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX01111111111111111111" => imask := X"FFFFFFFFFFF00000";
							when "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX011111111111111111111" => imask := X"FFFFFFFFFFE00000";
							when "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX0111111111111111111111" => imask := X"FFFFFFFFFFC00000";
							when "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX01111111111111111111111" => imask := X"FFFFFFFFFF800000";
							when "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX011111111111111111111111" => imask := X"FFFFFFFFFF000000";
							when "XXXXXXXXXXXXXXXXXXXXXXXXXXXXX0111111111111111111111111" => imask := X"FFFFFFFFFE000000";
							when "XXXXXXXXXXXXXXXXXXXXXXXXXXXX01111111111111111111111111" => imask := X"FFFFFFFFFC000000";
							when "XXXXXXXXXXXXXXXXXXXXXXXXXXX011111111111111111111111111" => imask := X"FFFFFFFFF8000000";
							when "XXXXXXXXXXXXXXXXXXXXXXXXXX0111111111111111111111111111" => imask := X"FFFFFFFFF0000000";
							when "XXXXXXXXXXXXXXXXXXXXXXXXX01111111111111111111111111111" => imask := X"FFFFFFFFE0000000";
							when "XXXXXXXXXXXXXXXXXXXXXXXX011111111111111111111111111111" => imask := X"FFFFFFFFC0000000";
							when "XXXXXXXXXXXXXXXXXXXXXXX0111111111111111111111111111111" => imask := X"FFFFFFFF80000000";
							when "XXXXXXXXXXXXXXXXXXXXXX01111111111111111111111111111111" => imask := X"FFFFFFFF00000000";
							when "XXXXXXXXXXXXXXXXXXXXX011111111111111111111111111111111" => imask := X"FFFFFFFE00000000";
							when "XXXXXXXXXXXXXXXXXXXX0111111111111111111111111111111111" => imask := X"FFFFFFFC00000000";
							when "XXXXXXXXXXXXXXXXXXX01111111111111111111111111111111111" => imask := X"FFFFFFF800000000";
							when "XXXXXXXXXXXXXXXXXX011111111111111111111111111111111111" => imask := X"FFFFFFF000000000";
							when "XXXXXXXXXXXXXXXXX0111111111111111111111111111111111111" => imask := X"FFFFFFE000000000";
							when "XXXXXXXXXXXXXXXX01111111111111111111111111111111111111" => imask := X"FFFFFFC000000000";
							when "XXXXXXXXXXXXXXX011111111111111111111111111111111111111" => imask := X"FFFFFF8000000000";
							when "XXXXXXXXXXXXXX0111111111111111111111111111111111111111" => imask := X"FFFFFF0000000000";
							when "XXXXXXXXXXXXX01111111111111111111111111111111111111111" => imask := X"FFFFFE0000000000";
							when "XXXXXXXXXXXX011111111111111111111111111111111111111111" => imask := X"FFFFFC0000000000";
							when "XXXXXXXXXXX0111111111111111111111111111111111111111111" => imask := X"FFFFF80000000000";
							when "XXXXXXXXXX01111111111111111111111111111111111111111111" => imask := X"FFFFF00000000000";
							when "XXXXXXXXX011111111111111111111111111111111111111111111" => imask := X"FFFFE00000000000";
							when "XXXXXXXX0111111111111111111111111111111111111111111111" => imask := X"FFFFC00000000000";
							when "XXXXXXX01111111111111111111111111111111111111111111111" => imask := X"FFFF800000000000";
							when "XXXXXX011111111111111111111111111111111111111111111111" => imask := X"FFFF000000000000";
							when "XXXXX0111111111111111111111111111111111111111111111111" => imask := X"FFFE000000000000";
							when "XXXX01111111111111111111111111111111111111111111111111" => imask := X"FFFC000000000000";
							when "XXX011111111111111111111111111111111111111111111111111" => imask := X"FFF8000000000000";
							when "XX0111111111111111111111111111111111111111111111111111" => imask := X"FFF0000000000000";
							when "X01111111111111111111111111111111111111111111111111111" => imask := X"FFE0000000000000";
							when "011111111111111111111111111111111111111111111111111111" => imask := X"FFC0000000000000";
							when others => imask := X"FFFFFFFFFFFFFFFF";
						end case;
						ilowaddr := ipmp_i.pmpaddr(i) and imask;
						if nor_reduce((ipmp_i.mem_addr(55 downto 2) and imask(53 downto 0)) xor ilowaddr(53 downto 0)) = '1' then
							if ipmp_i.pmpcfg(i).L = "1" or ipmp_i.mode = "00" then
								if ipmp_i.pmpcfg(i).X = "0" then
									iexc := '1';
								end if;
							end if;
							exit;
						end if;
					end if;
				end loop;
			end if;
		end if;

		if iexc = '1' then
			ietval := ipmp_i.mem_addr;
			iecause := except_instr_access_fault;
		end if;

		ipmp_o.exc <= iexc;
		ipmp_o.etval <= ietval;
		ipmp_o.ecause <= iecause;

		dexc := '0';
		detval := (others => '0');
		decause := (others => '0');
		dlowaddr := (others => '0');
		dhighaddr := (others => '0');
		dmask := (others => '0');

		if dpmp_i.mem_valid = '1' then
			if or_reduce(dpmp_i.mem_addr(63 downto 56)) = '1' then
				dexc := '1';
			else
				for i in 0 to 15 loop
					if dpmp_i.pmpcfg(i).A = "01" then
						if i = 0 then
							dlowaddr := (others => '0');
						else
							dlowaddr := dpmp_i.pmpaddr(i-1);
						end if;
						dhighaddr := dpmp_i.pmpaddr(i);
						if unsigned(dpmp_i.mem_addr(55 downto 2)) < unsigned(dhighaddr(53 downto 0)) and
								unsigned(dpmp_i.mem_addr(55 downto 2)) >= unsigned(dlowaddr(53 downto 0)) then
							if dpmp_i.pmpcfg(i).L = "1" or dpmp_i.mode = "00" then
								if dpmp_i.pmpcfg(i).W = "0" and dpmp_i.mem_store = '1' then
									dexc := '1';
								elsif  dpmp_i.pmpcfg(i).R = "0" and dpmp_i.mem_load = '1' then
									dexc := '1';
								end if;
							end if;
							exit;
						end if;
					elsif dpmp_i.pmpcfg(i).A = "10" then
						if nor_reduce(dpmp_i.mem_addr(55 downto 2) xor dpmp_i.pmpaddr(i)(53 downto 0)) = '1' then
							if dpmp_i.pmpcfg(i).L = "1" or dpmp_i.mode = "00" then
								if dpmp_i.pmpcfg(i).W = "0" and dpmp_i.mem_store = '1' then
									dexc := '1';
								elsif  dpmp_i.pmpcfg(i).R = "0" and dpmp_i.mem_load = '1' then
									dexc := '1';
								end if;
							end if;
							exit;
						end if;
					elsif dpmp_i.pmpcfg(i).A = "11" then
						case ipmp_i.pmpaddr(i)(53 downto 0) is
							when "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX0" => dmask := X"FFFFFFFFFFFFFFFE";
							when "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX01" => dmask := X"FFFFFFFFFFFFFFFC";
							when "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX011" => dmask := X"FFFFFFFFFFFFFFF8";
							when "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX0111" => dmask := X"FFFFFFFFFFFFFFF0";
							when "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX01111" => dmask := X"FFFFFFFFFFFFFFE0";
							when "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX011111" => dmask := X"FFFFFFFFFFFFFFC0";
							when "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX0111111" => dmask := X"FFFFFFFFFFFFFF80";
							when "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX01111111" => dmask := X"FFFFFFFFFFFFFF00";
							when "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX011111111" => dmask := X"FFFFFFFFFFFFFE00";
							when "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX0111111111" => dmask := X"FFFFFFFFFFFFFC00";
							when "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX01111111111" => dmask := X"FFFFFFFFFFFFF800";
							when "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX011111111111" => dmask := X"FFFFFFFFFFFFF000";
							when "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX0111111111111" => dmask := X"FFFFFFFFFFFFE000";
							when "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX01111111111111" => dmask := X"FFFFFFFFFFFFC000";
							when "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX011111111111111" => dmask := X"FFFFFFFFFFFF8000";
							when "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX0111111111111111" => dmask := X"FFFFFFFFFFFF0000";
							when "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX01111111111111111" => dmask := X"FFFFFFFFFFFE0000";
							when "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX011111111111111111" => dmask := X"FFFFFFFFFFFC0000";
							when "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX0111111111111111111" => dmask := X"FFFFFFFFFFF80000";
							when "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX01111111111111111111" => dmask := X"FFFFFFFFFFF00000";
							when "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX011111111111111111111" => dmask := X"FFFFFFFFFFE00000";
							when "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX0111111111111111111111" => dmask := X"FFFFFFFFFFC00000";
							when "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX01111111111111111111111" => dmask := X"FFFFFFFFFF800000";
							when "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX011111111111111111111111" => dmask := X"FFFFFFFFFF000000";
							when "XXXXXXXXXXXXXXXXXXXXXXXXXXXXX0111111111111111111111111" => dmask := X"FFFFFFFFFE000000";
							when "XXXXXXXXXXXXXXXXXXXXXXXXXXXX01111111111111111111111111" => dmask := X"FFFFFFFFFC000000";
							when "XXXXXXXXXXXXXXXXXXXXXXXXXXX011111111111111111111111111" => dmask := X"FFFFFFFFF8000000";
							when "XXXXXXXXXXXXXXXXXXXXXXXXXX0111111111111111111111111111" => dmask := X"FFFFFFFFF0000000";
							when "XXXXXXXXXXXXXXXXXXXXXXXXX01111111111111111111111111111" => dmask := X"FFFFFFFFE0000000";
							when "XXXXXXXXXXXXXXXXXXXXXXXX011111111111111111111111111111" => dmask := X"FFFFFFFFC0000000";
							when "XXXXXXXXXXXXXXXXXXXXXXX0111111111111111111111111111111" => dmask := X"FFFFFFFF80000000";
							when "XXXXXXXXXXXXXXXXXXXXXX01111111111111111111111111111111" => dmask := X"FFFFFFFF00000000";
							when "XXXXXXXXXXXXXXXXXXXXX011111111111111111111111111111111" => dmask := X"FFFFFFFE00000000";
							when "XXXXXXXXXXXXXXXXXXXX0111111111111111111111111111111111" => dmask := X"FFFFFFFC00000000";
							when "XXXXXXXXXXXXXXXXXXX01111111111111111111111111111111111" => dmask := X"FFFFFFF800000000";
							when "XXXXXXXXXXXXXXXXXX011111111111111111111111111111111111" => dmask := X"FFFFFFF000000000";
							when "XXXXXXXXXXXXXXXXX0111111111111111111111111111111111111" => dmask := X"FFFFFFE000000000";
							when "XXXXXXXXXXXXXXXX01111111111111111111111111111111111111" => dmask := X"FFFFFFC000000000";
							when "XXXXXXXXXXXXXXX011111111111111111111111111111111111111" => dmask := X"FFFFFF8000000000";
							when "XXXXXXXXXXXXXX0111111111111111111111111111111111111111" => dmask := X"FFFFFF0000000000";
							when "XXXXXXXXXXXXX01111111111111111111111111111111111111111" => dmask := X"FFFFFE0000000000";
							when "XXXXXXXXXXXX011111111111111111111111111111111111111111" => dmask := X"FFFFFC0000000000";
							when "XXXXXXXXXXX0111111111111111111111111111111111111111111" => dmask := X"FFFFF80000000000";
							when "XXXXXXXXXX01111111111111111111111111111111111111111111" => dmask := X"FFFFF00000000000";
							when "XXXXXXXXX011111111111111111111111111111111111111111111" => dmask := X"FFFFE00000000000";
							when "XXXXXXXX0111111111111111111111111111111111111111111111" => dmask := X"FFFFC00000000000";
							when "XXXXXXX01111111111111111111111111111111111111111111111" => dmask := X"FFFF800000000000";
							when "XXXXXX011111111111111111111111111111111111111111111111" => dmask := X"FFFF000000000000";
							when "XXXXX0111111111111111111111111111111111111111111111111" => dmask := X"FFFE000000000000";
							when "XXXX01111111111111111111111111111111111111111111111111" => dmask := X"FFFC000000000000";
							when "XXX011111111111111111111111111111111111111111111111111" => dmask := X"FFF8000000000000";
							when "XX0111111111111111111111111111111111111111111111111111" => dmask := X"FFF0000000000000";
							when "X01111111111111111111111111111111111111111111111111111" => dmask := X"FFE0000000000000";
							when "011111111111111111111111111111111111111111111111111111" => dmask := X"FFC0000000000000";
							when others => dmask := X"FFFFFFFFFFFFFFFF";
						end case;
						dlowaddr := dpmp_i.pmpaddr(i) and dmask;
						if nor_reduce((dpmp_i.mem_addr(55 downto 2) and dmask(53 downto 0)) xor dlowaddr(53 downto 0)) = '1' then
							if dpmp_i.pmpcfg(i).L = "1" or dpmp_i.mode = "00" then
								if dpmp_i.pmpcfg(i).W = "0" and dpmp_i.mem_store = '1' then
									dexc := '1';
								elsif  dpmp_i.pmpcfg(i).R = "0" and dpmp_i.mem_load = '1' then
									dexc := '1';
								end if;
							end if;
							exit;
						end if;
					end if;
				end loop;
			end if;
		end if;

		if dexc = '1' then
			detval := dpmp_i.mem_addr;
			if dpmp_i.mem_load = '1' then
				decause := except_load_access_fault;
			elsif dpmp_i.mem_store = '1' then
				decause := except_store_access_fault;
			end if;
		end if;

		dpmp_o.exc <= dexc;
		dpmp_o.etval <= detval;
		dpmp_o.ecause <= decause;

	end process;

end architecture;
