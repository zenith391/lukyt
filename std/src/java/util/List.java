package java.util;

public interface List<E> extends Collection<E> {
	public boolean addAll(int index, Collection<? extends E> c);
	public E get(int index);
	public E set(int index, E obj);
	public void add(int index, E obj);
	public E remove(int index);
	public int indexOf(Object obj);
	public int lastIndexOf(Object obj);
	public ListIterator<E> listIterator();
	public ListIterator<E> listIterator(int index);
	public List<E> subList(int fromIndex, int toIndex);
}
