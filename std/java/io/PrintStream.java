package java.io;

public class PrintStream {

	public void println(String str) {
		this.print(str);
	}

	public native void print(String str);

}
