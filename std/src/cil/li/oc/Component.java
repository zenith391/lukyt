package cil.li.oc;
import lukyt.LuaObject;

public final class Component {

	private static final LuaObject inst = Utils.require.execute(LuaObject.fromString("component"));

	private Component() {}

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
	public static String getPrimary(String type) {
		// getPrimary(type).address
		return inst.executeChild("getPrimary", new LuaObject[] {LuaObject.fromString(type)})
			.get("address").asString();
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
