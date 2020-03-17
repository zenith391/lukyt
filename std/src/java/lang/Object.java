package java.lang;

public class Object {

	public boolean equals(Object other) {
		return this == other;
	}

	public String toString() {
		return "some object@" + hashCode();
	}

	protected void finalize() throws Throwable {}

	public native int hashCode();
	public final native Class getClass(); // TODO

}
