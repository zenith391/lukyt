package java.awt.event;

import java.util.EventListener;

public interface ComponentListener extends EventListener {
	public void componentHidden(ComponentEvent e);
	public void componentMoved(ComponentEvent e);
	public void componentResized(ComponentEvent e);
	public void componentShown(ComponentEvent e);
}
