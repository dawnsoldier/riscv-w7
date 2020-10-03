-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.configure.all;
use work.constants.all;
use work.wire.all;

entity btb is
	generic(
		btb_enable : boolean := btb_enable;
		btb_depth  : integer := btb_depth;
		bht_depth  : integer := bht_depth;
		ras_depth  : integer := ras_depth
	);
	port(
		reset : in  std_logic;
		clock : in  std_logic;
		btb_i : in  btb_in_type;
		btb_o : out btb_out_type
	);
end btb;

architecture behavior of btb is

	type index_type is record
		address : std_logic_vector(63 downto 0);
		tag     : std_logic_vector(62 - btb_depth downto 0);
	end record;

	constant init_index : index_type := (
		address => (others => '0'),
		tag     => (others => '0')
	);

	type target_type is array (0 to 2**btb_depth-1) of index_type;

	signal target : target_type := (others => init_index);

	type reg_btb_type is record
		wpc    : std_logic_vector(63 downto 0);
		rpc    : std_logic_vector(63 downto 0);
		wid    : integer range 0 to 2**btb_depth-1;
		rid    : integer range 0 to 2**btb_depth-1;
		waddr  : std_logic_vector(63 downto 0);
		update : std_logic;
	end record;

	constant init_reg_btb : reg_btb_type := (
		wpc    => (others => '0'),
		rpc    => (others => '0'),
		wid    => 0,
		rid    => 0,
		waddr  => (others => '0'),
		update => '0'
	);

	type pattern_type is array (0 to 2**bht_depth-1) of unsigned(1 downto 0);

	signal pattern : pattern_type := (others => (others => '0'));

	type reg_bht_type is record
		history : std_logic_vector(bht_depth-1 downto 0);
		get_ind : integer range 0 to 2**bht_depth-1;
		get_sat : unsigned(1 downto 0);
		upd_ind : integer range 0 to 2**bht_depth-1;
		upd_sat : unsigned(1 downto 0);
		update  : std_logic;
	end record;

	constant init_reg_bht : reg_bht_type := (
		history => (others => '0'),
		get_ind => 0,
		get_sat => (others => '0'),
		upd_ind => 0,
		upd_sat => (others => '0'),
		update  => '0'
	);

	type stack_type is array (0 to 2**ras_depth-1) of std_logic_vector(63 downto 0);

	signal stack : stack_type := (others => (others => '0'));

	type reg_ras_type is record
		count  : integer range 0 to 2**ras_depth;
		rid    : integer range 0 to 2**ras_depth-1;
		wid    : integer range 0 to 2**ras_depth-1;
		waddr  : std_logic_vector(63 downto 0);
		update : std_logic;
	end record;

	constant init_reg_ras : reg_ras_type := (
		count  => 0,
		rid    => 0,
		wid    => 0,
		waddr  => (others => '0'),
		update => '0'
	);

	signal r_btb, rin_btb : reg_btb_type := init_reg_btb;
	signal r_bht, rin_bht : reg_bht_type := init_reg_bht;
	signal r_ras, rin_ras : reg_ras_type := init_reg_ras;

