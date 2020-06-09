package java.lang;

public class ClassLoader {

	protected ClassLoader parent;
	protected static ClassLoader systemClassLoader;

	protected ClassLoader() {
		this(getSystemClassLoader());
	}

	protected ClassLoader(ClassLoader parent) {
		this.parent = parent;
	}

	public static ClassLoader getSystemClassLoader() {
		if (systemClassLoader == null) {
			systemClassLoader = new SystemClassLoader();
		}
		return systemClassLoader;
	}

	public final ClassLoader getParent() {
		return parent;
	}

	public Class<?> loadClass(String name) throws ClassNotFoundException {
		return loadClass(name, true);
	}

	protected static boolean registerAsParallelCapable() {
		// TODO
		return false;
	}
	
	protected Object getClassLoadingLock(String className) {
		return this;
	}

	protected final Class<?> findLoadedClass(String name) {
		return null; // todo: cache using an hashmap
	}

	protected Class<?> loadClass(String name, boolean resolve) throws ClassNotFoundException {
		//synchronized (getClassLoadingLock(name)) {
			Class<?> cl = findLoadedClass(name);
			if (cl != null) {
				return cl;
			}
			if (parent != null) {
				try {
					return parent.loadClass(name, resolve);
				} catch (ClassNotFoundException e) {
					cl = findClass(name);
					if (cl != null) {
						throw new ClassNotFoundException(name);
					} else {
						return cl;
					}
				}
			} else {
				cl = findClass(name);
				if (cl != null) {
					throw new ClassNotFoundException(name);
				} else {
					return cl;
				}
			}
		//}
	}

	// Lukyt doesn't have linking as separeted step
	protected final void resolveClass(Class<?> c) {}

	protected Class<?> findSystemClass(String name) throws ClassNotFoundException {
		return getSystemClassLoader().findClass(name);
	}

	protected Class<?> findClass(String name) throws ClassNotFoundException {
		throw new ClassNotFoundException(name);
	}

	protected native Class<?> defineClass(String name, byte[] b, int off, int len);

	/*protected Class<?> defineClass(String name, byte[] b, int off, int len, ProtectionDomain domain) {
		// TODO
	}*/

	private static class SystemClassLoader extends ClassLoader {

		protected SystemClassLoader() {
			super(null);
		}

		protected Class<?> findClass(String name) throws ClassNotFoundException {
			throw new ClassNotFoundException(name);
		}

	}

}
