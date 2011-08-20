#include <iconv.h>
#include <stdio.h>

typedef unsigned char byte;

int decode(int cp932) {
	//if (0xf040 <= cp932 && cp932 <= 0xf9fc) { // cp932 private use area
	//	return -1;
	//}
	
	size_t inbytesleft;
	size_t outbytesleft = 2;
	char inbuf_[2];
	if (cp932 < 0x100) {
		inbuf_[0] = (char)cp932;
		inbytesleft = 1;
	} else {
		inbuf_[0] = (char)(cp932 >> 8);
		inbuf_[1] = (char)cp932;
		inbytesleft = 2;
	}
	char outbuf_[2];
	char *inbuf = inbuf_;
	char *outbuf = outbuf_;
	
	iconv_t cd = iconv_open("UTF-16BE", "CP932");
	size_t result = iconv(cd, &inbuf, &inbytesleft, &outbuf, &outbytesleft);
	iconv_close(cd);
	if (result != (size_t)-1 && outbytesleft == 0) {
		return ((int)(byte)outbuf_[0] << 8) | (int)(byte)outbuf_[1];
	} else {
		return -1;
	}
}

int main() {
	for (int cp932 = 0; cp932 <= 0xffff; ++ cp932) {
		int unicode = decode(cp932);
		if (0 <= unicode) {
			if (cp932 < 0x100) {
				printf("0x%02X\t", cp932);
			} else {
				printf("0x%04X\t", cp932);
			}
			printf("0x%04X\n", unicode);
		}
	}
	return 0;
}
