public class ThreadTest {

	public static void main(String[] args) throws Exception {
		Thread t1 = new Thread(new Runnable() { // using runnable
			public void run() {
				while (true) {
					System.out.println("1");
				}
			}
		});
		t1.start();

		Thread t2 = new Thread() { // using anonymous classes
			public void run() {
				while (true) {
					System.out.println("2");
				}
			}
		};
		//t2.start();
	}

}
