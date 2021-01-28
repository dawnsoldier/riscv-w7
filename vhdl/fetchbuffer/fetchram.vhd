-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.configure.all;
use work.constants.all;
use work.wire.all;

entity fetchram is
	generic(
		fetchbuffer_depth : integer := fetchbuffer_depth
	);
	port(
		reset      : in  std_logic;
		clock      : in  std_logic;
		fetchram_i : in  fetchram_in_type;
		fetchram_o : out fetchram_out_type
	);
end fetchram;

architecture behavior of fetchram is

	type ram_type is array (0 to 2**fetchbuffer_depth-1) of std_logic_vector(15 downto 0);

	signal fetch_ram : ram_type := (others => (others => '0'));

begin

  process(fetchram_i,fetch_ram)

  begin

    if fetchram_i.raddr = 2**fetchbuffer_depth-1 then
      fetchram_o.rdata <= fetch_ram(0) & fetch_ram(fetchram_i.raddr);
    else
      fetchram_o.rdata <= fetch_ram(fetchram_i.raddr+1) & fetch_ram(fetchram_i.raddr);
    end if;

  end process;

  process(clock)

  begin

    if rising_edge(clock) then

      if fetchram_i.wren = '1' then
        fetch_ram(fetchram_i.waddr) <= fetchram_i.wdata(15 downto 0);
        fetch_ram(fetchram_i.waddr+1) <= fetchram_i.wdata(31 downto 16);
        fetch_ram(fetchram_i.waddr+2) <= fetchram_i.wdata(47 downto 32);
        fetch_ram(fetchram_i.waddr+3) <= fetchram_i.wdata(63 downto 48);
      end if;

    end if;

  end process;


end architecture;
