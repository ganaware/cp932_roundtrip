#!/usr/bin/ruby
require "cgi"
require "date"

$uni_to_name = Array.new(0x10000, "")
open("UnicodeData.txt"){|file|
  first = -1
  file.each_line{|line|
    data = line.split(';')
    unicode = data[0].hex
    next unless 0 <= unicode && unicode <= 0xffff
    name = data[1]
    if name =~ /^<(.*),\s*First>$/
      first = unicode
    elsif name =~ /^<(.*),\s*Last>$/
      last = unicode
      name = "<#{$1}>"
      (first..last).each{|unicode| $uni_to_name[unicode] = name }
    else
      $uni_to_name[unicode] = name
    end
  }
}

class UniToCp932
  def initialize(name, filename, src, extra_class)
    @name = name
    @src = src
    @extra_class = (extra_class ? " " + extra_class : "")
    @to_cp932 = Array.new(0x10000, -1)
    open(filename){|file|
      file.each_line{|line|
        if line =~ /^0x([0-9a-z]+)\t0x([0-9a-z]+)\s*$/i
          unicode = $1.hex
          cp932 = $2.hex
          @to_cp932[unicode] = cp932
        end
      }
    }
  end
  attr_reader :name
  attr_reader :src
  attr_reader :extra_class
  attr_reader :to_cp932
end

$uni_to_cp932 =
  [
   UniToCp932.new("Win32<br>with<br>WC_NO_<br>BEST_<br>FIT_<br>CHARS",
                  "result/utf16_to_cp932-win32_wnbfc-windows7.txt",
                  "utf16_to_cp932-win32.cpp",
                  nil),
   UniToCp932.new("Win32<br>without<br>WC_NO_<br>BEST_<br>FIT_<br>CHARS",
                  "result/utf16_to_cp932-win32-windows7.txt",
                  "utf16_to_cp932-win32.cpp",
                  "reference-end"),
   UniToCp932.new("Perl<br>5.14.1",
                  "result/utf16_to_cp932-perl_5.14.1-osx_10.7.1.txt",
                  "utf16_to_cp932.pl",
                  nil),
   UniToCp932.new("Ruby<br>1.9.2<br>p290",
                  "result/utf16_to_cp932-ruby_1.9.2p290-osx_10.7.1.txt",
                  "utf16_to_cp932.rb",
                  nil),
   UniToCp932.new("eglibc<br>2.10.1",
                  "result/utf16_to_cp932-eglibc_2.10.1-ubuntu_9.10.txt",
                  "utf16_to_cp932-libiconv.cpp",
                  nil),
   UniToCp932.new("glibc<br>2.7",
                  "result/utf16_to_cp932-glibc_2.7-ubuntu_8.04_japanese.txt",
                  "utf16_to_cp932-libiconv.cpp",
                  nil),
   UniToCp932.new("Java<br>1.6.0<br>_26",
                  "result/utf16_to_cp932-java_1.6.0_26-osx_10.7.1.txt",
                  "utf16_to_cp932.java",
                  nil),
   UniToCp932.new("libiconv<br>1.13.1<br>+<br><a href=\"http://www2d.biglobe.ne.jp/~msyk/software/libiconv-1.13-cp932-patch.html\">cp932<br>patch</a>",
                  "result/utf16_to_cp932-libiconv_1.13.1_0+enable_cp932fix-macports_1.8.2.txt",
                  "utf16_to_cp932-libiconv.cpp",
                  nil),
   UniToCp932.new("apr-<br>iconv<br>1.2.1<br>+<br><a href=\"apr-iconv-1.2.1-cp932-patch.txt\">cp932<br>patch</a>",
                  "result/utf16_to_cp932-apriconv_1.2.1+cp932_patch.txt",
                  "utf16_to_cp932-apriconv.cpp",
                  nil),
   UniToCp932.new("apr-<br>iconv<br>1.2.1<br>+<br><a href=\"apr-iconv-1.2.1-cp932-patch2.txt\">cp932<br>patch2</a>",
                  "result/utf16_to_cp932-apriconv_1.2.1+cp932_patch2.txt",
                  "utf16_to_cp932-apriconv.cpp",
                  nil),
   UniToCp932.new("Python<br>2.7.2<br>+<br><a href=\"Python-2.7.2-cp932-patch.txt\">cp932<br>patch</a>",
                  "result/utf16_to_cp932-python_2.7.2+cp932_patch.txt",
                  "utf16_to_cp932.py",
                  nil),
   UniToCp932.new("Python<br>2.7.2<br>+<br><a href=\"Python-2.7.2-cp932-patch2.txt\">cp932<br>patch2</a>",
                  "result/utf16_to_cp932-python_2.7.2+cp932_patch2.txt",
                  "utf16_to_cp932.py",
                  nil),
   UniToCp932.new("PHP<br>5.3.6<br>(mb_<br>convert)",
                  "result/utf16_to_cp932-php_5.3.6-osx_10.7.1.txt",
                  "utf16_to_cp932.php",
                  nil),
   UniToCp932.new("libiconv<br>1.13.1",
                  "result/utf16_to_cp932-libiconv_1.13.1_0-macports_1.8.2.txt",
                  "utf16_to_cp932-libiconv.cpp",
                  " invalid-begin"),
   UniToCp932.new("apr-<br>iconv<br>1.2.1",
                  "result/utf16_to_cp932-apriconv_1.2.1.txt",
                  "utf16_to_cp932-apriconv.cpp",
                  nil),
   UniToCp932.new("Python<br>2.7.2",
                  "result/utf16_to_cp932-python_2.7.2-osx_10.7.1.txt",
                  "utf16_to_cp932.py",
                  nil),
  ]

