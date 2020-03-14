public class HelloWorld {

	public static void testLoop() {
		System.out.println("Test");
	}

	public static void main(String[] args) {
		System.out.println("Hello, World!");

		// String Buffer test
		StringBuffer buf = new StringBuffer("I'm a kind");
		buf.append(new char[] {'.', '.', '.'});
		buf.append(" Java program!");
		buf.append("\n");

		System.out.print(buf.toString());
		for (int i = 0; i < 10; i++) {
			testLoop();
		}
	}
	
}
