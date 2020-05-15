package java.lang;

public final class Boolean {
	public static Boolean FALSE = new Boolean(false);
	public static Boolean TRUE = new Boolean(true);
	public static Class<Boolean> TYPE = Boolean.class;

	private boolean value;

	public Boolean(boolean b) {
		value = b;
	}

	public Boolean(String s) {
		value = s.equals("true");
	}

	public boolean booleanValue() {
		return value;
	}

	public String toString() {
		return toString(value);
	}

	public static String toString(boolean b) {
		if (b == true) {
			return "true";
		} else {
			return "false";
		}
	}

	public int hashCode() {
		if (value == true) {
			return 1;
		} else {
			return 0;
		}
	}

	public static boolean parseBoolean(String s) {
		return s.equals("true");
	}

	public static boolean getBoolean(String name) {
		return parseBoolean(System.getProperty(name, "false"));
	}

	public static Boolean valueOf(boolean b) {
		return new Boolean(b);
	}

	public static Boolean valueOf(String s) {
		return new Boolean(s);
	}
}
