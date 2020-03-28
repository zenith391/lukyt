package java.util;

public abstract class AbstractCollection implements Collection {
	public abstract Iterator iterator();
	public abstract int size();

	public boolean isEmpty() {
		return size() == 0;
	}

	public boolean contains(Object o) {
		Iterator iterator = iterator();
		while (iterator.hasNext()) {
			if (o == null) {
				if (iterator.next() == null)
					return true;
			} else {
				if (iterator.next().equals(o))
					return true;
			}
		}
		return false;
	}

	public Object[] toArray() {
		return toArray(new Object[size()]);
	}

	public Object[] toArray(Object[] array) {
		int size = size();
		if (array.length < size) {
			array = new Object[size];
		}
		Iterator iterator = iterator();
		for (int i = 0; i < size; i++) {
			array[i] = iterator.next();
		}
		return array;
	}

	public boolean add(Object obj) {
		throw new UnsupportedOperationException();
	}

	public void clear() {
		throw new UnsupportedOperationException();
	}

	public boolean remove(Object obj) {
		Iterator iterator = iterator();
		while (iterator.hasNext()) {
			if (obj == null) {
				if (iterator.next() == null) {
					iterator.remove();
					return true;
				}
			} else {
				if (iterator.next().equals(obj)) {
					iterator.remove();
					return true;
				}
			}
		}
		return false;
	}

	public boolean containsAll(Collection c) {
		Iterator iterator = c.iterator();
		while (iterator.hasNext()) {
			if (!contains(iterator.next())) {
				return false;
			}
		}
		return true;
	}

	public boolean addAll(Collection c) {
		Iterator iterator = c.iterator();
		boolean s = true;
		while (iterator.hasNext()) {
			add(iterator.next());
		}
		return true;
	}

	public boolean removeAll(Collection c) {
		Iterator iterator = c.iterator();
		while (iterator.hasNext()) {
			remove(iterator.next());
		}
		return true;
	}

	public boolean retainAll(Collection c) {
		return false; // TODO
	}

	public String toString() {
		StringBuffer buf = new StringBuffer();
		buf.append(getClass().getName());
		buf.append('[');
		Iterator i = iterator();
		for (Object o = null; i.hasNext(); o = i.next()) {
			buf.append(String.valueOf(o));
			if (i.hasNext()) {
				buf.append(", ");
			}
		}
		buf.append(']');
		return buf.toString();
	}
}
