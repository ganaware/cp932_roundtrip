#include <windows.h>
#include <stdio.h>
#include <string.h>

int decode(int cp932) {
	//if (0xf040 <= cp932 && cp932 <= 0xf9fc) { // cp932 private use area
	//	return -1;
	//}
	
	char MultiByteBuf[2];
	if (cp932 < 0x100) {
		MultiByteBuf[0] = (char)cp932;
	} else {
		MultiByteBuf[0] = (char)(cp932 >> 8);
		MultiByteBuf[1] = (char)(cp932);
	}
	wchar_t WideCharBuf[100];
	
	UINT CodePage = 932;
	DWORD dwFlags = MB_PRECOMPOSED | MB_ERR_INVALID_CHARS;
	LPCSTR lpMultiByteStr = MultiByteBuf;
	int cchMultiByte = (cp932 < 0x100) ? 1 : 2;
	LPWSTR lpWideCharStr = WideCharBuf;
	int cchWideChar = sizeof(WideCharBuf) / sizeof(wchar_t);
	
	int len = MultiByteToWideChar(
		CodePage, dwFlags, lpMultiByteStr, cchMultiByte,
		lpWideCharStr, cchWideChar);
	
	if (len == 1) {
		return WideCharBuf[0];
	}
	if (len == 2 &&
		0xd800 <= WideCharBuf[0] && WideCharBuf[0] <= 0xdbff &&
		0xdc00 <= WideCharBuf[1] && WideCharBuf[1] <= 0xdfff) {
		return ((((int)WideCharBuf[0] - 0xd800) << 10) |
				((int)WideCharBuf[1] - 0xdc00));
	}
	return -1;
}

int main() {
	for (int cp932 = 0; cp932 <= 0xffff; ++ cp932) {
		int unicode = decode(cp932);
		if (0 < unicode) {
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
