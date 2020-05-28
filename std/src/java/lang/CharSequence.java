package java.lang;

public interface CharSequence {
	public char charAt(int index);
	public int length();
	public CharSequence subSequence(int start, int end);
	public String toString();
}
