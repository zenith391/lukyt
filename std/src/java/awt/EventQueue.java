package java.awt;

public class EventQueue {

	private Deque<AWTEvent> events = new ArrayDeque<AWTEvent>();
	private long initTime;

	public EventQueue() {
		initTime = System.currentTimeMillis();
	}

	public void postEvent(AWTEvent evt) {
		if (evt.getSource() instanceof Component) {
			// TODO: check for Component.coalesceEvents condition
		}
		events.add(evt);
	}

	public AWTEvent getNextEvent() {
		return events.removeFirst();
	}

	public AWTEvent peekEvent() {
		return events.peekFirst();
	}

	public static long getMostRecentEventTime() {
		// TODO
		return initTime;
	}

	public static boolean isDispatchThread() {
		// TODO
	}

	public static void invokeLater(Runnable runnable) {
		// TODO
	}

	public static void invokeAndWait(Runnable runnable) {
		// TODO
	}

	protected void dispatchEvent(AWTEvent event) {
		if (event == null) {
			throw new NullPointerException();
		}
		// TODO: Handle ActiveEvent and MenuComponent
		if (event.getSource() instanceof Component) {
			((Component) event.getSource()).dispatchEvent(event);
		}
	}
}
