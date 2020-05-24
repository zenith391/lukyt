package lukyt.oc.awt;

public interface GPUDrawer {

	public Dimension getResolution();
	public void setGPUAddress(String address);
	public void horizontalLine(int x, int y, int width, int rgb);
	public void verticalLine(int x, int y, int height, int rgb);
	public void set(int x, int y, int rgb);
	public void fill(int x, int y, int width, int height, int rgb);

}