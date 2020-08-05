package cil.li.oc;

import lukyt.LuaObject;

import cil.li.oc.proxies.*;

/**
	Class used to access the component API.
**/
public final class Components {

	private static final LuaObject inst = Utils.require.execute(LuaObject.fromString("component"));

	private Components() {}

	/**
		Returns the documentation string for the method with the specified name of the component
		with the specified address, if any.<br/>
	**/
	public static String doc(String address, String method) {
		return inst.executeChild("doc", new LuaObject[] {LuaObject.fromString(address), LuaObject.fromString(method)})
			.asString();
	}

	/**
		Invoke component's <code>method</code> with specified component <code>address</code> and with arguments
		<code>args</code><br/>

		This returns all the results of the call.<br/>
		If needed, objects are serialized to lua objects, in that case, Object can be one of:
		<ul>
			<li>Integer</li>
			<li>Long</li>
			<li>Map (mapped to a table)</li>
			<li>Double</li>
		</ul><br/>
		Functions are serialized to their <code>java.util.function</code> equivalent.
		That serialization is also applied to results.
	**/
	public static Object[] invoke(String address, String method, Object... args) {
		LuaObject[] finalArgs = new LuaObject[args.length + 2];
		finalArgs[0] = LuaObject.fromString(address);
		finalArgs[1] = LuaObject.fromString(method);
		for (int i = 0; i < args.length; i++) {
			finalArgs[i+2] = LuaObject.from(args[i]);
		}
		LuaObject[] result = inst.get("invoke").executeAll(finalArgs);
		Object[] ret = new Object[result.length];
		for (int i = 0; i < result.length; i++) {
			ret[i] = result[i].asObject();
		}
		return ret;
	}

	/**
		Get the primary component.<br/>
		Unlike Lua, this returns the address.<br/>
		@throws UnsupportedOperationException when the environment doesn't support getPrimary() (ex: no OS or the OS doesn't use that function).
	**/
	public static String getPrimaryAddress(String type) {
		return inst.executeChild("getPrimary", new LuaObject[] {LuaObject.fromString(type)})
			.get("address").asString();
	}

	/**
		Gets the proxy for the primary component of the specified type.<br/>

		Throws an error if there is no primary component of the specified type.
	**/
	public static <T extends ComponentProxy> T getPrimary(String type) {
		LuaObject l = inst.executeChild("getPrimary", new LuaObject[] {LuaObject.fromString(type)});
		return luaToJavaProxy(l);
	}

	/**
		Gets a 'proxy' object for a component, this provides all methods the component provides so they can be called more directly (instead of via invoke).

		This is what's used to generate 'primaries' of the individual component types, i.e. what you get via {@link #getPrimary(String)}
	**/
	public static <T extends ComponentProxy> T getProxy(String address) {
		LuaObject l = inst.executeChild("proxy", new LuaObject[] {LuaObject.fromString(address)});
		return luaToJavaProxy(l);
	}

	private static <T extends ComponentProxy> T luaToJavaProxy(LuaObject proxy) {
		String type = proxy.get("type").asString();
		if (type.equals("gpu")) {
			return (T) new GPUProxy(proxy);
		} else {
			throw new IllegalArgumentException("type not supported");
		}
	}

	/**
		<b>SPECIFIC TO LUKYT</b> : should not actually be used, this was some support function
		for complex lua object types but shouldn't be used now.
	**/
	public static LuaObject[] invoke(String address, String method, LuaObject[] args) {
		LuaObject[] nArgs = new LuaObject[args.length + 2];
		nArgs[0] = LuaObject.fromString(address);
		nArgs[1] = LuaObject.fromString(method);
		for (int i = 0; i < args.length; i++) {
			nArgs[i+2] = args[i];
		}
		return inst.get("invoke").executeAll(nArgs);
	}

}
