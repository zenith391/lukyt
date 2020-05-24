package java.awt.event;

import java.awt.AWTEvent;

public class KeyEvent extends AWTEvent {

	protected long when;
	protected int modifiers;
	protected int keyCode;
	protected char keyChar;
	protected int keyLocation;

	public static char CHAR_UNDEFINED = -1;

	public KeyEvent(Component source, int id, long when, int modifiers, int keyCode, char keychar, int keyLocation) {
		super(source, id);
		this.when = when;
		this.modifiers = modifiers;
		this.keyCode = keyCode;
		this.keyChar = keyChar;
		this.keyLocation = keyLocation;
	}

	public KeyEvent(Component source, int id, long when, int modifiers, int keyCode, char keyChar) {
		this(source, id, when, modifiers, keyCode, keyChar, -1);
	}

	public Component getComponent() {
		return (Component) source;
	}

	public String paramString() {
		return source.toString();
	}

}
