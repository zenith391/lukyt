# Lukyt
Lukyt is a toy project, a small JVM made in Lua supporting Java 6.
The most important reason i made it (other than being a toy project) was to run it on the [OpenComputers](https://github.com/MightyPirates/OpenComputers) mod. I am currently porting AWT to it to use Java software on OpenComputers.

This also supports a OpenComputers Java API shared with OCJ (link to come, will be released by [@TYKUHN2](https://github.com/TYKUHN2)), this way programs are compatible for both way of running Java on OC, its javadoc is available on [my website](https://bwsecondary.ddns.net/jd/cil/li/oc/package-summary.html), Lukyt also have a Lua interop, which also haves a [javadoc](https://bwsecondary.ddns.net/jd/lukyt/package-summary.html).

Note that unlike Luje, this is aimed towards features: OC and Lua interoptability.

[Roadmap](https://github.com/zenith391/lukyt/projects/1)

## How to use?
The JVM itself can be used by any program and is independent from the command-line program.

The command line program allows to execute classes.

To launch the HelloWorld test, just do:
```sh
lua lukyt.lua --classpath=test HelloWorld
```

## Examples

Here is an example of the OC integration:
```java
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
```
