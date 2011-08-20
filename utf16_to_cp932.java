import java.lang.*;
import java.nio.*;
import java.nio.charset.*;

class utf16_to_cp932 {
	static int encode(int unicode) {
		if (//(0xe000 <= unicode && unicode <= 0xf8ff) || // private use area
			(0xd800 <= unicode && unicode <= 0xdbff) || // high surrogate area
			(0xdc00 <= unicode && unicode <= 0xdfff)) { // low surrogate area
			return -1;
		}
		
		CharBuffer inbuf = CharBuffer.allocate(1);
		inbuf.put((char)unicode);
		inbuf.rewind();
		
		ByteBuffer outbuf = ByteBuffer.allocate(100);
		
		CharsetEncoder encoder = Charset.forName("MS932").newEncoder();
		encoder.reset();
		encoder.onMalformedInput(CodingErrorAction.REPORT);
		encoder.onUnmappableCharacter(CodingErrorAction.REPORT);
		CoderResult cr = encoder.encode(inbuf, outbuf, true);
		if (cr.isError() || cr.isOverflow()) {
			return -1;
		}
		cr = encoder.flush(outbuf);
		if (cr.isError() || cr.isOverflow() || outbuf.position() == 0) {
			return -1;
		}
		int cp932 = 0;
		for (int i = 0; i < outbuf.position(); ++ i) {
			cp932 = (cp932 << 8) | ((int)outbuf.get(i) & 0xff);
		}
		return cp932;
	}

	public static void main(String[] args) {
		for (int unicode = 0; unicode <= 0xffff; ++ unicode) {
			int cp932 = encode(unicode);
			if (0 < cp932) {
				System.out.printf("0x%04X\t0x", unicode);
				System.out.printf((cp932 < 0x100) ? "%02X" : "%04X", cp932);
				System.out.printf("\n");
			}
		}
	}
}
