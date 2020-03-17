package java.lang;

public final class Integer extends Number {
	public static int MAX_VALUE = 0x7FFFFFFF;
	public static int MIN_VALUE = 0;
	public static int SIZE = 64; // depends on Lua 5.3

	private int value;

	public Integer() {
		value = 0;
	}

	public Integer(int value) {
		this.value = value;
	}

	public static Integer parseInteger(String s, int radix) {
		return new Integer(Long.parseLong(s, radix).intValue());
	}

	public static String toString(int i, int radix) {
		return Long.toString((long) i, radix);
	}

	public static Integer parseInteger(String s) {
		return parseInteger(s, 10);
	}

	public static String toString(int i) {
		return toString(i, 10);
	}

	public byte byteValue() {
		return (byte) value;
	}

	public int intValue() {
		return value;
	}

	public long longValue() {
		return (long) value;
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
