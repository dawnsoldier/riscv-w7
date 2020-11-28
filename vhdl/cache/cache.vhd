-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.configure.all;
use work.constants.all;
use work.wire.all;

entity cache is
	generic(
		set_depth  : integer := set_depth
	);
	port(
		reset   : in  std_logic;
		clock   : in  std_logic;
		cache_i : in  cache_in_type;
		cache_o : out cache_out_type;
		mem_o   : in  mem_out_type;
		mem_i   : out mem_in_type
	);
end cache;

architecture behavior of cache is

	component data
		port(
			reset  : in  std_logic;
			clock  : in  std_logic;
			data_i : in  data_in_type;
			data_o : out data_out_type
		);
	end component;

	component tag
		port(
			reset : in  std_logic;
			clock : in  std_logic;
			tag_i : in  tag_in_type;
			tag_o : out tag_out_type
		);
	end component;

	component valid
		port(
			reset   : in  std_logic;
			clock   : in  std_logic;
			valid_i : in  valid_in_type;
			valid_o : out valid_out_type
		);
	end component;

	component lru
		port(
			reset : in  std_logic;
			clock : in  std_logic;
			lru_i : in  lru_in_type;
			lru_o : out lru_out_type
		);
	end component;

	component hit
		port(
			reset : in  std_logic;
			clock : in  std_logic;
			hit_i : in  hit_in_type;
			hit_o : out hit_out_type
		);
	end component;

	component ctrl
		port(
			reset  : in  std_logic;
			clock  : in  std_logic;
			ctrl_i : in  ctrl_in_type;
			ctrl_o  : out ctrl_out_type;
			cache_i : in  cache_in_type;
			cache_o : out cache_out_type;
			mem_o   : in  mem_out_type;
			mem_i   : out mem_in_type
		);
	end component;

	signal ctrl_i : ctrl_in_type;
	signal ctrl_o : ctrl_out_type;

begin

	data0_comp : data port map(reset => reset, clock => clock, data_i => ctrl_o.data0_i, data_o => ctrl_i.data0_o);
	data1_comp : data port map(reset => reset, clock => clock, data_i => ctrl_o.data1_i, data_o => ctrl_i.data1_o);
	data2_comp : data port map(reset => reset, clock => clock, data_i => ctrl_o.data2_i, data_o => ctrl_i.data2_o);
	data3_comp : data port map(reset => reset, clock => clock, data_i => ctrl_o.data3_i, data_o => ctrl_i.data3_o);
	data4_comp : data port map(reset => reset, clock => clock, data_i => ctrl_o.data4_i, data_o => ctrl_i.data4_o);
	data5_comp : data port map(reset => reset, clock => clock, data_i => ctrl_o.data5_i, data_o => ctrl_i.data5_o);
	data6_comp : data port map(reset => reset, clock => clock, data_i => ctrl_o.data6_i, data_o => ctrl_i.data6_o);
	data7_comp : data port map(reset => reset, clock => clock, data_i => ctrl_o.data7_i, data_o => ctrl_i.data7_o);

	tag0_comp : tag port map(reset => reset, clock => clock, tag_i => ctrl_o.tag0_i, tag_o => ctrl_i.tag0_o);
	tag1_comp : tag port map(reset => reset, clock => clock, tag_i => ctrl_o.tag1_i, tag_o => ctrl_i.tag1_o);
	tag2_comp : tag port map(reset => reset, clock => clock, tag_i => ctrl_o.tag2_i, tag_o => ctrl_i.tag2_o);
	tag3_comp : tag port map(reset => reset, clock => clock, tag_i => ctrl_o.tag3_i, tag_o => ctrl_i.tag3_o);
	tag4_comp : tag port map(reset => reset, clock => clock, tag_i => ctrl_o.tag4_i, tag_o => ctrl_i.tag4_o);
	tag5_comp : tag port map(reset => reset, clock => clock, tag_i => ctrl_o.tag5_i, tag_o => ctrl_i.tag5_o);
	tag6_comp : tag port map(reset => reset, clock => clock, tag_i => ctrl_o.tag6_i, tag_o => ctrl_i.tag6_o);
	tag7_comp : tag port map(reset => reset, clock => clock, tag_i => ctrl_o.tag7_i, tag_o => ctrl_i.tag7_o);

	valid_comp : valid port map(reset => reset, clock => clock, valid_i => ctrl_o.valid_i, valid_o => ctrl_i.valid_o);

	hit_comp : hit port map(reset => reset, clock => clock, hit_i => ctrl_o.hit_i, hit_o => ctrl_i.hit_o);

	lru_comp : lru port map(reset => reset, clock => clock, lru_i => ctrl_o.lru_i, lru_o => ctrl_i.lru_o);

	ctrl_comp : ctrl
		port map
		(
			reset => reset,
			clock => clock,
			ctrl_i => ctrl_i,
			ctrl_o => ctrl_o,
			cache_i => cache_i,
			cache_o => cache_o,
			mem_o => mem_o,
			mem_i => mem_i
		);

end architecture;
