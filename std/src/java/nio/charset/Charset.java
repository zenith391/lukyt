package java.nio.charset;

public abstract class Charset {

	private static Charset[] charsets = new Charset[0];

	private String name;
	private boolean canEncode;
	private boolean canEncodeSet;

	protected Charset(String canonicalName, String[] aliases) {
		name = canonicalName;
	}

	public final String name() {
		return name;
	}

	public String displayName() {
		return name;
	}

	public final boolean isRegistered() {
		return true; // TODO: more extensive checks
	}

	/*public String displayName(Locale locale) {
		return name;
	}*/ // TODO: Locale support

	public abstract CharsetDecoder newDecoder();
	public abstract CharsetEncoder newEncoder();
	public abstract boolean contains(Charset cs);

	public boolean canEncode() {
		if (!canEncodeSet) {
			canEncode = false;
			try {
				newEncoder();
			} catch (UnsupportedOperationException e) {
				canEncode = false;
			}
		}
		return canEncode;
	}


	public static boolean isSupported(String charsetName) {
		return charsetName.equals("US-ASCII") || charsetName.equals("UTF-8");
	}

	public static Charset forName(String charsetName) {
		for (Charset set : charsets) {
			if (set.name().equals(charsetName)) {
				return set;
			}
		}
		return null; // TODO: throw UnsupportedCharsetException
	}

	public static Charset defaultCharset() {
		return forName("UTF-8");
	}

}