class Cp932ToUni
  def initialize(name, filename, src, extra_class)
    @name = name
    @src = src
    @extra_class = (extra_class ? " " + extra_class : "")
    @to_uni = Array.new(0x10000, -1)
    open(filename){|file|
      file.each_line{|line|
        if line =~ /^0x([0-9a-z]+)\t0x([0-9a-z]+)\s*$/i
          cp932 = $1.hex
          unicode = $2.hex
          @to_uni[cp932] = unicode
        end
      }
    }
  end
  attr_reader :name
  attr_reader :src
  attr_reader :extra_class
  attr_reader :to_uni
end

$cp932_to_uni =
  [
   Cp932ToUni.new("Win32",
                  "result/cp932_to_utf16-win32-windows7.txt",
                  "cp932_to_utf16-win32.cpp",
                  "reference-end"),
   Cp932ToUni.new("Perl<br>5.14.1",
                  "result/cp932_to_utf16-perl_5.14.1-osx_10.7.1.txt",
                  "cp932_to_utf16.pl",
                  nil),
   Cp932ToUni.new("Ruby<br>1.9.2<br>p290",
                  "result/cp932_to_utf16-ruby_1.9.2p290-osx_10.7.1.txt",
                  "cp932_to_utf16.rb",
                  nil),
   Cp932ToUni.new("eglibc<br>2.10.1",
                  "result/cp932_to_utf16-eglibc_2.10.1-ubuntu_9.10.txt",
                  "cp932_to_utf16-libiconv.cpp",
                  nil),
   Cp932ToUni.new("glibc<br>2.7",
                  "result/cp932_to_utf16-glibc_2.7-ubuntu_8.04_japanese.txt",
                  "cp932_to_utf16-libiconv.cpp",
                  nil),
   Cp932ToUni.new("Java<br>1.6.0<br>_26",
                  "result/cp932_to_utf16-java_1.6.0_26-osx_10.7.1.txt",
                  "cp932_to_utf16.java",
                  nil),
   Cp932ToUni.new("libiconv<br>1.13.1<br>+<br><a href=\"http://www2d.biglobe.ne.jp/~msyk/software/libiconv-1.13-cp932-patch.html\">cp932<br>patch</a>",
                  "result/cp932_to_utf16-libiconv_1.13.1_0+enable_cp932fix-macports_1.8.2.txt",
                  "cp932_to_utf16-libiconv.cpp",
                  nil),
   Cp932ToUni.new("apr-<br>iconv<br>1.2.1<br>+<br><a href=\"apr-iconv-1.2.1-cp932-patch.txt\">cp932<br>patch</a>",
                  "result/cp932_to_utf16-apriconv_1.2.1+cp932_patch.txt",
                  "cp932_to_utf16-apriconv.cpp",
                  nil),
   Cp932ToUni.new("apr-<br>iconv<br>1.2.1<br>+<br><a href=\"apr-iconv-1.2.1-cp932-patch2.txt\">cp932<br>patch2</a>",
                  "result/cp932_to_utf16-apriconv_1.2.1+cp932_patch2.txt",
                  "cp932_to_utf16-apriconv.cpp",
                  nil),
   Cp932ToUni.new("PHP<br>5.3.6<br>(mb_<br>convert)",
                  "result/cp932_to_utf16-php_5.3.6-osx_10.7.1.txt",
                  "cp932_to_utf16.php",
                  nil),
   Cp932ToUni.new("libiconv<br>1.13.1",
                  "result/cp932_to_utf16-libiconv_1.13.1_0-macports_1.8.2.txt",
                  "cp932_to_utf16-libiconv.cpp",
                  nil),
   Cp932ToUni.new("apr-<br>iconv<br>1.2.1",
                  "result/cp932_to_utf16-apriconv_1.2.1.txt",
                  "cp932_to_utf16-apriconv.cpp",
                  nil),
   Cp932ToUni.new("Python<br>2.7.2",
                  "result/cp932_to_utf16-python_2.7.2-osx_10.7.1.txt",
                  "cp932_to_utf16.py",
                  nil),
  ]

