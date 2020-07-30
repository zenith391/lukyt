package java.io;

public class PrintStream extends FilterOutputStream implements Appendable {

	private boolean autoFlush;
	private boolean error;

	public PrintStream(File file) {
		this(new FileOutputStream(file));
	}

	public PrintStream(OutputStream o) {
		this(o, false);
	}

	public PrintStream(OutputStream o, boolean autoFlush) {
		super(o);
		this.autoFlush = autoFlush;
	}

	public PrintStream append(char c) throws IOException {
		return append(String.valueOf(c));
	}

	public PrintStream append(CharSequence sq) throws IOException {
		print(sq.toString());
		return this;
	}

	public PrintStream append(CharSequence sq, int start, int end) throws IOException {
		return append(sq.subSequence(start, end));
	}

	public void println(String str) {
		print(str);
		print('\n');
	}

	public void println(int i) {
		println(Long.toString((long) i));
	}

	public void println(boolean b) {
		println(String.valueOf(b));
	}

	public void println() {
		print('\n');
	}

	public void println(Object obj) {
		println(String.valueOf(obj));
	}

	public void print(Object obj) {
		print(String.valueOf(obj));
	}

	public void print(int i) {
		print(Long.toString((long) i));
	}

	public void print(char c) {
		print(new char[] {c});
	}

	public void print(boolean b) {
		print(String.valueOf(b));
	}

	public void print(char[] chars) {
		// TODO encode using NIO Charset
		byte[] bytes = new byte[chars.length];
		for (int i = 0; i < chars.length; i++) {
			bytes[i] = (byte) chars[i];
		}
		try {
			write(bytes);
		} catch (IOException e) {
			setError();
		}
	}

	public void print(String str) {
		str = str == null ? "null" : str;
		print(str.toCharArray());
	}

	public void write(byte[] b) throws IOException {
		out.write(b);
		if (autoFlush) flush();
	}

	public void write(byte[] b, int off, int len) throws IOException {
		out.write(b, off, len);
		if (autoFlush) flush();
	}

	public void write(int b) throws IOException {
		out.write(b);
		if (autoFlush) flush();
	}

	public boolean checkError() {
		try {
			flush();
		} catch (IOException e) {
			setError();
		}
		return error;
	}

	protected void setError() {
		error = true;
	}

	protected void clearError() {
		error = false;
	}

}
