package java.util;

public abstract class AbstractList extends AbstractCollection implements List {

	protected transient int modCount;

	public abstract Object get(int index);
	public abstract int size();

	protected AbstractList() {
		modCount = 0;
	}

	public ListIterator listIterator() {
		return new AbstractListIterator(this, 0);
	}

	public ListIterator listIterator(int start) {
		return new AbstractListIterator(this, start);
	}

	public Iterator iterator() {
		return (Iterator) new AbstractListIterator(this, 0);
	}

	public int indexOf(Object obj) {
		ListIterator iterator = listIterator();
		int i = 0;
		for (Object o = null; iterator.hasNext(); o = iterator.next()) {
			if (o.equals(obj)) {
				return i;
			}
			i++;
		}
		return -1;
	}

	public int lastIndexOf(Object obj) {
		ListIterator iterator = listIterator(size());
		int i = 0;
		for (Object o = null; iterator.hasPrevious(); o = iterator.previous()) {
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

	public boolean addAll(int index, Collection c) {
		return false; // TODO
	}

	public List subList(int fromIndex, int toIndex) {
		return new AbstractSubList(this, fromIndex, toIndex);
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

	public Object set(int index, Object obj) {
		throw new UnsupportedOperationException();
	}

	public void add(int index, Object obj) {
		throw new UnsupportedOperationException();
	}

	public Object remove(int index) {
		throw new UnsupportedOperationException();
	}

	class AbstractSubList extends AbstractList {
		private int from;
		private int to;
		private AbstractList list;

		public AbstractSubList(AbstractList list, int from, int to) {
			this.list = list;
			this.from = from;
			this.to = to;
		}

		public Object get(int index) {
			return list.get(index + from);
		}

		public Object set(int index, Object obj) {
			return list.set(index + from, obj);
		}

		public void add(int index, Object obj) {
			list.add(index + from, obj);
		}

		public Object remove(int index) {
			return list.remove(index + from);
		}

		public int size() {
			return to - from;
		}
	}

	class AbstractListIterator implements ListIterator {
		private AbstractList list;
		private int cur;
		private int expectedModCount;

		public AbstractListIterator(AbstractList list, int start) {
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

		public void set(Object obj) {
			if (list.modCount != expectedModCount)
				throw new ConcurrentModificationException();
			list.set(cur, obj);
			expectedModCount = list.modCount;
		}

		public void add(Object obj) {
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

		public Object next() {
			if (list.modCount != expectedModCount)
				throw new ConcurrentModificationException();
			return list.get(cur++);
		}

		public Object previous() {
			if (list.modCount != expectedModCount)
				throw new ConcurrentModificationException();
			return list.get(cur--);
		}
	}
}
