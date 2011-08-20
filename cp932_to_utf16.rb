#!/usr/bin/env ruby1.9

def decode(cp932)
#  return -1 if (0xf040 <= cp932 && cp932 <= 0xf9fc) # cp932 private use area
  
  if (cp932 < 0x100)
    inbuf = sprintf("%c", cp932 & 0xff)
  else
    inbuf = sprintf("%c%c", (cp932 >> 8) & 0xff, cp932 & 0xff)
  end
  unicode = 0
  begin
    outbuf = inbuf.force_encoding("CP932").encode("UTF-16BE")
    return -1 if outbuf.length != 1
    outbuf.each_byte{|p|
      unicode = (unicode << 8) | p
    }
  rescue
    unicode = -1
  end
  return unicode
end

def main()
  (0..0xffff).each{|cp932|
    unicode = decode(cp932)
    if (0 <= unicode)
      if (cp932 < 0x100)
        printf("0x%02X\t", cp932)
      else
        printf("0x%04X\t", cp932)
      end
      printf("0x%04X\n", unicode)
    end
  }
end

main()
