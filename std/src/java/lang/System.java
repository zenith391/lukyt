package java.lang;

import java.io.*;
import lukyt.Os;

public class System {

	public static final PrintStream out = new PrintStream(new FileOutputStream(FileDescriptor.out));
	public static final InputStream in = new ConsoleInputStream();
	public static final PrintStream err = new PrintStream(new FileOutputStream(FileDescriptor.err));

	public static native String getenv(String name);
	public static native String getProperty(String key);
	public static native void arraycopy(Object src, int srcPos, Object dest, int destPos, int length);

	/**
		Note: the default Lua timer only haves second precision and thus, this function is NOT to be used for benchmarking
	**/
	public static long currentTimeMillis() {
		return (long) (Os.time() * 1000);
	}

	/**
		Note: based on the CPU time to allow more precision
	**/
	public static long nanoTime() {
		return (long) (Os.clock() * 1000000000);
	}

	public static String getProperty(String key, String def) {
		String value = getProperty(key);
		if (value == null) {
			return def;
		} else {
			return value;
		}
	}

	public static void load(String filename) {
		Runtime.getRuntime().load(filename);
	}

	public static void loadLibrary(String libname) {
		Runtime.getRuntime().loadLibrary(libname);
	}

	public static void gc() {
		Runtime.getRuntime().gc();
	}

	public static void exit(int status) {
		Runtime.getRuntime().exit(status);
	}

}
