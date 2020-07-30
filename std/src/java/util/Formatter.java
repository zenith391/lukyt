package java.util;

import java.io.*;

public class Formatter implements Closeable, Flushable {

	private Appendable out;

	public Formatter() {
		this(new StringBuilder());
	}

	public Formatter(Appendable a) {
		this.out = a;
	}

	public Appendable out() {
		return out;
	}

	public String toString() {
		return out.toString();
	}

	public void flush() {
		try {
			if (out instanceof Flushable) {
				((Flushable) out).flush();
			}
		} catch (IOException e) {

		}
	}

	public void close() {
		try {
			if (out instanceof Closeable) {
				((Closeable) out).close();
			}
		} catch (IOException e) {

		}
	}

	public Formatter format(String format, Object... args) {
		StringBuilder str = new StringBuilder();
		int argIndex = 0;
		boolean waitFormat = false;
		for (int i = 0; i < format.length(); i++) {
			char ch = format.charAt(i);
			if (waitFormat) {
				if (ch == 'S' || ch == 's') {
					String arg = (String) args[argIndex];
					argIndex++;
					if (arg == null) {
						arg = "null";
					}
					str.append(arg);
				} else if (ch == '%') {
					str.append(ch);
				} else if (ch == 'd') {
					int d = (int) args[argIndex];
					argIndex++;
					str.append(d);
				}
			} else {
				if (ch == '%') waitFormat = true;
				else str.append(ch);
			}
		}
		try {
			out.append(str.toString());
		} catch (IOException e) {
			e.printStackTrace();
		}
		return this;
	}

}