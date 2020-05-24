package java.awt.geom;

public abstract class Rectangle2D extends RectangularShape {
	public static class Float extends Rectangle2D {

		public float x, y, width, height;

		public Float() {}

		public Float(float x, float y, float width, float height) {
			setRect(x, y, width, height);
		}

		public Rectangle2D getBounds2D() {
			return new Rectangle2D.Float(x, y, width, height);
		}

		public double getX() {
			return (double) x;
		}

		public double getY() {
			return (double) y;
		}

		public double getWidth() {
			return (double) width;
		}

		public double getHeight() {
			return (double) height;
		}

		public boolean isEmpty() {
			return width == 0 || height == 0;
		}

		public void setRect(Rectangle2D r) {
			setRect(r.getX(), r.getY(), r.getWidth(), r.getHeight());
		}

		public void setRect(double x, double y, double width, double height) {
			setRect((float) x, (float) y, (float) width, (float) height);
		}

		public void setRect(float x, float y, float width, float height) {
			this.x = x;
			this.y = y;
			this.width = width;
			this.height = height;
		}

		public String toString() {
			return "java.awt.geom.Rectangle2D.Float[x=" + x + ",y=" + y + ",width=" + width + ",height=" + height + "]";
		}
	}

	public static class Double extends Rectangle2D {

		public double x, y, width, height;

		public Double() {}

		public Double(double x, double y, double width, double height) {
			setRect(x, y, width, height);
		}

		public Rectangle2D getBounds2D() {
			return new Rectangle2D.Double(x, y, width, height);
		}

		public double getX() {
			return (double) x;
		}

		public double getY() {
			return (double) y;
		}

		public double getWidth() {
			return (double) width;
		}

		public double getHeight() {
			return (double) height;
		}

		public boolean isEmpty() {
			return width == 0 || height == 0;
		}

		public void setRect(Rectangle2D r) {
			setRect(r.getX(), r.getY(), r.getWidth(), r.getHeight());
		}

		public void setRect(double x, double y, double width, double height) {
			this.x = x;
			this.y = y;
			this.width = width;
			this.height = height;
		}

		public String toString() {
			return "java.awt.geom.Rectangle2D.Double[x=" + x + ",y=" + y + ",width=" + width + ",height=" + height + "]";
		}
	}
}
