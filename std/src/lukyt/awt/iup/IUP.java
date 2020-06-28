package lukyt.awt.iup;

public class IUP {

	public static LuaObject iup;

	static {
		iup = LuaObject._G.get("require").execute(LuaObject.fromString("iup")); // require("iup")
	}
}