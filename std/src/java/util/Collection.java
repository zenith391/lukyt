package java.util;

public interface Collection<E> extends Iterable<E> {
	public int size();
	public boolean isEmpty();
	public boolean contains(Object obj);
	public Iterator<E> iterator();
	public Object[] toArray();
	public <T> T[] toArray(T[] array);
	public boolean add(E obj);
	public boolean remove(Object o);
	public boolean containsAll(Collection<?> c);
	public boolean addAll(Collection<? extends E> c);
	public boolean removeAll(Collection<?> c);
	public boolean retainAll(Collection<?> c);
	public void clear();
}
