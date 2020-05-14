package java.lang;

public class IllegalArgumentException extends RuntimeException {

	public IllegalArgumentException() {
		super();
	}

	public IllegalArgumentException(String details) {
		super(details);
	}

	public IllegalArgumentException(Throwable cause) {
		super(cause);
	}

	public IllegalArgumentException(String details, Throwable cause) {
		super(details, cause);
	}

}