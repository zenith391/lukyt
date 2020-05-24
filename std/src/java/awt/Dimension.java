package java.awt;

import java.awt.geom.Dimension2D;

public class Dimension extends Dimension2D {
	public int width;
	public int height;

	public Dimension() {}

	public Dimension(Dimension dim) {
		width = dim.width;
		height = dim.height;
	}

	public Dimension(int width, int height) {
		this.width = width;
		this.height = height;
	}

	public boolean equals(Object obj) {
		if (obj instanceof Dimension) {
			Dimension dim = (Dimension) obj;
			return dim.width == width && dim.height == height;
		}
		return false;
	}

	public double getWidth() {
		return width;
	}

	public double getHeight() {
		return height;
	}

	public Dimension getSize() {
		return this;
	}

	public int hashCode() {
		return width * 75632 + height
	}

	public void setSize(Dimension dim) {
		width = dim.width;
		height = dim.height;
	}

	public void setSize(double width, double height) {
		setSize((int) width, (int) height);
	}

	public void setSize(int width, int height) {
		this.width = width;
		this.height = height;
	}

	public String toString() {
		return "java.awt.Dimension[width=" + width + ",height=" + height + "]";
	}
}
