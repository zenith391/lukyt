package java.awt;

public class EventObject {
	protected transient Object source;

	public EventObject(Object source) {
		this.source = source;
	}

	public Object getSource() {
		return source;
	}

	public String toString() {
		return "java.awt.EventObject[source=" + source + "]";
	}
}
