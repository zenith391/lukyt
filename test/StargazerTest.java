public class StargazerTest {

	public static void main(String[] args) {
		boolean precise = false;
		for (int i = 0; i < 10; i++) {
			long ms = System.currentTimeMillis();
			System.out.println("Wall clock time: " + ms);
			if (ms % 1000 != 0) {
				precise = true;
			}
		}
		if (precise) {
			System.out.println("The clock is precise!");
		} else {
			System.out.println("The clock is unprecise!");
		}
	}

}
