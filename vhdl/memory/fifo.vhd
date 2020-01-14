-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.configure.all;
use work.wire.all;

entity fifo is
	generic(
		fifo_depth : integer := fifo_depth
	);
	port(
		reset      : in  std_logic;
		clock      : in  std_logic;
		fifo_i     : in  fifo_in_type;
		fifo_o     : out fifo_out_type
	);
end fifo;

architecture behavior of fifo is

	type buffer_type is array (0 to 2**fifo_depth-1) of std_logic_vector(7 downto 0);

	type reg_type is record
		fifo_overflow : std_logic;
		fifo_en       : std_logic;
		fifo_we       : std_logic;
		fifo_windex   : unsigned(fifo_depth-1 downto 0);
		fifo_rindex   : unsigned(fifo_depth-1 downto 0);
		fifo_wdata    : std_logic_vector(7 downto 0);
	end record;

	constant init_reg : reg_type := (
		fifo_overflow => '0',
		fifo_en       => '0',
		fifo_we       => '0',
		fifo_windex   => (others => '0'),
		fifo_rindex   => (others => '0'),
		fifo_wdata    => (others => '0')
	);

	signal r, rin : reg_type := init_reg;

	signal fifo_buffer : buffer_type := (others => (others => '0'));

begin

	process(r, fifo_i, fifo_buffer)

		variable v : reg_type;

	begin
		v := r;

		v.fifo_en := '0';
		v.fifo_we := '0';

		if fifo_i.we = '1' then
			if (v.fifo_overflow = '0') or (v.fifo_overflow = '1' and v.fifo_windex < v.fifo_rindex) then
				v.fifo_en := '1';
				v.fifo_we := '1';
				v.fifo_wdata := fifo_i.wdata;
				if v.fifo_windex = 2**fifo_depth-1 then
					v.fifo_windex := (others => '0');
					v.fifo_overflow := '1';
				else
					v.fifo_windex := v.fifo_windex + 1;
				end if;
			end if;
		end if;

		if fifo_i.re = '1' then
			if (v.fifo_overflow = '0' and v.fifo_rindex < v.fifo_windex) or (v.fifo_overflow = '1') then
				v.fifo_en := '1';
				if v.fifo_rindex = 2**fifo_depth-1 then
					v.fifo_rindex := (others => '0');
					v.fifo_overflow := '0';
				else
					v.fifo_rindex := v.fifo_rindex + 1;
				end if;
			end if;
		end if;

		rin <= v;

		fifo_o.rdata <= fifo_buffer(to_integer(r.fifo_rindex));
		fifo_o.ready <= r.fifo_en;

	end process;

	process(clock)
	begin

		if rising_edge(clock) then

			if reset = '0' then

				r <= init_reg;

			else

				r <= rin;

				if rin.fifo_en = '1' then
					fifo_buffer(to_integer(rin.fifo_windex)) <= rin.fifo_wdata;
				end if;

			end if;

		end if;

	end process;

end architecture;
