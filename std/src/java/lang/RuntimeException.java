package java.lang;

public class RuntimeException extends Exception {

	public RuntimeException() {
		super();
	}

	public RuntimeException(String details) {
		super(details);
	}

	public RuntimeException(Throwable cause) {
		super(cause);
	}

	public RuntimeException(String details, Throwable cause) {
		super(details, cause);
	}

}