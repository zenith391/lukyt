package java.util.function;

@FunctionalInterface
public interface Predicate<T> {
	public boolean test(T t);
}
