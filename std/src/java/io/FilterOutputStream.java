package java.io;

public class FilterOutputStream extends OutputStream {
	protected OutputStream out;

	public FilterOutputStream(OutputStream out) {
		this.out = out;
	}

	public void close() throws IOException {
		out.close();
	}

	public void flush() throws IOException {
		out.flush();
	}

	public void write(byte[] b) throws IOException {
		out.write(b);
	}

	public void write(byte[] b, int off, int len) throws IOException {
		out.write(b, off, len);
	}

	public void write(int b) throws IOException {
		out.write(b);
	}
}
