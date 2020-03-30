import java.io.IOException;
import java.util.ArrayList;
import java.util.Iterator;

public class HelloWorld {

	public static void main(String[] args) throws Exception {
		long start = System.nanoTime();
		System.out.println("Hello, World!");
		System.out.println("OS kind: " + System.getProperty("os.name"));

		if (System.getProperty("java.vendor").equals("Lukyt")) {
			System.out.println("I am running on Lukyt currently!");
		} else {
			System.out.println("I am NOT running on Lukyt currently!");
		}
		long end = System.nanoTime();
		long total = end - start;
		System.out.println("Took: " + (total/1000000) + "ms");

		start = System.nanoTime();
		for (int i = 0; i < 10; i++) {
			System.out.println("Test " + (i+1));
		}
		end = System.nanoTime();
		total = end - start;
		System.out.println("Took: " + (total/1000000) + "ms");

		ArrayList<String> list = new ArrayList<String>();
		list.add("Hello");
		list.add("World");

		System.out.println("List content:");
		for (String str : list) {
			System.out.println("- " + str);
		}

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
			} else if (str.equals("exit\n")) {
				System.exit(0);
			} else if (str.equals("null\n")) {
				throw null;
			} else if (str.equals("gc\n")) {
				System.gc();
			}
		}
	}
	
}
