package java.util;

public abstract class AbstractSet<E> extends AbstractCollection<E> implements Set<E> {

	protected AbstractSet() {}

	public boolean equals(Object obj) {
		if (obj == this) return true;
		if (obj instanceof Set) {
			Set set = (Set) obj;
			if (set.size() != size()) {
				return false;
			}
			return containsAll(set);
		}
		return false;
	}

	public int hashCode() {
		int sum = 0;
		for (E elem : this) {
			if (elem != null) {
				sum += elem.hashCode();
			}
		}
		return sum;
	}
}
