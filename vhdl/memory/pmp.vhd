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
	generic(
		pmp_enable  : boolean := pmp_enable;
		pmp_regions : integer := pmp_regions
	);
	port(
		reset  : in  std_logic;
		clock  : in  std_logic;
		pmp_i  : in  pmp_in_type;
		pmp_o  : out pmp_out_type
	);
end pmp;

architecture behavior of pmp is

begin

	PMP_ON : if pmp_enable = true generate

		process(pmp_i)

		variable exc      : std_logic;
		variable etval    : std_logic_vector(63 downto 0);
		variable ecause   : std_logic_vector(3 downto 0);
		variable lowaddr  : std_logic_vector(63 downto 0);
		variable highaddr : std_logic_vector(63 downto 0);
		variable mask     : std_logic_vector(63 downto 0);


		begin

			exc := '0';
			etval := (others => '0');
			ecause := (others => '0');
			lowaddr := (others => '0');
			highaddr := (others => '0');
			mask := (others => '0');

			if pmp_i.mem_valid = '1' then
				if or_reduce(pmp_i.mem_addr(63 downto 56)) = '1' then
					exc := '1';
				else
					for i in 0 to pmp_regions-1 loop
						if pmp_i.pmpcfg(i).A = "01" then
							if i = 0 then
								lowaddr := (others => '0');
							else
								lowaddr := pmp_i.pmpaddr(i-1);
							end if;
							highaddr := pmp_i.pmpaddr(i);
							if unsigned(pmp_i.mem_addr(55 downto 2)) < unsigned(highaddr(53 downto 0)) and
									unsigned(pmp_i.mem_addr(55 downto 2)) >= unsigned(lowaddr(53 downto 0)) then
								if pmp_i.pmpcfg(i).L = "1" or pmp_i.priv_mode = "00" then
									if pmp_i.pmpcfg(i).X = "0" and pmp_i.mem_instr = '1' then
										exc := '1';
										etval := pmp_i.mem_addr;
										ecause := except_instr_access_fault;
									elsif pmp_i.pmpcfg(i).R = "0" and or_reduce(pmp_i.mem_wstrb) = '0' then
										exc := '1';
										etval := pmp_i.mem_addr;
										ecause := except_load_access_fault;
									elsif  pmp_i.pmpcfg(i).W = "0" and or_reduce(pmp_i.mem_wstrb) = '1' then
										exc := '1';
										etval := pmp_i.mem_addr;
										ecause := except_store_access_fault;
									end if;
								end if;
								exit;
							end if;
						elsif pmp_i.pmpcfg(i).A = "10" then
							if nor_reduce(pmp_i.mem_addr(55 downto 2) xor pmp_i.pmpaddr(i)(53 downto 0)) = '1' then
								if pmp_i.pmpcfg(i).L = "1" or pmp_i.priv_mode = "00" then
									if pmp_i.pmpcfg(i).X = "0" and pmp_i.mem_instr = '1' then
										exc := '1';
										etval := pmp_i.mem_addr;
										ecause := except_instr_access_fault;
									elsif pmp_i.pmpcfg(i).R = "0" and or_reduce(pmp_i.mem_wstrb) = '0' then
										exc := '1';
										etval := pmp_i.mem_addr;
										ecause := except_load_access_fault;
									elsif  pmp_i.pmpcfg(i).W = "0" and or_reduce(pmp_i.mem_wstrb) = '1' then
										exc := '1';
										etval := pmp_i.mem_addr;
										ecause := except_store_access_fault;
									end if;
								end if;
								exit;
							end if;
						elsif pmp_i.pmpcfg(i).A = "11" then
							case pmp_i.pmpaddr(i)(53 downto 0) is
								when "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX0" => mask := X"FFFFFFFFFFFFFFFE";
								when "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX01" => mask := X"FFFFFFFFFFFFFFFC";
								when "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX011" => mask := X"FFFFFFFFFFFFFFF8";
								when "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX0111" => mask := X"FFFFFFFFFFFFFFF0";
								when "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX01111" => mask := X"FFFFFFFFFFFFFFE0";
								when "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX011111" => mask := X"FFFFFFFFFFFFFFC0";
								when "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX0111111" => mask := X"FFFFFFFFFFFFFF80";
								when "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX01111111" => mask := X"FFFFFFFFFFFFFF00";
								when "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX011111111" => mask := X"FFFFFFFFFFFFFE00";
								when "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX0111111111" => mask := X"FFFFFFFFFFFFFC00";
								when "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX01111111111" => mask := X"FFFFFFFFFFFFF800";
								when "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX011111111111" => mask := X"FFFFFFFFFFFFF000";
								when "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX0111111111111" => mask := X"FFFFFFFFFFFFE000";
								when "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX01111111111111" => mask := X"FFFFFFFFFFFFC000";
								when "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX011111111111111" => mask := X"FFFFFFFFFFFF8000";
								when "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX0111111111111111" => mask := X"FFFFFFFFFFFF0000";
								when "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX01111111111111111" => mask := X"FFFFFFFFFFFE0000";
								when "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX011111111111111111" => mask := X"FFFFFFFFFFFC0000";
								when "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX0111111111111111111" => mask := X"FFFFFFFFFFF80000";
								when "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX01111111111111111111" => mask := X"FFFFFFFFFFF00000";
								when "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX011111111111111111111" => mask := X"FFFFFFFFFFE00000";
								when "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX0111111111111111111111" => mask := X"FFFFFFFFFFC00000";
								when "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX01111111111111111111111" => mask := X"FFFFFFFFFF800000";
								when "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX011111111111111111111111" => mask := X"FFFFFFFFFF000000";
								when "XXXXXXXXXXXXXXXXXXXXXXXXXXXXX0111111111111111111111111" => mask := X"FFFFFFFFFE000000";
								when "XXXXXXXXXXXXXXXXXXXXXXXXXXXX01111111111111111111111111" => mask := X"FFFFFFFFFC000000";
								when "XXXXXXXXXXXXXXXXXXXXXXXXXXX011111111111111111111111111" => mask := X"FFFFFFFFF8000000";
								when "XXXXXXXXXXXXXXXXXXXXXXXXXX0111111111111111111111111111" => mask := X"FFFFFFFFF0000000";
								when "XXXXXXXXXXXXXXXXXXXXXXXXX01111111111111111111111111111" => mask := X"FFFFFFFFE0000000";
								when "XXXXXXXXXXXXXXXXXXXXXXXX011111111111111111111111111111" => mask := X"FFFFFFFFC0000000";
								when "XXXXXXXXXXXXXXXXXXXXXXX0111111111111111111111111111111" => mask := X"FFFFFFFF80000000";
								when "XXXXXXXXXXXXXXXXXXXXXX01111111111111111111111111111111" => mask := X"FFFFFFFF00000000";
								when "XXXXXXXXXXXXXXXXXXXXX011111111111111111111111111111111" => mask := X"FFFFFFFE00000000";
								when "XXXXXXXXXXXXXXXXXXXX0111111111111111111111111111111111" => mask := X"FFFFFFFC00000000";
								when "XXXXXXXXXXXXXXXXXXX01111111111111111111111111111111111" => mask := X"FFFFFFF800000000";
								when "XXXXXXXXXXXXXXXXXX011111111111111111111111111111111111" => mask := X"FFFFFFF000000000";
								when "XXXXXXXXXXXXXXXXX0111111111111111111111111111111111111" => mask := X"FFFFFFE000000000";
								when "XXXXXXXXXXXXXXXX01111111111111111111111111111111111111" => mask := X"FFFFFFC000000000";
								when "XXXXXXXXXXXXXXX011111111111111111111111111111111111111" => mask := X"FFFFFF8000000000";
								when "XXXXXXXXXXXXXX0111111111111111111111111111111111111111" => mask := X"FFFFFF0000000000";
								when "XXXXXXXXXXXXX01111111111111111111111111111111111111111" => mask := X"FFFFFE0000000000";
								when "XXXXXXXXXXXX011111111111111111111111111111111111111111" => mask := X"FFFFFC0000000000";
								when "XXXXXXXXXXX0111111111111111111111111111111111111111111" => mask := X"FFFFF80000000000";
								when "XXXXXXXXXX01111111111111111111111111111111111111111111" => mask := X"FFFFF00000000000";
								when "XXXXXXXXX011111111111111111111111111111111111111111111" => mask := X"FFFFE00000000000";
								when "XXXXXXXX0111111111111111111111111111111111111111111111" => mask := X"FFFFC00000000000";
								when "XXXXXXX01111111111111111111111111111111111111111111111" => mask := X"FFFF800000000000";
								when "XXXXXX011111111111111111111111111111111111111111111111" => mask := X"FFFF000000000000";
								when "XXXXX0111111111111111111111111111111111111111111111111" => mask := X"FFFE000000000000";
								when "XXXX01111111111111111111111111111111111111111111111111" => mask := X"FFFC000000000000";
								when "XXX011111111111111111111111111111111111111111111111111" => mask := X"FFF8000000000000";
								when "XX0111111111111111111111111111111111111111111111111111" => mask := X"FFF0000000000000";
								when "X01111111111111111111111111111111111111111111111111111" => mask := X"FFE0000000000000";
								when "011111111111111111111111111111111111111111111111111111" => mask := X"FFC0000000000000";
								when others => mask := X"FFFFFFFFFFFFFFFF";
							end case;
							lowaddr := pmp_i.pmpaddr(i) and mask;
							if nor_reduce((pmp_i.mem_addr(55 downto 2) and mask(53 downto 0)) xor lowaddr(53 downto 0)) = '1' then
								if pmp_i.pmpcfg(i).L = "1" or pmp_i.priv_mode = "00" then
									if pmp_i.pmpcfg(i).X = "0" and pmp_i.mem_instr = '1' then
										exc := '1';
										etval := pmp_i.mem_addr;
										ecause := except_instr_access_fault;
									elsif pmp_i.pmpcfg(i).R = "0" and or_reduce(pmp_i.mem_wstrb) = '0' then
										exc := '1';
										etval := pmp_i.mem_addr;
										ecause := except_load_access_fault;
									elsif  pmp_i.pmpcfg(i).W = "0" and or_reduce(pmp_i.mem_wstrb) = '1' then
										exc := '1';
										etval := pmp_i.mem_addr;
										ecause := except_store_access_fault;
									end if;
								end if;
								exit;
							end if;
						end if;
					end loop;
				end if;
			end if;

			pmp_o.exc <= exc;
			pmp_o.etval <= etval;
			pmp_o.ecause <= ecause;

		end process;

	end generate PMP_ON;

	PMP_OFF : if pmp_enable = false generate

		pmp_o.exc <= '0';
		pmp_o.etval <= (others => '0');
		pmp_o.ecause <= (others => '0');

	end generate PMP_OFF;

end architecture;
