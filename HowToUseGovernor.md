This is written quick'n dirty because :-) peter has joined the project :-) and he wants to use it.

# Overview #

To use governor you need to do these steps:
  1. Instantiating the Scheduler in you core class.
  1. Write you own OpFunctions (Builds your own API).
  1. determinging the points in the code where programs should be started.
  1. call the Scheduler's main function in your main function.

I'll explain the usage with an example. In my game cannonrun the player can trigger hundreds of switches. Some of them are opening/closing doors, others are triggering scripted sequences.

This is the design of my engine:

LogicCore->LogicCreature->LogicDoors->LogicSwitches->LogicCannonrun

**LogicCore**
The class LogicCore provides some basic functions that are needed in all inherited classes. Here I instantiate the Scheduler from the governor namespace.

```
scriptEngine = new at.lueftenegger.governor.Scheduler();
```

**LogicCreature**
This class inherites from LogicCore and adds the functionality for creatures and the player. It holds all creatures in a hash. In this class I implement all OpFunctions for creature interaction(for example placeCreatur, getCreatureX, getCreatureY, setCreatureEnergy).

```
 class LogicCreature extends LogicCore{
    
    public function init():void{
      super.init();
      ...
      // not registerd to this.scriptEngine!!!
      // registered to a static function of the Thread class!!!
      at.lueftenegger.governor.Thread.registerScriptFunction(0xff, getCreatureX );
      ...
    }

    private function getCreatureX(thread:Thread, e:*):int{
        // ignore e for now in the opFunction
        var p1:* = thread.pop(); // takes a value from the stack
        
        var result:int = this.arCreatures[p1].x;
        thread.push(result);
        
        // For now always return 1.
        return 1;
    }
 }
```

In the init function of LogicCreature I register all opFunctions with the corresponding byteCode to the Thread class. Now the Scheduler knows what function to call if it finds the byteCode for getCreatureX in the program code.

This is the same in LogicDoors and LogicSwitches.

In the class LogicCore I save a reference to the byteCode(static AS3 class with an array containing the compiled governor scripts). Somewhere in the class LogicDoors there is a function that is called when the player triggers a switch in the game. This is the point where where a program is started in our scripEngine.

```
   ...
   private function switchTriggered(e:SwitchEvent):void{

      this.scriptEngine.start( this.refScripts[e.target.scriptName]);

   }
```




# Details #

Add your content here.  Format your content with:
  * Text in **bold** or _italic_
  * Headings, paragraphs, and lists
  * Automatic links to other wiki pages