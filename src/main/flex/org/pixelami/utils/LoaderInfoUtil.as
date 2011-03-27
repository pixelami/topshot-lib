package org.pixelami.utils
{
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.utils.getDefinitionByName;

	public class LoaderInfoUtil
	{
		
		private static var _rootLoaderInfo:LoaderInfo;
		public static function get rootLoaderInfo():LoaderInfo
		{
			if(!_rootLoaderInfo) 
			{
				try
				{
					// since sprite is always defined in the top level loaderInfo we
					// can get the top level loaderInfo by calling LoaderInfo.getLoaderInfoByDefinition
					_rootLoaderInfo = LoaderInfo.getLoaderInfoByDefinition(new Sprite());
				}
				// if we are an AIR app we may get a SecurityError
				// our fallback is to get a reference to FlexGlobals - making sure we 
				// don't actually reference thereby making the compiler include flex dependencies
				// into a pure AS3 lib
				//
				// TODO: What if we are a pure AS3 AIR app with no Flex libs ???
				//
				catch(err:SecurityError)
				{
					trace(err);
					
					var flexGlobalsRef:Class = getDefinitionByName("mx.core.FlexGlobals") as Class;
					
					if(flexGlobalsRef)
					{
						// if we found FlexGlobals then we can use it to get a reference to the topLevelApplication
						// and therefore get at the loaderInfo
						_rootLoaderInfo = flexGlobalsRef.topLevelApplication.loaderInfo;
					}
					else
					{
						
						
						// TODO work out an alternate solution for if we get here 
						// i.e. possibly a pure AS3 AIR app.
						throw new Error("Unable to determine a top level LoaderInfo object in this context");
					}
					
				}
			}
			return _rootLoaderInfo;
		}
		
		public static function get stage():Stage
		{
			// loaderInfo content's parent is Stage 
			return rootLoaderInfo.content.parent as Stage;
		}
		
		public static function get parameters():Object
		{
			return rootLoaderInfo.parameters;
		}
	}
}