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
		}
		return hashCode;
	}

	public String replace(char org, char dst) {
		for (int i = 0; i < chars.length; i++) {
			if (chars[i] == org) {
				chars[i] = dst;
			}
		}
		return this;
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
