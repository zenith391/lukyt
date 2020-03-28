package java.lang;

public class ArrayIndexOutOfBoundsException extends IndexOutOfBoundsException {

	public ArrayIndexOutOfBoundsException() {
		super();
	}

	public ArrayIndexOutOfBoundsException(int index) {
		super(Integer.toString(index));
	}

	public ArrayIndexOutOfBoundsException(String s) {
		super(s);
	}

}
