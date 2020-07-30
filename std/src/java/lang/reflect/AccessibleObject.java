package java.lang.reflect;

public class AccessibleObject implements AnnotatedElement {

	protected boolean accessible = false;

	protected AccessibleObject() {}

	public boolean isAccessible() {
		return accessible;
	}

	public void setAccessible(boolean accessible) {
		this.accessible = accessible;
	}


	public static void setAccessible(AccessibleObject[] array, boolean flag) {
		for (AccessibleObject obj : array) {
			obj.setAccessible(flag);
		}
	}

}
