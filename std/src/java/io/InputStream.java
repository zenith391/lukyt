package java.io;

public abstract class InputStream {

	public abstract int read();

	public int read(byte[] bytes, int off, int len) {
		int end = off + len;
		int readed = 0;
		for (int i = off; i < end; i++) {
			int in = read();
			if (in == -1) {
				break;
			}
			bytes[i] = (byte) in;
			++readed;
		}
		return len;
	}

	public void close() {}

	public long skip(long n) {
		return 0;
	}

	public int available() {
		return 0;
	}

	public int read(byte[] bytes) {
		return read(bytes, 0, bytes.length);
	}

	public void reset() {}

	public boolean markSupported() {
		return false;
	}

	public void mark(int readLimit) {}

}