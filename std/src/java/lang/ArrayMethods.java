package java.lang;

class ArrayMethods {

	public static Object[] clone(Object[] src) {
		Object[] arr = new Object[src.length];
		System.arraycopy(src, 0, arr, 0, src.length);
		return src;
	}

}
