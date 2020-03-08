package java.io;

public class PrintStream {

	public void println(String str) {
		print(str);
	}

	public void print(Object obj) {
		print(obj.toString());
	}

	public void print(String str) {
		_print(str);
	}

	public native void _print(String str);

}
