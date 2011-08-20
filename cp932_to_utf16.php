#!/usr/bin/php
<?php

function decode($cp932) {
	#if (0xf040 <= $cp932 && $cp932 <= 0xf9fc) { # $cp932 private use area
	#	return -1;
	#}
  
	if ($cp932 < 0x100) {
		$inbuf = sprintf("%c", $cp932 & 0xff);
	} else {
		$leadbyte = ($cp932 >> 8) & 0xff;
		if (!((0x81 <= $leadbyte && $leadbyte <= 0x9f) ||
			  (0xE0 <= $leadbyte && $leadbyte <= 0xFC))) {
			return -1;
		}
		$trailbyte = ($cp932 & 0xff);
		if (!((0x40 <= $trailbyte && $trailbyte <= 0x7E) ||
			  (0x80 <= $trailbyte && $trailbyte <= 0xFC))) {
			return -1;
		}
		$inbuf = sprintf("%c%c", $leadbyte, $trailbyte);
	}
	mb_substitute_character(0xfeff);
	$unicode = 0;
	$outbuf = mb_convert_encoding($inbuf, "UTF-16BE", "CP932");
	if (!(strlen($outbuf) == 2 && $outbuf != "\xfe\xff")) {
		return -1;
	}
	return hexdec(bin2hex($outbuf));
}

function main() {
	for ($cp932 = 0; $cp932 <= 0xffff; ++ $cp932) {
		$unicode = decode($cp932);
		if (0 <= $unicode) {
			if ($cp932 < 0x100) {
				printf("0x%02X\t", $cp932);
			} else {
				printf("0x%04X\t", $cp932);
			}
			printf("0x%04X\n", $unicode);
		}
	}
}

main();
