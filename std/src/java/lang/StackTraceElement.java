package java.lang;

public StackTraceElement {
	private String declaringClass;
	private String methodName;
	private String fileName;
	private int lineNumber;
	private boolean nativeMethod;

	public StackTraceElement(String declaringClass, String methodName, String fileName, int lineNumber) {
		this.declaringClass = declaringClass;
		this.methodName = methodName;
		this.fileName = fileName;
		this.lineNumber = lineNumber;
		this.nativeMethod = false;
	}

	public String getClassName() {
		return declaringClass;
	}

	public String getFileName() {
		return fileName;
	}

	public int getLineNumber() {
		return lineNumber;
	}

	public String getMethodName() {
		return methodName;
	}

	public boolean isNativeMethod() {
		return nativeMethod;
	}

	public String toString() {
		StringBuffer sb = new StringBuffer();
		sb.append(className);
		sb.append('.');
		sb.append(getMethodName());
		sb.append('(');
		if (fileName == null) {
			if (nativeMethod) {
				sb.append("Native Method");
			} else {
				sb.append("Unknown Source");
			}
		} else {
			sb.append(fileName);
			if (lineNumber > 0) {
				sb.append(lineNumber);
			}
		}
		sb.append(')');
		return sb.toString();
	}
}
