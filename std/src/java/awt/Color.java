package java.awt;

public class Color {

	public int[] components;

	public static final Color BLACK = new Color(0, 0, 0);
	public static final Color WHITE = new Color(255, 255, 255);

	public Color(int r, int g, int b) {
		components = new int[] {r, g, b};
	}

	public Color(int r, int g, int b, int a) {
		components = new int[] {r, g, b, a};
	}

	public Color(int rgb) {
		this(rgb, false);
	}

	public Color(int argb, boolean hasAlpha) {
		components = new int[] {
			argb & 0x00FF0000, // red
			argb & 0x0000FF00, // green
			argb & 0x000000FF, // blue
			hasAlpha ? argb & 0xFF000000 : 255
		};
	}

	public int getRed() {
		return components[0];
	}

	public int getGreen() {
		return components[1];
	}

	public int getBlue() {
		return components[2];
	}

	public int getAlpha() {
		return components[3];
	}

	public int getRGB() {
		return (components[0] << 16) |
			(components[1] << 8) |
			components[2];
	}

}
