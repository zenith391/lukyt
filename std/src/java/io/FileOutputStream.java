package java.io;

public class FileOutputStream extends OutputStream {
	private FileDescriptor fd;

	public FileOutputStream(String path) {
		this(new File(path));
	}

	public FileOutputStream(File file) {
		this(FileDescriptor.open(file, FileDescriptor.MODE_W));
	}

	public FileOutputStream(FileDescriptor fd) {
		this.fd = fd;
	}

	public void close() throws IOException {
		fd.close();
	}

	public FileDescriptor getFD() {
		return fd;
	}

	protected void finalize() {
		try {
			if (fd.valid()) {
				close();
			}
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	public void write(int b) {
		fd.write(new byte[] {(byte) b}, 0, 1);
	}

	public void write(byte[] b) {
		fd.write(b, 0, b.length);
	}

	public void write(byte[] b, int off, int len) {
		fd.write(b, off, len);
	}
}
