package java.lang;

public class Throwable {

	private String details;
	private Throwable cause; // yes it's in Java 1.4 but it's still end up here
	private StackTraceElement[] elements;

	public Throwable() {
		this(null, null);
	}

	public Throwable(String details) {
		this(details, null);
	}

	public Throwable(Throwable cause) {
		this(null, details);
	}

	public Throwable(String details, Throwable cause) {
		this.details = details;
		this.cause = cause;
		fillInStackTrace();
	}

	public Throwable initCause(Throwable throwable) {
		this.cause = throwable;
		return this;
	}

	public Throwable getCause() {
		return cause;
	}

	public String getMessage() {
		return details;
	}

	public String getLocalizedMessage() {
		return details;
	}

	private native StackTraceElement[] currentStackTrace();

	public void printStackTrace() {
		printStackTrace(System.out); // TODO: use System.err
	}

	public void printStackTrace(PrintStream s) {
		s.println(toString());
		for (int i = 0; i < elements.length; i++) {
			StackTraceElement element = elements[i];
			s.print("\t");
			s.print(" at ");
			s.print(element.toString());
			s.println();
		}
	}

	public Throwable fillInStackTrace() {
		elements = currentStackTrace();
		return this;
	}

	public String toString() {
		if (getLocalizedMessage() == null) { // todo actually class of the exception
			return "java.lang.Throwable";
		} else {
			return "java.lang.Throwable: " + getLocalizedMessage();
		}
	}

}
