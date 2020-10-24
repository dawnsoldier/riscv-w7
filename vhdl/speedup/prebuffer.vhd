-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.configure.all;
use work.constants.all;
use work.wire.all;

entity prebuffer is
	generic(
		pfetch_depth : integer := pfetch_depth
	);
	port(
		reset     : in  std_logic;
		clock     : in  std_logic;
		pbuffer_i : in  prebuffer_in_type;
		pbuffer_o : out prebuffer_out_type
	);
end prebuffer;

architecture behavior of prebuffer is

	type buffer_type is array (0 to 2**pfetch_depth-1) of std_logic_vector(15 downto 0);

	signal pbuffer : buffer_type := (others => (others => '0'));

begin

  process(pbuffer_i,pbuffer)

  begin

    if pbuffer_i.raddr = 2**pfetch_depth-1 then
      pbuffer_o.rdata <= pbuffer(0) & pbuffer(pbuffer_i.raddr);
    else
      pbuffer_o.rdata <= pbuffer(pbuffer_i.raddr+1) & pbuffer(pbuffer_i.raddr);
    end if;

  end process;

  process(clock)

  begin

    if rising_edge(clock) then

      if pbuffer_i.wren = '1' then
        pbuffer(pbuffer_i.waddr) <= pbuffer_i.wdata(15 downto 0);
        pbuffer(pbuffer_i.waddr+1) <= pbuffer_i.wdata(31 downto 16);
        pbuffer(pbuffer_i.waddr+2) <= pbuffer_i.wdata(47 downto 32);
        pbuffer(pbuffer_i.waddr+3) <= pbuffer_i.wdata(63 downto 48);
      end if;

    end if;

  end process;


end architecture;
