package java.lang;

public final class Math {

	public static final double E = 2.718281828459045;
	public static final double PI = 3.141592653589793;
	private static final boolean preferNative = Boolean.parseBoolean(System.getProperty("lukyt.math.preferNative", "true"));

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

	public static double pow(double a, double b) {
		double oa = a;
		if (b == 0) return 1;
		if (b > 0) {
			for (int i = 1; i < b; i++) {
				a = a * oa;
			}
		} else {
			for (int i = 0; i < 1/b; i++) {
				a = a / oa;
			}
		}
		return a;
	}

	private static final int[] factorials = new int[] {
		1, 1, 2, 6, 24, 120, 720, 5040, 40320, 362880, 3628800, 39916800, 479001600};
	private static int factorial(int n) {
		if (n < factorials.length) { // small pre-computed factorials
			return factorials[n];
		}
		if (n == 0) return 1;
		else return n * factorial(n - 1);
	}

	public static double sin(double x) {
		return 1 - cos(x);
	}


	public static double cos(double x) {
		if (preferNative) return cos_native(x);
		x = x % (2*PI);
		if (x < -(PI/2)) {
			return -cos(PI+x);
		} else if (x > PI/2) {
			return -cos(PI-x);
		}
		int terms = 6;
		double num = 1;
		int j = 0;
		for (int i = 2; i < terms*2; i += 2) {
			double term = pow(x, i) / factorial(i);
			if (j % 2 == 0) num -= term;
			else num += term;
			j++;
		}
		return num;
	}

	public static native double cos_native(double x);

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
