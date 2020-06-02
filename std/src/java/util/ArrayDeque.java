package java.util;

public class ArrayDeque<E> extends AbstractCollection<E> implements Deque<E>, Cloneable {

	protected Object[] array;
	private int size = 0; // pointer to current element in array
	private int arrayIncrement = 1;

	public ArrayDeque() {
		this(10);
	}

	public ArrayDeque(Collection<? extends E> c) {
		this(c.size());
		addAll(c);
	}

	public ArrayDeque(int numElements) {
		array = new Object[numElements];
	}

	protected void increaseSize(int increment) {
		Object[] newArray = new Object[array.length + increment];
		System.arraycopy(array, 0, newArray, 0, array.length);
		array = newArray;
	}

	public void addFirst(E e) {
		if (e == null) {
			throw new NullPointerException();
		}
		if (array.length < size+1) {
			increaseSize(arrayIncrement);
		}
		System.arraycopy(array, 0, array, 1, size);
		array[0] = e;
		size++;
	}

	public void addLast(E e) {
		if (e == null) {
			throw new NullPointerException();
		}
		if (array.length < size+1) {
			increaseSize(arrayIncrement);
		}
		array[size] = e;
		size++;
	}

	public void clear() {
		array = new Object[10];
		size = 0;
	}

	public boolean isEmpty() {
		return size == 0;
	}

	public Iterator<E> iterator() {
		return new ArrayDequeIterator(this, false);
	}

	public Iterator<E> descendingIterator() {
		return new ArrayDequeIterator(this, true);
	}

	public boolean offerFirst(E e) {
		addFirst(e);
		return true;
	}

	public boolean offerLast(E e) {
		addLast(e);
		return true;
	}

	public E removeFirst() {
		if (size == 0) {
			throw new NoSuchElementException();
		}
		Object o = array[0];
		System.arraycopy(array, 1, array, 0, size-1);
		size--;
		return (E) o;
	}

	public E removeLast() {
		if (size == 0) {
			throw new NoSuchElementException();
		}
		size--;
		return (E) array[size+1];
	}

	public E pollFirst() {
		if (size == 0) {
			return null;
		}
		Object o = array[0];
		System.arraycopy(array, 1, array, 0, size-1);
		size--;
		return (E) o;
	}

	public E pollLast() {
		if (size == 0) {
			return null;
		}
		size--;
		return (E) array[size+1];
	}

	public E getFirst() {
		if (size == 0) {
			throw new NoSuchElementException();
		}
		return (E) array[0];
	}

	public E getLast() {
		if (size == 0) {
			throw new NoSuchElementException();
		}
		return (E) array[size];
	}

	public E peekFirst() {
		if (size == 0) {
			return null;
		}
		return (E) array[0];
	}

	public E peekLast() {
		if (size == 0) {
			return null;
		}
		return (E) array[size];
	}

	public boolean removeFirstOccurence(Object o) {
		for (int i = 0; i < size; i++) {
			if (o.equals(array[i])) {
				return true;
			}
		}
		return false;
	}

	public boolean removeLastOccurence(Object o) {
		for (int i = size; i > 0; i--) {
			if (o.equals(array[i])) {
				return true;
			}
		}
		return false;
	}

	public boolean add(E e) {
		addLast(e);
		return true;
	}

	public boolean offer(E e) {
		return offerLast(e);
	}

	public E remove() {
		return removeFirst();
	}

	public E poll() {
		return pollFirst();
	}

	public E element() {
		return getFirst();
	}

	public E peek() {
		return peekFirst();
	}

	public void push(E e) {
		addFirst(e);
	}

	public E pop() {
		return removeFirst();
	}

	public int size() {
		return size;
	}

	class ArrayDequeIterator<T> implements Iterator<T> {
		private ArrayDeque deque;
		private boolean descending;
		private int index;

		public ArrayDequeIterator(ArrayDeque deque, boolean descending) {
			this.deque = deque;
			this.descending = descending;
			if (descending) {
				index = deque.size() + 1;
			} else {
				index = -1;
			}
		}

		public boolean hasNext() {
			if (descending) {
				return index > 0;
			} else {
				return index < deque.size();
			}
		}

		public T next() {
			if (descending) {
				index--;
			} else {
				index++;
			}
			return (T) deque.array[index];
		}

		public void remove() {
			throw new UnsupportedOperationException();
		}
	}

}
