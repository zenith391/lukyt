package java.lang;

public final class Math {

	public static double E = 2.718281828459045;
	public static double PI = 3.141592653589793;

	public static double abs(double a) {
		if (a < 0) return -a;
		else return a;
	}

	public static float abs(float a) {
		if (a < 0) return -a;
		else return a;
	}

	public static int abs(int a) {
		if (a < 0) return -a;
		else return a;
	}

	public static long abs(long a) {
		if (a < 0) return -a;
		else return a;
	}

	public static double ceil(double a) {
		double decimal = a - (int) a;
		return a + (1 - decimal);
	}

	public static double signum(double d) {
		if (d > 0d)
			return 1d;
		else if (d < 0d)
			return -1d;
		else
			return 0d;
	}

	public static float signum(float f) {
		if (f > 0f)
			return 1f;
		else if (f < 0f)
			return -1f;
		else
			return 0f;
	}

	public static double sin(double a) {
		return a;	
	}

	public static double toDegrees(double rad) {
		return (rad / (PI / 2)) * 180;
	}

	public static long toIntExact(long value) {
		if (value > Integer.MAX_VALUE) {
			throw new ArithmeticException();
		}
		return value;
	}
}
