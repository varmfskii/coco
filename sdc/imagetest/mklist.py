#!/bin/env python3
import sys

inname = sys.argv[1]
outname = sys.argv[2]
try:
    fin = open(inname, 'r')
    fout = open(outname, 'wb')
except IOError as ie:
    print(ie)
else:
    line = fin.readline().rstrip()
    while line:
        fout.write(line.upper().encode())
        fout.write(b'\0')
        line = fin.readline().rstrip()
        
    fin.close()
    fout.write(b'\0')
    fout.close()
