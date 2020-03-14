package java.lang;

import java.io.PrintStream;
import java.io.ConsolePrintStream;

public class System {

	public static final ConsolePrintStream out = new ConsolePrintStream();

	public static native String getenv(String name);
	public static native String getProperty(String key);

	public static native long currentTimeMillis();

	public static String getProperty(String key, String def) {
		String value = getProperty(key);
		if (value == null) {
			return def;
		} else {
			return value;
		}
	}

	public static void gc() {
		Runtime.getRuntime().gc();
	}

	public static void exit(int status) {
		Runtime.getRuntime().exit(status);
	}

}