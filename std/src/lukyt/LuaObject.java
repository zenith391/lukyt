package lukyt;

import java.util.*;

/**
	Java class wrapping a Lua value. Can be used for Lua interoptability.
**/
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

	/**
		Cast a String to a LuaObject.
	**/
	public static LuaObject fromString(String str) {
		return new LuaObject(handleFromS(str));
	}

	/**
		Cast a primitive <code>long</code> value to a LuaObject.
	**/
	public static LuaObject fromLong(long l) {
		return new LuaObject(handleFromL(l));
	}

	/**
		Cast a primitive <code>double</code> value to a LuaObject.
	**/
	public static LuaObject fromDouble(double d) {
		return new LuaObject(handleFromD(d));
	}

	/**
		Auto-cast object <code>o</code> to a LuaObject.
		Object must be one of:
		<ul>
			<li>Double</li>
			<li>Long</li>
			<li>Integer</li>
			<li>String</li>
		</ul>
	**/
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

	/**
		Init the LuaObject with a new <code>nil</code> value.
	**/
	public LuaObject() {
		this(nilHandle());
	}

	/**
		Use path <code>path</code> to find the LuaObject through {@link #_ENV}.<br/>
		Childrens are separated by dots (<code>.</code>)<br/><br/>
		Example: <code>os.time</code> returns the child named <code>time</code>
		of the <code>os</code> table which is a child of the {@link #_ENV} table.
	**/
	public LuaObject(String path) {
		// TODO
	}

	/**
		Execute this Lua Object as a function with arguments <code>args</code> and return
		all of its results as LuaObjects.
	**/
	public native LuaObject[] executeAll(LuaObject[] args);
	public native String getType();
	/**
		Returns this LuaObject as a primitive <code>double</code> value.<br/>
		If the Lua object isn't a <code>number</code>, this returns 0.
	**/
	public native double asDouble();
	/**
		Returns this LuaObject as a primitive <code>long</code> value.<br/>
		If the Lua object isn't a <code>number</code>, this returns 0.<br/>
		The number is floored if necessary.
	**/
	public native long asLong();
	/**
		Returns this LuaObject as a String object.<br/>
		If the Lua object isn't a <code>string</code>, this returns the result of <code>tostring()</code>.<br/>
	**/
	public native String asString();
	private native long get0(String key);

	/**
		Returns this LuaObject as either a String, a Double, a Boolean or a <code>null</code> value.
	**/
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

	/**
		Returns the list of all the keys used in this Lua <code>table</code> object.
	**/
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

	/**
		Returns the list of all the values in this Lua <code>table</code> object.
	**/
	public List<LuaObject> values() {
		List<String> keys = keys();
		ArrayList<LuaObject> list = new ArrayList<LuaObject>(keys.size());
		for (String key : keys) {
			list.add(get(key));
		}
		return list;
	}

	/**
		Returns <code>true</code> if this <b>object</b> only contains numerical keys.
		The keys do not have to be in sequencial.<br/>
		Example: {1, 2, 3, [5]=4} -> luaObject.isArray() -> <code>true</code>
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
		Returns <code>true</code> if {@link #getType()} returns <code>"nil"</code>.
	**/
	public boolean isNil() {
		return getType().equals("nil");
	}

	/**
		Returns <code>true</code> if {@link #getType()} returns <code>"table"</code>.
	**/
	public boolean isTable() {
		return getType().equals("table");
	}

	/**
		Execute this Lua Object as a function no arguments and
		return the first return value.
	**/
	public LuaObject execute() {
		return execute(new LuaObject[0]);
	}

	/**
		Execute this Lua Object as a function with one argument <code>arg</code> and
		return the first return value.
	**/
	public LuaObject execute(LuaObject arg) {
		return executeAll(new LuaObject[] {arg})[0];
	}

	/**
		Execute this Lua Object as a function with arguments <code>args</code> and
		return the first return value.
	**/
	public LuaObject execute(LuaObject[] args) {
		LuaObject[] lua = executeAll(args);
		if (lua.length == 0) {
			return null;
		} else {
			return lua[0];
		}
	}
}
