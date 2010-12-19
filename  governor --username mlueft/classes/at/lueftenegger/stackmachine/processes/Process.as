package at.lueftenegger.stackmachine.processes{
	
	import at.lueftenegger.stackmachine.scheduler.Scheduler;
	import at.lueftenegger.stackmachine.threads.*;
	
	/**
	 * Process is a container class and holds all threads which actually are responsible for program execution.
	 */
	public class Process {

		/**
		 * _id stores the next free process id.
		 */
		private static var _id:uint;
		
		/**
		 * Holds a reference to the first thread.
		 */
		protected var _firstThread:Thread;
		
		/**
		 * Holds a reference to the last thread.
		 */
		protected var _lastThread:Thread;
		
		/**
		 * Holds the total number of threads in this process.
		 */
		protected var _numberThreads:int;
		
		/**
		 * Holds a reference to the scheduler.
		 */
		protected var _refScheduler:Scheduler;
		
		/**
		 * Constructor function. Processes are instantiated by the scheduler.
		 * 
		 * @param	refScheduler Reference to the schedular.
		 * @param	priority executioin priority for the new process. Default is 1.
		 * 
		 * @see at.lueftenegger.stackmachine.processes.Priority.as
		 */
		public function Process(refScheduler:Scheduler, priority:int = 1){
			_refScheduler = refScheduler; 
			id = ++_id;
			this.priority = priority;
			_numberThreads = 0;
		}
		
		/**
		 * Holds a reference to the next process in the scheduler.
		 * If there is just one process or this is the last one
		 * .next is null.
		 */
		public var next:Process;
		
		/**
		 * Holds a reference to the previous process in the scheduler.
		 * If there is just one process or this is the last one
		 * .prev is null.
		 */
		public var prev:Process;
		
		/**
		 * Holds the priority of this process. The priority determines
		 * how often the main function of this process is called.
		 */
		public var priority:int;
		
		/**
		 * Holds the id of this process.
		 */
		public var id:uint;
		
		/**
		 * Creates a new Thread. This is a factory methode.
		 * @return Returns a new Thread.
		 */
		protected function getNewThread():ThreadProgramable{
			return new ThreadProgramable( this );
		}
		
		/**
		 * This function is called by the scheduler to initiate
		 * the execution of a new program.
		 * 
		 * @param	code The code array to be executed.
		 * 
		 * @return Returns the thread that is running the code.
		 */
		public function start(code:Array):ThreadProgramable{
			var tmp:ThreadProgramable = getNewThread();
			
			if( _firstThread == null){
				_firstThread = tmp;
			}else{
				tmp.prev = _lastThread;
				_lastThread.next = tmp;
			}

			_lastThread = tmp;
			ThreadProgramable(_lastThread).Code = code;
			_numberThreads++;
			return tmp;
		}
		
		/**
		 * This functions kills the given thread.
		 * 
		 * @param threadId The id of the thread to kill.
		 */
		public function kill(threadId:int):void{
			
			if( _firstThread == null ){
				if( _lastThread == null)
					return;
			}
			
			if( _firstThread == _lastThread){ 
				if( _firstThread.id == threadId ){
					_firstThread = null;
					_lastThread = null;
					_numberThreads--;
					return;
				}
			}
			
			if( _firstThread.id == threadId){
				_firstThread = ThreadProgramable(_firstThread.next );
				_firstThread.prev = null;
				_numberThreads--;
				return;
			}
			
			if( _lastThread.id == threadId){
				_lastThread = ThreadProgramable( _lastThread.prev );
				_lastThread.next = null;
				_numberThreads--;
				return;
			}
			
			var thread:Thread = _firstThread;
			while( thread ){
				if( thread.id == threadId){
					thread.prev.next = thread.next;
					if(thread.next)
						thread.next.prev = thread.prev;
					_numberThreads--;
					return;
				}
				thread = thread.next;
			}
		}

		/**
		 * Iterates throu all threads and calls its main functions.
		 */
		public function main():void{

			var thread:Thread = _firstThread;
			while( thread ){
				thread.main();
				thread = thread.next;
			}
			if(_numberThreads == 0){
				_refScheduler.kill(id);
				return;
			}			
		}
		
		/**
		 * Traces some debug information about the process.
		 */
		public function dotrace():void{
			trace("---------------------------------------");
			trace("Process :" + id );
			var thread:Thread = _firstThread;
			while( thread ){
				thread.dotrace();
				thread = ThreadProgramable(thread.next);
			}
		}
	}
}