package java.util;

import java.util.function.*;

public final class Optional<T> {

	private T value;

	private Optional() {
		this.value = null;
	}

	private Optional(T value) {
		this.value = value;
	}

	public static <T> Optional<T> empty() {
		return new Optional<T>();
	}

	public static <T> Optional<T> of(T value) {
		return new Optional<T>(Objects.requireNonNull(value, "value"));
	}

	public static <T> Optional<T> ofNullable(T value) {
		if (value == null)
			return empty();
		else
			return of(value);
	}

	public T get() {
		if (value == null)
			throw new NoSuchElementException();
		return value;
	}

	public boolean isPresent() {
		return value != null;
	}

	public void ifPresent(Consumer<? super T> consumer) {
		if (value != null) {
			consumer = Objects.requireNonNull(consumer, "consumer");
			consumer.accept(value);
		}
	}

	public Optional<T> filter(Predicate<? super T> predicate) {
		predicate = Objects.requireNonNull(predicate, "predicate");
		if (value != null) {
			value = predicate.test(value) ? value : null;
		}
		return Optional.empty();
	}

	public <U> Optional<U> map(Function<? super T, ? extends U> mapper) {
		mapper = Objects.requireNonNull(mapper, "mapper");
		if (value != null) {
			return ofNullable(mapper.apply(value));
		} else {
			return empty();
		}
	}

	public <U> Optional<U> flatMap(Function<? super T, Optional<U>> mapper) {
		if (value != null) {
			return Objects.requireNonNull(mapper.apply(value), "mapper result is null");
		} else {
			return Optional.empty();
		}
	}

	public T orElse(T other) {
		return value == null ? other : value;
	}

	public T orElseGet(Supplier<? extends T> other) {
		if (value == null) {
			return Objects.requireNonNull(other.get());
		} else {
			return value;
		}
	}

	public boolean equals(Object obj) {
		if (obj instanceof Optional) {
			Optional opt = (Optional) obj;
			if (value == null) {
				return opt.value == null;
			} else {
				return value.equals(opt.value);
			}
		}
		return false;
	}

	public int hashCode() {
		return value == null ? 0 : value.hashCode();
	}

	public String toString() {
		if (value == null) {
			return "Optional[empty]";
		} else {
			return "Optional[value=" + value.toString() + "]";
		}
	}

}
