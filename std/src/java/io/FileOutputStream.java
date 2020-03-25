package java.io;

public class FileOutputStream {
	private FileDescriptor fd;

	public FileOutputStream(FileDescriptor fd) {
		this.fd = fd;
	}

	public void close() {
		fd.close();
	}

	public FileDescriptor getFD() {
		return fd;
	}

	protected void finalize() {
		close();
	}

	public void write(int b) {
		fd.write(new byte[] {(byte) b});
	}

	public void write(byte[] b) {
		fd.write(b);
	}
}
