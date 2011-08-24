cp932_roundtrip.tar.bz2:						\
		Python-2.7.2-cp932-patch*.txt			\
		UnicodeData.txt							\
		apr-iconv-1.2.1-cp932-patch*.txt		\
		cp932_roundtrip.css						\
		cp932_roundtrip.html					\
		cp932_roundtrip.rb						\
		cp932_to_utf16-*.cpp					\
		cp932_to_utf16.java						\
		cp932_to_utf16.php						\
		cp932_to_utf16.pl						\
		cp932_to_utf16.py						\
		cp932_to_utf16.rb						\
		gen.html								\
		result/cp932_to_utf16-*.txt				\
		result/utf16_to_cp932-*.txt				\
		utf16_to_cp932-*.cpp					\
		utf16_to_cp932.java						\
		utf16_to_cp932.php						\
		utf16_to_cp932.pl						\
		utf16_to_cp932.py						\
		utf16_to_cp932.rb
	tar cvjf $@ $^

cp932_roundtrip.html:							\
		UnicodeData.txt							\
		cp932_roundtrip.rb						\
		gen.html								\
		result/cp932_to_utf16-*.txt				\
		result/utf16_to_cp932-*.txt
	ruby cp932_roundtrip.rb > $@~
	mv $@~ $@
