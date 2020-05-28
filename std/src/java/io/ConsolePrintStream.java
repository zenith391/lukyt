package java.io;

public class ConsolePrintStream extends PrintStream {
	
	public ConsolePrintStream() {
		super(null);
	}

	public native void print(String str);
}
