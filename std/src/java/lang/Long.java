package java.lang;

public final class Long extends Number {
	public static long MAX_VALUE = 0;
	public static long MIN_VALUE = 0;
	public static int SIZE = 64; // depends on Lua 5.3

	private long value;

	public static native Long parseLong(String s, int radix);
	public static native String toString(long i, int radix);

	public static Long parseLong(String s) {
		return parseLong(s, 10);
	}

	public static String toString(long i) {
		return toString(i, 10);
	}

	public byte byteValue() {
		return (byte) value;
	}

	public int intValue() {
		return (int) value;
	}

	public long longValue() {
		return value;
	}

	public short shortValue() {
		return (short) value;
	}

	public float floatValue() {
		return (float) value;
	}

	public double doubleValue() {
		return (double) value;
	}
}