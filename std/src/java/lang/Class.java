package java.lang;

public class Class {
	private long ref; // class reference id

	private Class(long ref) {
		this.ref = ref;
	}

	public Object newInstance() {
		return newClassInstance(ref);
	}

	public String getName() {
		return getClassName(ref).replace('/', '.');
	}


	private native static Object newClassInstance(long ref);
	private native static String getClassName(long ref);
}
