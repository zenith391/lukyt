package java.lang;

public class Object {

	private Class thizClass;

	public boolean equals(Object other) {
		return this == other;
	}

	public String toString() {
		return getClass().getName() + "@" + hashCode();
	}

	protected void finalize() throws Throwable {}

	public final native void notify();
	public final native void notifyAll();

	public final native void wait(long timeout) throws InterruptedException;

	public final void wait(long timeout, int nanos) throws InterruptedException {
		wait(timeout);
	}

	public final void wait() throws InterruptedException {
		wait(0);
	}

	public final Class<?> getClass() {
		if (thizClass == null) {
			thizClass = newClass();
		}
		return thizClass;
	}

	private native Class<?> newClass();
	public native int hashCode();

}
