package java.lang;

public class NoClassDefException extends LinkageError {

	public NoClassDefException() {
		super();
	}

	public NoClassDefException(String details) {
		super(details);
	}

}