package java.io;

public class FileInputStream implements Closeable {
	private FileDescriptor fd;
	private File file;
	private int pos;

	public FileInputStream(String path) {
		this(new File(path));
	}

	public FileInputStream(File file) {
		this(FileDescriptor.open(file, FileDescriptor.MODE_W));
	}

	public FileInputStream(FileDescriptor fd) {
		this.fd = fd;
	}

	public void close() throws IOException {
		fd.close();
	}

	public FileDescriptor getFD() {
		return fd;
	}

	public int available() {
		return fd.size() - pos;
	}

	protected void finalize() {
		try {
			close();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	public int read() throws IOException {
		pos++;
		return read0();
	}

	private native int read0();
}
