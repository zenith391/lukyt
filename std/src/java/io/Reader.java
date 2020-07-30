package java.io;

public abstract class Reader implements Closeable {

	protected Object lock;

	protected Reader() {
		lock = this;
	}

	protected Reader(Object lock) {
		this.lock = lock;
	}

	public int read() throws IOException {
		char[] buf = new char[1];
		if (read(buf, 0, 1) == -1) return -1;
		else return buf[0];
	}

	public int read(char[] cbuf) throws IOException {
		return read(cbuf, 0, cbuf.length);
	}

	public abstract int read(char[] cbuf, int off, int len) throws IOException;
	public abstract void close() throws IOException;

	public long skip(long n) throws IOException {
		throw new IOException();
	}

	public boolean ready() throws IOException {
		return false;
	}

	public boolean markSupported() {
		return false;
	}

	public void mark(int readAheadLimit) throws IOException {
		throw new IOException();
	}

	public void reset() throws IOException {
		throw new IOException();
	}

}
