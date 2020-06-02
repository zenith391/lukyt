# Lukyt
Lukyt is a toy project, a small JVM made in Lua supporting Java 6.
The most important reason i made it (other than being a toy project) was to run it on the [OpenComputers](https://github.com/MightyPirates/OpenComputers) mod. I am currently trying to port AWT to it :)

This also supports a shared OC Java API that this JVM shares with OCJ (link to come, will be released by [@TYKUHN2](https://github.com/TYKUHN2)), its javadoc [on my website](https://bwsecondary.ddns.net/jd/cil/li/oc/package-summary.html), Lukyt also have a Lua interop, which also haves a [javadoc](https://bwsecondary.ddns.net/jd/lukyt/package-summary.html).

[Roadmap](https://github.com/zenith391/lukyt/projects/1)

## How to use?
The JVM itself can be used by any program and is independent from the command-line program.

The command line program allows to execute classes.

To launch the HelloWorld test, just do:
```sh
lua lukyt.lua --classpath=test HelloWorld
```
