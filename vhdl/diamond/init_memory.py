#!/usr/bin/env python

file_in_vhd = open('bram_mem.vhd.init','r')
file_out_vhd = open('bram_mem.vhd','w')
file_mem = open('../../sim/work/bram_mem.dat','r')

line_in = file_in_vhd.readline()
while line_in:
    file_out_vhd.writelines(line_in)
    line_in = file_in_vhd.readline()
    if 'signal memory_block : memory_type := (' in line_in:
        file_out_vhd.writelines(line_in)
        break

line_in = file_mem.readline()
cnt = 1
bram_mem_depth = 2**10
while line_in:
    if cnt < bram_mem_depth:
        line_out = "\t\t"+ "x\""+ line_in[0:16] + "\"" + ",\n"
        file_out_vhd.writelines(line_out)
    else:
        line_out = "\t\t"+ "x\""+ line_in[0:16] + "\"" + "\n"
        file_out_vhd.writelines(line_out)
        break
    line_in = file_mem.readline()
    cnt = cnt + 1

line_in = file_in_vhd.readline()
while line_in:
    file_out_vhd.writelines(line_in)
    line_in = file_in_vhd.readline()

file_in_vhd.close();
file_out_vhd.close();
file_mem.close();
