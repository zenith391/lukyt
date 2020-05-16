package lukyt;

/**
	This package is a binding around Lua <code>os</code> API
**/
public class OS {

	private static final LuaObject os = LuaObject._ENV.get("os");
	
	public static double time() {
		return os.executeChild("time").asDouble();
	}

	public static double clock() {
		return os.executeChild("clock").asDouble();
	}

}
