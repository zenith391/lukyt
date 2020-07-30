package java.nio.impl;

import java.nio.*;

public abstract class DirectByteBufferImpl extends ByteBuffer {
	
	public abstract byte get(int index);
	public abstract ByteBuffer put(int index, byte b);

	public byte get() {
		return get(position++);
	}

	public ByteBuffer put(byte b) {
		return put(position++, b);
	}

}