def isNECSpecialCharacters(cp932)
  return 0x8740 <= cp932 && cp932 <= 0x879c
end

def isNECSelectionOfIBMExtensions(cp932)
  return 0xed40 <= cp932 && cp932 <= 0xeefc
end

def isIBMExtensions(cp932)
  return 0xfa40 <= cp932 && cp932 <= 0xfc4b
end

def getCP932Class(cp932)
  c = "cp932"
  c = c + " nec" if isNECSpecialCharacters(cp932)
  c = c + " nec-ibm" if isNECSelectionOfIBMExtensions(cp932)
  c = c + " ibm" if isIBMExtensions(cp932)
  c = c + " private-use-area" if 0xf040 <= cp932 && cp932 <= 0xf9fc
  return c
end

def getUniClass(uni)
  c = "unicode"
  c = c + " private-use-area" if 0xe000 <= uni && uni <= 0xf8ff
  return c
end

def printUniToCP932Header()
  printf("      <tr><th></th><th></th>")
  $uni_to_cp932.each_with_index{|i, index|
    printf("<th class=\"app%s\">%s</th>", i.extra_class, i.name)
  }
  printf("<th></th></tr>\n")
end

def printCP932ToUniHeader()
  printf("      <tr><th></th>")
  $cp932_to_uni.each_with_index{|i, index|
    printf("<th class=\"app%s\" colspan=\"2\">%s</th>", i.extra_class, i.name)
  }
  printf("</tr>\n")
end

