package java.awt;

import cil.li.oc.awt.GPUToolkit;
import lukyt.awt.iup.IUPToolkit;

import java.awt.peer.*;

public class Toolkit {

	protected static Toolkit defaultToolkit;

	public abstract Dimension getScreenSize();
	public abstract int getScreenResolution();
	public abstract void beep();
	public abstract Clipboard getSystemSelection();
	public abstract Clipboard getSystemClipboard();
	public abstract boolean getLockingKeyState(int keyCode) throws UnsupportedOperationException;
	public abstract void setLockingKeyState(int keyCode, boolean on) throws UnsupportedOperationException;

	public abstract ContainerPeer createContainer(Container target);

	public final EventQueue getSystemEventQueue() {
		return getSystemEventQueueImpl();
	}

	public boolean areExtraMouseButtonsEnabled() {
		return false;
	}

	protected static Container getNativeContainer(Component comp) {
		return comp.getParent();
	}

	protected abstract EventQueue getSystemEventQueueImpl();

	public static Toolkit getDefaultToolkit() {
		if (Boolean.getBoolean("java.awt.headless")) {
			throw new HeadlessException(); // TODO: use an headless toolkit
		}
		if (defaultToolkit == null) {
			if (System.getProperty("os.name").contains("OpenOS")) {
				defaultToolkit = new GPUToolkit();
			} else {
				if (System.getProperty("os.name").contains("Mac OS X")) {
					throw new HeadlessException("Lukyt doesn't support any Mac OS X render backend"); // TODO: use an headless toolkit
				}
				defaultToolkit = new IUPToolkit();
			}
		}
		return new GPUToolkit();
	}
}
