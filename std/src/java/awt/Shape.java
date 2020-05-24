package java.awt;

import java.awt.geom.*;

public interface Shape {

	public boolean contains(double x, double y);
	public boolean contains(double x, double y, double w, double h);
	public boolean contains(Point2D pt);
	public boolean contains(Rectangle2D r);

	public Rectangle getBounds();
	public Rectangle2D getBounds2D();

	public PathIterator getPathIterator(AffineTransform at);
	public PathIterator getPathIterator(AffineTransform at, double flatness);

	public boolean intersects(double x, double y, double w, double h);
	public boolean intersects(Rectangle2D r);
}
