package java.nio;

public final class ByteOrder {

	private String s;

	private ByteOrder(String s) {
		this.s = s;
	}

	public static final ByteOrder BIG_ENDIAN = new ByteOrder("BIG_ENDIAN");
	public static final ByteOrder LITTLE_ENDIAN = new ByteOrder("LITTLE_ENDIAN");

	public static ByteOrder nativeOrder() {
		return LITTLE_ENDIAN; // TODO: use Lua's string.pack to check and actually benefit performance gain
	}

	public String toString() {
		return s;
	}

}