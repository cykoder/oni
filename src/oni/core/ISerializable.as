package oni.core 
{
	
	/**
	 * A class that can be serialized to an object
	 * @author Sam Hellawell
	 */
	public interface ISerializable 
	{
		/**
		 * Serializes data to an object
		 * @return
		 */
		function serialize():Object;
	}
	
}