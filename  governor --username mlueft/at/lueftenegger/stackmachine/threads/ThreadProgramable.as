package at.lueftenegger.stackmachine.threads{
	
	import at.lueftenegger.stackmachine.processes.Process;
	
	/**
	 * Extends the Thread class to add some properties and functions to
	 * enable program execution for the virtual machine.
	 */
	public class ThreadProgramable extends Thread {
		
		/**
		 * Holds references to functions for code commands.
		 * The function doesn't have to be implemented in this/inherited class.
		 */
		protected static var _functions:Array  = new Array();
		
		/**
		 * Holds the program code to execute.
		 */
		protected var _code:Array
		
		/**
		 * Holds stack for computations in program code.
		 */
		public var _stack:Array;
		
		/**
		 * A flag that indicated if this thread is the parent thread after forking.
		 */
		public var _isParent:Boolean;
		
		/**
		 * Code pointer. Points to the next command in the _code array.
		 * 
		 * @see _code
		 */
		public var _CP:uint;

		/**
		 * Points to the top of the stack.
		 */
		public var _stackTop:int;
		
		/**
		 * The constructor is called from the process and gets a reference from it.
		 * 
		 * @param refProcess A reference to the process.
		 */
		public function ThreadProgramable(refProc:Process){
			super(refProc);
			_code = new Array();
			_stack = new Array();
			_stackTop = 0;
			_CP = 0;
			_isParent = true;
			
		}
		
		/**
		 * Takes the code to execute in this thread and sets the code pointer to 0.
		 */
		public function set Code(value:Array):void{
			_code = value;
			_CP = 0;
		}
		
		/**
		 * This function registers a script function to the _functions array.
		 * 
		 * @param opCode the opcode to the function
		 * @param f A reference to a function that is called for the given opcode.
		 * 
		 * @see _functions
		 */
		public static function registerFunction(opCode:int, f:Object):void{
			_functions[opCode] = f;
		}
		
		/**
		 * Clones this thread. .next and .prev are set correctly automatically.
		 * 
		 * @return Returns a clone of this thread.
		 */
		public override function clone():Thread{
			var tmp:ThreadProgramable = new ThreadProgramable( refProc );
			tmp.next = next;
			tmp.prev = this;
			if( next != null)
				next.prev = tmp;
			next = tmp;
			
			var i:uint = 0;
//			for( i; i++ < _functions.length;)
//				tmp._functions[i] =  _functions[i] ;
			
			for( i = 0; i < _code.length;i++)
				tmp._code[i] = this._code[i];

			for( i = 0; i < _stack.length;i++)
				tmp._stack[i] = this._stack[i];
								
			tmp._CP = _CP;
			tmp._stackTop = _stackTop;
			tmp._isParent = false;
			_isParent = true;
			return tmp;
		}

		/**
		 * This is a very basic main function for program execution.
		 * This implementation just execudes parameter less functions
		 * In practice there is just the push function with one parameter.
		 * All others are parameterless.
		 */
		override public function main():void{
			if( _CP >= _code.length)			return;
			if( _functions[ _code[ _CP ] ]() )	_CP++;
		}
		
		/**
		 * Traces some debugging information
		 */
		public override function dotrace():void {
			trace( "Thread :"+ id +" codesize :"+ _code.length +" codepointer :"+ _CP + " stacksize :"+ _stackTop);
			//trace( "Thread :"+ id +" codesize :"+ _code.length +" codepointer :"+ _CP + " stacksize :"+ _stack.length);
		}		
	}
}
