package java.io;

import java.util.Formatter;

public class PrintWriter extends Writer implements Appendable {

	private boolean autoFlush;
	private boolean error;
	private Formatter formatter;
	protected Writer out;

	/*public PrintWriter(File file) {
		this(new FileOutputStream(file));
	}*/

	public PrintWriter(Writer out) {
		this(out, false);
	}

	public PrintWriter(Writer out, boolean autoFlush) {
		this.out = out;
		this.autoFlush = autoFlush;
		this.formatter = new Formatter(this);
	}

	public PrintWriter append(char c) throws IOException {
		return append(String.valueOf(c));
	}

	public PrintWriter append(CharSequence sq) throws IOException {
		print(sq.toString());
		return this;
	}

	public PrintWriter append(CharSequence sq, int start, int end) throws IOException {
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
		try {
			write(chars);
		} catch (IOException e) {
			setError();
		}
	}

	public PrintWriter format(String format, Object... args) {
		formatter.format(format, args);
		return this;
	}

	public PrintWriter printf(String fmt, Object... args) {
		return format(fmt, args);
	}

	public void print(String str) {
		str = str == null ? "null" : str;
		print(str.toCharArray());
	}

	public void write(char[] b) throws IOException {
		out.write(b);
		if (autoFlush) flush();
	}

	public void write(char[] b, int off, int len) throws IOException {
		out.write(b, off, len);
		if (autoFlush) flush();
	}

	public void write(String s, int off, int len) throws IOException {
		out.write(s, off, len);
	}

	public void write(String s) throws IOException {
		out.write(s);
	}

	public void write(int b) throws IOException {
		out.write(b);
		if (autoFlush) flush();
	}

	public void flush() throws IOException {
		out.flush();
	}

	public void close() throws IOException {
		out.close();
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
