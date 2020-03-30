package java.lang;

public class StringBuilder {

	public char[] chars;

	public StringBuilder() {
		chars = new char[0];
	}

	public StringBuilder(String str) {
		chars = str.toCharArray();
	}

	public StringBuilder append(char[] chars) {
		int orgLength = this.chars.length;
		char[] newChars = new char[orgLength + chars.length];
		System.arraycopy(this.chars, 0, newChars, 0, orgLength);
		System.arraycopy(chars, 0, newChars, orgLength, chars.length);
		this.chars = newChars;
		return this;
	}

	public StringBuilder append(String str) {
		append(str.toCharArray());
		return this;
	}

	public StringBuilder append(Object obj) {
		append(String.valueOf(obj));
		return this;
	}

	public StringBuilder append(char c) {
		char[] array = new char[1];
		array[0] = c;
		return append(array);
	}

	public StringBuilder append(long l) {
		return append(Long.toString(l));
	}

	public StringBuilder append(int i) {
		return append((long) i);
	}

	public String toString() {
		return new String(chars);
	}

}
