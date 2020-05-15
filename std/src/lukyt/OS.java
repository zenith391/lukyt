package lukyt;

/**
	This package is a binding around Lua <code>os</code> API
**/
public class OS {
	
	public static double time() {
		return LuaObject._ENV.get("os").get("time").execute().asDouble();
	}

	public static double clock() {
		return LuaObject._ENV.get("os").get("clock").execute().asDouble();
	}

}
