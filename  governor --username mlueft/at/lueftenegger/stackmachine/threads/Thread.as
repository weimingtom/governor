package at.lueftenegger.stackmachine.threads{
	
	import at.lueftenegger.stackmachine.processes.*;
	
	/**
	 * This class build the basic thread. It provides basic functions and
	 * properties for the linked list. of thread in the process.
	 */	
	public class Thread {
		/**
		 * _id stores the next free thread id.
		 */
		private static var _id:uint;
		
		/**
		 * Holds a reference to the parent process.
		 */
		public var refProc:Process;

		/**
		 * Holds the id of this thread.
		 */
		public var id:int;
		
		/**
		 * Holds a reference to the next thread in this process.
		 * If there is just one thread or this is the last one
		 * .next is null.
		 */
		public var next:Thread;
		
		/**
		 * Holds a reference to the previous thread in this process.
		 * If there is just one thread or this is the first one
		 * .prev is null.
		 */
		public var prev:Thread;

		/**
		 * The constructor is called from the process and gets a reference from it.
		 * 
		 * @param refProcess A reference to the process.
		 */
		public function Thread( refProcess:Process ){
			refProc = refProcess;
			id = ++_id;
		}

		/**
		 * Clones this thread. .next and .prev are set correctly automatically.
		 * 
		 * @return Returns a clone of this thread.
		 */
		public function clone():Thread {
			//TODO: why isn't this a factory methode?
			var tmp:Thread = new Thread( refProc );
			tmp.next = next;
			tmp.prev = this;
			if( next != null)
				next.prev = tmp;
			next = tmp;
			
			return tmp;
		}

		/**
		 * Traces some debugging information
		 */
		public function dotrace():void {
			trace( "Thread :"+id);
		}
		
		/**
		 * Executes the program code. In this class .main is empty and does nothing.
		 * It is implemented in this class to safe castings in inherited classes.
		 */
		public function main():void {
			
		}
		
	}
}