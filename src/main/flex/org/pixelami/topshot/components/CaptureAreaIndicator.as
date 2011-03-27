package org.pixelami.topshot.components
{
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.core.UIComponent;
	
	import org.pixelami.icons.CloseButtonGraphic;
	import org.pixelami.icons.DownArrowGraphic;
	
	import spark.components.Button;
	
	[Event(name="close",type="flash.events.Event")]
	[Event(name="download",type="flash.events.Event")]
	public class CaptureAreaIndicator extends UIComponent
	{
		protected var closeButton:IconGraphic;
		protected var downloadButton:IconGraphic;
		
		private var _capturePoint:Point;
		private var _captureWidth:Number = 0;
		private var _captureHeight:Number = 0;
		
		private var buttonsShowing:Boolean;
		
		private var background:UIComponent;
		
		
		
		public function get capturePoint():Point
		{
			return _capturePoint;
		}

		public function set capturePoint(value:Point):void
		{
			if(_capturePoint != value)
			{
				_capturePoint = value;
				invalidateDisplayList();
			}
		}

		
		public function get captureWidth():Number
		{
			return _captureWidth;
		}

		public function set captureWidth(value:Number):void
		{
			if(_captureWidth != value)
			{
				_captureWidth = value;
				invalidateDisplayList();
			}
		}

		public function get captureHeight():Number
		{
			return _captureHeight;
		}

		public function set captureHeight(value:Number):void
		{
			if(_captureHeight != value)
			{
				_captureHeight = value;
				invalidateDisplayList();
			}
		}

		
		public function CaptureAreaIndicator()
		{
			super();
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			background = new UIComponent();
			addChild(background);
			
			var buttonSize:uint = 16;
			
			closeButton = new IconGraphic()
			closeButton.setStyle('iconClass',CloseButtonGraphic);
			setButtonButtonTraits(closeButton);
			closeButton.width = buttonSize;
			closeButton.height = buttonSize;
			
			downloadButton = new IconGraphic();
			downloadButton.setStyle('iconClass',DownArrowGraphic);
			setButtonButtonTraits(downloadButton);
			downloadButton.width = buttonSize;
			downloadButton.height = buttonSize;
			
			
			
			closeButton.visible = false;
			downloadButton.visible = false;
			
			addChild(closeButton);
			addChild(downloadButton);
		}
		
		protected function setButtonButtonTraits(component:UIComponent):void
		{
			component.buttonMode = true;
			component.useHandCursor = true;
			component.mouseChildren = false;
			
		}
		
		public function showButtons():void
		{
			
			closeButton.visible = true;
			downloadButton.visible = true;
			initListeners();
			buttonsShowing = true;
			invalidateDisplayList();
		}
		
		public function initListeners():void
		{
			closeButton.addEventListener(MouseEvent.CLICK,closeButton_clickHandler);
			downloadButton.addEventListener(MouseEvent.CLICK,downloadButton_clickHandler);
		}

		private function downloadButton_clickHandler(event:MouseEvent):void
		{
			dispatchEvent(new Event('download'));
		}
		
		protected function closeButton_clickHandler(event:MouseEvent):void
		{
			dispatchEvent(new Event('close'));
		}
		
		override protected function updateDisplayList(w:Number, h:Number):void
		{
			super.updateDisplayList(w,h);
			
			
			if(captureWidth == 0 && captureHeight == 0) return;
			
			background.setActualSize(unscaledWidth,unscaledHeight);
			
			var lineThickness:Number = 2;
			var color:uint = buttonsShowing ? 0x00CC66 : 0x991010;
			var gap:Number = 3;
			var padding:Number = 3;
			
			var g:Graphics = background.graphics;
			g.clear();
			g.lineStyle(lineThickness,color,alpha);
			g.drawRect(
				capturePoint.x,
				capturePoint.y,
				captureWidth,
				captureHeight
			);
			
			
			
			if(buttonsShowing)
			{
				// faint outline on the selected area
				g.lineStyle(.25,0x006633);
				g.drawRect(
					capturePoint.x - (lineThickness),
					capturePoint.y - (lineThickness),
					captureWidth  + lineThickness + (lineThickness * .5),
					captureHeight + lineThickness + (lineThickness * .5)
				);
				
				var buttonAreaWidth:Number = closeButton.width + downloadButton.width + gap + (padding * 2);
				var buttonAreaHeight:Number = closeButton.height + (padding * 2);
				var borderLeft:Number = capturePoint.x + captureWidth - buttonAreaWidth;
				
				// draw button background
				g.lineStyle(0,0,0);
				g.beginFill(color,1);
				g.drawRect(borderLeft, capturePoint.y, buttonAreaWidth - lineThickness * .5, buttonAreaHeight);
				g.endFill();
				
				// layout buttons
				closeButton.move(capturePoint.x + captureWidth - closeButton.width - padding , capturePoint.y + padding);
				downloadButton.move(borderLeft + padding, capturePoint.y + padding);
			}
			
			
		}
		
	}
}