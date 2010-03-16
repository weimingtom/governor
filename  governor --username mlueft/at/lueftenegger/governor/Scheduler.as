package at.lueftenegger.governor{
	
	import at.lueftenegger.stackmachine.processes.*;
	import at.lueftenegger.stackmachine.scheduler.Scheduler;
	
	public class Scheduler extends at.lueftenegger.stackmachine.scheduler.Scheduler{

		/**
		 * Factory methode to get a new process.
		 * 
		 * @return Returns a new process.
		 */		
		override protected function getNewProcess():at.lueftenegger.stackmachine.processes.Process{
			return new at.lueftenegger.governor.Process(this);
		}
		
	}
	
}
