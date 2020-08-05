package java.lang;

public final class Long extends Number {
	public static long MAX_VALUE = 9223372036854775807L;
	public static long MIN_VALUE = -9223372036854775808L;
	public static int SIZE = 64; // depends on Lua 5.3
	public static int BYTES = 8;
	public static Class<Long> TYPE = Long.class;

	private long value;

	public Long(long l) {
		this.value = l;
	}

	public Long(String str) {
		this.value = parseLong(str);
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

	public static long parseLong(String s, int radix) {
		if (s == null || s.length() == 0) throw new NumberFormatException("null or empty string");
		s = s.toLowerCase();
		int j = 0;
		long l = 0;
		char sign = s.charAt(0);
		boolean hasSign = sign == '+' || sign == '-';
		int start = hasSign ? 1 : 0;
		for (int i = s.length()-1; i > start; i--) {
			char ch = s.charAt(i);
			long digit = toDigit(ch, radix);
			if (digit == -1 || digit > radix) {
				throw new NumberFormatException(s);
			}
			l += digit * (j+1);
			j++;
		}
		if (sign == '-')
			l = -l;
		return l;
	}

	public static String toString(long i, long radix) {
		StringBuilder sb = new StringBuilder();
		if (i == 0) {
			sb.append("0");
		} else if (i < 0) {
			sb.append("-");
			i = -i;
		}
		while (i > 0) {
			long digit = i % radix;
			char ch = (char) (digit + 0x30);
			if (digit > 9) {
				ch = (char) (digit + 0x61);
			}
			sb.insert(0, ch);
			i /= radix;
		}
		String s = sb.toString();
		return s;
	}

	public static long parseLong(String s) {
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