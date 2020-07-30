package java.awt;

import java.awt.peer.FramePeer;

public class Window extends Frame {

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

	public void setTitle(String title) {
		((FramePeer) peer).setTitle(title);
	}

	public void setResizable(boolean resizable) {
		((FramePeer) peer).setResizable(resizable);
	}

}
