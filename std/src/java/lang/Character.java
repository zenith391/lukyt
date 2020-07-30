package java.lang;

public class Character {

	public static String toString(char c) {
		return String.valueOf(c);
	}

	public static char toUpperCase(char ch) {
		if (ch > 96 && ch <= 122) {
			ch &= 0b11011111;
		}
		return ch;
	}

	public static char toLowerCase(char ch) {
		if (ch > 64 && ch <= 90) {
			ch |= 0b00100000;
		}
		return ch;
	}
}
