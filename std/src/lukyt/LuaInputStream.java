package lukyt;

import java.io.InputStream;
import java.io.IOException;

public class LuaInputStream extends InputStream {

	private LuaObject stream;
	private boolean eof;
	private static final LuaObject stringByte = LuaObject._G.get("string").get("byte");

	public LuaInputStream(LuaObject stream) {
		this.stream = stream;
	}

	public int read() throws IOException {
		LuaObject obj = stream.executeChild("read", new LuaObject[] {LuaObject.fromLong(1)});
		if (obj.asString().length() == 1) {
			LuaObject ch = stringByte.execute(obj);
			return (int) ch.asLong();
		} else {
			eof = true;
			return -1;
		}
	}

	public int available() {
		return eof ? 1 : 0;
	}

	public void close() throws IOException {
		stream.executeChild("close");
	}

}
