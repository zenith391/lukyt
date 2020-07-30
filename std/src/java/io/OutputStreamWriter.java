package java.io;

public class OutputStreamWriter extends Writer {

	private String encoding;
	private OutputStream out;

	public OutputStreamWriter(OutputStream out) {
		this(out, "UTF-8");
	}

	public OutputStreamWriter(OutputStream out, String encoding) {
		this.out = out;
		this.encoding = encoding;
	}

	public String getEncoding() {
		return encoding;
	}

	public void write(int c) throws IOException {
		out.write(c);
	}

	public void write(char[] cbuf, int off, int len) throws IOException {
		byte[] buf = new byte[cbuf.length];
		for (int i = 0; i < buf.length; i++) {
			buf[i] = (byte) cbuf[i];
		}
		out.write(buf, off, len);
	}

	public void flush() throws IOException {
		out.flush();
	}

	public void close() throws IOException {
		out.close();
	}

}
