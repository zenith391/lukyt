package java.awt;

public abstract class GraphicsEnvironment {

	public static boolean isHeadless() {
		return false;
	}

	public boolean isHeadlessInstance() {
		return true;
	}

	public abstract GraphicsDevice[] getScreenDevices() throws HeadlessException;
	public abstract GraphicsDevice getDefaultScreenDevice() throws HeadlessException;
	
	public Point getCenterPoint() throws HeadlessException {
		if (isHeadless()) {
			throw new HeadlessException();
		}
		return new Point(500, 500); // TODO
	}

	public Rectangle getMaximumWindowBounds() throws HeadlessException {
		if (isHeadless()) {
			throw new HeadlessException();
		}
		return new Rectangle(1920, 1080); // TODO
	}

}
