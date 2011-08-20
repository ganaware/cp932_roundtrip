import java.lang.*;
import java.nio.*;
import java.nio.charset.*;

class cp932_to_utf16 {
	static int decode(int cp932) {
		//if (0xf040 <= cp932 && cp932 <= 0xf9fc) { // cp932 private use area
		//	return -1;
		//}

		ByteBuffer inbuf;
		if (cp932 < 0x100) {
			inbuf = ByteBuffer.allocate(1);
		} else {
			inbuf = ByteBuffer.allocate(2);
			inbuf.put((byte)((cp932 >> 8) & 0xff));
		}
		inbuf.put((byte)(cp932 & 0xff));
		inbuf.rewind();

		CharBuffer outbuf = CharBuffer.allocate(100);
		CharsetDecoder decoder = Charset.forName("MS932").newDecoder();
		decoder.reset();
		decoder.onMalformedInput(CodingErrorAction.REPORT);
		decoder.onUnmappableCharacter(CodingErrorAction.REPORT);
		CoderResult cr = decoder.decode(inbuf, outbuf, true);
		if (cr.isError() || cr.isOverflow()) {
			return -1;
		}
		cr = decoder.flush(outbuf);
		if (cr.isError() || cr.isOverflow() || outbuf.position() != 1) {
			return -1;
		}
		return outbuf.get(0);
	}
	
	public static void main(String[] args) {
		for (int cp932 = 0; cp932 <= 0xffff; ++ cp932) {
			int unicode = decode(cp932);
			if (0 <= unicode) {
				if (cp932 < 0x100) {
					System.out.printf("0x%02X\t", cp932);
				} else {
					System.out.printf("0x%04X\t", cp932);
				}
				System.out.printf("0x%04X\n", unicode);
			}
		}
	}
}
