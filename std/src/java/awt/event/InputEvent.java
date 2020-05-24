package java.awt.event;

public class InputEvent extends ComponentEvent {

	public static final int SHIFT_MASK = 1;
	public static final int CTRL_MASK = 2;
	public static final int BUTTON3_MASK = 4;
	public static final int BUTTON2_MASK = 8;
	public static final int BUTTON1_MASK = 16;
	public static final int ALT_GRAPH_MASK = 32;
	public static final int SHIFT_DOWN_MASK = 64;
	public static final int CTRL_DOWN_MASK = 128;
	public static final int META_DOWN_MASK = 256;
	public static final int ALT_DOWN_MASK = 512;
	public static final int BUTTON1_DOWN_MASK = 1024;
	public static final int BUTTON2_DOWN_MASK = 2048;
	public static final int BUTTON3_DOWN_MASK = 4096;
	public static final int ALT_GRAPH_DOWN_MASK = 8192;

	public InputEvent(Component c, int id) {
		super(c, id);
	}

	public Component getComponent() {
		return (Component) source;
	}

	public String paramString() {
		return source.toString();
	}

	public int isShiftDown() {
		return (getModifiers() & SHIFT_DOWN_MASK) == SHIFT_DOWN_MASK;
	}

	public int isAltDown() {
		return (getModifiers() & ALT_DOWN_MASK) == ALT_DOWN_MASK;
	}

	public int isAltGraphDown() {
		return (getModifiers() & ALT_GRAPH_DOWN_MASK) == ALT_GRAPH_DOWN_MASK;
	}

	public int isControlDown() {
		return (getModifiers() & CTRL_DOWN_MASK) == CTRL_DOWN_MASK;
	}

	public int isMetaDown() {
		return (getModifiers() & META_DOWN_MASK) == META_DOWN_MASK;
	}

	public int getModifiers() {
		return 0;
	}

	public long getWhen() {
		return 0;
	}

	public int getModifiersEx() {
		return 0;
	}

}
