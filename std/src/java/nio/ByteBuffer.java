package java.nio;

import java.nio.impl.DirectByteBufferImpl;

public abstract class ByteBuffer {

	protected ByteOrder order;

	public static ByteBuffer allocate(int capacity) {
		return allocateDirect(capacity);
	}

	public static ByteBuffer allocateDirect(int capacity) {
		return new DirectByteBufferImpl(capacity);
	}

	public abstract CharBuffer asCharBuffer();
	public abstract DoubleBuffer asDoubleBuffer();
	public abstract FloatBuffer asFloatBuffer();
	public abstract IntBuffer asIntBuffer();
	public abstract LongBuffer asLongBuffer();
	public abstract ShortBuffer asShortBuffer();

	public abstract ByteBuffer asReadOnlyBuffer();
	public abstract ByteBuffer compact();
	public abstract ByteBuffer duplicate();

	public abstract byte get();
	public abstract byte get(int index);
	public abstract char getChar();
	public abstract char getChar(int index);
	public abstract double getDouble();
	public abstract double getDouble(int index);
	public abstract float getFloat();
	public abstract float getFloat(int index);
	public abstract int getInt();
	public abstract int getInt(int index);
	public abstract long getLong();
	public abstract long getLong(int index);
	public abstract short getShort();
	public abstract short getShort(int index);

	public abstract ByteBuffer put(byte b);
	public abstract ByteBuffer put(int index, byte b);
	public abstract ByteBuffer putChar(char b);
	public abstract ByteBuffer putChar(int index, char b);
	public abstract ByteBuffer putDouble(double b);
	public abstract ByteBuffer putDouble(int index, double b);
	public abstract ByteBuffer putFloat(float b);
	public abstract ByteBuffer putFloat(int index, float b);
	public abstract ByteBuffer putInt(int b);
	public abstract ByteBuffer putInt(int index, int b);
	public abstract ByteBuffer putLong(long b);
	public abstract ByteBuffer putLong(int index, long b);
	public abstract ByteBuffer putShort(short b);
	public abstract ByteBuffer putShort(int index, short b);

	public abstract boolean isDirect();
	public abstract ByteBuffer slice();

	public final ByteOrder order() {
		return order;
	}

	public final ByteBuffer order(ByteOrder o) {
		order = o;
	}

	public byte[] array() {
		return null;
	}

	public int arrayOffset() {
		return 0;
	}

	public boolean equals(Object o) {
		return false;
	}

	public ByteBuffer get(byte[] dst, int offset, int length) {
		if (remaining() < length) {
			throw new BufferUnderflowException();
		}

		for (int i = 0; i < length; i++) {
			dst[i + offset] = get();
		}
	}

	public ByteBuffer get(byte[] dst) {
		return get(dst, 0, dst.length);
	}

	public ByteBuffer put(ByteBuffer src) {
		if (isReadOnly()) {
			throw new ReadOnlyBufferException();
		}
		if (src.remaining() > remaining()) {
			throw new BufferOverflowException();
		}
		while (src.hasRemaining()) {
			put(src.get());
		}
	}

	public ByteBuffer put(byte[] src, int offset, int length) {
		if (isReadOnly()) {
			throw new ReadOnlyBufferException();
		}
		if (src.length > remaining()) {
			throw new BufferOverflowException();
		}

		for (int i = 0; i < length; i++) {
			put(src[i + offset]);
		}
	}

	public ByteBuffer put(byte[] src) {
		put(src, 0, src.length);
	}

	public final boolean hasArray() {
		return true;
	}

	public int hashCode() {
		int x = remaining();
		x += (int) get(limit() - 1);
	}

}
