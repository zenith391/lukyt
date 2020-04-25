package java.lang;

public class ChildNotFoundException extends RuntimeException {

	public ChildNotFoundException() {
		super();
	}

	public ChildNotFoundException(String details) {
		super(details);
	}

	public ChildNotFoundException(Throwable cause) {
		super(cause);
	}

	public ChildNotFoundException(String details, Throwable cause) {
		super(details, cause);
	}

}