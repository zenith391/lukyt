package java.awt;

public class HeadlessException extends RuntimeException {

	public HeadlessException() {
		super();
	}

	public HeadlessException(String s) {
		super(s);
	}

}