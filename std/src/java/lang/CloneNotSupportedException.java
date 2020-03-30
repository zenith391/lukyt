package java.lang;

public class CloneNotSupportedException extends RuntimeException {

	public CloneNotSupportedException() {
		super();
	}

	public CloneNotSupportedException(String details) {
		super(details);
	}

	public CloneNotSupportedException(Throwable cause) {
		super(cause);
	}

	public CloneNotSupportedException(String details, Throwable cause) {
		super(details, cause);
	}

}