package lukyt;

/**
	This is used internally, do not use!
**/
public class OS {
	
	public static double time() {
		return LuaObject._ENV.get("os").get("time").execute().asDouble();
	}

	public static double clock() {
		return LuaObject._ENV.get("os").get("clock").execute().asDouble();
	}

}
