package java.awt;

import java.awt.geom.Point2D;

public class Point extends Point2D {
	public int x, y;

	public Point() {}

	public Point(int x, int y) {
		this.x = x;
		this.y = y;
	}

	public Point(Point pt) {
		x = pt.x;
		y = pt.y;
	}

	public Point getLocation() {
		return this;
	}

	public double getX() {
		return (double) x;
	}

	public double getY() {
		return (double) y;
	}

	public void move(int x, int y) {
		this.x = x;
		this.y = y;
	}

	public void setLocation(double x, double y) {
		this.x = (int) x;
		this.y = (int) y;
	}

	public void setLocation(int x, int y) {
		this.x = x;
		this.y = y;
	}

	public void setLocation(Point pt) {
		x = pt.x;
		y = pt.y;
	}

	public void translate(int dx, int dy) {
		x += dx;
		y += dy;
	}

	public String toString() {
		return "java.awt.Point[x=" + x, + ",y" + y + "]";
	}
}
