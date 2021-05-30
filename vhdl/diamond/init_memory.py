#!/usr/bin/env python

file_in_vhd = open('bram_mem.vhd.init','r')
file_out_vhd = open('bram_mem.vhd','w')

for i in range(0,8):
    file_mem = open('../../sim/work/bram_mem.dat','r')
    line_in = file_in_vhd.readline()
    while line_in:
        file_out_vhd.writelines(line_in)
        line_in = file_in_vhd.readline()
        if ('signal memory_block_' + str(i) + ' : memory_type := (') in line_in:
            file_out_vhd.writelines(line_in)
            break

    cnt = 1
    cont = 1;
    bram_mem_depth = 2**10
    while cont:
        line_out = "\t\t"
        for j in range(0,16):
            line_in = file_mem.readline()
            line_out = line_out + "x\""+ line_in[14-2*i:16-2*i] + "\""
            if not line_in or cnt == bram_mem_depth:
                cont = 0
                break
            else:
                line_out = line_out + ","
            cnt = cnt + 1
        line_out = line_out + "\n"
        file_out_vhd.writelines(line_out)
    file_mem.close();

line_in = file_in_vhd.readline()
while line_in:
    file_out_vhd.writelines(line_in)
    line_in = file_in_vhd.readline()

file_in_vhd.close();
file_out_vhd.close();
