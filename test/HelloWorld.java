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

		long start = System.nanoTime();
		for (int i = 0; i < 10; i++) {
			System.out.println("Test " + (i+1));
		}
		long end = System.nanoTime();
		long total = end - start;
		System.out.println("Took: " + (total/1000) + "ms");
	}
	
}
