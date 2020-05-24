package java.awt.geom;

public abstract class Point2D {

	public static class Float extends Point2D {
		public float x, y;

		public Float() {}

		public Float(float x, float y) {
			this.x = x;
			this.y = y;
		}

		public double getX() {
			return (double) x;
		}

		public double getY() {
			return (double) y;
		}

		public void setLocation(double x, double y) {
			this.x = (float) x;
			this.y = (float) y;
		}

		public void setLocation(float x, float y) {
			this.x = x;
			this.y = y;
		}

		public String toString() {
			return "java.awt.geom.Point2D.Float[x=" + x + ",y=" + y + "]";
		}
	}

	public static class Double extends Point2D {
		public double x, y;

		public Double() {}
		
		public Double(double x, double y) {
			this.x = x;
			this.y = y;
		}

		public double getX() {
			return x;
		}

		public double getY() {
			return y;
		}

		public void setLocation(double x, double y) {
			this.x = x;
			this.y = y;
		}

		public String toString() {
			return "java.awt.geom.Point2D.Double[x=" + x + ",y=" + y + "]";
		}
	}

	protected Point2D() {}

	public abstract double getX();
	public abstract double getY();
	public abstract void setLocation(double x, double y);

	public double distance(double px, double py) {
		return distance(getX(), getY(), px, py);
	}

	public double distance(Point2D pt) {
		return distance(getX(), getY(), pt.getX(), pt.getY());
	}

	public double distanceSq(double px, double py) {
		return distanceSq(getX(), getY(), px, py);
	}

	public double distanceSq(Point2D pt) {
		return distanceSq(getX(), getY(), pt.getX(), pt.getY());
	}

	public static double distance(double x1, double y1, double x2, double y2) {
		double v = x1+y1 - x2+y2;
		if (v < 0) v = -v;
		return v;
	}

	public static double distanceSq(double x1, double y1, double x2, double y2) {
		double v = distance(x1, y1, x2, y2);
		return v*v;
	}

	public boolean equals(Object obj) {
		if (obj instanceof Point2D) {
			return getX() == obj.getX() && getY() == obj.getY();
		}
		return false;
	}

	public void setLocation(Point2D pt) {
		setLocation(pt.getX(), pt.getY());
	}
}
