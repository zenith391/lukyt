package java.lang;

import java.lang.annotation.*;

@Retention(RetentionPolicy.RUNTIME)
@Target({ElementType.CONSTRUCTOR, ElementType.FIELD,
	ElementType.LOCAL_VARIABLE, ElementType.METHOD,
	ElementType.PACKAGE, ElementType.PARAMETER,
	ElementType.TYPE})
public @interface Deprecated {}