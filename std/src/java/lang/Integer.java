package java.lang;

public final class Integer extends Number {
	public static final int MAX_VALUE = 0x7FFFFFFF;
	public static final int MIN_VALUE = (-MAX_VALUE) - 1;
	public static final int SIZE = 32; // depends on Lua 5.3
	public static final int BYTES = 4;
	public static final Class<Integer> TYPE = Integer.class;

	private int value;

	public Integer() {
		value = 0;
	}

	public Integer(int value) {
		this.value = value;
	}

	public static Integer valueOf(int i) {
		return new Integer(i);
	}

	public static int parseInt(String s, int radix) {
		return (int) Long.parseLong(s, radix);
	}

	public static String toString(int i, int radix) {
		return Long.toString((long) i, radix);
	}

	public static int parseInt(String s) {
		return parseInt(s, 10);
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
