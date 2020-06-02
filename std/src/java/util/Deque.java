package java.util;

public interface Deque<E> extends Queue<E> {
	public void addFirst(E e);
	public void addLast(E e);
	public boolean offerFirst(E e);
	public boolean offerLast(E e);
	public E removeFirst();
	public E removeLast();

	public E pollFirst();
	public E pollLast();
	public E peekFirst();
	public E peekLast();

	public E pop();

	public E getFirst();
	public E getLast();

	public boolean removeFirstOccurence(Object o);
	public boolean removeLastOccurence(Object o);

	public Iterator<E> descendingIterator();
}
