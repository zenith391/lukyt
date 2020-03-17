package java.lang;

public class String {

	private char[] chars; // not Unicode-proof
	private static String[] interned = new String[0];

	public String(char[] chars) {
		this.chars = chars;
		intern();
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

	public String intern() {
		for (int i = 0; i < interned.length; i++) {
			if (this.equals(interned[i])) {
				return interned[i];
			}
		}
		// not found, insert the string
		String[] newArray = new String[interned.length+1];
		for (int i = 0; i < interned.length; i++) {
			newArray[i] = interned[i];
		}
		newArray[interned.length] = this;
		interned = newArray;
		return this;
	}

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

	public char[] toCharArray() {
		return chars;
	}

	public String toString() {
		return this;
	}
}
