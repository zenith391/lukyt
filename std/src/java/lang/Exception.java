package java.lang;

public class Exception extends Throwable {

	public Exception() {
		super();
	}

	public Exception(String details) {
		super(details);
	}

	public Exception(Throwable cause) {
		super(cause);
	}

	public Exception(String details, Throwable cause) {
		super(details, cause);
	}

}