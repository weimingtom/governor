# Introduction #

A Governor script is the source code of a program running in the script engine. As in other programming languages it is written in a text file( For governor with the extension .gvs which stands for governor scripts). With a compiler the .gvs file gets compiled to byte code. The byte code is executed by the script engine.

# Byte code #

The byte code for governor is actually a static AS3 class containing an array with the compiled governor scripts. This class gets imported to the user's project.

# Governor script #

The .gvs file can contain more than one program. The begining of a program is indecated with a **=** followed by the program name. As explained in the previous section the source is compiled into an array. The program name is used for the index. So there are some rules:
  * the name has to be unique.
  * don't start the name with numbers.
  * prevent white spaces. (leading and tailing white spaces are trimmed.)
  * don't use special characters.

This is how a script can look like:
```
=script1
  // do something here
=script2
  // do something here
```

The governor script engine is a stack engine. Stack engines are operating in a certain way: **Each command takes it parameters from the stack and puts the result back on it.** That means you have to put each parameter you want to give to a command on the stack. To put a value on the stack use the command **push** followed by the value.

```
=script1
  push 1
  push 2
  add
```

In this example we use the command **add** to add the numbers 1 and 2. We have to know that add takes two parameters (most of the commands take two parameters). So before we call **add** we have to **push** the numbers 1 and 2 on the stack. Normally commands remove the parameters from the stack. So after calling **add** there is just 3 on the stack and not 1, 2 and 3.

Here are some other example scripts:

```
=script1
  push 4
  push 2
  div      // 4/2 = 2 - 2 is on the stack
  push 3
  mul      // 2*3 = 6 - 6 is on the stack

=script2
  push 4
  push 2
  mod      // 4%2 = 0 - 0 is on the stack

=script3
  push 4
  push 2
  pow      // 4^2 = 16 - 16 is on the stack
```

# program flow #

...

# multithreading #

Governor provides multithreading functionalities. Every time you start a program, the script engine creates a new process to run it. A process is a container object for program threads which are executing the code. A process can have more than one thread running parallely and the engine can have more than one process at the same time. A second thread is started by splitting a program with the command **fork**. Fork clones the thread with all properties, program code, memory, position in code, ... After forking a thread the original thread is thread is called the parent thread and the clone is called child thread. With the command **ipt** (isParentThread) you can you can separate the parent from the client to execute different command in each thread. Because you have to do this every time you fork a program, fork executes this command automatically for you.

```
=script1
  push #parent
  fork            // in the parent thread 1 is on stack
                  // in the child thread 0 is on stack
  jmp

  push "I am the child thread!"
  trace

  push #end      // jumps to the end mark to prevent execution of parent code
  gto

parent:

  push "I am the parent thread!"
  trace

end:

  push "End of child or parent thread."
  trace
```

# Memory access #

Governor has got a memory module to store values. There are two kind of memories. One memory that is local to the thread and a second memory that is local to the process.
...