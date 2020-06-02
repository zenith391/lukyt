package java.awt;

public class AWTEventMulticaster {
	protected final EventListener a;
	protected final EventListener b;

	protected AWTEventMulticaster(EventListener a, EventListener b) {
		this.a = a;
		this.b = b;
	}

	protected EventListener remove(EventListener old) {

		return this;
	}
}