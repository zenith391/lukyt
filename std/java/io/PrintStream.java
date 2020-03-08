package java.io;

public abstract class PrintStream {

	public void println(String str) {
		print(str);
	}

	public void print(Object obj) {
		print(obj.toString());
	}

	public abstract void print(String str);

}
