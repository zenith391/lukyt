package java.io;

public class IOException extends Exception {

	public IOException() {
		super();
	}

	public IOException(String details) {
		super(details);
	}

	public IOException(Throwable cause) {
		super(cause);
	}

	public IOException(String details, Throwable cause) {
		super(details, cause);
	}

}