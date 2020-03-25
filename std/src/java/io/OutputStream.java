package java.io;

public abstract class OutputStream {

	public abstract void write(int b);

	public void write(byte[] bytes, int off, int len) {
		int end = off + len;
		for (int i = off; i < end; i++) {
			write((int) bytes[i]);
		}
	}

	public void close() {}
	public void flush() {}

	public void write(byte[] bytes) {
		write(bytes, 0, bytes.length);
	}

}
