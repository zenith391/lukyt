package java.lang;

public class Object {

	public boolean equals(Object other) {
		return this == other;
	}

	public String toString() {
		return "some object";
	}

	public native int hashCode(); // TODO
	public native Class getClass(); // TODO

}
