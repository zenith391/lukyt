package java.util;

public class ArrayList<E> extends AbstractList<E> implements RandomAccess {

	private Object[] array;
	private int size = 0;

	public ArrayList(int initialCapacity) {
		super();
		array = new Object[initialCapacity];
	}

	public ArrayList(Collection<E> c) {
		this(c.size());
		addAll(c);
	}

	public ArrayList() {
		this(10);
	}

	protected void increaseSize(int increment) {
		Object[] newArray = new Object[array.length + increment];
		System.arraycopy(array, 0, newArray, 0, array.length);
		array = newArray;
	}

	public void trimToSize() {
		Object[] newArray = new Object[size];
		System.arraycopy(array, 0, newArray, 0, size);
		array = newArray;
	}

	public E set(int index, E obj) {
		if (index < 0 || index >= size) {
			throw new IndexOutOfBoundsException(Integer.toString(index));
		}
		array[index] = obj;
		modCount++;
		return obj;
	}

	public void add(int index, E obj) {
		if (index < 0 || index >= size) {
			throw new IndexOutOfBoundsException(Integer.toString(index));
		}
		if (size + 1 > array.length)
			increaseSize(1);
		System.arraycopy(array, index, array, index+1, array.length-index-1);
		array[index] = obj;
		modCount++;
		size++;
	}

	public boolean add(E obj) {
		if (size + 1 > array.length)
			increaseSize(1);
		array[size] = obj;
		size++;
		return true;
	}

	public E remove(int index) {
		if (index < 0 || index > size) {
			throw new IndexOutOfBoundsException(Integer.toString(index));
		}
		Object old = array[index];
		System.arraycopy(array, index, array, index-1, array.length-index-1);
		modCount++;
		size--;
		return (E) old;
	}

	public E get(int index) {
		if (index < 0 || index > size) {
			throw new IndexOutOfBoundsException(Integer.toString(index));
		}
		return (E) array[index];
	}

	public int size() {
		return size;
	}

}
