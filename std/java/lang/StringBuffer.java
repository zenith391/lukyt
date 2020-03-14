package java.lang;

public class StringBuffer {

	public char[] chars;

	public StringBuffer() {
		chars = new char[0];
	}

	public StringBuffer(String str) {
		chars = str.toCharArray();
	}

	public StringBuffer append(char[] chars) {
		int oldLength = this.chars.length;
		char[] newChars = new char[this.chars.length + chars.length];
		for (int i = 0; i < newChars.length; i++) {
			if (i < this.chars.length) {
				newChars[i] = this.chars[i];
			} else {
				newChars[i] = chars[i-oldLength];
			}
		}
		this.chars = newChars;
		return this;
	}

	public StringBuffer append(String str) {
		append(str.toCharArray());
		return this;
	}

	public StringBuffer append(Object obj) {
		append(obj.toString());
		return this;
	}

	public StringBuffer append(long l) {
		return append(Long.toString(l));
	}

	public StringBuffer append(int i) {
		return append((long) i);
	}

	public String toString() {
		return new String(chars);
	}

}
