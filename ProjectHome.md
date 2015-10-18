Governor is a script engine written in AS3. It provides all functions and operators you know from AS3; operators, math functions, math constants. Additionally it provides multithreading functionality for parallel execution of code. !The flash player is design as a single thread application, so governor is providing green threads!

http://en.wikipedia.org/wiki/Green_threads

Governor started in 2006 as a AS2 project. At that time I worked on a game engine and I wanted a flexible system to interact with the game world. Without knowing anything about script engines, virtual machines and so on I started to read articles, web pages ...


I wanted the design to meet the following conditions:
  * It should be Independent from any other framework, so it can be used in AIR, Flash and Flex.
  * To use governor it must not be necessary to inherit from it. So it can be integrated easily in any existing project.
  * It should be easy to extend the core API when used in a project.