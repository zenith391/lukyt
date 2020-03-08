package java.lang;

public class String {
	private char[] chars; // not Unicode-proof

	public String(char[] chars) {
		this.chars = chars;
	}

	public int length() {
		return chars.length;
	}

	public char[] toCharArray() {
		return chars;
	}
}
