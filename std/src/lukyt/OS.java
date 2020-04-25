package lukyt;

/**
	This is used internally, do not use!
**/
public class OS {

	/*
	public static double time() {
		return LuaObject.getEnv().get("os").get("time").execute().asDouble();
	}

	public static double clock() {
		return LuaObject.getEnv().get("os").get("clock").execute().asDouble();
	}*/

	public static native double time();
	public static native double clock();

}
