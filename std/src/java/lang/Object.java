package java.lang;

public class Object {

	private Class thizClass;

	public boolean equals(Object other) {
		return this == other;
	}

	public String toString() {
		return getClass().getName() + "@" + hashCode();
	}

	protected void finalize() throws Throwable {}

	public final Class getClass() {
		if (thizClass == null) {
			thizClass = newClass();
		}
		return thizClass;
	}

	private native Class newClass();
	public native int hashCode();

}
