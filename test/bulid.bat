rem A simple bat. file to compile your Java files.
rem To compile a file, run it and specify .java file as an argument (>build HelloWorld.java)
rem Or just drag and drop your file on it!
"%JAVA_HOME%/bin/javac" -Xlint:-options -source 6 -target 6 %1