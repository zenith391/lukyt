package java.util;

public interface List extends Collection {
	public boolean addAll(int index, Collection c);
	public Object get(int index);
	public Object set(int index, Object obj);
	public void add(int index, Object obj);
	public Object remove(int index);
	public int indexOf(Object obj);
	public int lastIndexOf(Object obj);
	public ListIterator listIterator();
	public ListIterator listIterator(int index);
	public List subList(int fromIndex, int toIndex);
}
