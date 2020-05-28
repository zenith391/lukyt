package java.nio;

public abstract class Buffer {

	protected int capacity;
	protected int position;
	protected int limit;
	protected int mark;

	public abstract boolean isReadOnly();
	public abstract boolean hasArray();
	public abstract Object array();
	public abstract int arrayOffset();
	public abstract boolean isDirect();

	public final int capacity() {
		return capacity;
	}

	public final int position() {
		return position;
	}

	public final Buffer position(int pos) {
		position = pos;
		return this;
	}

	public final Buffer limit(int l) {
		limit = l;
		return this;
	}

	public final Buffer mark() {
		mark = position;
		return this;
	}

	public final Buffer reset() {
		position = mark;
		return this;
	}

	public final Buffer clear() {
		position = 0;
		limit = capacity;
		mark = -1;
		return this;
	}

	public final Buffer flip() {
		limit = position;
		position = 0;
		mark = -1;
		return this;
	}

	public final Buffer rewind() {
		position = 0;
		mark = -1;
		return this;
	}

	public final int remaining() {
		return limit - position;
	}

	public final boolean hasRemaining() {
		return remaining() != 0;
	}

}
