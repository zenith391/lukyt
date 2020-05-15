import lukyt.oc.Component;

public class ComponentTest {

	public static void main(String[] args) {
		String gpu = Component.getPrimary("gpu");
		Component.invoke(gpu, "setBackground", new Object[] {0x2D2D2D});
		Component.invoke(gpu, "fill", new Object[] {1, 1, 160, 50, " "});
		System.out.println("Filled screen with RGB 0x2D2D2D");
	}

}
