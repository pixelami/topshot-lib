package org.pixelami.topshot.components
{
	import flash.display.DisplayObject;
	
	import mx.core.UIComponent;
	
	[Style(name="iconClass",type="Class")]
	public class IconGraphic extends UIComponent
	{
		private var skinGraphic:DisplayObject;
		
		public function IconGraphic()
		{
			super();
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			createIcon();
		}
		
		protected function createIcon():void
		{
			var skinClass:Class = getStyle('iconClass') as Class;
			//trace('skinClass:',skinClass);
			if(skinClass)
			{
				if(skinGraphic)
				{
					removeChild(skinGraphic);
				}
				skinGraphic = new skinClass();
				addChild(skinGraphic);
				//trace("skin",skinGraphic);
			}
		}
		
		override protected function measure():void
		{
			measuredWidth = 20;
			measuredHeight = 20;
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth,unscaledHeight);
			
			skinGraphic.width = unscaledWidth;
			skinGraphic.height = unscaledHeight;
		}
		
		override public function styleChanged(styleProp:String):void
		{
			super.styleChanged(styleProp);
			//trace("styleProp:"+styleProp);
			if(styleProp == 'iconClass')
			{
				createIcon();
			}
		}
	}
}