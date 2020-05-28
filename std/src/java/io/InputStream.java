package java.io;

public abstract class InputStream implements Closeable {

	public abstract int read() throws IOException;

	public int read(byte[] bytes, int off, int len) throws IOException {
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

	public void close() throws IOException {}

	public long skip(long n) throws IOException {
		return 0;
	}

	public int available() throws IOException {
		return 0;
	}

	public int read(byte[] bytes) throws IOException {
		return read(bytes, 0, bytes.length);
	}

	public void reset() throws IOException {}

	public boolean markSupported() {
		return false;
	}

	public void mark(int readLimit) {}

}