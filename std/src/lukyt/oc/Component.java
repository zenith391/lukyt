package lukyt.oc;
import lukyt.LuaObject;

public class Component {

	private static final LuaObject inst = Utils.require.execute(LuaObject.fromString("component"));

	public static String doc(String address, String method) {
		return inst.executeChild("doc", new LuaObject[] {LuaObject.fromString(address), LuaObject.fromString(method)})
			.asString();
	}

	public static Object[] invoke(String address, String method, Object[] args) {
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
		Unlike Lua, this returns the address
	**/
	public static String getPrimary(String type) {
		// getPrimary(type).address
		return inst.executeChild("getPrimary", new LuaObject[] {LuaObject.fromString(type)})
			.get("address").asString();
	}

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