begin

	BTB_ON : if btb_enable = true generate

		branch_target_buffer : process(r_btb,btb_i,target)

		variable v : reg_btb_type;

		begin

			v := r_btb;

			if btb_i.upd_jump = '0' and btb_i.stall = '0' and btb_i.clear = '0' then
				v.rpc := btb_i.get_pc;
				v.rid := to_integer(unsigned(v.rpc(btb_depth downto 1)));
			end if;

			if (btb_i.upd_branch = '1' and btb_i.upd_jump = '1') or (btb_i.upd_uncond = '1') then
				v.wpc := btb_i.upd_pc;
				v.waddr := btb_i.upd_addr;
				v.wid := to_integer(unsigned(v.wpc(btb_depth downto 1)));
			end if;

			if btb_i.upd_jump = '0' and btb_i.stall = '0' and btb_i.clear = '0' and
					nor_reduce(target(v.rid).tag xor v.rpc(63 downto btb_depth+1)) = '1' then
				btb_o.pred_baddr <= target(v.rid).address;
				btb_o.pred_branch <= btb_i.get_branch;
				btb_o.pred_uncond <= btb_i.get_uncond;
			else
				btb_o.pred_baddr <= (others => '0');
				btb_o.pred_branch <= '0';
				btb_o.pred_uncond <= '0';
			end if;

			v.update := (btb_i.upd_branch and btb_i.upd_jump) or btb_i.upd_uncond;

			rin_btb <= v;

		end process;

		branch_history_table : process(r_bht,btb_i,pattern)

		variable v : reg_bht_type;

		begin

			v := r_bht;

			if btb_i.upd_branch = '1' then
				v.upd_ind := to_integer(unsigned(v.history xor btb_i.upd_pc(bht_depth downto 1)));
				v.upd_sat := pattern(v.upd_ind);
				v.history := v.history(bht_depth-2 downto 0) & '0';
				if btb_i.upd_jump = '1' then
					v.history(0) := '1';
					if v.upd_sat < 3 then
						v.upd_sat := v.upd_sat + 1;
					end if;
				elsif btb_i.upd_jump = '0' then
					if v.upd_sat > 0 then
						v.upd_sat := v.upd_sat - 1;
					end if;
				end if;
			end if;

			if btb_i.get_branch = '1' and btb_i.upd_jump = '0' and btb_i.stall = '0' and
					btb_i.clear = '0' then
				v.get_ind := to_integer(unsigned(v.history xor btb_i.get_pc(bht_depth downto 1)));
				v.get_sat := pattern(v.get_ind);
				btb_o.pred_jump <= v.get_sat(1);
			else
				btb_o.pred_jump <= '0';
			end if;

			v.update := btb_i.upd_branch;

			rin_bht <= v;

		end process;

		return_address_stack : process(r_ras,btb_i,stack)

		variable v : reg_ras_type;

		begin

			v := r_ras;

			v.waddr := btb_i.upd_npc;

			if btb_i.upd_return = '1' then
				if v.count < 2**ras_depth then
					v.count := v.count + 1;
				end if;
				v.rid := v.wid;
				if v.wid < 2**ras_depth-1 then
					v.wid := v.wid + 1;
				else
					v.wid := 0;
				end if;
			end if;

			if btb_i.get_return = '1' and btb_i.upd_jump = '0' and btb_i.stall = '0' and
					btb_i.clear = '0' and v.count > 0 then
				btb_o.pred_raddr <= stack(v.rid);
				btb_o.pred_return <= '1';
				v.count := v.count - 1;
				v.wid := v.rid;
				if v.rid > 0 then
					v.rid := v.rid - 1;
				else
					v.rid := 2**ras_depth-1;
				end if;
			else
				btb_o.pred_raddr <= (others => '0');
				btb_o.pred_return <= '0';
			end if;

			v.update := btb_i.upd_return;

			rin_ras <= v;

	  	end process;

		process(clock)

		begin

			if rising_edge(clock) then

				if reset = '0' then

					r_btb <= init_reg_btb;
					r_bht <= init_reg_bht;
					r_ras <= init_reg_ras;

				else

					if rin_btb.update = '1' then
						target(rin_btb.wid).tag <= rin_btb.wpc(63 downto btb_depth+1);
						target(rin_btb.wid).address <= rin_btb.waddr;
					end if;

					if rin_bht.update = '1' then
						pattern(rin_bht.upd_ind) <= rin_bht.upd_sat;
					end if;

					if rin_ras.update = '1' then
						stack(r_ras.wid) <= rin_ras.waddr;
					end if;

					r_btb <= rin_btb;
					r_bht <= rin_bht;
					r_ras <= rin_ras;

				end if;

			end if;

		end process;

	end generate BTB_ON;

	BTB_OFF : if btb_enable = false generate

		btb_o.pred_baddr <= (others => '0');
		btb_o.pred_branch <= '0';
		btb_o.pred_jump <= '0';
		btb_o.pred_raddr <= (others => '0');
		btb_o.pred_return <= '0';
		btb_o.pred_uncond <= '0';

	end generate BTB_OFF;

end architecture;
