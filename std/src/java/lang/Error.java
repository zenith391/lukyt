package java.lang;

public class Error extends Throwable {

	public Error() {
		super();
	}

	public Error(String details) {
		super(details);
	}

	public Error(Throwable cause) {
		super(cause);
	}

	public Error(String details, Throwable cause) {
		super(details, cause);
	}

}