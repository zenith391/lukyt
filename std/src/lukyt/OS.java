package lukyt;

/**
	Binding class around Lua <code>os</code> API, it uses {@link LuaObject}.
**/
public class OS {

	private static final LuaObject os = LuaObject._ENV.get("os");
	
	/**
		Invoke `os.time()` and return the result as a double.
	**/
	public static double time() {
		return os.executeChild("time").asDouble();
	}

	/**
		Invoke `os.clock()` and return the result as a double.
	**/
	public static double clock() {
		return os.executeChild("clock").asDouble();
	}

	/**
		Invoke `os.execute()` which returns true if the shell is available.
	**/
	public static boolean isShellAvailable() {
		return os.executeChild("execute").asString().equals("true");
	}

	public static void execute(String command) {
		os.executeChild("execute", new LuaObject[] {LuaObject.fromString(command)});
	}

}
