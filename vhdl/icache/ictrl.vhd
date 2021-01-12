-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.configure.all;
use work.constants.all;
use work.wire.all;
use work.iwire.all;

entity ictrl is
	generic(
		cache_sets  : integer;
		cache_ways  : integer;
		cache_words : integer
	);
	port(
		reset   : in  std_logic;
		clock   : in  std_logic;
		ctrl_i  : in  ictrl_in_type;
		ctrl_o  : out ictrl_out_type;
		cache_i : in  mem_in_type;
		cache_o : out mem_out_type;
		mem_o   : in  mem_out_type;
		mem_i   : out mem_in_type
	);
end ictrl;

architecture behavior of ictrl is

	type state_type is (HIT,MISS,UPDATE,INVALIDATE);

	type ctrl_type is record
		addr    : std_logic_vector(63 downto 0);
		tag     : std_logic_vector(60-(cache_sets+cache_words) downto 0);
		sid     : integer range 0 to 2**cache_sets-1;
		lid     : integer range 0 to 2**cache_words-1;
		invalid : std_logic;
		spec    : std_logic;
		en      : std_logic;
	end record;

	constant init_ctrl_type : ctrl_type := (
		addr    => (others => '0'),
		tag     => (others => '0'),
		sid     => 0,
		lid     => 0,
		invalid => '0',
		spec    => '0',
		en      => '0'
	);

	type data_type is record
		state   : state_type;
		addr    : std_logic_vector(63 downto 0);
		rdata   : std_logic_vector(63 downto 0);
		tag     : std_logic_vector(60-(cache_sets+cache_words) downto 0);
		cline   : std_logic_vector((2**cache_words)*64-1 downto 0);
		wen     : std_logic_vector(2**cache_ways-1 downto 0);
		wvec    : std_logic_vector(2**cache_ways-1 downto 0);
		sid     : integer range 0 to 2**cache_sets-1;
		lid     : integer range 0 to 2**cache_words-1;
		count   : integer range 0 to 2**cache_words-1;
		wid     : integer range 0 to 2**cache_ways-1;
		invalid : std_logic;
		flush   : std_logic;
		valid   : std_logic;
		hit     : std_logic;
		miss    : std_logic;
		en      : std_logic;
		spec    : std_logic;
		ready   : std_logic;
	end record;

	constant init_data_type : data_type := (
		state   => INVALIDATE,
		addr    => (others => '0'),
		rdata   => (others => '0'),
		tag     => (others => '0'),
		cline   => (others => '0'),
		wen     => (others => '0'),
		wvec    => (others => '0'),
		sid     => 0,
		lid     => 0,
		wid     => 0,
		count   => 0,
		invalid => '0',
		flush   => '0',
		valid   => '0',
		hit     => '0',
		miss    => '0',
		en      => '0',
		spec    => '0',
		ready   => '0'
	);

	signal r,rin : ctrl_type := init_ctrl_type;
	signal r_next,rin_next : data_type := init_data_type;

