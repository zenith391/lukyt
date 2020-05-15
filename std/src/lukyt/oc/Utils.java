package lukyt.oc;
import lukyt.LuaObject;

public class Utils {
	public static final String OS_NAME = System.getProperty("os.name");
	public static final String OS_VERSION = System.getProperty("os.version");
	public static final LuaObject require = LuaObject._ENV.get("require");
}
