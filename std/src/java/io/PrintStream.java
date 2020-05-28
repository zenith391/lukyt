package java.io;

public abstract class PrintStream extends FilterOutputStream /*implements Appendable*/ {

	public PrintStream(OutputStream o) {
		super(o);
	}

	public void append(char c) {

	}

	public void println(String str) {
		print(str + "\n");
	}

	public void println(int i) {
		println(Long.toString((long) i));
	}

	public void println(boolean b) {
		println(String.valueOf(b));
	}

	public void println() {
		print("\n");
	}

	public void println(Object obj) {
		print(String.valueOf(obj) + "\n");
	}

	public void print(Object obj) {
		print(obj.toString());
	}

	public void print(int i) {
		print(Long.toString((long) i));
	}

	public void print(char c) {
		print(new String(new char[] {c}));
	}

	public void print(boolean b) {
		print(String.valueOf(b));
	}

	public abstract void print(String str);

}
