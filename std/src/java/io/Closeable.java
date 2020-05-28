package java.io;

public interface Closeable extends AutoCloseable {
	public void close() throws IOException;
}
