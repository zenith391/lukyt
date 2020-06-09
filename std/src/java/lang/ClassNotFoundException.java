package java.lang;

public class ClassNotFoundException extends RuntimeException {

	public ClassNotFoundException() {
		super();
	}

	public ClassNotFoundException(String details) {
		super(details);
	}

	public ClassNotFoundException(Throwable cause) {
		super(cause);
	}

	public ClassNotFoundException(String details, Throwable cause) {
		super(details, cause);
	}

}