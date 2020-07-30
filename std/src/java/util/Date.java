package java.util;

public class Date {

	private long epoch;

	public Date() {
		this.epoch = System.currentTimeMillis();
	}

	public Date(long epoch) {
		this.epoch = epoch;
	}

	public boolean before(Date when) {
		return epoch < when.epoch;
	}

	public boolean after(Date when) {
		return epoch > when.epoch;
	}

}