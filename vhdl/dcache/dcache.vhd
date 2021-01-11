-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.configure.all;
use work.constants.all;
use work.wire.all;
use work.dwire.all;

entity dcache is
	generic(
		cache_enable : boolean;
		cache_sets   : integer;
		cache_ways   : integer;
		cache_words  : integer
	);
	port(
		reset   : in  std_logic;
		clock   : in  std_logic;
		cache_i : in  mem_in_type;
		cache_o : out mem_out_type;
		mem_o   : in  mem_out_type;
		mem_i   : out mem_in_type
	);
end dcache;

architecture behavior of dcache is

	component ddata
		generic(
			cache_sets  : integer;
			cache_ways  : integer;
			cache_words : integer
		);
		port(
			reset  : in  std_logic;
			clock  : in  std_logic;
			data_i : in  ddata_in_type;
			data_o : out ddata_out_type
		);
	end component;

	component dtag
		generic(
			cache_sets  : integer;
			cache_ways  : integer;
			cache_words : integer
		);
		port(
			reset : in  std_logic;
			clock : in  std_logic;
			tag_i : in  dtag_in_type;
			tag_o : out dtag_out_type
		);
	end component;

	component dvalid
		generic(
			cache_sets  : integer;
			cache_ways  : integer;
			cache_words : integer
		);
		port(
			reset   : in  std_logic;
			clock   : in  std_logic;
			valid_i : in  dvalid_in_type;
			valid_o : out dvalid_out_type
		);
	end component;

	component dirty
		generic(
			cache_sets  : integer;
			cache_ways  : integer;
			cache_words : integer
		);
		port(
			reset   : in  std_logic;
			clock   : in  std_logic;
			dirty_i : in  dirty_in_type;
			dirty_o : out dirty_out_type
		);
	end component;

	component dlru_ctrl
		generic(
			cache_sets  : integer;
			cache_ways  : integer;
			cache_words : integer
		);
		port(
			reset      : in  std_logic;
			clock      : in  std_logic;
			lru_ctrl_i : in  dlru_ctrl_in_type;
			lru_ctrl_o : out dlru_ctrl_out_type
		);
	end component;

	component dhit
		generic(
			cache_sets  : integer;
			cache_ways  : integer;
			cache_words : integer
		);
		port(
			reset : in  std_logic;
			clock : in  std_logic;
			hit_i : in  dhit_in_type;
			hit_o : out dhit_out_type
		);
	end component;

	component dctrl
		generic(
			cache_sets  : integer;
			cache_ways  : integer;
			cache_words : integer
		);
		port(
			reset   : in  std_logic;
			clock   : in  std_logic;
			ctrl_i  : in  dctrl_in_type;
			ctrl_o  : out dctrl_out_type;
			cache_i : in  mem_in_type;
			cache_o : out mem_out_type;
			mem_o   : in  mem_out_type;
			mem_i   : out mem_in_type
		);
	end component;

	signal ctrl_i : dctrl_in_type;
	signal ctrl_o : dctrl_out_type;

