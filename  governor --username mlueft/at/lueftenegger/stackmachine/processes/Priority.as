package at.lueftenegger.stackmachine.processes{
	/**
	 * This class provides priority states for processes. It's used as Enum.
	 */
	public final class Priority {
		/**
		 * Every three main() calls of the sheduler a command is executed from this process.
		 */
		public static const LOWER:int		= -3;
		/**
		 * Every two main() calls of the sheduler a command is executed from this process.
		 */
		public static const LOW:int			= -2;
		/**
		 * KILL is a special state. The precess will be terminated and removed by the sheduler in the next main() call.
		 */
		public static const KILL:int		=  0;
		/**
		 * In every main() call of the sheduler a command is executed from this process.
		 */
		public static const NORMAL:int		=  1;
		/**
		 * In every main() call of the sheduler two commands are executed from this process.
		 */
		public static const HIGH:int		=  2;
		/**
		 * In every main() call of the sheduler three commands are executed from this process.
		 */
		public static const HIGHER:int		=  3;
		/**
		 * In every main() call of the sheduler four commands are executed from this process.
		 */
		public static const VERYHIGH:int	=  4;
	}
}