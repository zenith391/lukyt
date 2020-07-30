package cil.li.oc.proxies;

import cil.li.oc.*;
import lukyt.*;

public class GPUProxy extends ComponentProxy {
	private LuaObject o;

	public GPUProxy(LuaObject o) {
		this.o = o;
	}

	public void fill(int x, int y, int width, int height, char ch) {
		o.executeChild("fill", new LuaObject[] {
			LuaObject.fromLong(x), LuaObject.fromLong(y),
			LuaObject.fromLong(width), LuaObject.fromLong(height),
			LuaObject.fromString(String.valueOf(ch))});
	}

	public void setForeground(int rgb) {
		o.executeChild("setForeground", new LuaObject[] {LuaObject.fromLong(rgb)});
	}

	public void setBackground(int rgb) {
		o.executeChild("setBackground", new LuaObject[] {LuaObject.fromLong(rgb)});
	}

	public String getAddress() {
		return o.get("address").asString();
	}
}
