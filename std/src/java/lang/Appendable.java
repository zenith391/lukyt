package java.lang;

import java.io.IOException;

public interface Appendable {
	public Appendable append(char c) throws IOException;
	public Appendable append(CharSequence sq) throws IOException;
	public Appendable append(CharSequence sq, int start, int end) throws IOException;
}
