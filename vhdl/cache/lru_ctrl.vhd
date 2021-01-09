-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.configure.all;
use work.constants.all;
use work.wire.all;

entity lru_ctrl is
	generic(
		cache_type      : integer;
		cache_set_depth : integer
	);
	port(
		reset      : in  std_logic;
		clock      : in  std_logic;
		lru_ctrl_i : in  lru_ctrl_in_type;
		lru_ctrl_o : out lru_ctrl_out_type
	);
end lru_ctrl;

architecture behavior of lru_ctrl is

	constant LEFT  : std_logic := '0';
	constant RIGHT : std_logic := '1';

	signal lru_wid : integer range 0 to 7 := 0;
	signal lru_rdata : std_logic_vector(7 downto 0) := (others => '0');

	function lru_update(
		rdata : in std_logic_vector(7 downto 0);
		k1 : integer range 0 to 7;
		v1 : std_logic;
		k2 : integer range 0 to 7;
		v2 : std_logic;
		k3 : integer range 0 to 7;
		v3 : std_logic
	) return std_logic_vector is
		variable wdata : std_logic_vector(7 downto 0);
	begin
		wdata := rdata;
		wdata(k1) := v1;
		wdata(k2) := v2;
		wdata(k3) := v3;
		return wdata;
	end;

	function lru_access(
		rdata : in std_logic_vector(7 downto 0);
		acc  : in integer range 0 to 7
	) return std_logic_vector is
		variable wdata : std_logic_vector(7 downto 0);
	begin
		wdata := (others => '0');
		if acc = 0 then
			wdata := lru_update(rdata,1,LEFT,2,LEFT,4,LEFT);
		elsif acc = 1 then
			wdata := lru_update(rdata,1,LEFT,2,LEFT,4,RIGHT);
		elsif acc = 2 then
			wdata := lru_update(rdata,1,LEFT,2,RIGHT,5,LEFT);
		elsif acc = 3 then
			wdata := lru_update(rdata,1,LEFT,2,RIGHT,5,RIGHT);
		elsif acc = 4 then
			wdata := lru_update(rdata,1,RIGHT,3,LEFT,6,LEFT);
		elsif acc = 5 then
			wdata := lru_update(rdata,1,RIGHT,3,LEFT,6,RIGHT);
		elsif acc = 6 then
			wdata := lru_update(rdata,1,RIGHT,3,RIGHT,7,LEFT);
		elsif acc = 7 then
			wdata := lru_update(rdata,1,RIGHT,3,RIGHT,7,RIGHT);
		end if;
		return wdata;
	end;

	function lru_get (
		data : in std_logic_vector(7 downto 0)
	) return integer is
		variable seek1 : integer range 0 to 7;
		variable seek2 : integer range 0 to 7;
		variable blk : unsigned(2 downto 0);
	begin
		seek1 := 2 + to_integer(unsigned'('0' & not(data(1))));
		blk := shift_left(to_unsigned(seek1-2,3),2);
		seek2 :=  to_integer(shift_left(to_unsigned(seek1,3),1)) + to_integer(unsigned'('0' & not(data(seek1))));
		blk := blk + shift_left(unsigned'('0' & not(data(seek1))),1);
		blk := blk + unsigned'('0' & not(data(seek2)));
		return to_integer(blk);
	end;

	component lru
		generic(
			cache_type      : integer;
			cache_set_depth : integer
		);
		port(
			reset : in  std_logic;
			clock : in  std_logic;
			lru_i : in  lru_in_type;
			lru_o : out lru_out_type
		);
	end component;

	signal lru_i : lru_in_type;
	signal lru_o : lru_out_type;

begin

	lru_i.raddr <= lru_ctrl_i.raddr;

	lru_rdata <= lru_o.rdata;

	lru_wid <= lru_get(lru_rdata) when (lru_ctrl_i.hit or lru_ctrl_i.miss) = '1' else 0;

	process(clock)

	variable wen : std_logic;
	variable waddr : integer range 0 to 2**cache_set_depth-1;
	variable wdata : std_logic_vector(7 downto 0);

	begin

		if rising_edge(clock) then

			if lru_ctrl_i.hit = '1' then
				wen := '1';
				waddr := lru_ctrl_i.waddr;
				wdata := lru_access(lru_rdata,lru_ctrl_i.wid);
			elsif lru_ctrl_i.miss = '1' then
				wen := '1';
				waddr := lru_ctrl_i.waddr;
				wdata := lru_access(lru_rdata,lru_wid);
			else
				wen := '0';
				waddr := 0;
				wdata := (others => '0');
			end if;

			lru_i.wen <= wen;
			lru_i.waddr <= waddr;
			lru_i.wdata <= wdata;

			lru_ctrl_o.wid <= lru_wid;

		end if;

	end process;

	lru_comp : lru
		generic map(
			cache_type => cache_type,
			cache_set_depth => cache_set_depth
		)
		port map(
			reset => reset,
			clock => clock,
			lru_i => lru_i,
			lru_o => lru_o
		);

end architecture;
