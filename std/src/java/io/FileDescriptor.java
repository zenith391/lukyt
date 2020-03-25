package java.io;

public class FileDescriptor {
	private long handle; // the Lua handle is actually written there, which means this field CANNOT be used inside of the Java Environment

	FileDescriptor() {}

	public static final FileDescriptor in = new FileDescriptor(); // TODO
	public static final FileDescriptor out = new FileDescriptor(); // TODO
	public static final FileDescriptor err = new FileDescriptor(); // TODO

	static final int MODE_R = 0;
	static final int MODE_W = 1;
	static final int MODE_A = 2;

	private void setHandle(long handle) { // helper method
		this.handle = handle;
	}

	public boolean valid() {
		return true;
	}

	native void open(String path, int mode);

	public void sync() {}
	native void read(byte[] b);
	native void write(byte[] b);
	native void close();
}
