-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;

package iwire is

	type idata_in_type is record
		raddr : integer range 0 to 2**icache_sets-1;
		wen   : std_logic;
		waddr : integer range 0 to 2**icache_sets-1;
		wdata : std_logic_vector((2**icache_words)*64-1 downto 0);
	end record;

	type idata_out_type is record
		rdata : std_logic_vector((2**icache_words)*64-1 downto 0);
	end record;

	type itag_in_type is record
		raddr : integer range 0 to 2**icache_sets-1;
		wen   : std_logic;
		waddr : integer range 0 to 2**icache_sets-1;
		wdata : std_logic_vector(60-(icache_sets+icache_words) downto 0);
	end record;

	type itag_out_type is record
		rdata :  std_logic_vector(60-(icache_sets+icache_words) downto 0);
	end record;

	type ivalid_in_type is record
		raddr : integer range 0 to 2**icache_sets-1;
		wen   : std_logic;
		waddr : integer range 0 to 2**icache_sets-1;
		wdata : std_logic_vector(2**icache_ways-1 downto 0);
	end record;

	type ivalid_out_type is record
		rdata :  std_logic_vector(2**icache_ways-1 downto 0);
	end record;

	type ilru_in_type is record
		raddr : integer range 0 to 2**icache_sets-1;
		wen   : std_logic;
		waddr : integer range 0 to 2**icache_sets-1;
		wdata : std_logic_vector(2**icache_ways-1 downto 0);
	end record;

	type ilru_out_type is record
		rdata :  std_logic_vector(2**icache_ways-1 downto 0);
	end record;

	type ilru_ctrl_in_type is record
		raddr : integer range 0 to 2**icache_sets-1;
		waddr : integer range 0 to 2**icache_sets-1;
		wid   : integer range 0 to 2**icache_ways-1;
		hit   : std_logic;
		miss  : std_logic;
	end record;

	type ilru_ctrl_out_type is record
		wid   : integer range 0 to 2**icache_ways-1;
	end record;

	type ihit_in_type is record
		tag   : std_logic_vector(60-(icache_sets+icache_words) downto 0);
		tag0  : std_logic_vector(60-(icache_sets+icache_words) downto 0);
		tag1  : std_logic_vector(60-(icache_sets+icache_words) downto 0);
		tag2  : std_logic_vector(60-(icache_sets+icache_words) downto 0);
		tag3  : std_logic_vector(60-(icache_sets+icache_words) downto 0);
		tag4  : std_logic_vector(60-(icache_sets+icache_words) downto 0);
		tag5  : std_logic_vector(60-(icache_sets+icache_words) downto 0);
		tag6  : std_logic_vector(60-(icache_sets+icache_words) downto 0);
		tag7  : std_logic_vector(60-(icache_sets+icache_words) downto 0);
		valid : std_logic_vector(2**icache_ways-1 downto 0);
	end record;

	type ihit_out_type is record
		hit   : std_logic;
		miss  : std_logic;
		wid   : integer range 0 to 2**icache_ways-1;
	end record;

	type ictrl_in_type is record
		data0_o : idata_out_type;
		data1_o : idata_out_type;
		data2_o : idata_out_type;
		data3_o : idata_out_type;
		data4_o : idata_out_type;
		data5_o : idata_out_type;
		data6_o : idata_out_type;
		data7_o : idata_out_type;
		tag0_o  : itag_out_type;
		tag1_o  : itag_out_type;
		tag2_o  : itag_out_type;
		tag3_o  : itag_out_type;
		tag4_o  : itag_out_type;
		tag5_o  : itag_out_type;
		tag6_o  : itag_out_type;
		tag7_o  : itag_out_type;
		valid_o : ivalid_out_type;
		lru_o   : ilru_ctrl_out_type;
		hit_o   : ihit_out_type;
	end record;

	type ictrl_out_type is record
		data0_i : idata_in_type;
		data1_i : idata_in_type;
		data2_i : idata_in_type;
		data3_i : idata_in_type;
		data4_i : idata_in_type;
		data5_i : idata_in_type;
		data6_i : idata_in_type;
		data7_i : idata_in_type;
		tag0_i  : itag_in_type;
		tag1_i  : itag_in_type;
		tag2_i  : itag_in_type;
		tag3_i  : itag_in_type;
		tag4_i  : itag_in_type;
		tag5_i  : itag_in_type;
		tag6_i  : itag_in_type;
		tag7_i  : itag_in_type;
		valid_i : ivalid_in_type;
		lru_i   : ilru_ctrl_in_type;
		hit_i   : ihit_in_type;
	end record;

end package;
