#!/usr/bin/env perl
use Encode;

sub decode_ {
  my $cp932 = $_[0];
  #return -1 if (0xf040 <= $cp932 && $cp932 <= 0xf9fc); # cp932 private use area

  my $inbuf;
  if ($cp932 < 0x100) {
    $inbuf = sprintf("%c", $cp932 & 0xff);
  } else {
    $inbuf = sprintf("%c%c", ($cp932 >> 8) & 0xff, $cp932 & 0xff);
  }
  my $outbuf;
  eval {
    my $tmp = decode("CP932", $inbuf, Encode::FB_CROAK);
    die unless ($inbuf eq "");
    $outbuf = encode("UTF-16BE", $tmp, Encode::FB_CROAK);
    die unless ($tmp eq "");
  };
  return -1 if ($@);
  return -1 unless (length($outbuf) == 2);
  my @tmp = unpack("C*", $outbuf);
  my $unicode = (($tmp[0] << 8) | $tmp[1]);
  return $unicode;
}

sub main {
  for (my $cp932 = 0; $cp932 <= 0xffff; ++ $cp932) {
    my $unicode = decode_($cp932);
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
