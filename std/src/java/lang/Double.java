package java.lang;

public final class Double extends Number {
	public static long MAX_VALUE = 0;
	public static long MIN_VALUE = 0;
	public static int SIZE = 64; // depends on Lua 5.3

	private double value;

	public Double(double d) {
		this.value = d;
	}

	public static Double valueOf(double d) {
		return new Double(d);
	}

	public static Double parseDouble(String s) {
		return null; // TODO
	}

	public static native String toString(double i);

	public byte byteValue() {
		return (byte) value;
	}

	public int intValue() {
		return (int) value;
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
		return value;
	}
}