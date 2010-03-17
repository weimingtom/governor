package at.lueftenegger.governor{
	
	import at.lueftenegger.stackmachine.processes.Process;
	import at.lueftenegger.stackmachine.scheduler.Scheduler;
	import at.lueftenegger.stackmachine.threads.*;
	
	public class Process extends at.lueftenegger.stackmachine.processes.Process{

		/**
		 * Is used for stsg and ldsg to store
		 * objects locally to this process.
		 */
		private var _memProcess:Array;

		/**
		 * Constructor function. Processes are instantiated by the scheduler.
		 * 
		 * @param	refScheduler Reference to the schedular.
		 * @param	priority executioin priority for the new process. Default is 1.
		 * 
		 * @see at.lueftenegger.stackmachine.processes.Priority.as
		 */
		public function Process(refScheduler:at.lueftenegger.stackmachine.scheduler.Scheduler, priority:int = 1) {
			super(refScheduler, priority);
			_memProcess = new Array();
		}
		
		/**
		 * Stores object in _memProcess at index addr.
		 * 
		 * @param	addr The address(array index) in the memory.
		 * @param	object The object to safe.
		 */
		public function sts(addr:String, object:Object):void{
			_memProcess[addr] = object;
		}
		
		/**
		 * Returns the object from _memProcess at the given address(array index);
		 * 
		 * @param	addr The address(array index) in the memory.
		 * 
		 * @return The read object.
		 */
		public function lds( addr:String ):Object{
			return _memProcess[addr];
		}
		
		/**
		 * Creates a new Thread. This is a factory methode.
		 * @return Returns a new Thread.
		 */		
		override protected function getNewThread() :ThreadProgramable{
			return new at.lueftenegger.governor.Thread(this);
		}
	
	}
}