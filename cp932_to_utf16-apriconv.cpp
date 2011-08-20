#include "apr_general.h"
#include "apr_pools.h"
#include "apr_iconv.h"
#include <stdio.h>

typedef unsigned char byte;

int decode(int cp932, apr_pool_t *pool) {
	//if (0xf040 <= cp932 && cp932 <= 0xf9fc) { // cp932 private use area
	//	return -1;
	//}
#define OUTBUFSIZE 100
	apr_size_t inbytesleft;
	apr_size_t outbytesleft = OUTBUFSIZE;
	char inbuf_[2];
	if (cp932 < 0x100) {
		inbuf_[0] = (char)cp932;
		inbytesleft = 1;
	} else {
		inbuf_[0] = (char)(cp932 >> 8);
		inbuf_[1] = (char)cp932;
		inbytesleft = 2;
	}
	char outbuf_[OUTBUFSIZE];
	const char *inbuf = inbuf_;
	char *outbuf = outbuf_;
	
	apr_iconv_t cd;
	if (apr_iconv_open("UTF-16", "CP932", pool, &cd) < 0) {
		return -1;
	}
	apr_size_t result = 0;
	if (apr_iconv(cd, &inbuf, &inbytesleft, &outbuf, &outbytesleft, &result)
		< 0) {
		return -1;
	}
	if (apr_iconv_close(cd, pool) < 0) {
		return -1;
	}
	if (result == 0 && inbytesleft == 0 && outbytesleft == OUTBUFSIZE - 4) {
		// outbuf_[0],outbuf_[1] is 0xfe,0xff (= BOM)
		return ((int)(byte)outbuf_[2] << 8) | (int)(byte)outbuf_[3];
	} else {
		return -1;
	}
}

int main() {
	apr_initialize();
	apr_pool_t *pool;
	apr_pool_create(&pool, NULL);
	for (int cp932 = 0; cp932 <= 0xffff; ++ cp932) {
		int unicode = decode(cp932, pool);
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
