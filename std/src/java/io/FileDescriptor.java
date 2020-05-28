package java.io;

public class FileDescriptor {
	private long handle; // the Lua handle is actually written there, which means this field CANNOT be used inside of the Java Environment

	private FileDescriptor() {}

	private FileDescriptor(int fd) {
		openStandard(fd);
	}

	public static final FileDescriptor in = new FileDescriptor(0); // TODO
	public static final FileDescriptor out = new FileDescriptor(1); // TODO
	public static final FileDescriptor err = new FileDescriptor(2); // TODO

	static final int MODE_R = 0;
	static final int MODE_W = 1;
	static final int MODE_A = 2;

	static FileDescriptor open(File file, int mode) {
		FileDescriptor fd = new FileDescriptor();
		fd.open(file.getPath(), mode);
		return fd;
	}

	public boolean valid() {
		return handle != -1;
	}

	public void finalize() {
		close();
	}

	native boolean open(String path, int mode);
	native boolean openStandard(int fd); // 0 = in, 1 = out, 2 = err

	public void sync() {}
	native void read(byte[] b);
	native void write(byte[] b);
	native void close();
	native int size();
}
