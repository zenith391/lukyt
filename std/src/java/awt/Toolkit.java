package java.awt;

import lukyt.oc.awt.GPUToolkit;

public class Toolkit {

	protected static String gpuAddress;

	public abstract Dimension getScreenSize();
	public abstract int getScreenResolution();
	public abstract void beep();
	public abstract Clipboard getSystemSelection();
	public abstract Clipboard getSystemClipboard();
	public abstract boolean getLockingKeyState(int keyCode) throws UnsupportedOperationException;
	public abstract void setLockingKeyState(int keyCode, boolean on) throws UnsupportedOperationException;

	public final EventQueue getSystemEventQueue() {
		return getSystemEventQueueImpl();
	}

	public boolean areExtraMouseButtonsEnabled() {
		return false;
	}

	protected abstract EventQueue getSystemEventQueueImpl();

	public static Toolkit getDefaultToolkit() {
		return new GPUToolkit();
	}
}
