#include "apr_general.h"
#include "apr_pools.h"
#include "apr_iconv.h"
#include <stdio.h>

typedef unsigned char byte;

int encode(int unicode, apr_pool_t *pool) {
	if (//(0xe000 <= unicode && unicode <= 0xf8ff) || // private use area
		(0xd800 <= unicode && unicode <= 0xdbff) || // high surrogate area
		(0xdc00 <= unicode && unicode <= 0xdfff)) { // low surrogate area
		return -1;
	}
	
	apr_size_t inbytesleft = 2;
	apr_size_t outbytesleft = 2;
	char inbuf_[2] = { (char)(unicode >> 8), (char)unicode };
	char outbuf_[2];
	const char *inbuf = inbuf_;
	char *outbuf = outbuf_;

	apr_iconv_t cd;
	if (apr_iconv_open("CP932", "UTF-16", pool, &cd) < 0) {
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
	if (result == 0 && inbytesleft == 0) {
		if (outbytesleft == 1) {
			int cp932 = (int)(byte)outbuf_[0];
			if (cp932 == 0x5f && unicode != 0x5f) {
				// missing char is converted to 0x5f
				return -1;
			}
			return cp932;
		} else if (outbytesleft == 0) {
			return ((int)(byte)outbuf_[0] << 8) | (int)(byte)outbuf_[1];
		}
	}
	return -1;
}

int main() {
	apr_initialize();
	apr_pool_t *pool;
	apr_pool_create(&pool, NULL);
	for (int unicode = 0; unicode <= 0xffff; ++ unicode) {
		int cp932 = encode(unicode, pool);
		if (0 < cp932) {
			printf("0x%04X\t0x", unicode);
			printf((cp932 < 0x100) ? "%02X" : "%04X", cp932);
			printf("\n");
		}
	}
	return 0;
}
