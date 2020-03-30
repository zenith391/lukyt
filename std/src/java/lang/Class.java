package java.lang;

public class Class<T> {
	private long ref; // class reference id

	private Class(long ref) {
		this.ref = ref;
	}

	public <T> T newInstance() {
		return newClassInstance(ref);
	}

	public String getName() {
		return getClassName(ref).replace('/', '.');
	}

	public boolean isEnum() {
		return isEnum(ref);
	}

	private native static <T> T newClassInstance(long ref);
	private native static String getClassName(long ref);
	private native static boolean isEnum(long ref);
}
