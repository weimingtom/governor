
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
			
			// registerA
			registerFunction( OpCodes.STA, stA );
			registerFunction( OpCodes.LDA, ldA );
			registerFunction( OpCodes.INCA, incA );
			registerFunction( OpCodes.DECA, decA );
			registerFunction( OpCodes.ADDA, addA );
			registerFunction( OpCodes.ADDA, subA );
		}
		
		/**
		 * Clones this thread. .next and .prev are set correctly automatically.
		 * 
		 * @return Returns a clone of this thread.
		 */
		public override function clone():at.lueftenegger.stackmachine.threads.Thread{
			var tmp:Thread = new Thread( refProc );
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
			for( i = 0; i < _code.length;i++)
				tmp._code[i] = this._code[i];

			
			//TODO: probably faster with slice
			for( i = 0; i < _stack.length;i++)
				tmp._stack[i] = this._stack[i];
								
			tmp._CP = _CP;
			tmp._stackTop = _stackTop;
			tmp.regA = regA;
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
				// push returns 2, because it's a function with one parameter.
				// Latent functions like sleep returns 0 as long as the
				// thread is sleeping.
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
		// actually i think this function is unused and obsolet.
		public static function peek( thread:Thread ):Object{
			return thread._stack[thread._stack.length-1];
		}
		
//{ opFunctions

//{ register A functions
		public var regA:*;
		private static function stA( thread:Thread, e:* ):int{
			thread.regA = e;
			return 2;
		}
		private static function ldA( thread:Thread, e:* ):int{
			thread._stack.push( thread.regA );
			return 1;
		}
		private static function incA( thread:Thread, e:* ):int{
			thread.regA++;
			return 1;
		}
		private static function decA( thread:Thread, e:* ):int{
			thread.regA--;
			return 1;
		}
		private static function addA( thread:Thread, e:* ):int{
			thread.regA += e;
			return 2;
		}
		private static function subA( thread:Thread, e:* ):int{
			thread.regA += e;
			return 2;
		}
//}
		public static function push( thread:Thread, value:Object ):int{
			thread._stack.push( value );
			return 2;
		}

		public static function pop( thread:Thread, e:* ):int {
			// This function removes the top element from stack.
			// don't use this function to get the top element
			// it ever returns true.
			thread._stack.pop();
			return 1;
		}
		
		// memory managment
		public static function sts( thread:Thread, e:* ):int{
			// addresses starting with "_" are write protected
			var addr:String = thread._stack.pop();
			if ( addr.substr(1,1 ) == "_" )
				return 1;
			at.lueftenegger.governor.Thread(thread)._memLocal[ addr ] = peek(thread);
			return 1;
		}
		public static function lds( thread:Thread, e:* ):int{
			// addresses starting with "_" are write protected
			var addr:* = thread._stack.pop();
			thread._stack.push( at.lueftenegger.governor.Thread(thread)._memLocal[ addr ] );
			return 1;
		}
		public static function stsg( thread:Thread, e:* ):int{
			var addr:* = thread._stack.pop();
			at.lueftenegger.governor.Process(thread.refProc).sts(addr, thread._stack[ thread._stack.length - 1 ] );
			return 1;
		}
		public static function ldsg( thread:Thread, e:* ):int{
			thread._stack.push( at.lueftenegger.governor.Process(thread.refProc).lds( thread._stack.pop() ) );
			return 1;
		}
		
		// numeric operators
		private static function add( thread:Thread, e:* ):int{
			var p1:* = thread._stack.pop();
			var p2:* = thread._stack.pop();
			thread._stack.push(p2+p1);
			return 1;
		}
		private static function sub( thread:Thread, e:* ):int{
			var p1:Number = thread._stack.pop();
			var p2:Number = thread._stack.pop();
			thread._stack.push(p2-p1);
			return 1;		
		}
		private static function mul( thread:Thread, e:* ):int{
			// multiplication is Associative => performance
			var p1:Number = thread._stack.pop();
			var p2:Number = thread._stack.pop();
			thread._stack.push(p2*p1);
			return 1;
		}
		private static function div( thread:Thread, e:* ):int{
			var p1:Number = thread._stack.pop();
			var p2:Number = thread._stack.pop();
			thread._stack.push(p2/p1);
			return 1;
		}	
		private static function inc( thread:Thread, e:* ):int{
			thread._stack[ thread._stack.length - 1 ]++;
			return 1;
		}
		private static function dec( thread:Thread, e:* ):int{
			thread._stack[ thread._stack.length - 1 ]--;
			return 1;
		}
		private static function mod( thread:Thread, e:* ):int{
			var p1:Number = thread._stack.pop();
			var p2:Number = thread._stack.pop();
			thread._stack.push(p2%p1);
			return 1;
		}	
		
		// boolean operators
		private static function and( thread:Thread, e:* ):int{
			var p1:Boolean = thread._stack.pop();
			var p2:Boolean = thread._stack.pop();
			thread._stack.push(p2&&p1);
			return 1;
		}
		private static function or( thread:Thread, e:* ):int{
			var p1:Boolean = thread._stack.pop();
			var p2:Boolean = thread._stack.pop();
			thread._stack.push(p2||p1);
			return 1;
		}
		private static function not( thread:Thread, e:* ):int{
			//TODO: Needs to be tested.
			thread._stack.push( !thread._stack.pop() );
			return 1;
		}
		private static function band( thread:Thread, e:* ):int {
			var p1:* = thread._stack.pop();
			var p2:* = thread._stack.pop();
			thread._stack.push(p1&p2);
			return 1;
		}
		private static function bor( thread:Thread, e:* ):int {
			var p1:* = thread._stack.pop();
			var p2:* = thread._stack.pop();
			thread._stack.push(p1|p2);
			return 1;
		}
		private static function bxor( thread:Thread, e:* ):int {
			var p1:* = thread._stack.pop();
			var p2:* = thread._stack.pop();
			thread._stack.push(p1^p2);
			return 1;
		}
		private static function bnot( thread:Thread, e:* ):int {
			var p1:* = thread._stack.pop();
			thread._stack.push(~p1);
			return 1;
		}
		
		// binary operators
		private static function rol( thread:Thread, e:* ):int{
			var p1:* = thread._stack.pop();
			var p2:* = thread._stack.pop();
			thread._stack.push(p2<<p1);
			return 1;
		}
		private static function ror0( thread:Thread, e:* ):int{
			var p1:* = thread._stack.pop();
			var p2:* = thread._stack.pop();
			thread._stack.push(p2>>p1);
			return 1;
		}
		private static function ror1( thread:Thread, e:* ):int{
			var p1:* = thread._stack.pop();
			var p2:* = thread._stack.pop();
			thread._stack.push(p2>>>p1);
			return 1;
		}
		
		// comparative operators
		private static function eq( thread:Thread, e:* ):int {
			var p1:* = thread._stack.pop();
			var p2:* = thread._stack.pop();
			thread._stack.push(p1==p2);
			return 1;
		}
		private static function seq( thread:Thread, e:* ):int {
			var p1:* = thread._stack.pop();
			var p2:* = thread._stack.pop();
			thread._stack.push(p1===p2);
			return 1;
		}
		private static function uq( thread:Thread, e:* ):int {
			var p1:* = thread._stack.pop();
			var p2:* = thread._stack.pop();
			thread._stack.push(p1!=p2);
			return 1;
		}
		private static function suq( thread:Thread, e:* ):int {
			var p1:* = thread._stack.pop();
			var p2:* = thread._stack.pop();
			thread._stack.push(p1!==p2);
			return 1;
		}
		private static function les( thread:Thread, e:* ):int{
			var p1:* = thread._stack.pop();
			var p2:* = thread._stack.pop();
			thread._stack.push(p2<p1);
			return 1;
		}
		private static function mor( thread:Thread, e:* ):int{
			var p1:* = thread._stack.pop();
			var p2:* = thread._stack.pop();
			thread._stack.push(p2>p1);
			return 1;
		}
		private static function leq( thread:Thread, e:* ):int{
			var p1:* = thread._stack.pop();
			var p2:* = thread._stack.pop();
			thread._stack.push(p2<=p1);
			return 1;
		}
		private static function moq( thread:Thread, e:* ):int{
			var p1:* = thread._stack.pop();
			var p2:* = thread._stack.pop();
			thread._stack.push(p2>=p1);
			return 1;
		}
		
		// math function
		private static function abs( thread:Thread, e:* ):int {
			var p1:* = thread._stack.pop();
			thread._stack.push( Math.abs( p1 ) );
			return 1;
		}
		private static function acos( thread:Thread, e:* ):int {
			var p1:* = thread._stack.pop();
			thread._stack.push( Math.acos( p1 ) );
			return 1;
		}
		private static function asin( thread:Thread, e:* ):int {
			var p1:* = thread._stack.pop();
			thread._stack.push( Math.asin( p1 ) );
			return 1;
		}
		private static function atan( thread:Thread, e:* ):int {
			var p1:* = thread._stack.pop();
			thread._stack.push( Math.atan( p1 ) );
			return 1;
		}
		private static function atan2( thread:Thread, e:* ):int {
			var p1:* = thread._stack.pop();
			var p2:* = thread._stack.pop();
			thread._stack.push( Math.atan2(p2,p1) );
			return 1;
		}
		private static function ceil( thread:Thread, e:* ):int {
			var p1:* = thread._stack.pop();
			thread._stack.push( Math.ceil( p1 ) );
			return 1;
		}
		private static function cos( thread:Thread, e:* ):int {
			var p1:* = thread._stack.pop();
			thread._stack.push( Math.cos( p1 ) );
			return 1;
		}
		private static function exp( thread:Thread, e:* ):int {
			var p1:* = thread._stack.pop();
			thread._stack.push( Math.exp( p1 ) );
			return 1;
		}
		private static function floor( thread:Thread, e:* ):int {
			var p1:* = thread._stack.pop();
			thread._stack.push( Math.floor( p1 ) );
			return 1;
		}
		private static function log( thread:Thread, e:* ):int {
			var p1:* = thread._stack.pop();
			thread._stack.push( Math.log( p1 ) );
			return 1;
		}
		private static function max( thread:Thread, e:* ):int {
			var p1:* = thread._stack.pop();
			var p2:* = thread._stack.pop();
			thread._stack.push( Math.max(p2,p1) );
			return 1;
		}
		private static function min( thread:Thread, e:* ):int {
			var p1:* = thread._stack.pop();
			var p2:* = thread._stack.pop();
			thread._stack.push( Math.min(p2,p1) );
			return 1;
		}
		private static function pow( thread:Thread, e:* ):int {
			var p1:* = thread._stack.pop();
			var p2:* = thread._stack.pop();
			thread._stack.push( Math.pow(p2,p1) );
			return 1;
		}
		private static function random( thread:Thread, e:* ):int {
			thread._stack.push(  Math.random() );
			return 1;
		}
		private static function round( thread:Thread, e:* ):int {
			var p1:* = thread._stack.pop();
			thread._stack.push( Math.round( p1 ) );
			return 1;
		}
		private static function sin( thread:Thread, e:* ):int {
			var p1:* = thread._stack.pop();
			thread._stack.push( Math.sin( p1 ) );
			return 1;
		}
		private static function sqrt( thread:Thread, e:* ):int {
			var p1:* = thread._stack.pop();
			thread._stack.push( Math.sqrt( p1 ) );
			return 1;
		}
		private static function tan( thread:Thread, e:* ):int {
			var p1:* = thread._stack.pop();
			thread._stack.push( Math.tan( p1 ) );
			return 1;
		}
		
		// math const
		private static function E( thread:Thread, e:* ):int {
			thread._stack.push( Math.E );
			return 1;
		}
		private static function LN10( thread:Thread, e:* ):int {
			thread._stack.push( Math.LN10 );
			return 1;
		}
		private static function LN2( thread:Thread, e:* ):int {
			thread._stack.push( Math.LN2 );
			return 1;
		}
		private static function LOG10E( thread:Thread, e:* ):int {
			thread._stack.push( Math.LOG10E );
			return 1;
		}
		private static function LOG2E( thread:Thread, e:* ):int {
			thread._stack.push( Math.LOG2E );
			return 1;
		}
		private static function PI( thread:Thread, e:* ):int {
			thread._stack.push( Math.PI );
			return 1;
		}
		private static function SQRT1_2( thread:Thread, e:* ):int {
			thread._stack.push( Math.SQRT1_2 );
			return 1;
		}
		private static function SQRT2( thread:Thread, e:* ):int {
			thread._stack.push( Math.SQRT2 );
			return 1;
		}
		
		/*private  static function sleep(thread:Thread, e:*):int{
			
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
		private static function non( thread:Thread, e:* ):int{
			return 1;
		}
		private static function debugtrace( thread:Thread, e:* ):int{
			trace( "trace : " + peek(thread) );
			return 1;
		}
		
		// multithreading functions
		private static function fork( thread:Thread, e:* ):int{
			var tmp:Thread = Thread( thread.clone() );
			thread._isParent = true;
			thread._stack.push( 1 );
			
			tmp._CP++;
			tmp._stack.push( 0 );
			return 1;
		}
		private static function threadlock( thread:Thread, e:* ):int {
			var tmp:Thread = Thread( thread );
			tmp.locked = true;
			return 1;
		}
		private static function threadunlock( thread:Thread, e:* ):int {
			var tmp:Thread = Thread( thread );
			tmp.locked = false;
			return 1;
		}
		private static function ipt( thread:Thread, e:* ):int{
			thread._stack.push( thread._isParent );
			return 1;
		}
		
		// program flow
		private static function jmp( thread:Thread, e:* ):int{
			var p1:* = thread._stack.pop();
			var p2:* = thread._stack.pop();
			if( p1 != 0)
				thread._CP = p2;
			return 1;
		}
		private static function gto( thread:Thread, e:* ):int{
			thread._CP = thread._stack.pop();
			return 1;
		}	
		
		private static function time( thread:Thread, e:* ):int {
			var date:Date = new Date();
			thread._stack.push( date.time );
			return 1;
		}
//}
	
	}
}