begin

	process(cache_i,r)

	variable v : ctrl_type;

	begin

		v := r;

		v.invalid := '0';
		v.en := '0';
		v.spec := '0';

		if cache_i.mem_valid = '1' then
			if cache_i.mem_invalid = '1' then
				v.invalid := cache_i.mem_invalid;
			else
				v.spec := cache_i.mem_spec;
				v.en := cache_i.mem_valid;
				v.addr(63 downto cache_words+3) := cache_i.mem_addr(63 downto cache_words+3);
				v.addr(cache_words+2 downto 0) := (others => '0');
				v.tag := cache_i.mem_addr(63 downto cache_sets+cache_words+3);
				v.sid := to_integer(unsigned(cache_i.mem_addr(cache_sets+cache_words+2 downto 3+cache_words)));
				v.lid := to_integer(unsigned(cache_i.mem_addr(cache_words+2 downto 3)));
			end if;
		end if;

		rin <= v;

	end process;

	process(ctrl_i,cache_i,mem_o,r,r_next,rin)

	variable v : data_type;

	begin

		v := r_next;

		v.en := '0';
		v.hit := '0';
		v.miss := '0';
		v.invalid := '0';
		v.flush := '0';

		if r_next.state = HIT then
			v.en := r.en;
			v.addr := r.addr;
			v.tag := r.tag;
			v.sid := r.sid;
			v.lid := r.lid;
		end if;

		ctrl_o.hit_i.tag <= v.tag;
		for i in 0 to 2**cache_ways-1 loop
			ctrl_o.hit_i.tag_a(i) <= ctrl_i.tag_o(i).rdata;
		end loop;
		ctrl_o.hit_i.valid <= ctrl_i.valid_o.rdata;

		case r_next.state is

			when HIT =>

				v.wvec := ctrl_i.valid_o.rdata;
				v.wen := (others => '0');

				v.hit := ctrl_i.hit_o.hit and v.en;
				v.miss := ctrl_i.hit_o.miss and v.en;
				v.wid := ctrl_i.hit_o.wid;

				if v.miss = '1' then
					v.state := MISS;
					v.count := 0;
					v.valid := '1';
				else
					v.cline := ctrl_i.data_o(v.wid).rdata;
					v.valid := '0';
				end if;

				v.spec := '0';

			when MISS =>

				if r_next.miss = '1' then
					v.wid := ctrl_i.lru_o.wid;
				end if;

				if mem_o.mem_ready = '1' then

					case r_next.count is
						when 0 =>
							v.cline(63 downto 0) := mem_o.mem_rdata;
						when 1 =>
							v.cline(127 downto 64) := mem_o.mem_rdata;
						when 2 =>
							v.cline(191 downto 128) := mem_o.mem_rdata;
						when 3 =>
							v.cline(255 downto 192) := mem_o.mem_rdata;
							v.wen(v.wid) := '1';
							v.wvec(v.wid) := '1';
							v.valid := '0';
							v.state := UPDATE;
						when others =>
							null;
					end case;

					v.addr(63 downto 3) := std_logic_vector(unsigned(v.addr(63 downto 3))+1);
					if v.count /= 3 then
						v.count := v.count + 1;
					end if;

				end if;

			when UPDATE =>

				v.wen := (others => '0');
				v.wvec := (others => '0');
				v.valid := '0';
				v.state := HIT;

			when INVALIDATE =>

				v.wen := (others => '0');
				v.wvec := (others => '0');
				v.valid := '0';
				v.invalid := '1';

			when others =>

				null;

		end case;

		for i in 0 to 2**cache_ways-1 loop
			ctrl_o.data_i(i).raddr <= rin.sid;
			ctrl_o.tag_i(i).raddr <= rin.sid;
		end loop;

		ctrl_o.valid_i.raddr <= rin.sid;

		ctrl_o.lru_i.raddr <= rin.sid;

		for i in 0 to 2**cache_ways-1 loop
			ctrl_o.data_i(i).waddr <= v.sid;
			ctrl_o.data_i(i).wen <= v.wen(i);
			ctrl_o.data_i(i).wdata <= v.cline;
			ctrl_o.tag_i(i).waddr <= v.sid;
			ctrl_o.tag_i(i).wen <= v.wen(i);
			ctrl_o.tag_i(i).wdata <= v.tag;
		end loop;

		ctrl_o.lru_i.waddr <= v.sid;
		ctrl_o.lru_i.wid <= v.wid;
		ctrl_o.lru_i.hit <= v.hit;
		ctrl_o.lru_i.miss <= v.miss;

		ctrl_o.valid_i.waddr <= v.sid;
		ctrl_o.valid_i.wen <= or_reduce(v.wen) or v.invalid;
		ctrl_o.valid_i.wdata <= v.wvec;

		if r_next.state = INVALIDATE then
			if v.sid = 2**cache_sets-1 then
				v.state := HIT;
			else
				v.sid := v.sid+1;
			end if;
		end if;

		if (r.spec) = '1' then
			v.spec := '1';
		end if;

		if v.lid = 0 then
			v.rdata := v.cline(63 downto 0);
		elsif v.lid = 1 then
			v.rdata := v.cline(127 downto 64);
		elsif v.lid = 2 then
			v.rdata := v.cline(191 downto 128);
		elsif v.lid = 3 then
			v.rdata := v.cline(255 downto 192);
		end if;

		if r_next.state = HIT then
			v.ready := v.en and v.hit;
			v.flush := '0';
		elsif r_next.state = UPDATE then
			v.ready := not v.spec;
			v.flush := '0';
		elsif r_next.state = INVALIDATE then
			v.ready := '0';
			v.flush := '1';
		else
			v.ready := '0';
			v.flush := '0';
		end if;

		if (r.invalid) = '1' then
			v.sid := 0;
			v.state := INVALIDATE;
		end if;

		mem_i.mem_valid <= v.valid;
		mem_i.mem_instr <= '1';
		mem_i.mem_invalid <= '0';
		mem_i.mem_spec <= '0';
		mem_i.mem_addr <= v.addr;
		mem_i.mem_wdata <= (others => '0');
		mem_i.mem_wstrb <= (others => '0');

		cache_o.mem_rdata <= v.rdata;
		cache_o.mem_ready <= v.ready;
		cache_o.mem_flush <= v.flush;

		rin_next <= v;

	end process;

	process(clock)

	begin

		if rising_edge(clock) then

			if reset = '0' then

				r <= init_ctrl_type;
				r_next <= init_data_type;

			else

				r <= rin;
				r_next <= rin_next;

			end if;

		end if;

	end process;

end architecture;
