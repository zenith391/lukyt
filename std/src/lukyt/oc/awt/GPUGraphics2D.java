package lukyt.oc.awt;

import java.awt.*;
import java.awt.geom.*;
import java.util.*;

/**
	Maps virtual screen (320x200) to physical screen (160x50) using braille characters.
**/
public class GPUGraphics2D extends Graphics2D {

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
			points[i] = add(p0, mul(sub(p0, p1), t)); // = P0 + t*(P1-P0)
		}
		return points;
	}

}
