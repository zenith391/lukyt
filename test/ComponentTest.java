import cil.li.oc.Components;
import cil.li.oc.proxies.GPUProxy;

public class ComponentTest {

	public static void main(String[] args) {
		GPUProxy gpu = Components.getPrimary("gpu");
		gpu.setBackground(0x2D2D2D);
		gpu.fill(1, 1, 160, 50, ' ');
		System.out.println("Filled screen with color 0x2D2D2D");
	}

}
