package java.io;

public class BufferedReader extends Reader {

	private Reader reader;

	public BufferedReader(Reader reader) {
		this.reader = reader;
	}

	public int read() throws IOException {
		return reader.read();
	}

	public int read(char[] cbuf) throws IOException {
		return reader.read(cbuf);
	}

	public int read(char[] cbuf, int off, int len) throws IOException {
		return reader.read(cbuf, off, len);
	}

	public String readLine() {
		System.out.println("TODO READLINE");
		return null;
	}

	public void close() throws IOException {
		reader.close();
	}

	public long skip(long n) throws IOException {
		return reader.skip(n);
	}

	public boolean ready() throws IOException {
		return reader.ready();
	}

	public boolean markSupported() {
		return reader.markSupported();
	}

	public void mark(int readAheadLimit) throws IOException {
		reader.mark(readAheadLimit);
	}

	public void reset() throws IOException {
		reader.reset();
	}

}
