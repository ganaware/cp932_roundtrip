#!/usr/bin/env python3
import sys
import codecs

def decode(cp932):
#    if (0xf040 <= cp932 and cp932 <= 0xf9fc): # cp932 private use area
#        return -1
    if (cp932 < 0x100):
        inbuf = bytes([(cp932 & 0xff)])
    else:
        inbuf = bytes([(cp932 >> 8) & 0xff, cp932 & 0xff])

    try:
        outbuf = inbuf.decode("CP932")
    except UnicodeDecodeError:
        return -1
    if len(outbuf) != 1:
        return -1
    return ord(outbuf)

def main():
    for cp932 in range(0, 0xffff + 1):
        unicode_ = decode(cp932)
        if (0 <= unicode_):
            if (cp932 < 0x100):
                sys.stdout.write("0x%02X\t" % cp932)
            else:
                sys.stdout.write("0x%04X\t" % cp932)
            sys.stdout.write("0x%04X\n" % unicode_)

main()
