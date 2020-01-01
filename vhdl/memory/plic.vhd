-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.configure.all;
use work.constants.all;
use work.wire.all;
use work.functions.all;

use work.csr_wire.all;

entity plic is
	port(
		reset           : in  std_logic;
		clock           : in  std_logic;
		plic_mem_valid  : in  std_logic;
		plic_mem_instr  : in  std_logic;
		plic_mem_ready  : out std_logic;
		plic_mem_addr   : in  std_logic_vector(63 downto 0);
		plic_mem_wdata  : in  std_logic_vector(63 downto 0);
		plic_mem_wstrb  : in  std_logic_vector(7 downto 0);
		plic_mem_rdata  : out std_logic_vector(63 downto 0)
	);
end plic;

architecture behavior of plic is

begin

end architecture;
