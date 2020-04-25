package java.lang;

import java.util.ArrayList;

public class Thread {
	private long handle;
	private static ArrayList<Thread> threads;
	private Runnable run;
	private String name;

	public Thread() {}

	public Thread(Runnable run) {
		this.run = run;
	}

	public Thread(Runnable run, String name) {
		this.run = run;
		this.name = name;
	}

	public static Thread currenThread() {
		return threads.get((int) getCurrentThreadHandle());
	}

	public static void yield() {
		yield(getCurrentThreadHandle());
	}

	public void start() {
		start(handle);
	}

	public void run() {
		if (run != null) {
			run.run();
		}
	}

	private static native long getCurrentThreadHandle();
	private static native void yield(long handle);
	private static native void start(long handle);
}
