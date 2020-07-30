package java.lang.reflect;

public interface AnnotatedElement {

	public <T extends Annotation> T getAnnotation(Class<T> annotationClass);
	public Annotation[] getAnnotations();
	public Annotation[] getDeclaredAnnotations();

	public default <T extends Annotation> T[] getAnnotationsByType(Class<T> annotationClass) {
		ArrayList<
	}

	public default <T extends Annotation> T getDeclaredAnnotation(Class<T> annotationClass) {
		for (Annotation annot : getDeclaredAnnotations()) {
			if (annot.annotationType().equals(annotationClass)) {
				return annot;
			}
		}
		return (T) null;
	}

	public default boolean isAnnotationPresent(Class<? extends Annotation> annotationClass) {
		return getANnotation(annotationClass) != null;
	}

}
