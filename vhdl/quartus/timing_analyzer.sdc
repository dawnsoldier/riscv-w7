create_clock -name "clk" -period 40.000ns [get_ports {clk}]
derive_pll_clocks
derive_clock_uncertainty
