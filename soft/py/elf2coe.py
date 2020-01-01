#!/usr/bin/env python

import binascii
import sys
import subprocess
import os
from os.path import basename


if __name__ == '__main__':

    if len(sys.argv) < 5:
        print('Expected usage: {0} <filename> <start_address> <offset> <path>'.format(sys.argv[0]))
        sys.exit(1)

    filename = sys.argv[1]
    bin_file = '{0}/elf/{1}.bin'.format(sys.argv[4],os.path.splitext(basename(sys.argv[1]))[0])
    coe_file = '{0}/coe/{1}.coe'.format(sys.argv[4],os.path.splitext(basename(sys.argv[1]))[0])
    start_address = int(sys.argv[2],16)
    offset = int(sys.argv[3],16)

    print(coe_file)

    with open(bin_file, 'rb') as f:
        content = f.read()

    output = open(coe_file, 'wb')

    lines = len(content)

    output.writelines("memory_initialization_radix=16;\n")
    output.writelines("memory_initialization_vector=\n")

    address = 0
    while address < offset:
        if address < start_address:
            string0 = "00"
            string1 = "00"
            string2 = "00"
            string3 = "00"
            string4 = "00"
            string5 = "00"
            string6 = "00"
            string7 = "00"
        elif address-start_address < lines:
            if (address-start_address+7) < lines:
                string0 = str(binascii.hexlify(content[address-start_address+7])).upper()
            else:
                string0 = "00"
            if (address-start_address+6) < lines:
                string1 = str(binascii.hexlify(content[address-start_address+6])).upper()
            else:
                string1 = "00"
            if (address-start_address+5) < lines:
                string2 = str(binascii.hexlify(content[address-start_address+5])).upper()
            else:
                string2 = "00"
            if (address-start_address+4) < lines:
                string3 = str(binascii.hexlify(content[address-start_address+4])).upper()
            else:
                string3 = "00"
            if (address-start_address+3) < lines:
                string4 = str(binascii.hexlify(content[address-start_address+3])).upper()
            else:
                string4 = "00"
            if (address-start_address+2) < lines:
                string5 = str(binascii.hexlify(content[address-start_address+2])).upper()
            else:
                string5 = "00"
            if (address-start_address+1) < lines:
                string6 = str(binascii.hexlify(content[address-start_address+1])).upper()
            else:
                string6 = "00"
            if (address-start_address+0) < lines:
                string7 = str(binascii.hexlify(content[address-start_address+0])).upper()
            else:
                string7 = "00"
        else:
            string0 = "00"
            string1 = "00"
            string2 = "00"
            string3 = "00"
            string4 = "00"
            string5 = "00"
            string6 = "00"
            string7 = "00"
        if address<(offset-8):
            string = string0 + string1 + string2 + string3 + string4 + string5 + string6 + string7 + ",\n"
        else:
            string = string0 + string1 + string2 + string3 + string4 + string5 + string6 + string7 + ";"
        output.writelines(string)
        address = address + 8

    output.close()
