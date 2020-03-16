import java.io.IOException;

public class HelloWorld {

	public static void main(String[] args) {
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

		long start = System.nanoTime();
		for (int i = 0; i < 10; i++) {
			System.out.println("Test " + (i+1));
		}
		long end = System.nanoTime();
		long total = end - start;
		System.out.println("Took: " + (total/1000) + "ms");

		while (true) {
			String str = "";
			char c = 0;
			while (c != 10) {
				try {
					c = (char) System.in.read();
				} catch (IOException e) {
					e.printStackTrace();
				}
				str = str + c;
			}
			System.out.print("You typed: " + str);
		}
	}
	
}
