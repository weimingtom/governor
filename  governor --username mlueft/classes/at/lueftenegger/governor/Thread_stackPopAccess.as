
package at.lueftenegger.governor{
	
	import at.lueftenegger.stackmachine.processes.Process;
	import at.lueftenegger.stackmachine.threads.*;
	
	/**
	 * This class implements a congrete thread for the swfscript engine.
	 */
	public class Thread extends ThreadProgramable{
		
		/**
		 * Is used for sts and ldr to store
		 * objects in memory locally to this thread.
		 */
		public var _memLocal:Array;
		
		/**
		 * Indicates if this thread is locked. If the thread is locked 
		 * just the code of this thread is executed till the the thread
		 * is unlocked or the end of code is reached.
		 */
		public var locked:Boolean = false;
		
		/**
		 * The constructor is called from the process and gets a reference from it.
		 * 
		 * @param refProcess A reference to the process.
		 */
		public function Thread(m:at.lueftenegger.stackmachine.processes.Process){
			super(m);
			_memLocal = new Array();			
			
			// stack operators
			registerFunction( OpCodes.PUSH, push );
			registerFunction( OpCodes.POP, pop );
			
			// memory management
			registerFunction( OpCodes.STS, sts );
			registerFunction( OpCodes.LDS, lds );
			registerFunction( OpCodes.STSG, stsg );
			registerFunction( OpCodes.LDSG, ldsg );
			
			// numeric operators
			registerFunction( OpCodes.ADD, add );
			registerFunction( OpCodes.SUB, sub );
			registerFunction( OpCodes.MUL, mul );
			registerFunction( OpCodes.DIV, div );
			registerFunction( OpCodes.INC, inc );
			registerFunction( OpCodes.DEC, dec );
			registerFunction( OpCodes.MOD, mod );
			
			// boolean operators
			registerFunction( OpCodes.AND, and );
			registerFunction( OpCodes.OR, or );
			registerFunction( OpCodes.NOT, not );
			registerFunction( OpCodes.BAND, band );
			registerFunction( OpCodes.BOR, bor );
			registerFunction( OpCodes.BXOR, bxor );
			registerFunction( OpCodes.BNOT, bnot );
			
			// binary operators
			registerFunction( OpCodes.ROL, rol );
			registerFunction( OpCodes.ROR0, ror0 );
			registerFunction( OpCodes.ROR1, ror1 );
			
			// comparative operators
			registerFunction( OpCodes.EQ, eq );
			registerFunction( OpCodes.SEQ, seq );
			registerFunction( OpCodes.UQ, uq );
			registerFunction( OpCodes.SUQ, suq );
			registerFunction( OpCodes.LES, les );
			registerFunction( OpCodes.MOR, mor );
			registerFunction( OpCodes.LEQ, leq );
			registerFunction( OpCodes.MOQ, moq );
			
			// math function
			registerFunction( OpCodes.ABS, abs );
			registerFunction( OpCodes.ACOS, acos );
			registerFunction( OpCodes.ASIN, asin );
			registerFunction( OpCodes.ATAN, atan );
			registerFunction( OpCodes.ATAN2, atan2 );
			registerFunction( OpCodes.CEIL, ceil );
			registerFunction( OpCodes.COS, cos );
			registerFunction( OpCodes.EXP, exp );
			registerFunction( OpCodes.FLOOR, floor );
			registerFunction( OpCodes.LOG, log );
			registerFunction( OpCodes.MAX, max );
			registerFunction( OpCodes.MIN, min );
			registerFunction( OpCodes.POW, pow );
			registerFunction( OpCodes.RANDOM, random );
			registerFunction( OpCodes.ROUND, round );
			registerFunction( OpCodes.SIN, sin );
			registerFunction( OpCodes.SQRT, sqrt );
			registerFunction( OpCodes.TAN, tan );
			
			// math const
			registerFunction( OpCodes.E, E );
			registerFunction( OpCodes.LN10, LN10 );
			registerFunction( OpCodes.LN2, LN2 );
			registerFunction( OpCodes.LOG10E, LOG10E );
			registerFunction( OpCodes.LOG2E, LOG2E );
			registerFunction( OpCodes.PI, PI );
			registerFunction( OpCodes.SQRT1_2, SQRT1_2 );
			registerFunction( OpCodes.SQRT2, SQRT2 );
			
			// misc functions
			registerFunction( OpCodes.TRACE, debugtrace );
			registerFunction( OpCodes.NON, non );
			
			// multithreading functions
			registerFunction( OpCodes.FORK, fork );
			registerFunction( OpCodes.THREADLOCK, threadlock );
			registerFunction( OpCodes.THREADUNLOCK, threadunlock );
			registerFunction( OpCodes.IPT, ipt );
			
			// program flow
			registerFunction( OpCodes.JMP, jmp );
			registerFunction( OpCodes.GTO, gto );
			
			// timestamp
			registerFunction( OpCodes.TIME, time );
		}
		
		/**
		 * Clones this thread. .next and .prev are set correctly automatically.
		 * 
		 * @return Returns a clone of this thread.
		 */
		public override function clone():at.lueftenegger.stackmachine.threads.Thread{
			var tmp:at.lueftenegger.swfscript.Thread = new at.lueftenegger.swfscript.Thread( refProc );
			tmp.next = next;
			tmp.prev = this;
			if( next != null)
				next.prev = tmp;
			next = tmp;
			var i:uint = 0;
			//TODO: probably faster with slice
//			for( i = 0; i++ < _functions.length;)
//				tmp._functions[i] =  _functions[i] ;
			
			//TODO: probably faster with slice
			for( i = 0; i++ < _code.length;)
				tmp._code[i] = this._code[i];

			
			//TODO: probably faster with slice
			for( i = 0; i++ < _stack.length;)
				tmp._stack[i] = this._stack[i];
								
			tmp._CP = _CP;
			tmp._stackTop = _stackTop;
			tmp.locked = locked;
			tmp._isParent = false;
			_isParent = true;
			
			//TODO: probably faster with slice
			for( i = 0; i++ < _memLocal.length;)
				tmp._memLocal[i] =  _memLocal[i];

			return tmp;
		}				

		/**
		 * This function is responsible for program execution.
		 * This implementation differs according to functions with parameters
		 * and functions without parameters. In fact there is just one function
		 * with parameter - push. Push takes the object to be pushed on stack.
		 */
		public override function main():void{
			
			var cmd:int;
			var e:int;

			do {
				// The opFunction returns the movement of the code pointer.
				// push returns 2, because it's a function with parameter.
				// latente functions like sleep returns 0 as long as the
				// thread is sleeping.
				// the second parameter is always null, except for push.
				// this style of coding brings 20 ms at the test script
				// with 1000 runs.
				// var e is necessary because some opFunctions are manipulating
				// the code pointer directly.
				e = _functions[ _code[ _CP ] ]( this , _code[ _CP + 1 ]);
				_CP += e;
				
			// trace(_CP, cmd);
			// if thread is locked continue executing code
			// quite if codepointer is at the end of the code,
			// even if locked
			}while (locked && _CP  < _code.length);
			
			if( _CP >= _code.length){
				refProc.kill(id);
				return;
			}

		}

		//TODO:This is not a opFunction. There is no mnemonic peek.
		public static function peek( thread:ThreadProgramable ):Object{
			return thread._stack[thread._stack.length-1];
		}
		
//{ opFunctions
		
		public static function push( thread:ThreadProgramable, value:Object ):int{
			thread._stack.push( value );
			return 2;
		}

		public static function pop( thread:ThreadProgramable, e:* = null ):int {
			// This function removes the top element from stack.
			// don't use this function to get the top element
			// it ever returns true.
			thread._stack.pop();
			return 1;
		}
		
		// memory managment
		public static function sts( thread:ThreadProgramable, e:* = null ):int{
			// addresses starting with "_" are write protected
			var addr:String = thread._stack.pop();
			if ( addr.substr(1,1 ) == "_" )
				return 1;
			at.lueftenegger.swfscript.Thread(thread)._memLocal[ addr ] = peek(thread);
			return 1;
		}
		public static function lds( thread:ThreadProgramable, e:* = null ):int{
			// addresses starting with "_" are write protected
			var addr:* = thread._stack.pop();
			thread._stack.push( at.lueftenegger.swfscript.Thread(thread)._memLocal[ addr ] );
			return 1;
		}
		public static function stsg( thread:ThreadProgramable, e:* = null ):int{
			// addresses starting with "_" are write protected
			var addr:* = thread._stack.pop();
			if ( addr.substr(1,1 ) == "_" )
				return 1;
			trace("stsg needs implementation in threadASM.as");
//			refProc.sts(addr, _stack[ _stack.length - 1 ] );
			return 1;
		}
		public static function ldsg( thread:ThreadProgramable, e:* = null ):int{
			// addresses starting with "_" are write protected
//			_stack.push( refProc.lds( _stack.pop() ) );
			trace("ldsg needs implementation in threadASM.as");
			return 1;
		}
		
		// numeric operators
		private static function add( thread:ThreadProgramable, e:* = null ):int{
			var p1:* = thread._stack.pop();
			var p2:* = thread._stack.pop();
			thread._stack.push(p2+p1);
			return 1;
		}
		private static function sub( thread:ThreadProgramable, e:* = null ):int{
			var p1:Number = thread._stack.pop();
			var p2:Number = thread._stack.pop();
			thread._stack.push(p2-p1);
			return 1;		
		}
		private static function mul( thread:ThreadProgramable, e:* = null ):int{
			// multiplication is Associative => performance
			var p1:Number = thread._stack.pop();
			var p2:Number = thread._stack.pop();
			thread._stack.push(p2*p1);
			return 1;
		}
		private static function div( thread:ThreadProgramable, e:* = null ):int{
			var p1:Number = thread._stack.pop();
			var p2:Number = thread._stack.pop();
			thread._stack.push(p2/p1);
			return 1;
		}	
		private static function inc( thread:ThreadProgramable, e:* = null ):int{
			thread._stack[ thread._stack.length - 1 ]++;
			return 1;
		}
		private static function dec( thread:ThreadProgramable, e:* = null ):int{
			thread._stack[ thread._stack.length - 1 ]--;
			return 1;
		}
		private static function mod( thread:ThreadProgramable, e:* = null ):int{
			var p1:Number = thread._stack.pop();
			var p2:Number = thread._stack.pop();
			thread._stack.push(p2%p1);
			return 1;
		}	
		
		// boolean operators
		private static function and( thread:ThreadProgramable, e:* = null ):int{
			var p1:Boolean = thread._stack.pop();
			var p2:Boolean = thread._stack.pop();
			thread._stack.push(p2&&p1);
			return 1;
		}
		private static function or( thread:ThreadProgramable, e:* = null ):int{
			var p1:Boolean = thread._stack.pop();
			var p2:Boolean = thread._stack.pop();
			thread._stack.push(p2||p1);
			return 1;
		}
		private static function not( thread:ThreadProgramable, e:* = null ):int{
			//TODO: Needs to be tested.
			thread._stack.push( !thread._stack.pop() );
			return 1;
		}
		private static function band( thread:ThreadProgramable, e:* = null ):int {
			var p1:* = thread._stack.pop();
			var p2:* = thread._stack.pop();
			thread._stack.push(p1&p2);
			return 1;
		}
		private static function bor( thread:ThreadProgramable, e:* = null ):int {
			var p1:* = thread._stack.pop();
			var p2:* = thread._stack.pop();
			thread._stack.push(p1|p2);
			return 1;
		}
		private static function bxor( thread:ThreadProgramable, e:* = null ):int {
			var p1:* = thread._stack.pop();
			var p2:* = thread._stack.pop();
			thread._stack.push(p1^p2);
			return 1;
		}
		private static function bnot( thread:ThreadProgramable, e:* = null ):int {
			var p1:* = thread._stack.pop();
			thread._stack.push(~p1);
			return 1;
		}
		
		// binary operators
		private static function rol( thread:ThreadProgramable, e:* = null ):int{
			var p1:* = thread._stack.pop();
			var p2:* = thread._stack.pop();
			thread._stack.push(p2<<p1);
			return 1;
		}
		private static function ror0( thread:ThreadProgramable, e:* = null ):int{
			var p1:* = thread._stack.pop();
			var p2:* = thread._stack.pop();
			thread._stack.push(p2>>p1);
			return 1;
		}
		private static function ror1( thread:ThreadProgramable, e:* = null ):int{
			var p1:* = thread._stack.pop();
			var p2:* = thread._stack.pop();
			thread._stack.push(p2>>>p1);
			return 1;
		}
		
		// comparative operators
		private static function eq( thread:ThreadProgramable, e:* = null ):int {
			var p1:* = thread._stack.pop();
			var p2:* = thread._stack.pop();
			thread._stack.push(p1==p2);
			return 1;
		}
		private static function seq( thread:ThreadProgramable, e:* = null ):int {
			var p1:* = thread._stack.pop();
			var p2:* = thread._stack.pop();
			thread._stack.push(p1===p2);
			return 1;
		}
		private static function uq( thread:ThreadProgramable, e:* = null ):int {
			var p1:* = thread._stack.pop();
			var p2:* = thread._stack.pop();
			thread._stack.push(p1!=p2);
			return 1;
		}
		private static function suq( thread:ThreadProgramable, e:* = null ):int {
			var p1:* = thread._stack.pop();
			var p2:* = thread._stack.pop();
			thread._stack.push(p1!==p2);
			return 1;
		}
		private static function les( thread:ThreadProgramable, e:* = null ):int{
			var p1:* = thread._stack.pop();
			var p2:* = thread._stack.pop();
			thread._stack.push(p2<p1);
			return 1;
		}
		private static function mor( thread:ThreadProgramable, e:* = null ):int{
			var p1:* = thread._stack.pop();
			var p2:* = thread._stack.pop();
			thread._stack.push(p2>p1);
			return 1;
		}
		private static function leq( thread:ThreadProgramable, e:* = null ):int{
			var p1:* = thread._stack.pop();
			var p2:* = thread._stack.pop();
			thread._stack.push(p2<=p1);
			return 1;
		}
		private static function moq( thread:ThreadProgramable, e:* = null ):int{
			var p1:* = thread._stack.pop();
			var p2:* = thread._stack.pop();
			thread._stack.push(p2>=p1);
			return 1;
		}
		
		// math function
		private static function abs( thread:ThreadProgramable, e:* = null ):int {
			var p1:* = thread._stack.pop();
			thread._stack.push( Math.abs( p1 ) );
			return 1;
		}
		private static function acos( thread:ThreadProgramable, e:* = null ):int {
			var p1:* = thread._stack.pop();
			thread._stack.push( Math.acos( p1 ) );
			return 1;
		}
		private static function asin( thread:ThreadProgramable, e:* = null ):int {
			var p1:* = thread._stack.pop();
			thread._stack.push( Math.asin( p1 ) );
			return 1;
		}
		private static function atan( thread:ThreadProgramable, e:* = null ):int {
			var p1:* = thread._stack.pop();
			thread._stack.push( Math.atan( p1 ) );
			return 1;
		}
		private static function atan2( thread:ThreadProgramable, e:* = null ):int {
			var p1:* = thread._stack.pop();
			var p2:* = thread._stack.pop();
			thread._stack.push( Math.atan2(p2,p1) );
			return 1;
		}
		private static function ceil( thread:ThreadProgramable, e:* = null ):int {
			var p1:* = thread._stack.pop();
			thread._stack.push( Math.ceil( p1 ) );
			return 1;
		}
		private static function cos( thread:ThreadProgramable, e:* = null ):int {
			var p1:* = thread._stack.pop();
			thread._stack.push( Math.cos( p1 ) );
			return 1;
		}
		private static function exp( thread:ThreadProgramable, e:* = null ):int {
			var p1:* = thread._stack.pop();
			thread._stack.push( Math.exp( p1 ) );
			return 1;
		}
		private static function floor( thread:ThreadProgramable, e:* = null ):int {
			var p1:* = thread._stack.pop();
			thread._stack.push( Math.floor( p1 ) );
			return 1;
		}
		private static function log( thread:ThreadProgramable, e:* = null ):int {
			var p1:* = thread._stack.pop();
			thread._stack.push( Math.log( p1 ) );
			return 1;
		}
		private static function max( thread:ThreadProgramable, e:* = null ):int {
			var p1:* = thread._stack.pop();
			var p2:* = thread._stack.pop();
			thread._stack.push( Math.max(p2,p1) );
			return 1;
		}
		private static function min( thread:ThreadProgramable, e:* = null ):int {
			var p1:* = thread._stack.pop();
			var p2:* = thread._stack.pop();
			thread._stack.push( Math.min(p2,p1) );
			return 1;
		}
		private static function pow( thread:ThreadProgramable, e:* = null ):int {
			var p1:* = thread._stack.pop();
			var p2:* = thread._stack.pop();
			thread._stack.push( Math.pow(p2,p1) );
			return 1;
		}
		private static function random( thread:ThreadProgramable, e:* = null ):int {
			thread._stack.push(  Math.random() );
			return 1;
		}
		private static function round( thread:ThreadProgramable, e:* = null ):int {
			var p1:* = thread._stack.pop();
			thread._stack.push( Math.round( p1 ) );
			return 1;
		}
		private static function sin( thread:ThreadProgramable, e:* = null ):int {
			var p1:* = thread._stack.pop();
			thread._stack.push( Math.sin( p1 ) );
			return 1;
		}
		private static function sqrt( thread:ThreadProgramable, e:* = null ):int {
			var p1:* = thread._stack.pop();
			thread._stack.push( Math.sqrt( p1 ) );
			return 1;
		}
		private static function tan( thread:ThreadProgramable, e:* = null ):int {
			var p1:* = thread._stack.pop();
			thread._stack.push( Math.tan( p1 ) );
			return 1;
		}
		
		// math const
		private static function E( thread:ThreadProgramable, e:* = null ):int {
			thread._stack.push( Math.E );
			return 1;
		}
		private static function LN10( thread:ThreadProgramable, e:* = null ):int {
			thread._stack.push( Math.LN10 );
			return 1;
		}
		private static function LN2( thread:ThreadProgramable, e:* = null ):int {
			thread._stack.push( Math.LN2 );
			return 1;
		}
		private static function LOG10E( thread:ThreadProgramable, e:* = null ):int {
			thread._stack.push( Math.LOG10E );
			return 1;
		}
		private static function LOG2E( thread:ThreadProgramable, e:* = null ):int {
			thread._stack.push( Math.LOG2E );
			return 1;
		}
		private static function PI( thread:ThreadProgramable, e:* = null ):int {
			thread._stack.push( Math.PI );
			return 1;
		}
		private static function SQRT1_2( thread:ThreadProgramable, e:* = null ):int {
			thread._stack.push( Math.SQRT1_2 );
			return 1;
		}
		private static function SQRT2( thread:ThreadProgramable, e:* = null ):int {
			thread._stack.push( Math.SQRT2 );
			return 1;
		}
		
		/*private  static function sleep(thread:ThreadProgramable, e:* = null):int{
			
			if( stack._sleeperEnd == 0){
				var p1:Object = pop();
				stack._sleeperEnd = getTimer() + p1;
			}
	
			if( stack._sleeperEnd <= getTimer() ){
				stack._sleeperEnd = 0;
				return 1;
			}
			
			return 0;
			
		}
		*/

		// diverse functions
		private static function non( thread:ThreadProgramable, e:* = null ):int{
			return 1;
		}
		private static function debugtrace( thread:ThreadProgramable, e:* = null ):int{
			trace( "trace : " + peek(thread) );
			return 1;
		}
		
		// multithreading functions
		private static function fork( thread:ThreadProgramable, e:* = null ):int{
			var tmp:at.lueftenegger.swfscript.Thread = at.lueftenegger.swfscript.Thread( thread.clone() );
			thread._isParent = true;
			thread._stack.push( 1 );
			
			tmp._CP++;
			tmp._stack.push( 0 );
			return 1;
		}
		private static function threadlock( thread:ThreadProgramable, e:* = null ):int {
			var tmp:at.lueftenegger.swfscript.Thread = at.lueftenegger.swfscript.Thread( thread );
			tmp.locked = true;
			return 1;
		}
		private static function threadunlock( thread:ThreadProgramable, e:* = null ):int {
			var tmp:at.lueftenegger.swfscript.Thread = at.lueftenegger.swfscript.Thread( thread );
			tmp.locked = false;
			return 1;
		}
		private static function ipt( thread:ThreadProgramable, e:* = null ):int{
			thread._stack.push( thread._isParent );
			return 1;
		}
		
		// program flow
		private static function jmp( thread:ThreadProgramable, e:* = null ):int{
			var p1:* = thread._stack.pop();
			var p2:* = thread._stack.pop();
			if( p1 != 0)
				thread._CP = p2;
			return 1;
		}
		private static function gto( thread:ThreadProgramable, e:* = null ):int{
			thread._CP = thread._stack.pop();
			return 1;
		}	
		
		private static function time( thread:ThreadProgramable, e:* = null ):int {
			var date:Date = new Date();
			thread._stack.push( date.time );
			return 1;
		}
//}
	
	}
}
