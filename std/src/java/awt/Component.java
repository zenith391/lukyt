package java.awt;

import java.awt.event.*;

public class Component {

	protected Component() {}

	public void addComponentListener(ComponentListener l) {

	}

	public void addKeyListener(KeyListener l) {

	}

	protected void processComponentEvent(ComponentEvent e) {

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
	
}
