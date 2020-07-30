package java.io;

public class FileInputStream extends InputStream {

	private FileDescriptor fd;
	private File file;
	private int pos;

	public FileInputStream(String path) {
		this(new File(path));
	}

	public FileInputStream(File file) {
		this(FileDescriptor.open(file, FileDescriptor.MODE_R));
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
			if (fd.valid()) {
				close();
			}
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	public int read() throws IOException {
		byte[] b = new byte[1];
		read(b, 0, 1);
		return (int) b[0];
	}

	public int read(byte[] bytes, int off, int len) throws IOException {
		return fd.read(bytes, off, len);
	}
}
