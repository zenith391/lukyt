package java.lang.annotation;

import static java.lang.annotation.RetentionPolicy.*;
import static java.lang.annotation.ElementType.*;

@Documented
@Retention(RUNTIME)
@Target(ANNOTATION_TYPE)
public @interface Retention {
	public RetentionPolicy value();
}
