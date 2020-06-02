package cil.li.oc;
import lukyt.LuaObject;

/**
	Implementation-specific (Lukyt) for OC integration classes.
**/
class Utils {
	static final LuaObject require = LuaObject._ENV.get("require");
}
