package java.util;

public interface ListIterator<E> extends Iterator<E> {
	public void add(E obj);
	public void set(E obj);
	public boolean hasPrevious();
	public E previous();
	public int nextIndex();
	public int previousIndex();
	public void remove();
}