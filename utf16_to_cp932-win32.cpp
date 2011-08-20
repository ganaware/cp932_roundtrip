#include <windows.h>
#include <stdio.h>

#ifndef WC_NO_BEST_FIT_CHARS					// for cygwin
#	define WC_NO_BEST_FIT_CHARS 0x400
#endif

int encode(int unicode, bool wnbfc) {
	if (//(0xe000 <= unicode && unicode <= 0xf8ff) || // private use area
		(0xd800 <= unicode && unicode <= 0xdbff) || // high surrogate area
		(0xdc00 <= unicode && unicode <= 0xdfff)) { // low surrogate area
		return -1;
	}
	
	UINT CodePage = 932;
	DWORD dwFlags = wnbfc ? WC_NO_BEST_FIT_CHARS : 0;
	
	int cchWideChar;
	wchar_t WideCharBuf[2];
	if (unicode < 0x10000) {
		WideCharBuf[0] = unicode;
		cchWideChar = 1;
	} else {
		WideCharBuf[0] = ((unicode >> 10) & 0x3ff) + 0xd800;
		WideCharBuf[1] = (unicode & 0x3ff) + 0xdc00;
		cchWideChar = 2;
	}
	LPCWSTR lpWideCharStr = WideCharBuf;
	
	char MultiByteBuf[100];
	LPSTR lpMultiByteStr = MultiByteBuf;
	int cchMultiByte = sizeof(MultiByteBuf);
	LPCSTR lpDefaultChar = NULL;
	BOOL UsedDefaultChar = FALSE;
	LPBOOL lpUsedDefaultChar = &UsedDefaultChar;
	
	int len = WideCharToMultiByte(
		CodePage, dwFlags, lpWideCharStr, cchWideChar,
		lpMultiByteStr, cchMultiByte, lpDefaultChar, lpUsedDefaultChar);
	if (!UsedDefaultChar) {
		if (len == 1) {
			return (int)(BYTE)MultiByteBuf[0];
		}
		if (len == 2) {
			return ((int)(BYTE)MultiByteBuf[0] << 8) | (int)(BYTE)MultiByteBuf[1];
		}
	}
	return -1;
}

int main(int argc, char **argv) {
	bool wnbfc = (argc == 2 && strcmp(argv[1], "--wnbfc") == 0);
	for (int unicode = 0; unicode <= 0x10ffff; ++ unicode) {
		int cp932 = encode(unicode, wnbfc);
		if (0 < cp932) {
			printf("0x%04X\t0x", unicode);
			printf((cp932 < 0x100) ? "%02X" : "%04X", cp932);
			printf("\n");
		}
	}
	return 0;
}
