package java.nio.impl;

import java.nio.*;

public class ArrayByteBufferImpl extends AbstractByteBuffer {

	private byte[] array;

	public ArrayByteBufferImpl(int capacity) {
		array = new byte[capacity];
		this.capacity = capacity;
		this.limit = limit;
	}

	public byte get(int index) {
		if (index < 0 || index > limit) {
			throw new IndexOutOfBoundsException();
		}
		return array[index];
	}

	public ByteBuffer put(int index, byte b) {
		array[index] = b;
		return this;
	}

}
