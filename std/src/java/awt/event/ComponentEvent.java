package java.awt.event;

import java.awt.AWTEvent;

public class ComponentEvent extends AWTEvent {

	public ComponentEvent(Component c, int id) {
		super(c, id);
	}

	public Component getComponent() {
		return (Component) source;
	}

	public String paramString() {
		return source.toString();
	}

}
