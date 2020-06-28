package java.awt.peer;

import java.awt.*;

public interface ComponentPeer {

	public boolean setVisible(boolean visible);
	public boolean setEnabled(boolean visible);
	public void setBounds(int x, int y, int w, int h);
	public void setLocation(int x, int y);
	public void setSize(int w, int h);
	public void dispatchEvent(AWTEvent e);
	public Dimension getPreferredSize();
	public Dimension getMinimumSize();
	public Point getLocation();
	public void dispose();

	/**
		A purely heavyweight component can return null
	**/
	public Graphics getGraphics();

	public void setParent(ContainerPeer peer);

}
