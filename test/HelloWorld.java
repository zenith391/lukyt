public class HelloWorld {

	public static void main(String[] args) {
		System.out.println("Hello, World!");

		// String Buffer test
		StringBuffer buf = new StringBuffer("I'm a kind");
		buf.append(new char[] {'.', '.', '.'});
		buf.append(" Java program!");
		buf.append("\n");

		System.out.println("OS name: " + System.getProperty("os.name"));

		System.out.print(buf.toString());
		long start = System.nanoTime();
		for (int i = 0; i < 100; i++) {
			System.out.println("Test " + (i+1));
		}
		long end = System.nanoTime();
		long total = end - start;
		System.out.println("Took: " + (total/1000) + "ms");
	}
	
}
