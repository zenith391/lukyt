package java.lang;

public class StringBuilder implements Appendable {

	public char[] chars;

	public StringBuilder() {
		chars = new char[0];
	}

	public StringBuilder(String str) {
		chars = str.toCharArray();
	}

	/*
	public StringBuilder append(char[] chars) {
		int orgLength = this.chars.length;
		char[] newChars = new char[orgLength + chars.length];
		System.arraycopy(this.chars, 0, newChars, 0, orgLength);
		System.arraycopy(chars, 0, newChars, orgLength, chars.length);
		this.chars = newChars;
		return this;
	}
	*/

	public native StringBuilder append(char[] chars);

	public StringBuilder append(CharSequence sq) {
		return append(sq.toString());
	}

	public StringBuilder append(CharSequence sq, int start, int end) {
		return append(sq.subSequence(start, end));
	}

	public StringBuilder append(String str) {
		return append(str.toCharArray());
	}

	public StringBuilder append(Object obj) {
		return append(String.valueOf(obj));
	}

	public StringBuilder append(char c) {
		return append(new char[] {c});
	}

	public StringBuilder append(double d) {
		return append(String.valueOf(d));
	}

	public StringBuilder append(float f) {
		return append(String.valueOf(f));
	}

	public StringBuilder append(long l) {
		return append(Long.toString(l));
	}

	public StringBuilder append(int i) {
		return append((long) i);
	}

	public StringBuilder insert(int off, char[] chars) {
		int orgLength = this.chars.length;
		char[] newChars = new char[orgLength + chars.length];
		System.arraycopy(this.chars, 0, newChars, 0, off);
		System.arraycopy(chars, 0, newChars, off, chars.length);
		System.arraycopy(this.chars, off, newChars, off+1, orgLength-off);
		this.chars = newChars;
		return this;
	}

	public StringBuilder insert(int off, char c) {
		return insert(off, new char[] {c});
	}

	public StringBuilder insert(int off, String str) {
		return insert(off, str.toCharArray());
	}

	public String toString() {
		return new String(chars);
	}

}
