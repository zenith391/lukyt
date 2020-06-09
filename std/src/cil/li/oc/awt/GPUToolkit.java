package cil.li.oc.awt;

import java.awt.Dimension;

import lukyt.oc.Component;

public class GPUToolkit {
	private String gpu;

	public GPUToolkit() {
		gpu = Component.getPrimary("gpu");
	}

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
		Object[] size = Component.invoke(gpu, "getViewport", new Object[0]);
		Double width = (Double) size[0];
		Double height = (Double) size[1];
		return new Dimension(width.intValue(), height.intValue() * 2);
	}

	public void beep() {
		// TODO computer.beep
		LuaObject._ENV.get("computer").executeChild("beep", new LuaObject[] {LuaObject.fromLong(440), LuaObject.fromDouble(0.5D)});
	}
}