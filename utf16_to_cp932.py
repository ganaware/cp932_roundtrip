#!/usr/bin/env python
import sys
import codecs

def encode(unicode):
    if (#(0xe000 <= unicode and unicode <= 0xf8ff) or # private use area
        (0xd800 <= unicode and unicode <= 0xdbff) or # high surrogate area
        (0xdc00 <= unicode and unicode <= 0xdfff)):   # low surrogate area
        return -1
    
    cp932 = 0
    try:
        for p in (u"%c" % unicode).encode("CP932"):
            cp932 = (cp932 << 8) | ord(p)
        return cp932
    except UnicodeEncodeError:
        return -1

def main():
    for unicode in range(0, 0xffff + 1):
        cp932 = encode(unicode)
        if (0 < cp932):
            sys.stdout.write("0x%04X\t0x" % unicode)
            if (cp932 < 0x100):
                sys.stdout.write("%02X" % cp932)
            else:
                sys.stdout.write("%04X" % cp932)
            sys.stdout.write("\n");

main()
