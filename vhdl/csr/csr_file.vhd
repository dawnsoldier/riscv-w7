-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.configure.all;
use work.csr_constants.all;
use work.csr_wire.all;
use work.csr_functions.all;

entity csr_file is
	generic(
		pmp_enable  : boolean := pmp_enable;
		pmp_regions : integer := pmp_regions
	);
	port(
		reset  : in  std_logic;
		clock  : in  std_logic;
		csr_ri : in  csr_read_in_type;
		csr_wi : in  csr_write_in_type;
		csr_o  : out csr_out_type;
		csr_ei : in  csr_exception_in_type;
		csr_eo : out csr_exception_out_type;
		csr_ci : in  csr_counter_in_type
	);
end csr_file;

architecture behavior of csr_file is

	signal mcsr : csr_machine_register := init_csr_machine_reg;

	signal ucsr : csr_user_register := init_csr_user_reg;

	signal priv_mode : std_logic_vector(1 downto 0) := m_mode;

	signal exc  : std_logic := '0';
	signal mret : std_logic := '0';

begin

	process(csr_ei,mcsr,ucsr,priv_mode,exc,mret)

	begin

		csr_eo.fs <= mcsr.mstatus.fs;
		csr_eo.epc <= mcsr.mepc;
		csr_eo.frm <= ucsr.frm;
		csr_eo.pmpcfg <= mcsr.pmpcfg;
		csr_eo.pmpaddr <= mcsr.pmpaddr;
		csr_eo.priv_mode <= priv_mode;
		csr_eo.exc <= exc;
		csr_eo.mret <= mret;

		if mcsr.mtvec.mode = "01" then
			csr_eo.tvec <= std_logic_vector(unsigned(mcsr.mtvec.base) + unsigned(csr_ei.ecause)) & "00";
		else
			csr_eo.tvec <= mcsr.mtvec.base & "00";
		end if;

	end process;

	process(csr_ri,mcsr,ucsr)

	begin

		if csr_ri.rden = '1' then

			case csr_ri.raddr is
				when csr_misa =>
					csr_o.data <= mcsr.misa.mxl & X"000000000" &
									mcsr.misa.z & mcsr.misa.y &
									mcsr.misa.x & mcsr.misa.w &
									mcsr.misa.v & mcsr.misa.u &
									mcsr.misa.t & mcsr.misa.s &
									mcsr.misa.r & mcsr.misa.q &
									mcsr.misa.p & mcsr.misa.o &
									mcsr.misa.n & mcsr.misa.m &
									mcsr.misa.l & mcsr.misa.k &
									mcsr.misa.j & mcsr.misa.i &
									mcsr.misa.h & mcsr.misa.g &
									mcsr.misa.f & mcsr.misa.e &
									mcsr.misa.d & mcsr.misa.c &
									mcsr.misa.b & mcsr.misa.a;
				when csr_mstatus =>
					csr_o.data <= mcsr.mstatus.sd & X"0000000" & "0" &
									mcsr.mstatus.uxl  & X"000" & "00" &
									mcsr.mstatus.mprv & "00"  &
									mcsr.mstatus.fs   &
									mcsr.mstatus.mpp  & "000"  &
									mcsr.mstatus.mpie & "00"  &
									mcsr.mstatus.upie &
									mcsr.mstatus.mie  & "00"  &
									mcsr.mstatus.uie;
				when csr_mip =>
					csr_o.data <= X"0000000000000" &
									mcsr.mip.meip & "00" &
									mcsr.mip.ueip &
									mcsr.mip.mtip & "00" &
									mcsr.mip.utip &
									mcsr.mip.msip & "00" &
									mcsr.mip.usip;
				when csr_mie =>
					csr_o.data <= X"0000000000000" &
									mcsr.mie.meie & "00" &
									mcsr.mie.ueie &
									mcsr.mie.mtie & "00" &
									mcsr.mie.utie &
									mcsr.mie.msie & "00" &
									mcsr.mie.usie;
				when csr_mcause =>
					csr_o.data <= mcsr.mcause.irpt & mcsr.mcause.code;
				when csr_mtvec =>
					csr_o.data <= mcsr.mtvec.base & mcsr.mtvec.mode;
				when csr_mtval =>
					csr_o.data <= mcsr.mtval;
				when csr_mepc =>
					csr_o.data <= mcsr.mepc;
				when csr_mscratch =>
					csr_o.data <= mcsr.mscratch;
				when csr_mideleg =>
					csr_o.data <= mcsr.mideleg;
				when csr_medeleg =>
					csr_o.data <= mcsr.medeleg;
				when csr_mcycle =>
					csr_o.data <= mcsr.mcycle;
				when csr_minstret =>
					csr_o.data <= mcsr.minstret;
				when csr_pmpcfg0 =>
					csr_o.data <= mcsr.pmpcfg(7).L & "00" & mcsr.pmpcfg(7).A & mcsr.pmpcfg(7).X & mcsr.pmpcfg(7).X & mcsr.pmpcfg(7).R &
									mcsr.pmpcfg(6).L & "00" & mcsr.pmpcfg(6).A & mcsr.pmpcfg(6).X & mcsr.pmpcfg(6).W & mcsr.pmpcfg(6).R &
									mcsr.pmpcfg(5).L & "00" & mcsr.pmpcfg(5).A & mcsr.pmpcfg(5).X & mcsr.pmpcfg(5).W & mcsr.pmpcfg(5).R &
									mcsr.pmpcfg(4).L & "00" & mcsr.pmpcfg(4).A & mcsr.pmpcfg(4).X & mcsr.pmpcfg(4).W & mcsr.pmpcfg(4).R &
									mcsr.pmpcfg(3).L & "00" & mcsr.pmpcfg(3).A & mcsr.pmpcfg(3).X & mcsr.pmpcfg(3).W & mcsr.pmpcfg(3).R &
									mcsr.pmpcfg(2).L & "00" & mcsr.pmpcfg(2).A & mcsr.pmpcfg(2).X & mcsr.pmpcfg(2).W & mcsr.pmpcfg(2).R &
									mcsr.pmpcfg(1).L & "00" & mcsr.pmpcfg(1).A & mcsr.pmpcfg(1).X & mcsr.pmpcfg(1).W & mcsr.pmpcfg(1).R &
									mcsr.pmpcfg(0).L & "00" & mcsr.pmpcfg(0).A & mcsr.pmpcfg(0).X & mcsr.pmpcfg(0).W & mcsr.pmpcfg(0).R;
				when csr_pmpcfg2 =>
					csr_o.data <= mcsr.pmpcfg(15).L & "00" & mcsr.pmpcfg(15).A & mcsr.pmpcfg(15).X & mcsr.pmpcfg(15).X & mcsr.pmpcfg(15).R &
									mcsr.pmpcfg(14).L & "00" & mcsr.pmpcfg(14).A & mcsr.pmpcfg(14).X & mcsr.pmpcfg(14).W & mcsr.pmpcfg(14).R &
									mcsr.pmpcfg(13).L & "00" & mcsr.pmpcfg(13).A & mcsr.pmpcfg(13).X & mcsr.pmpcfg(13).W & mcsr.pmpcfg(13).R &
									mcsr.pmpcfg(12).L & "00" & mcsr.pmpcfg(12).A & mcsr.pmpcfg(12).X & mcsr.pmpcfg(12).W & mcsr.pmpcfg(12).R &
									mcsr.pmpcfg(11).L & "00" & mcsr.pmpcfg(11).A & mcsr.pmpcfg(11).X & mcsr.pmpcfg(11).W & mcsr.pmpcfg(11).R &
									mcsr.pmpcfg(10).L & "00" & mcsr.pmpcfg(10).A & mcsr.pmpcfg(10).X & mcsr.pmpcfg(10).W & mcsr.pmpcfg(10).R &
									mcsr.pmpcfg(9).L & "00" & mcsr.pmpcfg(9).A & mcsr.pmpcfg(9).X & mcsr.pmpcfg(9).W & mcsr.pmpcfg(9).R &
									mcsr.pmpcfg(8).L & "00" & mcsr.pmpcfg(8).A & mcsr.pmpcfg(8).X & mcsr.pmpcfg(8).W & mcsr.pmpcfg(8).R;
				when csr_pmpaddr0 =>
					csr_o.data <= X"00" & "00" & mcsr.pmpaddr(0)(53 downto 0);
				when csr_pmpaddr1 =>
					csr_o.data <= X"00" & "00" & mcsr.pmpaddr(1)(53 downto 0);
				when csr_pmpaddr2 =>
					csr_o.data <= X"00" & "00" & mcsr.pmpaddr(2)(53 downto 0);
				when csr_pmpaddr3 =>
					csr_o.data <= X"00" & "00" & mcsr.pmpaddr(3)(53 downto 0);
				when csr_pmpaddr4 =>
					csr_o.data <= X"00" & "00" & mcsr.pmpaddr(4)(53 downto 0);
				when csr_pmpaddr5 =>
					csr_o.data <= X"00" & "00" & mcsr.pmpaddr(5)(53 downto 0);
				when csr_pmpaddr6 =>
					csr_o.data <= X"00" & "00" & mcsr.pmpaddr(6)(53 downto 0);
				when csr_pmpaddr7 =>
					csr_o.data <= X"00" & "00" & mcsr.pmpaddr(7)(53 downto 0);
				when csr_pmpaddr8 =>
					csr_o.data <= X"00" & "00" & mcsr.pmpaddr(8)(53 downto 0);
				when csr_pmpaddr9 =>
					csr_o.data <= X"00" & "00" & mcsr.pmpaddr(9)(53 downto 0);
				when csr_pmpaddr10 =>
					csr_o.data <= X"00" & "00" & mcsr.pmpaddr(10)(53 downto 0);
				when csr_pmpaddr11 =>
					csr_o.data <= X"00" & "00" & mcsr.pmpaddr(11)(53 downto 0);
				when csr_pmpaddr12 =>
					csr_o.data <= X"00" & "00" & mcsr.pmpaddr(12)(53 downto 0);
				when csr_pmpaddr13 =>
					csr_o.data <= X"00" & "00" & mcsr.pmpaddr(13)(53 downto 0);
				when csr_pmpaddr14 =>
					csr_o.data <= X"00" & "00" & mcsr.pmpaddr(14)(53 downto 0);
				when csr_pmpaddr15 =>
					csr_o.data <= X"00" & "00" & mcsr.pmpaddr(15)(53 downto 0);
				when csr_ucycle =>
					csr_o.data <= mcsr.mcycle;
				when csr_uinstret =>
					csr_o.data <= mcsr.minstret;
				when csr_fcsr =>
					csr_o.data <= X"00000000000000" & ucsr.frm & ucsr.fflags;
				when csr_fflags =>
					csr_o.data <= X"00000000000000" & "000" & ucsr.fflags;
				when csr_frm =>
					csr_o.data <= X"000000000000000" & "0" & ucsr.frm;
				when others =>
					csr_o.data <= (others => '0');
			end case;

		else

			csr_o.data <= (others => '0');

		end if;

	end process;

	write_user_csr : process(clock)

	begin

		if rising_edge(clock) then

			if reset = '0' then

				ucsr <= init_csr_user_reg;

			else

				if (csr_ci.fpu and (csr_ci.fpu_op.fflag)) = '1' then
					ucsr.fflags <= csr_ci.flags;
				end if;

				if csr_wi.wren = '1' then

					case csr_wi.waddr is
						when csr_fcsr =>
							ucsr.frm <= csr_wi.wdata(7 downto 5);
							ucsr.fflags <= csr_wi.wdata(4 downto 0);
						when csr_fflags =>
							ucsr.fflags <= csr_wi.wdata(4 downto 0);
						when csr_frm =>
							ucsr.frm <= csr_wi.wdata(2 downto 0);
						when others => null;
					end case;

				end if;

			end if;

		end if;

	end process;

	process(clock)

	variable instr_valid : std_logic;

	begin

		if rising_edge(clock) then

			if reset = '0' then

				mcsr <= init_csr_machine_reg;

				priv_mode <= m_mode;

				exc  <= '0';
				mret <= '0';

			else

				instr_valid := csr_ci.int or csr_ci.fpu or csr_ci.csr;

				mcsr.mcycle <= std_logic_vector(unsigned(mcsr.mcycle) + 1);

				if instr_valid = '1' then
					mcsr.minstret <= std_logic_vector(unsigned(mcsr.minstret) + 1);
				end if;

				if csr_ei.time_irpt = '1' then
					mcsr.mip.mtip <= "1";
				else
					mcsr.mip.mtip <= "0";
				end if;

				if csr_ei.ext_irpt = '1' then
					mcsr.mip.meip <= "1";
				else
					mcsr.mip.meip <= "0";
				end if;

				if csr_ei.exc = '1' then
					mcsr.mstatus.mpie <= mcsr.mstatus.mie;
					mcsr.mstatus.mpp <= priv_mode;
					mcsr.mstatus.mie <= "0";
					priv_mode <= m_mode;
					mcsr.mepc <= csr_ei.epc;
					mcsr.mtval <= csr_ei.etval;
					mcsr.mcause.irpt <= "0";
					mcsr.mcause.code <= X"00000000000000" & "000" & csr_ei.ecause;
					exc <= '1';
				elsif mcsr.mstatus.mie = "1" and mcsr.mie.mtie = "1" and mcsr.mip.mtip = "1" then
					mcsr.mstatus.mpie <= mcsr.mstatus.mie;
					mcsr.mstatus.mpp <= priv_mode;
					mcsr.mstatus.mie <= "0";
					priv_mode <= m_mode;
					mcsr.mepc <= csr_ei.epc;
					mcsr.mtval <= X"0000000000000000";
					mcsr.mcause.irpt <= "1";
					mcsr.mcause.code <= X"00000000000000" & "000" & interrupt_mach_timer;
					exc <= '1';
				elsif mcsr.mstatus.mie = "1" and mcsr.mie.meie = "1" and mcsr.mip.meip = "1" then
					mcsr.mstatus.mpie <= mcsr.mstatus.mie;
					mcsr.mstatus.mpp <= priv_mode;
					mcsr.mstatus.mie <= "0";
					priv_mode <= m_mode;
					mcsr.mepc <= csr_ei.epc;
					mcsr.mtval <= X"0000000000000000";
					mcsr.mcause.irpt <= "1";
					mcsr.mcause.code <= X"00000000000000" & "000" & interrupt_mach_extern;
					exc <= '1';
				else
					exc <= '0';
				end if;

				if csr_ei.mret = '1' then
					priv_mode <= mcsr.mstatus.mpp;
					mcsr.mstatus.mie <= mcsr.mstatus.mpie;
					mcsr.mstatus.mpie <= "0";
					mcsr.mstatus.mpp <= u_mode;
					mret <= '1';
				else
					mret <= '0';
				end if;

				if csr_wi.wren = '1' then
					case csr_wi.waddr is
						when csr_mstatus =>
							mcsr.mstatus.sd   <= csr_wi.wdata(63 downto 63);
							mcsr.mstatus.mprv <= csr_wi.wdata(17 downto 17);
							mcsr.mstatus.fs   <= csr_wi.wdata(14 downto 13);
							if xor_reduce(csr_wi.wdata(12 downto 11)) = '0' then
								mcsr.mstatus.mpp  <= csr_wi.wdata(12 downto 11);
							end if;
							mcsr.mstatus.mpie <= csr_wi.wdata(7 downto 7);
							mcsr.mstatus.upie <= csr_wi.wdata(4 downto 4);
							mcsr.mstatus.mie  <= csr_wi.wdata(3 downto 3);
							mcsr.mstatus.uie  <= csr_wi.wdata(0 downto 0);
						when csr_mie =>
							mcsr.mie.meie <= csr_wi.wdata(11 downto 11);
							mcsr.mie.ueie <= csr_wi.wdata(8 downto 8);
							mcsr.mie.mtie <= csr_wi.wdata(7 downto 7);
							mcsr.mie.utie <= csr_wi.wdata(4 downto 4);
							mcsr.mie.msie <= csr_wi.wdata(3 downto 3);
							mcsr.mie.usie <= csr_wi.wdata(0 downto 0);
						when csr_mcause =>
							mcsr.mcause.irpt <= csr_wi.wdata(63 downto 63);
							mcsr.mcause.code <= csr_wi.wdata(62 downto 0);
						when csr_mtvec =>
							mcsr.mtvec.base <= csr_wi.wdata(63 downto 2);
							mcsr.mtvec.mode <= csr_wi.wdata(1 downto 0);
						when csr_mtval =>
							mcsr.mtval <= csr_wi.wdata;
						when csr_mepc =>
							mcsr.mepc <= csr_wi.wdata;
						when csr_mscratch =>
							mcsr.mscratch <= csr_wi.wdata;
						when csr_mideleg =>
							mcsr.mideleg <= csr_wi.wdata;
						when csr_medeleg =>
							mcsr.medeleg <= csr_wi.wdata;
						when csr_pmpcfg0 =>
							if mcsr.pmpcfg(7).L = "0" then
								mcsr.pmpcfg(7).L <= csr_wi.wdata(63 downto 63);
								mcsr.pmpcfg(7).A <= csr_wi.wdata(60 downto 59);
								mcsr.pmpcfg(7).X <= csr_wi.wdata(58 downto 58);
								mcsr.pmpcfg(7).W <= csr_wi.wdata(57 downto 57);
								mcsr.pmpcfg(7).R <= csr_wi.wdata(56 downto 56);
							end if;
							if mcsr.pmpcfg(6).L = "0" then
								mcsr.pmpcfg(6).L <= csr_wi.wdata(55 downto 55);
								mcsr.pmpcfg(6).A <= csr_wi.wdata(52 downto 51);
								mcsr.pmpcfg(6).X <= csr_wi.wdata(50 downto 50);
								mcsr.pmpcfg(6).W <= csr_wi.wdata(49 downto 49);
								mcsr.pmpcfg(6).R <= csr_wi.wdata(48 downto 48);
							end if;
							if mcsr.pmpcfg(5).L = "0" then
								mcsr.pmpcfg(5).L <= csr_wi.wdata(47 downto 47);
								mcsr.pmpcfg(5).A <= csr_wi.wdata(44 downto 43);
								mcsr.pmpcfg(5).X <= csr_wi.wdata(42 downto 42);
								mcsr.pmpcfg(5).W <= csr_wi.wdata(41 downto 41);
								mcsr.pmpcfg(5).R <= csr_wi.wdata(40 downto 40);
							end if;
							if mcsr.pmpcfg(4).L = "0" then
								mcsr.pmpcfg(4).L <= csr_wi.wdata(39 downto 39);
								mcsr.pmpcfg(4).A <= csr_wi.wdata(36 downto 35);
								mcsr.pmpcfg(4).X <= csr_wi.wdata(34 downto 34);
								mcsr.pmpcfg(4).W <= csr_wi.wdata(33 downto 33);
								mcsr.pmpcfg(4).R <= csr_wi.wdata(32 downto 32);
							end if;
							if mcsr.pmpcfg(3).L = "0" then
								mcsr.pmpcfg(3).L <= csr_wi.wdata(31 downto 31);
								mcsr.pmpcfg(3).A <= csr_wi.wdata(28 downto 27);
								mcsr.pmpcfg(3).X <= csr_wi.wdata(26 downto 26);
								mcsr.pmpcfg(3).W <= csr_wi.wdata(25 downto 25);
								mcsr.pmpcfg(3).R <= csr_wi.wdata(24 downto 24);
							end if;
							if mcsr.pmpcfg(2).L = "0" then
								mcsr.pmpcfg(2).L <= csr_wi.wdata(23 downto 23);
								mcsr.pmpcfg(2).A <= csr_wi.wdata(20 downto 19);
								mcsr.pmpcfg(2).X <= csr_wi.wdata(18 downto 18);
								mcsr.pmpcfg(2).W <= csr_wi.wdata(17 downto 17);
								mcsr.pmpcfg(2).R <= csr_wi.wdata(16 downto 16);
							end if;
							if mcsr.pmpcfg(1).L = "0" then
								mcsr.pmpcfg(1).L <= csr_wi.wdata(15 downto 15);
								mcsr.pmpcfg(1).A <= csr_wi.wdata(12 downto 11);
								mcsr.pmpcfg(1).X <= csr_wi.wdata(10 downto 10);
								mcsr.pmpcfg(1).W <= csr_wi.wdata(9 downto 9);
								mcsr.pmpcfg(1).R <= csr_wi.wdata(8 downto 8);
							end if;
							if mcsr.pmpcfg(0).L = "0" then
								mcsr.pmpcfg(0).L <= csr_wi.wdata(7 downto 7);
								mcsr.pmpcfg(0).A <= csr_wi.wdata(4 downto 3);
								mcsr.pmpcfg(0).X <= csr_wi.wdata(2 downto 2);
								mcsr.pmpcfg(0).W <= csr_wi.wdata(1 downto 1);
								mcsr.pmpcfg(0).R <= csr_wi.wdata(0 downto 0);
							end if;
						when csr_pmpcfg2 =>
							if mcsr.pmpcfg(15).L = "0" then
								mcsr.pmpcfg(15).L <= csr_wi.wdata(63 downto 63);
								mcsr.pmpcfg(15).A <= csr_wi.wdata(60 downto 59);
								mcsr.pmpcfg(15).X <= csr_wi.wdata(58 downto 58);
								mcsr.pmpcfg(15).W <= csr_wi.wdata(57 downto 57);
								mcsr.pmpcfg(15).R <= csr_wi.wdata(56 downto 56);
							end if;
							if mcsr.pmpcfg(14).L = "0" then
								mcsr.pmpcfg(14).L <= csr_wi.wdata(55 downto 55);
								mcsr.pmpcfg(14).A <= csr_wi.wdata(52 downto 51);
								mcsr.pmpcfg(14).X <= csr_wi.wdata(50 downto 50);
								mcsr.pmpcfg(14).W <= csr_wi.wdata(49 downto 49);
								mcsr.pmpcfg(14).R <= csr_wi.wdata(48 downto 48);
							end if;
							if mcsr.pmpcfg(13).L = "0" then
								mcsr.pmpcfg(13).L <= csr_wi.wdata(47 downto 47);
								mcsr.pmpcfg(13).A <= csr_wi.wdata(44 downto 43);
								mcsr.pmpcfg(13).X <= csr_wi.wdata(42 downto 42);
								mcsr.pmpcfg(13).W <= csr_wi.wdata(41 downto 41);
								mcsr.pmpcfg(13).R <= csr_wi.wdata(40 downto 40);
							end if;
							if mcsr.pmpcfg(12).L = "0" then
								mcsr.pmpcfg(12).L <= csr_wi.wdata(39 downto 39);
								mcsr.pmpcfg(12).A <= csr_wi.wdata(36 downto 35);
								mcsr.pmpcfg(12).X <= csr_wi.wdata(34 downto 34);
								mcsr.pmpcfg(12).W <= csr_wi.wdata(33 downto 33);
								mcsr.pmpcfg(12).R <= csr_wi.wdata(32 downto 32);
							end if;
							if mcsr.pmpcfg(11).L = "0" then
								mcsr.pmpcfg(11).L <= csr_wi.wdata(31 downto 31);
								mcsr.pmpcfg(11).A <= csr_wi.wdata(28 downto 27);
								mcsr.pmpcfg(11).X <= csr_wi.wdata(26 downto 26);
								mcsr.pmpcfg(11).W <= csr_wi.wdata(25 downto 25);
								mcsr.pmpcfg(11).R <= csr_wi.wdata(24 downto 24);
							end if;
							if mcsr.pmpcfg(10).L = "0" then
								mcsr.pmpcfg(10).L <= csr_wi.wdata(23 downto 23);
								mcsr.pmpcfg(10).A <= csr_wi.wdata(20 downto 19);
								mcsr.pmpcfg(10).X <= csr_wi.wdata(18 downto 18);
								mcsr.pmpcfg(10).W <= csr_wi.wdata(17 downto 17);
								mcsr.pmpcfg(10).R <= csr_wi.wdata(16 downto 16);
							end if;
							if mcsr.pmpcfg(9).L = "0" then
								mcsr.pmpcfg(9).L <= csr_wi.wdata(15 downto 15);
								mcsr.pmpcfg(9).A <= csr_wi.wdata(12 downto 11);
								mcsr.pmpcfg(9).X <= csr_wi.wdata(10 downto 10);
								mcsr.pmpcfg(9).W <= csr_wi.wdata(9 downto 9);
								mcsr.pmpcfg(9).R <= csr_wi.wdata(8 downto 8);
							end if;
							if mcsr.pmpcfg(8).L = "0" then
								mcsr.pmpcfg(8).L <= csr_wi.wdata(7 downto 7);
								mcsr.pmpcfg(8).A <= csr_wi.wdata(4 downto 3);
								mcsr.pmpcfg(8).X <= csr_wi.wdata(2 downto 2);
								mcsr.pmpcfg(8).W <= csr_wi.wdata(1 downto 1);
								mcsr.pmpcfg(8).R <= csr_wi.wdata(0 downto 0);
							end if;
						when csr_pmpaddr0 =>
							if mcsr.pmpcfg(0).L = "0" and mcsr.pmpcfg(1).A /= "01" then
								mcsr.pmpaddr(0)(53 downto 0) <= csr_wi.wdata(53 downto 0);
							end if;
						when csr_pmpaddr1 =>
							if mcsr.pmpcfg(1).L = "0" and mcsr.pmpcfg(2).A /= "01" then
								mcsr.pmpaddr(1)(53 downto 0) <= csr_wi.wdata(53 downto 0);
							end if;
						when csr_pmpaddr2 =>
							if mcsr.pmpcfg(2).L = "0" and mcsr.pmpcfg(3).A /= "01" then
								mcsr.pmpaddr(2)(53 downto 0) <= csr_wi.wdata(53 downto 0);
							end if;
						when csr_pmpaddr3 =>
							if mcsr.pmpcfg(3).L = "0" and mcsr.pmpcfg(4).A /= "01" then
								mcsr.pmpaddr(3)(53 downto 0) <= csr_wi.wdata(53 downto 0);
							end if;
						when csr_pmpaddr4 =>
							if mcsr.pmpcfg(4).L = "0" and mcsr.pmpcfg(5).A /= "01" then
								mcsr.pmpaddr(4)(53 downto 0) <= csr_wi.wdata(53 downto 0);
							end if;
						when csr_pmpaddr5 =>
							if mcsr.pmpcfg(5).L = "0" and mcsr.pmpcfg(6).A /= "01" then
								mcsr.pmpaddr(5)(53 downto 0) <= csr_wi.wdata(53 downto 0);
							end if;
						when csr_pmpaddr6 =>
							if mcsr.pmpcfg(6).L = "0" and mcsr.pmpcfg(7).A /= "01" then
								mcsr.pmpaddr(6)(53 downto 0) <= csr_wi.wdata(53 downto 0);
							end if;
						when csr_pmpaddr7 =>
							if mcsr.pmpcfg(7).L = "0" and mcsr.pmpcfg(8).A /= "01" then
								mcsr.pmpaddr(7)(53 downto 0) <= csr_wi.wdata(53 downto 0);
							end if;
						when csr_pmpaddr8 =>
							if mcsr.pmpcfg(8).L = "0" and mcsr.pmpcfg(9).A /= "01" then
								mcsr.pmpaddr(8)(53 downto 0) <= csr_wi.wdata(53 downto 0);
							end if;
						when csr_pmpaddr9 =>
							if mcsr.pmpcfg(9).L = "0" and mcsr.pmpcfg(10).A /= "01" then
								mcsr.pmpaddr(9)(53 downto 0) <= csr_wi.wdata(53 downto 0);
							end if;
						when csr_pmpaddr10 =>
							if mcsr.pmpcfg(10).L = "0" and mcsr.pmpcfg(11).A /= "01" then
								mcsr.pmpaddr(10)(53 downto 0) <= csr_wi.wdata(53 downto 0);
							end if;
						when csr_pmpaddr11 =>
							if mcsr.pmpcfg(11).L = "0" and mcsr.pmpcfg(12).A /= "01" then
								mcsr.pmpaddr(11)(53 downto 0) <= csr_wi.wdata(53 downto 0);
							end if;
						when csr_pmpaddr12 =>
							if mcsr.pmpcfg(12).L = "0" and mcsr.pmpcfg(13).A /= "01" then
								mcsr.pmpaddr(12)(53 downto 0) <= csr_wi.wdata(53 downto 0);
							end if;
						when csr_pmpaddr13 =>
							if mcsr.pmpcfg(13).L = "0" and mcsr.pmpcfg(14).A /= "01" then
								mcsr.pmpaddr(13)(53 downto 0) <= csr_wi.wdata(53 downto 0);
							end if;
						when csr_pmpaddr14 =>
							if mcsr.pmpcfg(14).L = "0" and mcsr.pmpcfg(15).A /= "01" then
								mcsr.pmpaddr(14)(53 downto 0) <= csr_wi.wdata(53 downto 0);
							end if;
						when csr_pmpaddr15 =>
							if mcsr.pmpcfg(15).L = "0" then
								mcsr.pmpaddr(15)(53 downto 0) <= csr_wi.wdata(53 downto 0);
							end if;
						when others => null;
					end case;
				end if;

			end if;

		end if;

	end process;

end architecture;
