package java.lang;

import java.io.*;

public abstract class Process {
	// to get r/w, use write mode in popen and redirect output to a /tmp file (using > redirection operand)
	public int waitFor() {
		return 0; // if not alive call stream:close() and retrieve status code (3rd return)
	}

	public boolean isAlive() {
		return false; // must do read(*a) and return false if empty
	}

	public abstract OutputStream getOutputStream();
	public abstract InputStream getInputStream();
	public abstract InputStream getErrorStream();

	//public abstract int waitFor() throws InterruptedException;
	public abstract int exitValue();
	public abstract void destroy();

	public Process destroyForcibly() {
		destroy();
		return this;
	}

}
