package java.awt.event;

import java.awt.AWTEvent;

public class ComponentEvent extends AWTEvent {

	public static final int COMPONENT_FIRST = 100;
	public static final int COMPONENT_LAST = 103;

	public static final int COMPONENT_MOVED = 100;
	public static final int COMPONENT_RESIZED = 101;
	public static final int COMPONENT_SHOWN = 102;
	public static final int COMPONENT_HIDDEN = 103;

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
