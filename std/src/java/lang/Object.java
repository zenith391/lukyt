package java.lang;

public class Object {

	public boolean equals(Object other) {
		return this == other;
	}

	public String toString() {
		return getClass().getName() + "@" + hashCode();
	}

	protected void finalize() throws Throwable {}

	public native int hashCode();
	public final native Class getClass();

}
