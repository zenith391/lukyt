package java.util;

public interface ListIterator extends Iterator {
	public void add(Object obj);
	public void set(Object obj);
	public boolean hasPrevious();
	public Object previous();
	public int nextIndex();
	public int previousIndex();
	public void remove();
}