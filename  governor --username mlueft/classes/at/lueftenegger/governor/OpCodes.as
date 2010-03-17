package at.lueftenegger.governor {
	
	/**
	 * This class provides the opcodes. It's used as enum.
	 * 
	 * @author Michael Lueftenegger
	 */
	public class OpCodes{
		
		// stack operators
		public static const PUSH:int 			= 0x01;
		public static const POP:int 			= 0x02;
		
		// memory management
		public static const STS:int 			= 0x03;
		public static const LDS:int 			= 0x04;
		public static const STSG:int 			= 0x05;
		public static const LDSG:int 			= 0x06;
		
		// numeric operators
		public static const ADD:int 			= 0x07;
		public static const SUB:int 			= 0x08;
		public static const MUL:int 			= 0x09;
		public static const DIV:int 			= 0x0a;
		public static const INC:int 			= 0x0b;
		public static const DEC:int 			= 0x0c;
		public static const MOD:int 			= 0x0d;
		
		// boolean operators
		public static const AND:int 			= 0x0e;
		public static const OR:int 				= 0x0f;
		public static const NOT:int 			= 0x10;
		public static const BAND:int 			= 0x11;
		public static const BOR:int 			= 0x12;
		public static const BXOR:int 			= 0x13;
		public static const BNOT:int 			= 0x14;
		
		// binary operators
		public static const ROL:int 			= 0x15;
		public static const ROR0:int 			= 0x16;
		public static const ROR1:int 			= 0x17;
		
		// comparative operators
		public static const EQ:int 				= 0x18;
		public static const SEQ:int 			= 0x19;
		public static const UQ:int 				= 0x1a;
		public static const SUQ:int 			= 0x1b;
		public static const LES:int 			= 0x1c;
		public static const MOR:int 			= 0x1d;
		public static const LEQ:int 			= 0x1e;
		public static const MOQ:int 			= 0x1f;
		
		// math function
		public static const ABS:int 			= 0x20;
		public static const ACOS:int 			= 0x21;
		public static const ASIN:int 			= 0x22;
		public static const ATAN:int 			= 0x23;
		public static const ATAN2:int 			= 0x24;
		public static const CEIL:int 			= 0x25;
		public static const COS:int 			= 0x26;
		public static const EXP:int 			= 0x27;
		public static const FLOOR:int 			= 0x28;
		public static const LOG:int 			= 0x29;
		public static const MAX:int 			= 0x2a;
		public static const MIN:int 			= 0x2b;
		public static const POW:int 			= 0x2c;
		public static const RANDOM:int 			= 0x2d;
		public static const ROUND:int 			= 0x2e;
		public static const SIN:int 			= 0x2f;
		public static const SQRT:int 			= 0x30;
		public static const TAN:int 			= 0x31;
		
		// math const
		public static const E:int 				= 0x32;
		public static const LN10:int 			= 0x33;
		public static const LN2:int 			= 0x34;
		public static const LOG10E:int 			= 0x35;
		public static const LOG2E:int 			= 0x36;
		public static const PI:int 				= 0x37;
		public static const SQRT1_2:int			= 0x38;
		public static const SQRT2:int 			= 0x39;
		
		// misc functions
		public static const TRACE:int 			= 0x3a;
		public static const NON:int 			= 0x3b;
		
		// multithreading functions
		public static const FORK:int 			= 0x3c;
		public static const THREADLOCK:int 		= 0x3d;
		public static const THREADUNLOCK:int 	= 0x3e;
		public static const IPT:int 			= 0x3f;
		
		// program flow
		public static const JMP:int 			= 0x40;
		public static const GTO:int 			= 0x41;

		// timestamp
		public static const TIME:int 			= 0x42;
		
		// registerA functions
		public static const STA:int 			= 0x43;
		public static const LDA:int 			= 0x44;
		public static const INCA:int 			= 0x45;
		public static const DECA:int 			= 0x46;
		public static const ADDA:int 			= 0x47;
		public static const SUBA:int 			= 0x48;
	}

}