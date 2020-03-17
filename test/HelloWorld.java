import java.io.IOException;

public class HelloWorld {

	public static void main(String[] args) throws Exception {
		long start = System.nanoTime();
		System.out.println("Hello, World!");

		// String Buffer test
		StringBuffer buf = new StringBuffer("I'm a kind");
		buf.append(new char[] {'.', '.', '.'});
		buf.append(" Java program!");
		buf.append("\n");

		System.out.print(buf);
		System.out.println("OS name: " + System.getProperty("os.name"));

		if (System.getProperty("java.vendor").equals("Lukyt")) {
			System.out.println("I am running on Lukyt currently!");
		} else {
			System.out.println("I am NOT running on Lukyt currently!");
		}
		long end = System.nanoTime();
		long total = end - start;
		System.out.println("Took: " + (total/1000) + "ms");

		start = System.nanoTime();
		for (int i = 0; i < 10; i++) {
			System.out.println("Test " + (i+1));
		}
		end = System.nanoTime();
		total = end - start;
		System.out.println("Took: " + (total/1000) + "ms");

		System.out.println("Welcome to this.. testing program?");
		System.out.println("Type \"throw\" to throw an exception");
		System.out.println("Type \"woops\" to throw a catched exception");
		while (true) {
			String str = "";
			char c = 0;
			System.out.print("> ");
			while (c != 10) {
				try {
					c = (char) System.in.read();
				} catch (IOException e) {
					e.printStackTrace();
				}
				str = str + c;
			}
			System.out.print("You typed: " + str);
			if (str.equals("throw\n")) {
				throw new Exception("Test exception");
			} else if (str.equals("woops\n")) {
				try {
					throw new Exception("Woops :/");
				} catch (Exception e) {
					System.out.println("Caught exception");
					e.printStackTrace();
				}
			}
		}
	}
	
}
