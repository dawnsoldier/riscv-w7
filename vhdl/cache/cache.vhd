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
		mem_i   : out mem_in_type;
		mem_o   : in  mem_out_type
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
  		ctrl_o : out ctrl_out_type;
			mem_i  : out mem_in_type;
			mem_o  : in  mem_out_type
  	);
  end component;

	signal data0_i : data_in_type;
	signal data0_o : data_out_type;
	signal data1_i : data_in_type;
	signal data1_o : data_out_type;
	signal data2_i : data_in_type;
	signal data2_o : data_out_type;
	signal data3_i : data_in_type;
	signal data3_o : data_out_type;
	signal data4_i : data_in_type;
	signal data4_o : data_out_type;
	signal data5_i : data_in_type;
	signal data5_o : data_out_type;
	signal data6_i : data_in_type;
	signal data6_o : data_out_type;
	signal data7_i : data_in_type;
	signal data7_o : data_out_type;

	signal tag0_i : tag_in_type;
	signal tag0_o : tag_out_type;
	signal tag1_i : tag_in_type;
	signal tag1_o : tag_out_type;
	signal tag2_i : tag_in_type;
	signal tag2_o : tag_out_type;
	signal tag3_i : tag_in_type;
	signal tag3_o : tag_out_type;
	signal tag4_i : tag_in_type;
	signal tag4_o : tag_out_type;
	signal tag5_i : tag_in_type;
	signal tag5_o : tag_out_type;
	signal tag6_i : tag_in_type;
	signal tag6_o : tag_out_type;
	signal tag7_i : tag_in_type;
	signal tag7_o : tag_out_type;

	signal valid_i : valid_in_type;
	signal valid_o : valid_out_type;

	signal lru_i : lru_in_type;
	signal lru_o : lru_out_type;

	signal hit_i : hit_in_type;
	signal hit_o : hit_out_type;

	signal ctrl_i : ctrl_in_type;
	signal ctrl_o : ctrl_out_type;

begin

	ctrl_i.cache_i <= cache_i;
	ctrl_i.data0_o <= data0_o;
	ctrl_i.data1_o <= data1_o;
	ctrl_i.data2_o <= data2_o;
	ctrl_i.data3_o <= data3_o;
	ctrl_i.data4_o <= data4_o;
	ctrl_i.data5_o <= data5_o;
	ctrl_i.data6_o <= data6_o;
	ctrl_i.data7_o <= data7_o;
	ctrl_i.tag0_o <= tag0_o;
	ctrl_i.tag1_o <= tag1_o;
	ctrl_i.tag2_o <= tag2_o;
	ctrl_i.tag3_o <= tag3_o;
	ctrl_i.tag4_o <= tag4_o;
	ctrl_i.tag5_o <= tag5_o;
	ctrl_i.tag6_o <= tag6_o;
	ctrl_i.tag7_o <= tag7_o;
	ctrl_i.valid_o <= valid_o;
	ctrl_i.hit_o <= hit_o;
	ctrl_i.lru_o <= lru_o;

	ctrl_o.cache_o <= cache_o;
	ctrl_o.data0_i <= data0_i;
	ctrl_o.data1_i <= data1_i;
	ctrl_o.data2_i <= data2_i;
	ctrl_o.data3_i <= data3_i;
	ctrl_o.data4_i <= data4_i;
	ctrl_o.data5_i <= data5_i;
	ctrl_o.data6_i <= data6_i;
	ctrl_o.data7_i <= data7_i;
	ctrl_o.tag0_i <= tag0_i;
	ctrl_o.tag1_i <= tag1_i;
	ctrl_o.tag2_i <= tag2_i;
	ctrl_o.tag3_i <= tag3_i;
	ctrl_o.tag4_i <= tag4_i;
	ctrl_o.tag5_i <= tag5_i;
	ctrl_o.tag6_i <= tag6_i;
	ctrl_o.tag7_i <= tag7_i;
	ctrl_o.valid_i <= valid_i;
	ctrl_o.hit_i <= hit_i;
	ctrl_o.lru_i <= lru_i;

	data0_comp : data port map(reset => reset, clock => clock, data_i => data0_i, data_o => data0_o);
	data1_comp : data port map(reset => reset, clock => clock, data_i => data1_i, data_o => data1_o);
	data2_comp : data port map(reset => reset, clock => clock, data_i => data2_i, data_o => data2_o);
	data3_comp : data port map(reset => reset, clock => clock, data_i => data3_i, data_o => data3_o);
	data4_comp : data port map(reset => reset, clock => clock, data_i => data4_i, data_o => data4_o);
	data5_comp : data port map(reset => reset, clock => clock, data_i => data5_i, data_o => data5_o);
	data6_comp : data port map(reset => reset, clock => clock, data_i => data6_i, data_o => data6_o);
	data7_comp : data port map(reset => reset, clock => clock, data_i => data7_i, data_o => data7_o);

	tag0_comp : tag port map(reset => reset, clock => clock, tag_i => tag0_i, tag_o => tag0_o);
	tag1_comp : tag port map(reset => reset, clock => clock, tag_i => tag1_i, tag_o => tag1_o);
	tag2_comp : tag port map(reset => reset, clock => clock, tag_i => tag2_i, tag_o => tag2_o);
	tag3_comp : tag port map(reset => reset, clock => clock, tag_i => tag3_i, tag_o => tag3_o);
	tag4_comp : tag port map(reset => reset, clock => clock, tag_i => tag4_i, tag_o => tag4_o);
	tag5_comp : tag port map(reset => reset, clock => clock, tag_i => tag5_i, tag_o => tag5_o);
	tag6_comp : tag port map(reset => reset, clock => clock, tag_i => tag6_i, tag_o => tag6_o);
	tag7_comp : tag port map(reset => reset, clock => clock, tag_i => tag7_i, tag_o => tag7_o);

	valid_comp : valid port map(reset => reset, clock => clock, valid_i => valid_i, valid_o => valid_o);

	hit_comp : hit port map(reset => reset, clock => clock, hit_i => hit_i, hit_o => hit_o);

	lru_comp : lru port map(reset => reset, clock => clock, lru_i => lru_i, lru_o => lru_o);

	ctrl_comp : ctrl port map(reset => reset, clock => clock, ctrl_i => ctrl_i, ctrl_o => ctrl_o, mem_i => mem_i, mem_o => mem_o);

end architecture;
