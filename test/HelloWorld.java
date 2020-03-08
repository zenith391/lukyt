public class HelloWorld {

	public static void main(String[] args) {
		StringBuffer buf = new StringBuffer("Hello");
		buf.append(new char[] {',', ' '});
		buf.append("World!");
		buf.append("\n");
		System.out.println(buf.toString());
		System.out.println("I'm a kind Java program!\n");
	}
	
}
