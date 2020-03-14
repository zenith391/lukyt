package java.lang;

public class Runtime {

	private static Runtime runtime = null;

	public native void gc();
	public native long freeMemory();
	public native long maxMemory();
	public native long totalMemory();
	public native void halt(int status);
	public native void load(String filename);

	public void loadLibrary(String libname) {
		load(libname + ".lua");
	}

	public void exit(int status) {
		halt(status);
	}

	public int availableProcessors() {
		return 1; // always executed on one core, as using coroutines
	}

	public static Runtime getRuntime() {
		if (runtime == null) {
			runtime = new Runtime();
		}
		return runtime;
	}

}
