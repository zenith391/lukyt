public class HelloWorld {

	public static void main(String[] args) {
		System.out.print("I'm a kind Java program!\n");
		StringBuffer buf = new StringBuffer("Hello");
		buf.append(new char[] {',', ' '});
		buf.append("World!");
		buf.append("\n");
		System.out.print(buf.toString());
	}
	
}
