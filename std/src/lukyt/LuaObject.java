package lukyt;

import java.util.*;

public class LuaObject {
	private long handle; /* unsafe value:
		to save memory and for sake of simplicity the value isn't actually a long
		and the JVM will crash when attempting to do math operations on it
	*/

	/**
		The {@link lukyt.LuaObject} corresponding to the Lua variable <code>_ENV</code>
	**/
	public static final LuaObject _ENV = new LuaObject(envHandle());

	/**
		The {@link lukyt.LuaObject} corresponding to the Lua variable <code>_G</code>
	**/
	public static final LuaObject _G   = _ENV.get("_G");

	private static native long handleFrom(String str);
	private static native long handleFrom(long l);
	private static native long handleFrom(double d);
	private static native long nilHandle();
	private static native long envHandle();

	public static LuaObject fromString(String str) {
		return new LuaObject(handleFrom(str));
	}

	public static LuaObject fromLong(long l) {
		return new LuaObject(handleFrom(l));
	}

	public static LuaObject fromDouble(double d) {
		return new LuaObject(handleFrom(d));
	}

	private LuaObject(long handle) {
		this.handle = handle;
	}

	public LuaObject() {
		this(nilHandle());
	}

	public LuaObject(String path) {
		// TODO
	}

	public native LuaObject[] executeAll(LuaObject[] args);
	public native String getType();
	public native double asDouble();
	public native long asLong();
	public native String asString();
	private native long get0(String key);

	/**
		Set the child with this key to the lua variable corresponding to the given {@link lukyt.LuaObject}.
		@param key the key of the LuaObject to set
	**/
	public void set(String key, LuaObject lua) {
		if (lua == null) {
			lua = new LuaObject();
		}
		set0(key, lua);
	}

	private native void set0(String key, LuaObject lua);

	/**
		Returns the {@link lukyt.LuaObject} corresponding to the child of the lua variable corresponding to this LuaObject.
		@param key the key of the LuaObject to get
		@throws ChildNotFoundException if the child is not found
		@return the result
	**/
	public LuaObject get(String key) {
		long handle = get0(key);
		if (handle == 0)
			throw new ChildNotFoundException(key);
		return new LuaObject(handle);
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
			return obj.execute(args);
		} else {
			throw new TypeNotPresentException(obj.getType() + " != function", null);
		}
	}

	/**
		Execute the child with key <code>key</code> as a function with zero arguments.
		@param  key  the key of the function to execute
		@throws ChildNotFoundException if the child is not found
		@throws TypeNotPresentException if the child isn't a function
		@return the first result of the function, or null if there isn't any
	**/
	public LuaObject executeChild(String key) {
		executeChild(key, new LuaObject[0])
	}

	private static native String[] keys0();

	public List<String> keys() {
		if (!getType().equals("object")) {
			throw new TypeNotPresentException(getType() + " != object", null);
		}
		String[] keys = keys0();
		ArrayList<String> list = new ArrayList<String>(keys.length);
		for (int i = 0; i < keys.length; i++) {
			list.add(keys[i]);
		}
		return list;
	}

	public List<LuaObject> values() {
		ArrayList<LuaObject> list = new ArrayList<LuaObject>();
		List<String> keys = keys();
		for (int i = 0; i < keys.size(); i++) {
			list.add(get(keys.get(i)));
		}
		return list;
	}

	/**
		Returns <code>true</code> if this <b>object</b> only contains numerical keys.
		The keys do not have to be in consequent order.<br/>
		Example: {1, 2, 3, 4} -> luaObject.isArray() -> <code>true</code><br/>
	**/
	public boolean isArray() {
		List<String> keys = keys();
		for (int i = 0; i < keys.size(); i++) {
			Long l = Long.parseLong(keys.get(i));
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
		return getType().equals("object");
	}

	public LuaObject execute() {
		return execute(new LuaObject[0]);
	}

	public LuaObject execute(LuaObject[] args) {
		return executeAll(args)[0];
	}
}
