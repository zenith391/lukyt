package lukyt;

import java.util.List;
import java.util.ArrayList;
import java.util.ListIterator;

public class LuaObject {
	private long handle;

	/**
		The {@link lukyt.LuaObject} corresponding to the Lua variable <code>_ENV</code>
	**/
	public static final LuaObject _ENV = new LuaObject(-1);

	/**
		The {@link lukyt.LuaObject} corresponding to the Lua variable <code>_G</code>
	**/
	public static final LuaObject _G   = new LuaObject(-2);

	private LuaObject(long handle) {
		this.handle = handle;
	}

	private static native long handleFrom(String str);
	private static native long handleFrom(long l);
	private static native long handleFrom(double d);

	public static LuaObject fromString(String str) {
		return new LuaObject(handleFrom(str));
	}

	public static LuaObject fromLong(long l) {
		return new LuaObject(handleFrom(l));
	}

	public static LuaObject fromDouble(double d) {
		return new LuaObject(handleFrom(d));
	}

	/**
		Set the child with this key to the lua variable corresponding to the given {@link lukyt.LuaObject}.
		@param key the key of the LuaObject to set
	**/
	public void set(String key, LuaObject lua) {
		set(handle, key, lua);
	}

	/**
		Returns the {@link lukyt.LuaObject} corresponding to the child of the lua variable corresponding to this LuaObject.
		@param key the key of the LuaObject to get
		@throws ChildNotFoundException if the child is not found
		@return the result
	**/
	public LuaObject get(String key) {
		LuaObject obj = get(handle, key);
		if (obj == null)
			throw new ChildNotFoundException(key);
		return obj;
	}

	/**
		Execute the child with key <code>key</code> as a function
		@param  key  the key of the function to execute
		@param  args the arguments of the function to execute
		@throws ChildNotFoundException if the child is not found
		@throws TypeNotPresentException if the child isn't a function
		@return the first result of the function, or null if there isn't any
	**/
	public LuaObject executeChild(String key, LuaObject[] args) {
		LuaObject obj = get(key);
		if (obj.getType().equals("function")) {

		} else {
			throw new TypeNotPresentException(obj.getType() + " != function", null);
		}
	}

	public List<String> keys() {
		if (!typeof(handle).equals("object")) {
			throw new TypeNotPresentException(typeof(handle) + " != object", null);
		}
		String[] keys = keys(handle);
		ArrayList<String> list = new ArrayList<String>(keys.length);
		for (int i = 0; i < keys.length; i++) {
			list.add(keys[i]);
		}
		return list;
	}

	public List<LuaObject> values() {
		ArrayList<LuaObject> list = new ArrayList<LuaObject>();
		for (String key : keys()) {
			list.add(get(handle, key));
		}
		return list;
	}

	/**
		Returns <code>true</code> if this <b>object</b> only contains numerical keys.
		The keys do not have to be in consequent order.<br/>
		Example: {1, 2, 3, 4} -> luaObject.isArray() -> <code>true</code><br/>
		
	**/
	public boolean isArray() {
		for (String key : keys()) {
			Long l = Long.parseLong(key);
			if (l == null) {
				return false;
			}
		}
		return true;
	}

	/**
		Returns <code>true/<code> if {@link lukyt.LuaObject.getType()} returns <code>"object"</code>.
	**/
	public boolean isObject() {
		return typeof(handle).equals("object");
	}

	public LuaObject execute() {
		return execute(new LuaObject[0]);
	}

	public LuaObject execute(LuaObject[] args) {
		return executeAll(args)[0];
	}

	public LuaObject[] executeAll(LuaObject[] args) {
		return execute(handle, args);
	}

	public String getType() {
		return typeof(handle);
	}

	public double asDouble() {
		return asDouble(handle);
	}

	public long asLong() {
		return asLong(handle);
	}

	private static native LuaObject get(long handle, String key);
	private static native String[] keys(long handle);
	private static native void set(long handle, String key, LuaObject lua);
	private static native String typeof(long handle);
	private static native LuaObject[] execute(long handle, LuaObject[] args);
	private static native double asDouble(long handle);
	private static native long asLong(long handle);
	private static native String asString();
}
