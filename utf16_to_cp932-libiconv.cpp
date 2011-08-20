#include <iconv.h>
#include <stdio.h>

typedef unsigned char byte;

int encode(int unicode) {
	if (//(0xe000 <= unicode && unicode <= 0xf8ff) || // private use area
		(0xd800 <= unicode && unicode <= 0xdbff) || // high surrogate area
		(0xdc00 <= unicode && unicode <= 0xdfff)) { // low surrogate area
		return -1;
	}
	
	size_t inbytesleft = 2;
	size_t outbytesleft = 2;
	char inbuf_[2] = { (char)(unicode >> 8), (char)unicode };
	char outbuf_[2];
	char *inbuf = inbuf_;
	char *outbuf = outbuf_;
	
	iconv_t cd = iconv_open("CP932", "UTF-16BE");
	size_t result = iconv(cd, &inbuf, &inbytesleft, &outbuf, &outbytesleft);
	iconv_close(cd);
	if (result != (size_t)-1) {
		if (outbytesleft == 1) {
			return (int)(byte)outbuf_[0];
		} else if (outbytesleft == 0) {
			return ((int)(byte)outbuf_[0] << 8) | (int)(byte)outbuf_[1];
		}
	}
	return -1;
}

int main() {
	for (int unicode = 0; unicode <= 0xffff; ++ unicode) {
		int cp932 = encode(unicode);
		if (0 < cp932) {
			printf("0x%04X\t0x", unicode);
			printf((cp932 < 0x100) ? "%02X" : "%04X", cp932);
			printf("\n");
		}
	}
	return 0;
}
