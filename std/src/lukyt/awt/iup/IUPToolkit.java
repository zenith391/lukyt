package lukyt.awt.iup;

import java.awt.Dimension;
import lukyt.LuaObject;

public class IUPToolkit {

	public IUPToolkit() {}

	public boolean getLockingKeyState(int keyCode) throws UnsupportedOperationException {
		throw new UnsupportedOperationException();
	}

	public void setLockingKeyState(int keyCode, boolean on) throws UnsupportedOperationException {
		throw new UnsupportedOperationException();
	}

	public Clipboard getSystemSelection() {
		return null;
	}

	public Clipboard getSystemClipboard() {
		return null;
	}

	protected EventQueue getSystemEventQueueImpl() {
		return null;
	}

	public Dimension getScreenSize() {
		return new Dimension(1920, 1080);
	}

	public void beep() {
		
	}
}