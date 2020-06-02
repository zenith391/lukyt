package cil.li.oc.awt;

import java.awt.*;
import java.awt.geom.*;
import java.util.*;

/**
	Maps virtual screen (320x200) to physical screen (160x50) using braille characters.
**/
public class GPUGraphics2D extends Graphics2D {

	private GPUDrawer drawer = new SemiBrailleGPUDrawer();
	private AffineTransform at = new AffineTransform(
		1, 0, 0,
		0, 1, 0
	);

	// Helper point methods
	protected Point2D.Float add(Point2D p0, Point2D p1) {
		return new Point2D.Float(p0.getX() + p1.getX(), p0.getY() + p1.getY());
	}

	protected Point2D.Float sub(Point2D p0, Point2D p1) {
		return new Point2D.Float(p0.getX() - p1.getX(), p0.getY() - p1.getY());
	}

	protected Point2D.Float mul(Point2D p, float scalar) {
		return new Point2D.Float(p.getX() * scalar, p.getY() * scalar);
	}

	// Precision for Bezier curves need to scale with the curve's size in order to not have unfilled dots between lines
	// Precision is the number of points.
	protected Point[] linearBezier(Point2D p0, Point2D p1, int precision) {
		Point[] points = new Point[precision];
		for (int i = 0; i < precision; i++) {
			float t = (float) i / (float) precision;
			Point2D p2d = add(p0, mul(sub(p0, p1), t)); // = P0 + t*(P1-P0)
			points[i] = new Point((int) p2d.getX(), (int) p2d.getY());
		}
		return points;
	}

	protected void drawLinearBezier(Point2D p0, Point2D p1) {
		Point[] points = linearBezier(p0, p1, 10);
		Point lastPoint = new Point(-1, -1);
		for (Point point : points) {
			if (!point.equals(lastPoint)) {
				drawer.set((int) point.getX(), (int) point.getY(), 0xFFFFFF);
				lastPoint = point;
			}
		}
	}

	public void drawRect(int x, int y, int width, int height) {
		draw(new Rectangle2D.Float(x, y, width, height));
	}

	public void draw(Shape shape) {
		PathIterator iterator = shape.getPathIterator(at);
		float[] coords = new float[6];
		Point2D p0 = new Point2D.Float();
		Point2d lastMoveTo = p0;
		while (!iterator.isDone()) {
			int type = iterator.currentSegments(coords);
			if (type == PathIterator.SEG_MOVETO) {
				p0 = new Point2D.Float(coords[0], coords[1]);
				lastMoveTo = p0;
			} else if (type == PathIterator.SEG_LINETO) {
				Point2D p1 = new Point2D.Float(coords[0], coords[1]);
				drawLinearBezier(p0, p1);
				p0 = p1;
			} else if (type == PathIterator.SEG_CLOSE) {
				drawLinearBezier(p0, lastMoveTo);
			}
			iterator.next();
		}
	}



}
