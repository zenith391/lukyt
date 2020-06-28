package java.awt;

import java.awt.event.*;
import java.awt.peer.ComponentPeer;

public class Component {

	protected Object treeLock = new Object();
	Container parent;
	protected String name;
	protected ComponentPeer peer;
	protected boolean valid = true;
	protected boolean visible = true;

	private ComponentListener componentListener = null;
	private KeyListener keyListener = null;

	protected Component() {}

	public void addComponentListener(ComponentListener l) {
		componentListener = AWTEventMulticaster.add(componentListener, l);
	}

	public void addKeyListener(KeyListener l) {

	}

	public boolean isVisible() {
		return visible;
	}

	public void setVisible(boolean visible) {
		this.visible = visible;
	}

	public boolean isDisplayable() {
		return peer != null;
	}

	protected void processComponentEvent(ComponentEvent e) {
		if (componentListener != null) {
			int id = e.getId();
			if (id == ComponentEvent.COMPONENT_SHOWN) {
				componentListener.componentShown(e);
			} else if (id == ComponentEvent.COMPONENT_HIDDEN) {
				componentListener.componentHidden(e);
			} else if (id == ComponentEvent.COMPONENT_RESIZED) {
				componentListener.componentResized(e);
			} else if (id == ComponentEvent.COMPONENT_MOVED) {
				componentListener.componentMoved(e);
			}
		}
	}

	protected void processEvent(AWTEvent e) {
		if (e instanceof ComponentEvent) {
			processComponentEvent((ComponentEvent) e);
		}
	}

	public final void dispatchEvent(AWTEvent e) {
		// TODO check if enabled before calling processEvent
		processEvent(e);
	}

	public Container getParent() {
		return parent;
	}

	public final Object getTreeLock() {
		return treeLock;
	}

	public String getName() {
		return name;
	}

	@Deprecated
	public ComponentPeer getPeer() {
		return peer;
	}

	public void setName(String name) {
		this.name = name;
	}

	public void invalidate() {
		valid = false;
		if (parent != null) {
			parent.invalidate();
		}
	}

	public void validate() {
		valid = true;
	}

	public void addNotify() {
		throw new UnsupportedOperationException();
	}
	
}
