package java.io;

public abstract class OutputStream implements Closeable, Flushable {

	public abstract void write(int b) throws IOException;

	public void write(byte[] bytes, int off, int len) throws IOException {
		int end = off + len;
		for (int i = off; i < end; i++) {
			write((int) bytes[i]);
		}
	}

	public void close() throws IOException {}
	public void flush() throws IOException {}

	public void write(byte[] bytes) throws IOException {
		write(bytes, 0, bytes.length);
	}

}
