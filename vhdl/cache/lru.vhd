-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.configure.all;
use work.constants.all;
use work.wire.all;

entity lru is
	generic(
		icache_set_depth : integer := icache_set_depth
	);
	port(
		reset : in  std_logic;
		clock : in  std_logic;
		lru_i : in  lru_in_type;
		lru_o : out lru_out_type
	);
end lru;

architecture behavior of lru is

	constant LEFT  : std_logic := '0';
	constant RIGHT : std_logic := '1';

	type lru_type is array (0 to 2**icache_set_depth-1) of std_logic_vector(7 downto 0);

	signal lru_data : lru_type := (others => (others => '0'));

	signal lru_wid : integer range 0 to 7 := 0;

	procedure lru_update(
		signal data  : inout lru_type;
		signal index : in integer range 0 to 2**icache_set_depth-1;
		k1 : integer range 0 to 7;
		v1 : std_logic;
		k2 : integer range 0 to 7;
		v2 : std_logic;
		k3 : integer range 0 to 7;
		v3 : std_logic
	) is
	begin
		data(index)(k1) <= v1;
		data(index)(k2) <= v2;
		data(index)(k3) <= v3;
	end;

	procedure lru_access(
		signal data  : inout lru_type;
		signal index : in integer range 0 to 2**icache_set_depth-1;
		acc  : in integer range 0 to 7
	) is
	begin
		if acc = 0 then
			lru_update(data,index,1,LEFT,2,LEFT,4,LEFT);
		elsif acc = 1 then
			lru_update(data,index,1,LEFT,2,LEFT,4,RIGHT);
		elsif acc = 2 then
			lru_update(data,index,1,LEFT,2,RIGHT,5,LEFT);
		elsif acc = 3 then
			lru_update(data,index,1,LEFT,2,RIGHT,5,RIGHT);
		elsif acc = 4 then
			lru_update(data,index,1,RIGHT,3,LEFT,6,LEFT);
		elsif acc = 5 then
			lru_update(data,index,1,RIGHT,3,LEFT,6,RIGHT);
		elsif acc = 6 then
			lru_update(data,index,1,RIGHT,3,RIGHT,7,LEFT);
		elsif acc = 7 then
			lru_update(data,index,1,RIGHT,3,RIGHT,7,RIGHT);
		end if;
	end;

	function lru_get (
		signal data  : in lru_type;
		signal index : in integer range 0 to 2**icache_set_depth-1
	) return integer is
		variable seek1 : integer range 0 to 7;
		variable seek2 : integer range 0 to 7;
		variable blk : unsigned(2 downto 0);
		variable dat : std_logic_vector(7 downto 0);
	begin
		dat := data(index);
		seek1 := 2 + to_integer(unsigned'('0' & not(dat(1))));
		blk := shift_left(to_unsigned(seek1-2,3),2);
		seek2 :=  to_integer(shift_left(to_unsigned(seek1,3),1)) + to_integer(unsigned'('0' & not(dat(seek1))));
		blk := blk + shift_left(unsigned'('0' & not(dat(seek1))),1);
		blk := blk + unsigned'('0' & not(dat(seek2)));
		return to_integer(blk);
	end;

begin

	lru_wid <= lru_get(lru_data,lru_i.sid);

	process(clock)

	variable wid : integer range 0 to 7;

	begin

		if rising_edge(clock) then

			if lru_i.hit = '1' then
				lru_access(lru_data,lru_i.sid,lru_i.wid);
			elsif lru_i.miss = '1' then
				lru_access(lru_data,lru_i.sid,lru_wid);
			end if;
			lru_o.wid <= lru_wid;

		end if;

	end process;

end architecture;
