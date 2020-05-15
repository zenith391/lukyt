package lukyt;

import java.util.*;

public class LuaObject {
	private long handle;

	/**
		The {@link lukyt.LuaObject} corresponding to the Lua variable <code>_ENV</code>
	**/
	public static final LuaObject _ENV = new LuaObject(envHandle());

	/**
		The {@link lukyt.LuaObject} corresponding to the Lua variable <code>_G</code>
	**/
	public static final LuaObject _G   = _ENV.get("_G");

	/**
		The {@link lukyt.LuaObject} corresponding to Lua <code>nil</code>
	**/
	public static final LuaObject NIL  = new LuaObject();

	private static native long handleFromS(String str);
	private static native long handleFromL(long l);
	private static native long handleFromD(double d);
	private static native long nilHandle();
	private static native long envHandle();

	public static LuaObject fromString(String str) {
		return new LuaObject(handleFromS(str));
	}

	public static LuaObject fromLong(long l) {
		return new LuaObject(handleFromL(l));
	}

	public static LuaObject fromDouble(double d) {
		return new LuaObject(handleFromD(d));
	}

	public static LuaObject from(Object o) {
		if (o == null) {
			return LuaObject.NIL;
		} else if (o instanceof Double) {
			return LuaObject.fromDouble(((Double) o).doubleValue());
		} else if (o instanceof Long) {
			return LuaObject.fromLong(((Long) o).longValue());
		} else if (o instanceof Integer) {
			return LuaObject.fromLong(((Integer) o).longValue());
		} else if (o instanceof String) {
			return LuaObject.fromString((String) o);
		} else {
			throw new RuntimeException("Could not cast \"" + o.getClass().getName() + "\" to a Lua object.");
		}
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

	public Object asObject() {
		String type = getType();
		if (type.equals("number")) {
			return new Double(asDouble());
		} else if (type.equals("string")) {
			return asString();
		} else if (type.equals("nil")) {
			return null;
		} else if (type.equals("boolean")) {
			return new Boolean(asString());
		} else {
			throw new RuntimeException("Could not cast \"" + type + "\" to a Java object.");
		}
	}

	/**
		Set the child with this key to the lua variable corresponding to the given {@link lukyt.LuaObject}.
		@param key the key of the LuaObject to set
	**/
	public void set(String key, LuaObject lua) {
		if (key == null) {
			throw new IllegalArgumentException("key is null");
		}
		if (lua == null) {
			lua = LuaObject.NIL;
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
		if (!getType().equals("table")) {
			throw new TypeNotPresentException(getType() + " != table", null);
		}
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
		return executeChild(key, new LuaObject[0]);
	}

	private native String[] keys0();

	public List<String> keys() {
		if (!getType().equals("table")) {
			throw new TypeNotPresentException(getType() + " != table", null);
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
		The keys do not have to be in sequencial.<br/>
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
		Returns <code>true/<code> if {@link lukyt.LuaObject.getType()} returns <code>"nil"</code>.
	**/
	public boolean isNil() {
		return getType().equals("nil");
	}

	/**
		Returns <code>true/<code> if {@link lukyt.LuaObject.getType()} returns <code>"table"</code>.
	**/
	public boolean isTable() {
		return getType().equals("table");
	}

	public LuaObject execute() {
		return execute(new LuaObject[0]);
	}

	public LuaObject execute(LuaObject arg) {
		return executeAll(new LuaObject[] {arg})[0];
	}

	public LuaObject execute(LuaObject[] args) {
		return executeAll(args)[0];
	}
}
