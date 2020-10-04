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
bram_mem_depth = 2**13
while line_in:
    byte0 = "x\""+ line_in[0:2] + "\""
    byte1 = "x\""+ line_in[2:4] + "\""
    byte2 = "x\""+ line_in[4:6] + "\""
    byte3 = "x\""+ line_in[6:8] + "\""
    byte4 = "x\""+ line_in[8:10] + "\""
    byte5 = "x\""+ line_in[10:12] + "\""
    byte6 = "x\""+ line_in[12:14] + "\""
    byte7 = "x\""+ line_in[14:16] + "\""
    if cnt < bram_mem_depth:
        line_out = "\t\t("+ byte7 + "," + byte6 + "," + byte5 + "," + byte4 + "," \
                        + byte3 + "," + byte2 + "," + byte1 + "," + byte0 + "),\n"
        file_out_vhd.writelines(line_out)
    else:
        line_out = "\t\t("+ byte7 + "," + byte6 + "," + byte5 + "," + byte4 + "," \
                        + byte3 + "," + byte2 + "," + byte1 + "," + byte0 + ")\n"
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
