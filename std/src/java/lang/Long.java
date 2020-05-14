package java.lang;

public final class Long extends Number {
	public static long MAX_VALUE = 0;
	public static long MIN_VALUE = 0;
	public static int SIZE = 64; // depends on Lua 5.3

	private long value;

	public Long(long l) {
		this.value = l;
	}

	private static long toDigit(char ch, int radix) {
		long l = ch;
		l -= 0x30;
		if (l < 0) {
			l = -1;
		} else if (l > 9) {
			l = ch - 0x61;
		}
		return l;
	}

	public static Long parseLong(String s, int radix) {
		int j = 0;
		long l = 0;
		for (int i = s.length(); i > 0; i--) {
			char ch = s.charAt(i);
			long digit = toDigit(ch, radix);
			if (digit == -1) {
				throw new NumberFormatException(s);
			}
			l += digit * (j+1);
			j++;
		}
		return new Long(l);
	}

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