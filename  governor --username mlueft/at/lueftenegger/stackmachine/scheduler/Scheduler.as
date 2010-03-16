package at.lueftenegger.stackmachine.scheduler{
	
	import at.lueftenegger.stackmachine.processes.*;
	import at.lueftenegger.stackmachine.threads.ThreadProgramable;
	
	/**
	 * This is the main class of the script engine. This class is instantiated from the user.
	 */
	public class Scheduler{

		/**
		 * Holds a reference to the first process.
		 */
		private var _firstProcess:Process;
		
		/**
		 * Holds a reference to the last process.
		 */
		private var _lastProcess:Process;
		
		/**
		 * A helper for priority handling. It is encreased at each main call.
		 * If five is reached it is reset to 0.
		 */
		private var _run:uint;
		
		/**
		 * Holds the total number of processes.
		 */
		private var _numberProcesses:int;
		
		public function Scheduler(){
			_run = 0;
		}
		
		/**
		 * Factory methode to get a new process.
		 * 
		 * @return Returns a new process.
		 */
		protected function getNewProcess():Process {
			return new Process( this );
		}
		
		/**
		 * Initiates the execution of a new program.
		 * 
		 * @param	code The program to execute.
		 * 
		 * @return Returns the thread that is running the code.
		 */
		public function start( code:Array ):ThreadProgramable{
			var tmp:Process = getNewProcess();
			
			if( _firstProcess == null){
				_firstProcess = tmp;
			}else{
				tmp.prev = _lastProcess;				
				_lastProcess.next = tmp;
			}
			_numberProcesses++;
			_lastProcess = tmp;
			return _lastProcess.start( code );
		}
		
		/**
		 * Sets the priority of the process of the given id.
		 * 
		 * @param	Pid Process id.
		 * @param	Priority The priority for the process.
		 * 
		 * @see Priority
		 */
		public function setPriority(Pid:uint, Priority:int):void{
			var process:Process = _firstProcess;
			while( process )
			{
				if( process.id == Pid )
					process.priority = Priority;
				process = process.next;
			}
		}
		
		/**
		 * Manages the execution of all processes and threads.
		 * This functions is mostly called in the main function
		 * in the user's game logic on an onEnterFrame basis.
		 */
		public function main():void{
			if(_numberProcesses == 0)
				return;

			var process:Process = _firstProcess;
			while( process ){
				while(process.priority== Priority.KILL){
					kill( process.id );
					process = process.next;
				}
				
				if( process.priority > Priority.KILL){
					process.main();
					if ( process.priority > Priority.NORMAL){
						process.main();
						if ( process.priority > Priority.HIGH){
							process.main();
							if ( process.priority > Priority.HIGHER){
								process.main();
							}
						}
					}
				}else if( process.priority < Priority.KILL){
					if( process.priority % _run == 0)
						process.main();
				}
				process = process.next;
			}
			_run++;
			if( _run == 5)
				_run = 0;
			
		}
		
		/**
		 * Kills the process with the given id.
		 * 
		 * @param	v Process id.
		 */
		public function kill(v:int):void{
			
			if( _firstProcess == null )
				if( _lastProcess == null)
					return;
			
			if( _firstProcess == _lastProcess){ 
				if( _firstProcess.id == v ){
					_firstProcess = null;
					_lastProcess = null;
					_numberProcesses--;
					return;
				}
			}
			
			if( _firstProcess.id == v){
				_firstProcess = _firstProcess.next;
				_firstProcess.prev = null;
				_numberProcesses--;
				return;
			}
			
			if( _lastProcess.id == v){
				_lastProcess = _lastProcess.prev ;
				_lastProcess.next = null;
				_numberProcesses--;
				return;
			}
			
			var thread:Process = _firstProcess.next;
			while( thread ){
				if( thread.id == v){
					thread.prev.next = thread.next;
					thread.next.prev = thread.prev;
					_numberProcesses--;
					return;
				}
				thread = thread.next;
			}
		}

		/**
		 * Tracces some debug information about the scheduler.
		 */
		public function dotrace():void{
			var process:Process = _firstProcess;
			while ( process ) {
				process.dotrace();
				process = process.next;
			}			
		}		
	}
}