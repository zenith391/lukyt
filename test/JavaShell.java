import java.io.IOException;
import lukyt.OS;

public class JavaShell {

	private static final String CSI = ((char) 27) + "[";

	public static String sgr(String sgr) {
		return CSI + sgr + "m";
	}

	public static String reset(String str) {
		return reset() + str;
	}

	public static String reset() {
		return sgr("0");
	}

	public static String bold(String str) {
		return sgr("1") + str;
	}

	public static String bgColor(String str, int color) {
		return sgr(Integer.toString(40 + color)) + str;
	}

	public static String fgColor(String str, int color) {
		return sgr(Integer.toString(30 + color)) + str;
	}

	public static String bfgColor(String str, int color) {
		return sgr(Integer.toString(90 + color)) + str;
	}

	public static void main(String[] args) {
		while (true) {
			String str = "";
			char c = 0;
			System.out.print(bold(bfgColor(System.getenv("PWD"), 4)) + reset("> "));
			while (c != 10) {
				try {
					c = (char) System.in.read();
				} catch (IOException e) {
					e.printStackTrace();
				}
				if (c != 10)
					str = str + c;
			}
			try {
				if (str.equals("exit")) {
					System.exit(0);
				} else if (str.equals("gc")) {
					System.gc();
				} else if (str.equals("debug throw")) {
					throw new RuntimeException();
				} else {
					//throw new CommandNotFoundException(str);
					OS.execute(str);
				}
			} catch (CommandNotFoundException e) {
				System.err.println("CommandNotFoundException: " + e.getMessage());
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
	}

	static class CommandNotFoundException extends RuntimeException {

		public CommandNotFoundException(String command) {
			super(command);
		}

	}

}