package oni.assets 
{
	/**
	 * A global asset store
	 * @author Sam Hellawell
	 */
	public class AssetStore
	{
		/*
		 * Data files
		 */
        [Embed(source="../../../lib/data/physics.json", mimeType="application/octet-stream")]
        public static const physics_data:Class;
		
	}

}