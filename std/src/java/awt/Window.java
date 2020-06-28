package java.awt;

import java.awt.peer.WindowPeer;

public class Window extends Container {

	private Window owner;

	public Window(Window owner) {
		this.owner = owner;
		addNotify();
	}

	public void addNotify() {
		peer = new WindowPeer();
		for (Component child : childs) {
			if (!child.isDisplayable()) {
				child.addNotify();
			}
		}
	}

	public void setSize(int width, int height) {
		((WindowPeer) peer).setSize(width, height);
	}

	public void setLocation(int x, int y) {
		((WindowPeer) peer).setLocation(x, y);
	}

	public void setLocation(Point p) {
		setLocation(p.getX(), p.getY());
	}

	public void setVisible(boolean b) {
		((WindowPeer) peer).setVisible(b);
	}

	

}
