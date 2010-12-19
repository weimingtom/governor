package 
{
	import at.lueftenegger.governor.OpCodes;
	import at.lueftenegger.governor.Scheduler;
	import flash.display.Sprite;
	import flash.events.Event;
	import gvs.Governor;
	
	/**
	 * This example shows how governor is instantiated and used in a project-
	 * 
	 * @author Michael Lueftenegger
	 */
	public class Main extends Sprite 
	{
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private var _governor:Scheduler;
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			// prepare the script array for execution.
			Governor.fillScripts();
			
			// instantiates the script engine.
			_governor = new Scheduler();
			
			// give the script enginge a program to execute.
			_governor.start( Governor.scripts["script1"] );
			
			addEventListener(Event.ENTER_FRAME, enterFrame);
		}
		
		private var frame:int = 0;
		private function enterFrame(E:Event):void 
		{
			// execute scripts in the script engine
			_governor.main();
			
			if (frame++ == 500) {
				removeEventListener(Event.ENTER_FRAME, enterFrame);
			}
		}
	}
	
}