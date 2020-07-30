import java.io.*;

public class CosineTest {

	public static void main(String[] args) throws Exception {
		int j = 0;
		File file = new File("cosine.csv");
		FileOutputStream out = new FileOutputStream(file);
		System.out.println("Generating ~120 cosine values");
		long start = System.nanoTime();
		out.write("Radians,Cosine\n".getBytes());
		for (double i = -2*Math.PI; i < 2*Math.PI; i += 0.1) {
			double cos = Math.cos(i);
			String str = i + "," + cos + "\n";
			//System.out.print(str);
			out.write(str.getBytes());
			j++;
		}
		long end = System.nanoTime();
		System.out.println("Took " + ((end - start)/1000000) + "ms.");
		out.close();
	}

}
