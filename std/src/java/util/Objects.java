package java.util;

import java.util.function.Supplier;

public final class Objects {

	public static boolean equals(Object a, Object b) {
		if (a == null && b == null) {
			return true;
		} else if (a == null) { // && b != null is automatically implied by the above conditon
			return false;
		} else if (b == null) { // same as above
			return false;
		}
		return a.equals(b);
	}

	public static boolean deepEquals(Object a, Object b) {
		return equals(a, b); // TODO: actually do a deep check
	}

	public static int hashCode(Object o) {
		if (o == null) {
			return 0;
		} else {
			return o.hashCode();
		}
	}

	public static int hash(Object... values) {
		int hash = 1;
		for (Object o : values) {
			hash = 31 * hash + (o == null ? 0 : o.hashCode());
		}
		return hash;
	}

	public static String toString(Object o) {
		return toString(o, "null");
	}

	public static <T> int compare(T a, T b, Comparator<? super T> c) {
		if (a == b) {
			return 0;
		} else {
			return c.compare(a, b);
		}
	}

	public static <T> T requireNonNull(T o) {
		if (o == null) {
			throw new NullPointerException();
		}
		return o;
	}

	public static <T> T requireNonNull(T o, String message) {
		if (o == null) {
			throw new NullPointerException(message);
		}
		return o;
	}

	public static <T> T requireNonNull(T o, Supplier<String> supplier) {
		if (o == null) {
			throw new NullPointerException(supplier.get());
		}
		return o;
	}

	public static boolean isNull(Object obj) {
		return obj == null;
	}

	public static boolean nonNull(Object obj) {
		return obj != null;
	}

	public static String toString(Object o, String nullDefault) {
		if (o == null) {
			return nullDefault;
		} else {
			return o.toString();
		}
	}
}
