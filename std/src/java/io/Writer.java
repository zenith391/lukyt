package java.io;

public abstract class Writer implements Appendable, Closeable, Flushable {
	protected Object lock;

	protected Writer() {
		lock = this;
	}

	protected Writer(Object lock) {
		this.lock = lock;
	}

	public abstract void write(char[] cbuf, int off, int len) throws IOException;
	public abstract void flush() throws IOException;
	public abstract void close() throws IOException;

	public void write(char[] cbuf) throws IOException {
		write(cbuf, 0, cbuf.length);
	}

	public void write(int c) throws IOException {
		write(new char[] {(char) c}, 0, 1);
	}

	public void write(String str) throws IOException {
		write(str.toCharArray());
	}

	public void write(String str, int off, int len) throws IOException {
		if (len == 0)
			len = 1;
		append(str, off, off+len-1);
	}

	public Writer append(char c) throws IOException {
		write(new char[] {c}, 0, 1);
		return this;
	}

	public Writer append(CharSequence sq) throws IOException {
		write(sq.toString().toCharArray());
		return this;
	}

	public Writer append(CharSequence sq, int start, int end) throws IOException {
		return append(sq.subSequence(start, end));
	}
}
