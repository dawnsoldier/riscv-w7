-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;

package dwire is

	type ddata_in_type is record
		raddr : integer range 0 to 2**dcache_sets-1;
		wen   : std_logic;
		waddr : integer range 0 to 2**dcache_sets-1;
		wdata : std_logic_vector((2**dcache_words)*64-1 downto 0);
	end record;

	type ddata_out_type is record
		rdata : std_logic_vector((2**dcache_words)*64-1 downto 0);
	end record;

	type dtag_in_type is record
		raddr : integer range 0 to 2**dcache_sets-1;
		wen   : std_logic;
		waddr : integer range 0 to 2**dcache_sets-1;
		wdata : std_logic_vector(60-(dcache_sets+dcache_words) downto 0);
	end record;

	type dtag_out_type is record
		rdata :  std_logic_vector(60-(dcache_sets+dcache_words) downto 0);
	end record;

	type dvalid_in_type is record
		raddr : integer range 0 to 2**dcache_sets-1;
		wen   : std_logic;
		waddr : integer range 0 to 2**dcache_sets-1;
		wdata : std_logic_vector(2**dcache_ways-1 downto 0);
	end record;

	type dvalid_out_type is record
		rdata :  std_logic_vector(2**dcache_ways-1 downto 0);
	end record;

	type dirty_in_type is record
		raddr : integer range 0 to 2**dcache_sets-1;
		wen   : std_logic;
		waddr : integer range 0 to 2**dcache_sets-1;
		wdata : std_logic_vector(2**dcache_ways-1 downto 0);
	end record;

	type dirty_out_type is record
		rdata :  std_logic_vector(2**dcache_ways-1 downto 0);
	end record;

	type dlru_in_type is record
		raddr : integer range 0 to 2**dcache_sets-1;
		wen   : std_logic;
		waddr : integer range 0 to 2**dcache_sets-1;
		wdata : std_logic_vector(2**dcache_ways-1 downto 0);
	end record;

	type dlru_out_type is record
		rdata :  std_logic_vector(2**dcache_ways-1 downto 0);
	end record;

	type dlru_ctrl_in_type is record
		raddr : integer range 0 to 2**dcache_sets-1;
		waddr : integer range 0 to 2**dcache_sets-1;
		wid   : integer range 0 to 2**dcache_ways-1;
		hit   : std_logic;
		miss  : std_logic;
	end record;

	type dlru_ctrl_out_type is record
		wid   : integer range 0 to 2**dcache_ways-1;
	end record;

	type dhit_in_type is record
		tag   : std_logic_vector(60-(dcache_sets+dcache_words) downto 0);
		tag0  : std_logic_vector(60-(dcache_sets+dcache_words) downto 0);
		tag1  : std_logic_vector(60-(dcache_sets+dcache_words) downto 0);
		tag2  : std_logic_vector(60-(dcache_sets+dcache_words) downto 0);
		tag3  : std_logic_vector(60-(dcache_sets+dcache_words) downto 0);
		tag4  : std_logic_vector(60-(dcache_sets+dcache_words) downto 0);
		tag5  : std_logic_vector(60-(dcache_sets+dcache_words) downto 0);
		tag6  : std_logic_vector(60-(dcache_sets+dcache_words) downto 0);
		tag7  : std_logic_vector(60-(dcache_sets+dcache_words) downto 0);
		valid : std_logic_vector(2**dcache_ways-1 downto 0);
	end record;

	type dhit_out_type is record
		hit   : std_logic;
		miss  : std_logic;
		wid   : integer range 0 to 2**dcache_ways-1;
	end record;

	type dctrl_in_type is record
		data0_o : ddata_out_type;
		data1_o : ddata_out_type;
		data2_o : ddata_out_type;
		data3_o : ddata_out_type;
		data4_o : ddata_out_type;
		data5_o : ddata_out_type;
		data6_o : ddata_out_type;
		data7_o : ddata_out_type;
		tag0_o  : dtag_out_type;
		tag1_o  : dtag_out_type;
		tag2_o  : dtag_out_type;
		tag3_o  : dtag_out_type;
		tag4_o  : dtag_out_type;
		tag5_o  : dtag_out_type;
		tag6_o  : dtag_out_type;
		tag7_o  : dtag_out_type;
		valid_o : dvalid_out_type;
		dirty_o : dirty_out_type;
		lru_o   : dlru_ctrl_out_type;
		hit_o   : dhit_out_type;
	end record;

	type dctrl_out_type is record
		data0_i : ddata_in_type;
		data1_i : ddata_in_type;
		data2_i : ddata_in_type;
		data3_i : ddata_in_type;
		data4_i : ddata_in_type;
		data5_i : ddata_in_type;
		data6_i : ddata_in_type;
		data7_i : ddata_in_type;
		tag0_i  : dtag_in_type;
		tag1_i  : dtag_in_type;
		tag2_i  : dtag_in_type;
		tag3_i  : dtag_in_type;
		tag4_i  : dtag_in_type;
		tag5_i  : dtag_in_type;
		tag6_i  : dtag_in_type;
		tag7_i  : dtag_in_type;
		valid_i : dvalid_in_type;
		dirty_i : dirty_in_type;
		lru_i   : dlru_ctrl_in_type;
		hit_i   : dhit_in_type;
	end record;

end package;
