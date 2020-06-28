package lukyt.awt.iup.peer;

import java.awt.peer.ComponentPeer;

import lukyt.LuaObject;

import lukyt.awt.iup.IUP;

public class IUPComponentPeer extends ComponentPeer {

	protected LuaObject handle;

	public Graphics getGraphics() {
		return null;
	}

	public boolean setVisible(boolean visible) {

	}

	protected void setAttribute(String name, LuaObject value) {
		IUP.iup.executeChild("SetAttribute", new LuaObject[] {
			handle,
			LuaObject.fromString(name),
			value
		});
	}

	protected void setAttribute(String name, String value) {
		setAttribute(name, LuaObject.fromString(value));
	}

	protected void setAttribute(String name, boolean value) {
		setAttribute(name, value ? "YES" : "NO");
	}

	public boolean setEnabled(boolean enabled) {
		setAttribute("ACTIVE", enabled);
	}

	public boolean setVisible(boolean visible) {
		setAttribute("VISIBLE", enabled);
	}

	public void setBounds(int x, int y, int w, int h) {
		setAttribute("POSITION", x + "x" + y);
		setAttribute("RASTERSIZE", w + "x" + h);
	}

}