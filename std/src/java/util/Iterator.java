package java.util;

public interface Iterator<T> {
	public boolean hasNext();
	public T next();
	public void remove();
}
