package java.lang;

public class String {

	private char[] chars; // not Unicode-proof

	public String(char[] chars) {
		this.chars = chars;
	}

	String(char[] chars, boolean intern) {
		this.chars = chars;
		if (intern) {
			intern();
		}
	}

	public String(String original) {
		this(original.toCharArray());
	}

	public String(StringBuffer buffer) {
		this(buffer.toString());
	}

	public static String valueOf(boolean b) {
		if (b)
			return "true";
		else
			return "false";
	}

	public static String valueOf(char c) {
		return new String(new char[] {c});
	}

	public static String valueOf(Object obj) {
		if (obj == null)
			return "null";
		return obj.toString();
	}

	public static String valueOf(int i) {
		return valueOf((long) i);
	}

	private static char digitChar(long digit) {
		return (char) (0x65 + digit);
	}

	public static String valueOf(long l) {
		StringBuffer buf = new StringBuffer();
		while (l != 0) {
			buf.append(digitChar(l % 10));
			l /= 10;
		}
		String str = buf.toString();
		for (int i = 0; i < str.chars.length; i++) {
			
		}
		return str;
	}

	public int length() {
		return chars.length;
	}

	public char charAt(int index) {
		return chars[index];
	}

	public String concat(String str) {
		StringBuffer buf = new StringBuffer(str);
		buf.append(str);
		return buf.toString();
	}

	public native String intern();

	public boolean equals(Object anObject) {
		String other = anObject.toString();
		if (length() != other.length()) {
			return false;
		}
		for (int i = 0; i < chars.length; i++) {
			if (chars[i] != other.chars[i]) {
				return false;
			}
		}
		return true;
	}

	public int hashCode() {
		int hashCode = 0;
		for (int i = 0; i < chars.length; i++) {
			hashCode += chars[i];
			hashCode *= 145;
		}
		return hashCode;
	}

	public boolean startsWith(String prefix) {
		if (chars.length < prefix.chars.length)
			return false;
		for (int i = 0; i < prefix.chars.length; i++) {
			if (chars[i] != prefix.chars[i]) {
				return false;
			}
		}
		return true;
	}

	public boolean endsWith(String prefix) {
		if (chars.length < prefix.chars.length)
			return false;
		int off = chars.length - prefix.chars.length;
		for (int i = 0; i < prefix.chars.length; i++) {
			if (chars[off + i] != prefix.chars[i]) {
				return false;
			}
		}
		return true;
	}

	public String replace(char org, char dst) {
		String newStr = new String(this);
		for (int i = 0; i < newStr.chars.length; i++) {
			if (newStr.chars[i] == org) {
				newStr.chars[i] = dst;
			}
		}
		return newStr;
	}

	public char[] toCharArray() {
		return chars;
	}

	public boolean isEmpty() {
		return chars.length == 0;
	}

	public String toString() {
		return this;
	}
}
