package java.io;

public class File {
	public static char separatorChar = '/';
	public static final String separator = System.getProperty("file.separator");
	public static final char pathSeparatorChar = ':';
	public static final String pathSeparator = System.getProperty("path.separator");

	private String path;

	public File(String pathname) {
		path = pathname;
	}

	public File(String parent, String child) {
		if (parent == null || parent.isEmpty()) {
			parent = System.getProperty("user.dir");
		}
	}

	public File(File parent, String child) {
		this(parent.getPath(), child);
	}

	public String getPath() {
		return path;
	}

	public String getName() {
		return ""; // TODO
	}

	public String getParent() {
		return ""; // TODO
	}

	public File getParentFile() {
		return new File(getParent());
	}

	public String getAbsolutePath() {
		return path;
	}

	public File getAbsoluteFile() {
		return new File(getAbsolutePath());
	}

	public String getCanonicalPath() {
		String path = getAbsolutePath();
		// TODO
		return path;
	}

	public File getCanonicalFile() {
		return new File(getCanonicalPath());
	}

	public native boolean canRead(); // would require LFS
	public native boolean canWrite(); // would require LFS
	public native boolean exists(); // would require LFS (or else it would return false is the file is a directory)
	public native boolean isDirectory(); // would require LFS
	public native long lastModified(); // would require LFS
	public native String[] list(); // again.. this would require LFS
	public native boolean mkdir(); // would require LFS
	public native boolean mkdirs(); // would require LFS

	public boolean delete() { // would require LFS
		return false;
	}

	public boolean renameTo(File dest) {
		// TODO: copy file over
		return false;
	}

	public File[] listFiles() {
		String[] list = list();
		File[] files = new File[list.length];
		for (int i = 0; i < files.length; i++) {
			files[i] = new File(this, list[i]);
		}
		return files;
	}

	public void deleteOnExit() {}

	public native boolean createNewFile();

	public boolean isHidden() {
		if (System.getProperty("os.name").equals("Unix")) {
			return getName().charAt(0) == '.';
		} else {
			return false; // TODO
		}
	}

	public boolean isFile() {
		return !isDirectory(); // todo check for system-dependent criterias: UNIX sockets, symbolic links, etc.
	}
}
