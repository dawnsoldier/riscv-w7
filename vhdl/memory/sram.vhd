-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.configure.all;
use work.wire.all;

entity sram is
	generic(
		ram_read_divider  : integer := ram_read_divider;
		ram_write_divider : integer := ram_write_divider
	);
	port(
		reset      : in  std_logic;
		clock      : in  std_logic;
		sram_valid : in  std_logic;
		sram_ready : out std_logic;
		sram_instr : in  std_logic;
		sram_addr  : in  std_logic_vector(63 downto 0);
		sram_wdata : in  std_logic_vector(63 downto 0);
		sram_wstrb : in  std_logic_vector(7 downto 0);
		sram_rdata : out std_logic_vector(63 downto 0);
		ram_a      : out std_logic_vector(26 downto 0);
		ram_dq_i   : out std_logic_vector(15 downto 0);
		ram_dq_o   : in  std_logic_vector(15 downto 0);
		ram_cen    : out std_logic;
		ram_oen    : out std_logic;
		ram_wen    : out std_logic;
		ram_ub     : out std_logic;
		ram_lb     : out std_logic
	);
end sram;

architecture behavior of sram is

	type state_type is (IDLE, LOAD, STORE);

	type register_type is record
		cen   : std_logic;
		oen   : std_logic;
		wen   : std_logic;
		ub    : std_logic;
		lb    : std_logic;
		a     : std_logic_vector(26 downto 0);
		dq    : std_logic_vector(15 downto 0);
		state : state_type;
		busy  : std_logic;
		count : integer range 0 to 7;
		iter  : integer range 0 to 3;
		wstrb : std_logic_vector(7 downto 0);
		wdata : std_logic_vector(63 downto 0);
		rdata : std_logic_vector(63 downto 0);
		ready : std_logic;
	end record;

	constant init_register : register_type := (
		cen   => '0',
		oen   => '0',
		wen   => '0',
		ub    => '0',
		lb    => '0',
		a     => (others => '0'),
		dq    => (others => '0'),
		state => IDLE,
		busy  => '0',
		count => 0,
		iter  => 0,
		wstrb => (others => '0'),
		wdata => (others => '0'),
		rdata => (others => '0'),
		ready => '0'
	);

	signal r,rin : register_type := init_register;

begin

	process(r,sram_valid,sram_instr,sram_addr,sram_wdata,sram_wstrb,ram_dq_o)

	variable v : register_type;

	begin

		v := r;

		case r.state is
			when IDLE =>
				v.cen := '1';
				v.oen := '1';
				v.wen := '1';
				v.ub := '1';
				v.lb := '1';
				v.count := 0;
				v.iter := 0;
				v.busy := '0';
				if sram_valid = '1' and nor_reduce(sram_addr(63 downto 27)) = '1' then
					if or_reduce(sram_wstrb) = '0' then
						v.state := LOAD;
					elsif or_reduce(sram_wstrb) = '1' then
						v.state := STORE;
					end if;
					v.busy := '1';
					v.a := sram_addr(26 downto 0);
					v.wstrb := sram_wstrb;
					v.wdata := sram_wdata;
				end if;
				v.ready := '0';
			when LOAD =>
				if v.count = ram_read_divider then
					v.count := 0;
					case v.iter is
						when 0 => v.rdata(15 downto 0) := ram_dq_o;
						when 1 => v.rdata(31 downto 16) := ram_dq_o;
						when 2 => v.rdata(47 downto 32) := ram_dq_o;
						when 3 => v.rdata(63 downto 48) := ram_dq_o;
					end case;
					if v.iter = 3 then
						v.state := IDLE;
						v.busy := '0';
						v.ready := '1';
					else
						v.iter := v.iter + 1;
						v.a := std_logic_vector(unsigned(v.a)+1);
					end if;
				else
					v.count := v.count + 1;
				end if;
				v.cen := '0';
				v.oen := '0';
				v.wen := '1';
				v.ub := '0';
				v.lb := '0';
				if v.busy = '0' then
					v.cen := '1';
					v.oen := '1';
					v.wen := '1';
					v.ub := '1';
					v.lb := '1';
				end if;
			when STORE =>
				if v.count = ram_write_divider then
					v.count := 0;
					if v.iter = 3 then
						v.state := IDLE;
						v.busy := '0';
						v.ready := '1';
					else
						v.iter := v.iter + 1;
						v.a := std_logic_vector(unsigned(v.a)+1);
					end if;
				else
					v.count := v.count + 1;
				end if;
				case v.iter is
					when 0 => v.dq := v.wdata(15 downto 0);
					when 1 => v.dq := v.wdata(31 downto 16);
					when 2 => v.dq := v.wdata(47 downto 32);
					when 3 => v.dq := v.wdata(63 downto 48);
				end case;
				v.cen := '0';
				v.oen := '1';
				v.wen := '0';
				v.ub := not(v.wstrb(2*v.iter+1));
				v.lb := not(v.wstrb(2*v.iter));
				if v.busy = '0' then
					v.cen := '1';
					v.oen := '1';
					v.wen := '1';
					v.ub := '1';
					v.lb := '1';
				end if;
		end case;

		rin <= v;

		ram_a <= v.a;
		ram_dq_i <= v.dq;
		ram_cen <= v.cen;
		ram_oen <= v.oen;
		ram_wen <= v.wen;
		ram_ub <= v.ub;
		ram_lb <= v.lb;

		sram_rdata <= r.rdata;
		sram_ready <= r.ready;

	end process;

	ASYNCHRONOUS : if reset_async = true generate

		process(reset,clock)

		begin

			if reset = reset_active then

				r <= init_register;

			elsif rising_edge(clock) then

				r <= rin;

			end if;

		end process;

	end generate ASYNCHRONOUS;

	SYNCHRONOUS : if reset_async = false generate

		process(clock)

		begin

			if rising_edge(clock) then

				if reset = reset_active then
					r <= init_register;
				else
					r <= rin;
				end if;

			end if;

		end process;

	end generate SYNCHRONOUS;

end architecture;
