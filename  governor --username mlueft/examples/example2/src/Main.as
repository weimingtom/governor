package  src{

	import flash.events.Event;	
	import flash.display.MovieClip;

	import src.gsc.Governor;
	import at.lueftenegger.governor.*;
	
	public class Main extends MovieClip {
		
		private var _governor:Scheduler;

		public function Main() {
			
			Governor.fillScripts();
			
			_governor = new Scheduler();
			
			_governor.start( Governor.scripts["script1"] );
			
			addEventListener(Event.ENTER_FRAME, enterFrame);
			
		}

		private var frame:int = 0;
		private function enterFrame(e:Event):void{
			// execute scripts in the script engine
			_governor.main();
			
			if (frame++ == 10) {
				removeEventListener(Event.ENTER_FRAME, enterFrame);
			}
		}
	}
}