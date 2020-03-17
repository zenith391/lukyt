package java.lang;

public class UnsupportedOperationException extends RuntimeException {

	public UnsupportedOperationException() {
		super();
	}

	public UnsupportedOperationException(String details) {
		super(details);
	}

	public UnsupportedOperationException(Throwable cause) {
		super(cause);
	}

	public UnsupportedOperationException(String details, Throwable cause) {
		super(details, cause);
	}

}