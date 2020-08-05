package cil.li.oc;

/**
	Abstract class for component proxies. This is equivalent to <code>component.proxy("xyz")</code> and <code>component.xyz</code> on Lua
**/
public abstract class ComponentProxy {

	public abstract String getAddress();
	public abstract String getType();

}