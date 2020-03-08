package java.lang;

public class String {
	public char[] characters; // not Unicode-proof

	public String(char[] chars) {
		characters = chars;
	}

	public int length() {
		return characters.length;
	}
}
