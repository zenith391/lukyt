package java.lang;

public abstract class Enum<T extends Enum<T>> {

	private String name;
	private int ordinal;

	protected Enum(String name, int ordinal) {
		this.name = name;
		this.ordinal = ordinal;
	}
	
	public static <T> T valueOf(Class<T> enumType, String s) {
		// TODO
		return null;
	}
	
	public final boolean equals(Object o) {
		return this == o;
	}

	public final int hashCode() {
		return super.hashCode();
	}

	public String toString() {
		return name;
	}

	public final String name() {
		return name;
	}

	public int ordinal() {
		return ordinal;
	}

	public final Class<T> getDeclaringClass() {
		return (Class<T>) getClass();
	}

	public final int compareTo(T e) {
		if (ordinal < e.ordinal()) {
			return -1;
		} else if (ordinal == e.ordinal()) {
			return 0;
		} else {
			return 1;
		}
	}

	protected final T clone() {
		throw new CloneNotSupportedException();
	}

}
