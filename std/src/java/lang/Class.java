package java.lang;

public class Class<T> {
	private long ref; // class reference id
	private ClassLoader classLoader;

	public static Class<?> forName(String name) {
		return forName(name, true, ClassLoader.getSystemClassLoader());
	}

	public static Class<?> forName(String name, boolean initialize, ClassLoader loader) {
		return loader.loadClass(name, initialize);
	}

	private Class(long ref) {
		this(ClassLoader.getSystemClassLoader(), ref);
	}

	private Class(ClassLoader classLoader, long ref) {
		this.ref = ref;
		this.classLoader = classLoader;
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
