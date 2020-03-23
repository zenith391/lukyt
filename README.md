# Lukyt
Lukyt is a small JVM made in Lua supporting Java 1.4.
It's main advantage is to currently have a very small startup time and use way much less memory.

[Roadmap](https://github.com/zenith391/lukyt/projects/1)

## How to use?
The JVM itself can be used by any program and is independent from the command-line program.

The command line program allows to execute classes.
You can print an help message with `lua lukyt.lua --help`

To launch the HelloWorld test, you can do:
```sh
lua lukyt.lua --classpath=test HelloWorld
```

which will give the same result as:
```sh
java -cp test HelloWorld
```

On my computer, the HelloWorld example used maximum 2.5MB while on the same computer, the OpenJDK's JVM used maximum 13MB.