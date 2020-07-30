package java.lang;

import java.util.ArrayList;

import lukyt.LuaObject;

public class Thread {
	private long handle;
	private static ArrayList<Thread> threads;
	private Runnable run;

	// MAX_PRIORITY-priority = number of opcodes executed between each yield
	public static int MAX_PRIORITY = 10;
	public static int NORM_PRIORITY = 5;
	public static int MIN_PRIORITY = 1;

	static {
		//threads.add(new Thread(getMainThreadHandle()));
	}

	public Thread() {
		this.handle = initNewHandle();
	}

	private Thread(long handle) {
		this.handle = handle;
	}

	public Thread(Runnable run) {
		this(run, null);
	}

	public Thread(Runnable run, String name) {
		this();
		this.run = run;
		if (name != null) {
			setName(name);
		}
	}

	public Thread(String name) {
		this(null, name);
	}

	public native void setName(String name);
	public native String getName();

	public native int getPriority();
	public native void setPriority(int priority);

	public native StackTraceElement[] getStackTrace();

	private native long initNewHandle();

	public static Thread currentThread() {
		long currHandle = getCurrentThreadHandle();
		for (Thread t : threads) {
			if (t.handle == currHandle) {
				return t;
			}
		}
		throw new RuntimeException("Could not find current thread ?!");
	}

	public static void yield() { // calls coroutine.yield()
		LuaObject coroutine = LuaObject._ENV.get("coroutine");
		coroutine.executeChild("yield");
	}

	public static native void sleep(long millis) throws InterruptedException;

	public static void sleep(long millis, int nanos) throws InterruptedException {
		sleep(millis);
	}

	public native void start();

	public void run() {
		if (run != null) {
			run.run();
		}
	}

	private static native long getCurrentThreadHandle();
	private static native long getMainThreadHandle();
}
