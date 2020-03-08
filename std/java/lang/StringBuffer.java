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
		char[] newChars = new char[this.chars.length + chars.length];
		for (int i = 0; i < this.chars.length; i++) {
			if (i < this.chars.length) {
				newChars[i] = this.chars[i];
			} else {
				newChars[i] = chars[i-this.chars.length];
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

	public String toString() {
		return new String(chars);
	}

}
