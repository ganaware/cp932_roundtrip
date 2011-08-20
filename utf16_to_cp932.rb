#!/usr/bin/env ruby1.9

def encode(unicode)
  if (#(0xe000 <= unicode && unicode <= 0xf8ff) || # private use area
      (0xd800 <= unicode && unicode <= 0xdbff) || # high surrogate area
      (0xdc00 <= unicode && unicode <= 0xdfff))   # low surrogate area
    return -1
  end

  cp932 = 0
  begin
    sprintf("%c%c", (unicode >> 8) & 0xff, unicode & 0xff).
      force_encoding("UTF-16BE").encode("CP932").each_byte{|p|
      cp932 = (cp932 << 8) | p
    }
  rescue
    cp932 = -1
  end
  return cp932
end

def main()
  (0..0xffff).each{|unicode|
    cp932 = encode(unicode)
    if (0 < cp932)
      printf("0x%04X\t0x", unicode)
      printf((cp932 < 0x100) ? "%02X" : "%04X", cp932)
      printf("\n")
    end
  }
end

main()
