package java.util;

public abstract class AbstractList<E> extends AbstractCollection<E> implements List<E> {

	protected transient int modCount;

	public abstract E get(int index);
	public abstract int size();

	protected AbstractList() {
		modCount = 0;
	}

	public ListIterator<E> listIterator() {
		return new AbstractListIterator<E>(this, 0);
	}

	public ListIterator<E> listIterator(int start) {
		return new AbstractListIterator<E>(this, start);
	}

	public Iterator<E> iterator() {
		return (Iterator<E>) new AbstractListIterator<E>(this, 0);
	}

	public int indexOf(Object obj) {
		ListIterator iterator = listIterator();
		Object o = null;
		int i = 0;
		while (iterator.hasNext()) {
			o = iterator.next();
			if (o.equals(obj)) {
				return i;
			}
			i++;
		}
		return -1;
	}

	public int lastIndexOf(Object obj) {
		ListIterator iterator = listIterator(size());
		Object o = null;
		int i = 0;
		while (iterator.hasPrevious()) {
			o = iterator.previous();
			if (o.equals(obj)) {
				return i;
			}
			i++;
		}
		return -1;
	}

	public void clear() {
		try {
			removeRange(0, size());
		} catch (UnsupportedOperationException e) {
			for (int i = 0; i < size(); i++) {
				remove(i);
			}
		}
	}

	public boolean addAll(int index, Collection<? extends E> c) {
		return false; // TODO
	}

	public List<E> subList(int fromIndex, int toIndex) {
		return new AbstractSubList<E>(this, fromIndex, toIndex);
	}

	public boolean add(Object obj) {
		add(size(), obj);
		return true;
	}

	public int hashCode() {
		int hashCode = 1;
		int size = size();
		for (int i = 0; i < size; i++) {
			Object obj = get(i);
			hashCode = 31 * hashCode + (obj == null ? 0 : obj.hashCode());
		}
		return hashCode;
	}

	protected void removeRange(int fromIndex, int toIndex) {
		ListIterator iterator = listIterator(fromIndex);
		while (iterator.nextIndex() < toIndex) {
			iterator.next();
			iterator.remove();
		}
	}

	public E set(int index, Object obj) {
		throw new UnsupportedOperationException();
	}

	public void add(int index, Object obj) {
		throw new UnsupportedOperationException();
	}

	public E remove(int index) {
		throw new UnsupportedOperationException();
	}

	class AbstractSubList<E> extends AbstractList<E> {
		private int from;
		private int to;
		private AbstractList<E> list;

		public AbstractSubList(AbstractList<E> list, int from, int to) {
			this.list = list;
			this.from = from;
			this.to = to;
		}

		public E get(int index) {
			return list.get(index + from);
		}

		public E set(int index, Object obj) {
			return list.set(index + from, obj);
		}

		public void add(int index, Object obj) {
			list.add(index + from, obj);
		}

		public E remove(int index) {
			return list.remove(index + from);
		}

		public int size() {
			return to - from;
		}
	}

	class AbstractListIterator<T> implements ListIterator<T> {
		private AbstractList<T> list;
		private int cur;
		private int expectedModCount;

		public AbstractListIterator(AbstractList<T> list, int start) {
			this.list = list;
			this.expectedModCount = list.modCount;
			this.cur = start;
		}

		public boolean hasNext() {
			return cur < list.size();
		}

		public boolean hasPrevious() {
			return cur > 0;
		}

		public int previousIndex() {
			return cur - 1;
		}

		public int nextIndex() {
			return cur + 1;
		}

		public void set(T obj) {
			if (list.modCount != expectedModCount)
				throw new ConcurrentModificationException();
			list.set(cur, obj);
			expectedModCount = list.modCount;
		}

		public void add(T obj) {
			if (list.modCount != expectedModCount)
				throw new ConcurrentModificationException();
			list.add(cur, obj);
			expectedModCount = list.modCount;
		}

		public void remove() {
			if (list.modCount != expectedModCount)
				throw new ConcurrentModificationException();
			list.remove(cur);
			expectedModCount = list.modCount;
		}

		public T next() {
			if (list.modCount != expectedModCount)
				throw new ConcurrentModificationException();
			return list.get(cur++);
		}

		public T previous() {
			if (list.modCount != expectedModCount)
				throw new ConcurrentModificationException();
			return list.get(cur--);
		}
	}
}
