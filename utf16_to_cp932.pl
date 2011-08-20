#!/usr/bin/env perl
use Encode;

sub encode_ {
  my $unicode = $_[0];
  if (#(0xe000 <= $unicode && $unicode <= 0xf8ff) || # private use area
      (0xd800 <= $unicode && $unicode <= 0xdbff) || # high surrogate area
      (0xdc00 <= $unicode && $unicode <= 0xdfff)) {   # low surrogate area
    return -1;
  }

  my $inbuf = sprintf("%c%c", ($unicode >> 8) & 0xff, $unicode & 0xff);
  my $outbuf;
  eval {
    my $tmp = decode("UTF-16BE", $inbuf, Encode::FB_CROAK);
    die unless ($inbuf eq "");
    $outbuf = encode("CP932", $tmp, Encode::FB_CROAK);
    die unless ($tmp eq "");
  };
  return -1 if ($@);
  return -1 unless (length($outbuf) == 1 || length($outbuf) == 2);
  my $cp932 = 0;
  foreach my $p (unpack("C*", $outbuf)) {
    $cp932 = ($cp932 << 8) | $p;
  }
  return $cp932;
}

sub main {
  for (my $unicode = 0; $unicode <= 0xffff; ++ $unicode) {
    my $cp932 = encode_($unicode);
    if (0 < $cp932) {
      printf("0x%04X\t0x", $unicode);
      printf(($cp932 < 0x100) ? "%02X" : "%04X", $cp932);
      printf("\n");
    }
  }
}

main();