printf("<html>\n")
printf("  <head>\n")
printf("    <title>CP932-Unicode round trip conversion differences</title>\n")
printf("    <link rel=\"stylesheet\" type=\"text/css\" href=\"cp932_roundtrip.css\" />\n")
printf("  </head>\n")
printf("  <body>\n")
printf("    <p class=\"header\">Download: <a href=\"http://dl.dropbox.com/u/1340991/cp932_roundtrip/cp932_roundtrip.tar.bz2\">cp932_roundtrip.tar.bz2</a>\n")
printf("    <p class=\"header\">ganaware at gmail dot com</p>\n")
printf("    <p class=\"header\">%s</p>\n", Date.today.strftime("%F"))
printf("    <h1>CP932-Unicode round trip conversion differences</h1>\n")
printf("    <h2>Differences (Unicode to CP932)</h2>\n")
print "    <table id=\"unicode-to-cp932\">\n"
printUniToCP932Header()
(0..0xffff).each{|uni|
  cur = Array.new
  all_same = true
  prev = 0
  $uni_to_cp932.each_with_index{|i, index|
    cur[index] = i.to_cp932[uni]
    all_same = false if 0 < index && cur[index] != prev
    prev = cur[index]
  }
  next if all_same
  
  if 0xe000 < uni && uni < 0xe757
    if uni == 0xe001
      printf("      <tr><td colspan=\"%d\" class=\"private-use-area\">(snip private use characters)</td></tr>\n",
             cur.size + 3)
    end
    next
  end
  
  printf("      <tr>")
  printf("<th class=\"%s\">U+%04X</th>", getUniClass(uni), uni)
  printf("<td class=\"char\">&#x%04X;</td>", uni)
  cur.each_with_index{|cp932, index|
    i = $uni_to_cp932[index]
    ne_reference = (cur[0] != cp932) ? " ne-reference" : ""
    if cp932 < 0
      printf("<td class=\"noconv%s%s\">-</td>", ne_reference, i.extra_class)
    else
      w = (cp932 < 0x100) ? "02" : "04"
      printf("<td class=\"%s%s%s\">%#{w}X</td>",
             getCP932Class(cp932), ne_reference, i.extra_class, cp932)
    end
  }
  printf("<td class=\"name\">%s</td></td>", CGI.escapeHTML($uni_to_name[uni]))
  printf("</tr>\n")
}
printUniToCP932Header()
printf("    </table>\n")
printf("    <table>\n")
printf("      <tr><th colspan=\"2\">legend</th></tr>\n")
printf("      <tr><td class=\"nec\">NEC special characters</td><td class=\"cp932\">8740-879C</td></tr>\n")
printf("      <tr><td class=\"nec-ibm\">NEC selection of IBM extensions</td><td class=\"cp932\">ED40-EEFC</td></tr>\n")
printf("      <tr><td class=\"ibm\">IBM extensions</td><td class=\"cp932\">FA40-FC4B</td></tr>\n")
printf("      <tr><td class=\"private-use-area\">Private Use Area</td><td class=\"cp932\">F040-F9FC</td></tr>\n")
printf("      <tr><td class=\"ne-reference\" colspan=\"2\">red text: conversion not equal to that of Win32</td></tr>\n")
printf("    </table>\n")

printf("    <h2>Differences (CP932 to Unicode)</h2>\n")
printf("    <table id=\"cp932-to-unicode\">\n")
printCP932ToUniHeader()
(0..0xffff).each{|cp932|
  cur = Array.new
  all_same = true
  prev = 0
  $cp932_to_uni.each_with_index{|i, index|
    cur[index] = i.to_uni[cp932]
    all_same = false if 0 < index && cur[index] != prev
    prev = cur[index]
  }
  next if all_same
  
  if 0xf040 < cp932 && cp932 < 0xf9fc
    if cp932 == 0xf041
      printf("      <tr><td colspan=\"%d\" class=\"private-use-area\">(snip private use characters)</td></tr>\n",
             cur.size * 2 + 1)
    end
    next
  end
  
  printf("      <tr>")
  w = (cp932 < 0x100) ? "02" : "04"
  printf("<th class=\"%s\">%#{w}X</th>", getCP932Class(cp932), cp932)
  cur.each_with_index{|uni, index|
    i = $cp932_to_uni[index]
    ne_reference = (cur[0] != uni) ? " ne-reference" : ""
    title =  CGI.escapeHTML($uni_to_name[uni])
    if uni < 0
      printf("<td class=\"noconv%s%s\" colspan=\"2\">-</td>",
             i.extra_class, ne_reference)
    else
      printf("<td class=\"%s%s%s\" title=\"%s\">U+%04X</td>",
             getUniClass(uni), i.extra_class, ne_reference, title, uni)
      if uni == 0
        printf("<td class=\"char%s%s\"></td>", i.extra_class, ne_reference)
      else
        printf("<td class=\"char%s%s\" title=\"%s\">&#x%04X;</td>",
               i.extra_class, ne_reference, title, uni)
      end
    end
  }
  printf("</tr>\n")
}
printCP932ToUniHeader()
printf("    </table>\n")
printf("    <table>\n")
printf("      <tr><th colspan=\"2\">legend</th></tr>\n")
printf("      <tr><td class=\"private-use-area\">Private Use Area</td><td class=\"unicode\">U+E000-U+F8FF</td></tr>\n")
printf("      <tr><td class=\"ne-reference\" colspan=\"2\">red text: conversion not equal to that of Win32</td></tr>\n")
printf("    </table>\n")
printf("  </html>\n")
printf("</body>\n")

open("gen.html"){|file|
  file.each_line{|line|
    print(line)
  }
}
