package lukyt.oc.awt;

import lukyt.oc.Component;

public class SemiBrailleGPUDrawer implements GPUDrawer {

	private String addr;
	private static final SEMI_BRAILLE_CHAR = ' '; // fg = top, bg = bottom

	public void setGPUAddress(String addr) {
		this.addr = addr;
	}

	public Dimension getResolution() {
		return new Dimension(160, 100);
	}

	public void horizontalLine(int x, int y, int width, int rgb) {
		for (int i = 0; i < width; i++) {
			set(x+i, y, rgb);
		}
	}

	public void verticalLine(int x, int y, int height, int rgb) {
		for (int i = 0; i < height; i++) {
			set(x, y+i, rgb);
		}
	}

	public void set(int x, int y, int rgb) {
		x++; y++; // increase to correspond to the 1-based coordinate system
		Object[] rets = Component.invoke(addr, "get", new Object[] {x, y});
		int fg = ((Double) rets[1]).intValue();
		int bg = ((Double) rets[2]).intValue();
		if (y % 2 == 0) { // bottom
			bg = rgb;
		} else { // top
			fg = rgb;
		}
		Component.invoke(addr, "setForeground", new Object[] {fg});
		Component.invoke(addr, "setBackground", new Object[] {bg});
		Component.invoke(addr, "set", new Object[] {x, y, SEMI_BRAILLE_CHAR});
	}

	public void fill(int x, int y, int width, int height, int rgb) {
		for (int i = 0; i < width; i++) {
			for (int j = 0; j < height; j++) {
				set(x+i, y+j, rgb);
			}
		}
	}

}