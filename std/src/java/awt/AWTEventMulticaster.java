package java.awt;

import java.awt.event.*;

public class AWTEventMulticaster implements ComponentListener {
	protected final EventListener a;
	protected final EventListener b;

	protected AWTEventMulticaster(EventListener a, EventListener b) {
		this.a = a;
		this.b = b;
	}

	protected EventListener remove(EventListener old) {

		return this;
	}

	public static ComponentListener add(ComponentListener a, ComponentListener b) {
		return new AWTEventMulticaster(a, b);
	}

	public void componentHidden(ComponentEvent e) {
		if (a != null) {
			a.componentHidden(e);
		}
		b.componentHidden(e);
	}

	public void componentMoved(ComponentEvent e) {
		if (a != null) {
			a.componentMoved(e);
		}
		b.componentMoved(e);
	}
	
	public void componentResized(ComponentEvent e) {
		if (a != null) {
			a.componentResized(e);
		}
		b.componentResized(e);
	}

	public void componentShown(ComponentEvent e) {
		if (a != null) {
			a.componentShown(e);
		}
		b.componentShown(e);
	}
}