# Lukyt
Lukyt is a JVM made in Lua supporting Java 1.2.
It's main advantage is to currently have a very small startup time and overhead.

Features:
- [x] While loops (technically should work)
- [x] For loops
- [x] Native support (integration from Lua side)
- [ ] Standard library (will prob move to GNU Classpath)
  - [x] System.out
  - [x] Some system methods
  - [x] Basic PrintStreams
  - [ ] Lua integration (from Java side)
    - [x] OS class
- [x] Full int/short/byte/char math
- [ ] Full float math
- [ ] Full long/double math
- [x] Classes
- [ ] Interfaces
- [ ] Throwables
- [ ] JIT

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

You'll notice Lukyt seemingly takes less time to execute the HelloWorld program.
This is because all the overhead of the JVM are not required on a program that small.
So on small programs, Lukyt's small overhead and interpreter are able to execute the program fastly.
