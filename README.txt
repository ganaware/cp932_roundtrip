                CP932-Unicode round trip conversion differences

                                                ganaware at gmail dot com

* はじめに

    文字列を CP932 から UNICODE へ、UNICODE から CP932 へ変換する必要が
    しばしば生じますが、その変換テーブルは各々の言語やライブラリでかな
    り異なっています。

    そこで、実際にどの程度異なっているのかをまず調査してみることにしま
    した。

* CP932 から UNICODE

    - 最も問題なのはパッチを当てていない libiconv で、以下の6文字の変換
      が一般的ではありません。
      (パッチ: http://www2d.biglobe.ne.jp/~msyk/software/libiconv-patch.html)

        8160→U+301C 〜
        8161→U+2016 ‖
        817C→U+2212 −
        8191→U+00A2 ¢ 
        8192→U+00A3 £ 
        81CA→U+00AC ¬

    - パッチを当てていない libiconv 以外では、次のような変換になります。

        8160→U+FF5E ～
        8161→U+2225 ∥
        817C→U+FF0D －
        8191→U+FFE0 ￠
        8192→U+FFE1 ￡
        81CA→U+FFE2 ￢

    - Windows と Perl と Python では 80→U+0080 という変換をしますが、
      Ruby, eglibc, glibc, Java, libiconv, apr-iconv では行いません。
      U+0080 は未定義の文字ですが Windows と OSX ではユーロのグリフが割
      り当てられています。

    - Perl と Python では A0→U+F8F0, FD→U+F8F1, FE→U+F8F2, FF→
      U+F8F3 という、未定義の文字 4 文字を Private Use Area の文字へ変
      換しています。OSX ではこの 4 文字に括弧のようなグリフが割り当てら
      れています。

    - APR-iconv は CP932 の外字を Private Use Area の文字へ変換しません。

    - Windows の MultiByteToWideChar() はなぜか 00 を U+0000 へ変換して
      くれません。

* UNICODE から CP932

    - Perl は Windows の WideCharToMultiByte() に WC_NO_BEST_FIT_CHARS
      フラグを渡したものと、完全に一致する変換をします。

    - U+0000 から U+00FF までの変換は、変換を行うか行わないかの違いはあ
      りますが、各々の言語やライブラリで異なる文字へ変換されることはあ
      りません。

    - Python は NEC 選定 IBM 拡張文字に含まれる IBM 拡張文字を、NEC 選
      定 IBM 拡張文字へ変換する傾向があります。

    - パッチを当てていない iconv と APR-iconv は、NEC 特殊文字と IBM 拡
      張文字の両方に存在する文字を、IBM 拡張文字へ変換する傾向がありま
      す。

    - APR-iconv は JIS X 0208 と NEC 特殊文字の両方に存在する文字を
      NEC 特殊文字へ変換する傾向があります。
    
    - APR-iconv は Private Use Area の文字 を CP932 の外字へ変換しません。

    - Windows と Perl と Python では U+F8F0→A0, U+F8F1→FD, U+F8F2→
      FE , U+F8F3→FF という、Private Use Area の文字を未定義の文字 4
      文字へ変換しています。OSX ではこの 4 文字に括弧のようなグリフが割
      り当てられています。

* 参考文献

    - シフトJIS / EUC-JPとUnicodeとの妥当な変換表
      http://www.nslabs.jp/round-trip.rhtml
    - [PRB] SHIFT - JIS と Unicode 間の変換問題
      http://support.microsoft.com/default.aspx?scid=kb;ja;JP170559
    - libiconv-1.13-cp932.patch.gz
      http://www2d.biglobe.ne.jp/~msyk/software/libiconv-1.13-cp932-patch.html

* コンパイル/実行方法

    各変換テーブルは、各々の言語やライブラリで実際に変換してみた結果か
    ら作成しました。

    (1) C++ (Win32)

        *-win32.cpp は Visual C++ 2008 の cl でコンパイルします。

            C:\> cl cp932_to_utf16-win32.cpp
            C:\> .\cp932_to_utf16-win32.exe
            C:\> cl utf16_to_cp932-win32.cpp
            C:\> .\utf16_to_cp932-win32.exe

        WideCharToMultiByte に WC_NO_BEST_FIT_CHARS フラグを渡した時の
        変換テーブルを得たい場合は、--wnbfc オプションを指定します。
        
            C:\> .\utf16_to_cp932-win32.exe --wnbfc

        Cygwin の g++ でもコンパイル可能です。

            $ g++ cp932_to_utf16-win32.cpp && ./a.exe
            $ g++ utf16_to_cp932-win32.cpp && ./a.exe ; ./a.exe --wnbfc

    (2) C++ (libiconv, glibc, eglibc)

        *-libiconv.cpp を libiconv を利用するシステムでコンパイルする為
        には -liconv オプションが必要です。

            $ g++ cp932_to_utf16-libiconv.cpp -liconv && ./a.out
            $ g++ utf16_to_cp932-libiconv.cpp -liconv && ./a.out
        
        ただし、glibc や eglibc を利用するシステム (Linux など) では必
        要ありません。

            $ g++ cp932_to_utf16-libiconv.cpp && ./a.out
            $ g++ utf16_to_cp932-libiconv.cpp && ./a.out
        
    (3) C++ (APR-iconv)

        *-apriconv.cpp をコンパイルするのはやや大変です。APR (Apache
        Portable Runtime) と、APR-iconv を適切にインストールした上で、
        様々なオプションを渡す必要があります。例えば次のような感じにな
        ります。

            $ g++ -I/opt/local/include/apr-1/ \
                -L/opt/local/lib/ -lapriconv-1 -lapr-1 \
                utf16_to_cp932-apriconv.cpp && ./a.out
            $ g++ -I/opt/local/include/apr-1/ \
                -L/opt/local/lib/ -lapriconv-1 -lapr-1 \
                cp932_to_utf16-apriconv.cpp && ./a.out

    (4) Java

        ある程度新しめの Java を使用しておけば、特に注意する点はありません。

            $ javac cp932_to_utf16.java && java cp932_to_utf16
            $ javac utf16_to_cp932.java && java utf16_to_cp932

    (5) Ruby

        Ruby 1.9.1 以降が必要です。

        Ruby 1.8.x しか入っていない、あるいは 1.8 系統と 1.9 系統が同居
        していることが多いのでバージョンに注意する必要があります。

            $ ruby1.9 cp932_to_utf16.rb
            $ ruby1.9 utf16_to_cp932.rb

    (6) Python
    
        特に注意する点はありません。

            $ ./cp932_to_utf16.py
            $ ./utf16_to_cp932.py

    (7) Perl
    
        特に注意する点はありません。

            $ ./cp932_to_utf16.pl
            $ ./utf16_to_cp932.pl

* 同梱物についての補足

    (1) CP932.TXT は以下のものです。
        http://www.unicode.org/Public/MAPPINGS/VENDORS/MICSFT/WINDOWS/CP932.TXT
    (2) UnicodeData.txt は以下のものです。
        http://www.unicode.org/Public/5.2.0/ucd/UnicodeData.txt
