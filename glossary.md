# Glossary #

**API**

**Scheduler**

The Scheduler is main module of Governor. It's the "CPU"

**Process**


**Thread**


**OpFunction**
While executing a program the script engine is reading the byte code to determine what command has to be executed next. If the next command(opCode) is determined the script engine calls the corresponding function, the opFunction. Each opCode has its opFunction. When you build your own API you have to write your own opFunctions.

**OpCode**
Internally every command is identified with a number. Each number is unique and the relation between command and number is fix and not changeable. This number is called the opCode.

**Mnemonic**
A Mnemonic a command in the governor script. It is the human readable representation of a command that is internally itendified by a number(the opCode). Example: push, pop, add, ...

**ByteCode**
In general the Byte code is the binary version of a program (mostly) running in a virtual machine/script engine.

# Details #

Add your content here.  Format your content with:
  * Text in **bold** or _italic_
  * Headings, paragraphs, and lists
  * Automatic links to other wiki pages