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
		int orgLength = this.chars.length;
		char[] newChars = new char[orgLength + chars.length];
		System.arraycopy(this.chars, 0, newChars, 0, orgLength);
		System.arraycopy(chars, 0, newChars, orgLength, chars.length);
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

	public StringBuffer append(char c) {
		char[] array = new char[1];
		array[0] = c;
		return append(array);
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
