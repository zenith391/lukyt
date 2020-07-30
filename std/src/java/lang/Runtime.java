package java.lang;

import lukyt.*;

import java.io.*;

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

	private static final LuaObject popen = LuaObject._G.get("io").get("popen");

	public Process exec(String[] args) {
		StringBuilder cmd = new StringBuilder();
		for (int i = 0; i < args.length; i++) {
			cmd.append(args[i]);
			if (i < args.length) {
				cmd.append(" ");
			}
		}

		LuaObject stream = popen.execute(new LuaObject[] {
			LuaObject.fromString(cmd.toString()),
			LuaObject.fromString("r")
		});
		RuntimeProcess proc = new RuntimeProcess(stream);
		return proc;
	}

	public static Runtime getRuntime() {
		if (runtime == null) {
			runtime = new Runtime();
		}
		return runtime;
	}

	static class RuntimeProcess extends Process {
		private LuaObject pStream;
		private LuaObject wrStream;
		private InputStream in;

		public RuntimeProcess(LuaObject pStream) {
			this.pStream = pStream;
			this.in = new LuaInputStream(pStream);
		}

		public InputStream getInputStream() {
			return in;
		}

		public InputStream getErrorStream() {
			return null;
		}

		public OutputStream getOutputStream() {
			return null;
		}

		public void destroy() {}

		public int exitValue() {
			return 0;
		}
	}

}
