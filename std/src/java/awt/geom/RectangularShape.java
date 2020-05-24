package java.awt.geom;

public abstract class RectangularShape implements Shape {
	protected RectangularShape() {}

	public abstract double getX();
	public abstract double getY();
	public abstract double getWidth();
	public abstract double getHeight();
	public abstract boolean isEmpty();
	public abstract void setFrame(double x, double y, double w, double h);

	public double getMinX() {
		return getX();
	}

	public double getMinY() {
		return getY();
	}

	public double getMaxX() {
		return getX() + getWidth();
	}

	public double getMaxY() {
		return getX() + getHeight();
	}

	public double getCenterX() {
		return getX() + getWidth() / 2;
	}

	public double getCenterY() {
		return getY() + getHeight() / 2;
	}

	public Rectangle2D getFrame() {
		return new Rectangle2D(getX(), getY(), getWidth(), getHeight());
	}

	public void setFrame(Point2D loc, Dimension2D size) {
		setFrame(loc.getX(), loc.getY(), size.getWidth(), size.getHeight());
	}

	public void setFrame(Rectangle2D r) {
		setFrame(r.getX(), r.getY(), r.getWidth(), r.getHeight());
	}

	public void setFrameFromDiagonal(double x1, double y1, double x2, double y2) {
		throw new UnsupportedOperationException("TODO");
	}

	public void setFrameFromDiagonal(Point2D p1, Point2D p2) {
		setFrameFromDiagonal(p1.getX(), p1.getY(), p2.getX(), p2.getY());
	}

	public void setFrameFromCenter(double centerX, double centerY, double cornerX, double cornerY) {
		throw new UnsupportedOperationException("TODO");
	}

	public void setFrameFromCenter(Point2D center, Point2D corner) {
		setFrameFromCenter(center.getX(), center.getY(), corner.getX(), corner.getY());
	}

	public boolean contains(Point2D pt) {
		return pt.getX() > getX() && pt.getY() > getY() && pt.getX() < getX() + getWidth() && pt.getY() < getY() + getHeight();
	}

	public boolean intersects(Rectangle2D r) {
		throw new UnsupportedOperationException("TODO");
	}

	public boolean contains(Rectangle2D r) {
		throw new UnsupportedOperationException("TODO");
	}

	public Rectangle getBounds() {
		return new Rectangle(getX(), getY(), getWidth(), getHeight());
	}

	public PathIterator getPathIterator(AffineTransform at, double flatness) {
		throw new UnsupportedOperationException("TODO");
	}
}
