package java.io;

public abstract class PrintStream {

	public void println(String str) {
		print(str + "\n");
	}

	public void println(int i) {
		println(Long.toString((long) i));
	}

	public void println(Object obj) {
		print(obj.toString() + "\n");
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

	public abstract void print(String str);

}