begin

	CACHE_ENABLED : if cache_enable = true generate

		dirty_comp : dirty generic map (cache_sets  => cache_sets, cache_ways  => cache_ways, cache_words => cache_words) port map(reset => reset, clock => clock, dirty_i => ctrl_o.dirty_i, dirty_o => ctrl_i.dirty_o);

		data0_comp : ddata generic map (cache_sets  => cache_sets, cache_ways  => cache_ways, cache_words => cache_words) port map(reset => reset, clock => clock, data_i => ctrl_o.data0_i, data_o => ctrl_i.data0_o);
		data1_comp : ddata generic map (cache_sets  => cache_sets, cache_ways  => cache_ways, cache_words => cache_words) port map(reset => reset, clock => clock, data_i => ctrl_o.data1_i, data_o => ctrl_i.data1_o);
		data2_comp : ddata generic map (cache_sets  => cache_sets, cache_ways  => cache_ways, cache_words => cache_words) port map(reset => reset, clock => clock, data_i => ctrl_o.data2_i, data_o => ctrl_i.data2_o);
		data3_comp : ddata generic map (cache_sets  => cache_sets, cache_ways  => cache_ways, cache_words => cache_words) port map(reset => reset, clock => clock, data_i => ctrl_o.data3_i, data_o => ctrl_i.data3_o);
		data4_comp : ddata generic map (cache_sets  => cache_sets, cache_ways  => cache_ways, cache_words => cache_words) port map(reset => reset, clock => clock, data_i => ctrl_o.data4_i, data_o => ctrl_i.data4_o);
		data5_comp : ddata generic map (cache_sets  => cache_sets, cache_ways  => cache_ways, cache_words => cache_words) port map(reset => reset, clock => clock, data_i => ctrl_o.data5_i, data_o => ctrl_i.data5_o);
		data6_comp : ddata generic map (cache_sets  => cache_sets, cache_ways  => cache_ways, cache_words => cache_words) port map(reset => reset, clock => clock, data_i => ctrl_o.data6_i, data_o => ctrl_i.data6_o);
		data7_comp : ddata generic map (cache_sets  => cache_sets, cache_ways  => cache_ways, cache_words => cache_words) port map(reset => reset, clock => clock, data_i => ctrl_o.data7_i, data_o => ctrl_i.data7_o);

		tag0_comp : dtag generic map (cache_sets  => cache_sets, cache_ways  => cache_ways, cache_words => cache_words) port map(reset => reset, clock => clock, tag_i => ctrl_o.tag0_i, tag_o => ctrl_i.tag0_o);
		tag1_comp : dtag generic map (cache_sets  => cache_sets, cache_ways  => cache_ways, cache_words => cache_words) port map(reset => reset, clock => clock, tag_i => ctrl_o.tag1_i, tag_o => ctrl_i.tag1_o);
		tag2_comp : dtag generic map (cache_sets  => cache_sets, cache_ways  => cache_ways, cache_words => cache_words) port map(reset => reset, clock => clock, tag_i => ctrl_o.tag2_i, tag_o => ctrl_i.tag2_o);
		tag3_comp : dtag generic map (cache_sets  => cache_sets, cache_ways  => cache_ways, cache_words => cache_words) port map(reset => reset, clock => clock, tag_i => ctrl_o.tag3_i, tag_o => ctrl_i.tag3_o);
		tag4_comp : dtag generic map (cache_sets  => cache_sets, cache_ways  => cache_ways, cache_words => cache_words) port map(reset => reset, clock => clock, tag_i => ctrl_o.tag4_i, tag_o => ctrl_i.tag4_o);
		tag5_comp : dtag generic map (cache_sets  => cache_sets, cache_ways  => cache_ways, cache_words => cache_words) port map(reset => reset, clock => clock, tag_i => ctrl_o.tag5_i, tag_o => ctrl_i.tag5_o);
		tag6_comp : dtag generic map (cache_sets  => cache_sets, cache_ways  => cache_ways, cache_words => cache_words) port map(reset => reset, clock => clock, tag_i => ctrl_o.tag6_i, tag_o => ctrl_i.tag6_o);
		tag7_comp : dtag generic map (cache_sets  => cache_sets, cache_ways  => cache_ways, cache_words => cache_words) port map(reset => reset, clock => clock, tag_i => ctrl_o.tag7_i, tag_o => ctrl_i.tag7_o);

		valid_comp : dvalid generic map (cache_sets  => cache_sets, cache_ways  => cache_ways, cache_words => cache_words) port map(reset => reset, clock => clock, valid_i => ctrl_o.valid_i, valid_o => ctrl_i.valid_o);

		hit_comp : dhit generic map (cache_sets  => cache_sets, cache_ways  => cache_ways, cache_words => cache_words) port map(reset => reset, clock => clock, hit_i => ctrl_o.hit_i, hit_o => ctrl_i.hit_o);

		lru_ctrl_comp : dlru_ctrl generic map (cache_sets  => cache_sets, cache_ways  => cache_ways, cache_words => cache_words) port map(reset => reset, clock => clock, lru_ctrl_i => ctrl_o.lru_i, lru_ctrl_o => ctrl_i.lru_o);

		dctrl_comp : dctrl generic map (cache_sets  => cache_sets, cache_ways  => cache_ways, cache_words => cache_words) port map (reset => reset, clock => clock, ctrl_i => ctrl_i, ctrl_o => ctrl_o, cache_i => cache_i, cache_o => cache_o, mem_o => mem_o, mem_i => mem_i);

	end generate CACHE_ENABLED;

	CACHE_DISABLED : if cache_enable = false generate

		mem_i <= cache_i;

		cache_o <= mem_o;

	end generate CACHE_DISABLED;

end architecture;
