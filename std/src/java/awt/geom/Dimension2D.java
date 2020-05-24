package java.awt.geom;

public abstract class Dimension2D {

	protected Dimension2D() {}

	public abstract double getWidth();
	public abstract double getHeight();
	public abstract void setSize(double width, double height);

	public void setSize(Dimension2D dim) {
		setSize(dim.getWidth(), dim.getHeight());
	}
}
