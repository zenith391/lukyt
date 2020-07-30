package java.io;

public class InputStreamReader extends Reader {

	private InputStream in;
	private String encoding;

	public InputStreamReader(InputStream in) {
		this(in, "UTF-8");
	}

	public InputStreamReader(InputStream in, String charsetName) {
		this.in = in;
	}

	public String getEncoding() {
		return encoding;
	}

	public int read() throws IOException {
		return in.read();
	}

	public int read(char[] cbuf, int off, int len) throws IOException {
		byte[] buf = new byte[cbuf.length];
		int l = in.read(buf, off, len);
		for (int i = 0; i < l; i++) {
			cbuf[i] = (char) buf[i];
		}
		return l;
	}

	public boolean ready() throws IOException {
		return in.available() != 0;
	}

	public void close() throws IOException {
		in.close();
	}
}
