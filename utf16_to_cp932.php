#!/usr/bin/php
<?php

function encode($unicode) {
	if (#(0xe000 <= $unicode && $unicode <= 0xf8ff) || # private use area
		(0xd800 <= $unicode && $unicode <= 0xdbff) || # high surrogate area
		(0xdc00 <= $unicode && $unicode <= 0xdfff)) {   # low surrogate area
		return -1;
	}

	$inbuf = sprintf("%c%c", ($unicode >> 8) & 0xff, $unicode & 0xff);
	mb_substitute_character("none");
	$outbuf = mb_convert_encoding($inbuf, "CP932", "UTF-16BE");
	if (!(strlen($outbuf) == 1 || strlen($outbuf) == 2)) {
		return -1;
	}
	return hexdec(bin2hex($outbuf));
}

function main() {
	for ($unicode = 0; $unicode <= 0xffff; ++ $unicode) {
		$cp932 = encode($unicode);
		if (0 < $cp932) {
			printf("0x%04X\t0x", $unicode);
			printf(($cp932 < 0x100) ? "%02X" : "%04X", $cp932);
			printf("\n");
		}
	}
}

main();
