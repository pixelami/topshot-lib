////////////////////////////////////////////////////////////////////////////////
//
//  pixelami.com
//  Copyright 2011 Original Authors
//  All Rights Reserved.
//
//  NOTICE: Pixelami permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package org.pixelami.topshot.tools
{
	import cmodule.aircall.CLibInit;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.InteractiveObject;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	import mx.graphics.codec.JPEGEncoder;
	
	import org.pixelami.topshot.components.CaptureAreaIndicator;
	import org.pixelami.utils.LoaderInfoUtil;
	
	import spark.components.Group;
	
	public class TopShotTool extends EventDispatcher
	{
		public var target:UIComponent;
		private var mouseDownPoint:Point;
		private var captureAreaIndicatorContainer:CaptureAreaIndicator;
		private var isMouseDown:Boolean;
		private var mousePoint:Point
		private var captureArea:Rectangle;
		
		private var rawImageBytes:ByteArray;
		
		[Bindable('encodeComplete')]
		public var encodedImageBytes:ByteArray;
		
		public var jpeglib:Object;
		
		private var minCapWidth:Number = 40;
		private var minCapHeight:Number = 20;
		
		public static function getStage():Stage
		{
			return LoaderInfoUtil.stage;
		}
		
		public function TopShotTool(target:UIComponent=null)
		{
			super();
			this.target = target;
			
			var jpeginit:CLibInit = new CLibInit(); // get library
			jpeglib = jpeginit.init(); // initialize library exported class to an object
		}
		
		private var enabled:Boolean;
		
		public function toggle():void
		{
			enabled = !enabled;
			
			if(enabled)
			{
				enable();
			}
			else
			{
				if(captureAreaIndicatorContainer)
				{
					removeCaptureAreaContainer();
				}
				disable();
			}
		}
		
		
		protected function enable():void
		{
			mousePoint = new Point();
			captureArea = new Rectangle();;
			initListeners();
		}
		
		
		protected function disable():void
		{
			removeListeners();
		}
		
		
		protected function initListeners():void
		{
			target.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
			target.addEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
			target.addEventListener(MouseEvent.MOUSE_UP,onMouseUp);
		}
		
		
		protected function removeListeners():void
		{
			target.removeEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
			target.removeEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
			target.removeEventListener(MouseEvent.MOUSE_UP,onMouseUp);
		}
		

		private function onMouseDown(event:MouseEvent):void
		{
			mouseDownPoint = new Point(event.stageX, event.stageY);
			isMouseDown = true;
			addCaptureAreaContainer();
		}
		
		private function onMouseMove(event:MouseEvent):void
		{
			if(isMouseDown)
			{
				mousePoint.x = event.stageX;
				mousePoint.y = event.stageY;
				updateCaptureAreaIndicator();
			}
		}
		
		
		
		private function onMouseUp(event:MouseEvent):void
		{
			isMouseDown = false;
			
			captureArea = normalizeSelectionRect(captureArea);
			// update the captureAreaIndicatorContainer so that button will be drawn in correct position
			captureAreaIndicatorContainer.capturePoint = new Point(captureArea.x,captureArea.y);
			captureAreaIndicatorContainer.captureWidth = captureArea.width;
			captureAreaIndicatorContainer.captureHeight = captureArea.height;
			
			if(captureArea.width > minCapWidth && captureArea.height > minCapHeight)
			{
				doCapture();
			}
			else
			{
				trace("WARNING: selected area is smaller than minCapWidth of "+minCapWidth+" or minCapHeight of "+minCapHeight);
				removeCaptureAreaContainer();
			}
			
		}
		
		
		
		protected function addCaptureAreaContainer():void
		{
			if(!captureAreaIndicatorContainer) 
			{
				captureAreaIndicatorContainer = new CaptureAreaIndicator();
				if(target.hasOwnProperty("addElement"))
				{
					target["addElement"](captureAreaIndicatorContainer);
				}
				else
				{
					target.addChild(captureAreaIndicatorContainer);
				}
				
				captureAreaIndicatorContainer.width = getStage().stageWidth;
				captureAreaIndicatorContainer.height = getStage().stageHeight;
				captureAreaIndicatorContainer.capturePoint = mouseDownPoint;
			}
		}
		
		protected function removeCaptureAreaContainer():void
		{
			if(captureAreaIndicatorContainer) 
			{
				if(target.hasOwnProperty("addElement"))
				{
					target["removeElement"](captureAreaIndicatorContainer);
				}
				else
				{
					target.removeChild(captureAreaIndicatorContainer);
				}
				captureAreaIndicatorContainer = null;
			}
		}
		
		
		protected function updateCaptureAreaIndicator():void
		{
			captureArea.x = mouseDownPoint.x;
			captureArea.y = mouseDownPoint.y;
			captureArea.width = mousePoint.x - mouseDownPoint.x;
			captureArea.height = mousePoint.y - mouseDownPoint.y;
			
			captureAreaIndicatorContainer.captureWidth = captureArea.width;
			captureAreaIndicatorContainer.captureHeight = captureArea.height;
		}
		
		protected function doCapture():void
		{
			var stageBmd:BitmapData = new BitmapData(getStage().stageWidth,getStage().stageHeight);
			captureAreaIndicatorContainer.visible = false;
			stageBmd.draw(getStage());
			captureAreaIndicatorContainer.visible = true;
			var bmd:BitmapData = new BitmapData(captureArea.width,captureArea.height);
			bmd.copyPixels(stageBmd,captureArea,new Point());
			rawImageBytes = bmd.getPixels(bmd.rect);
			
			startEncode();
		}
		
		protected function startEncode():void
		{
			encodedImageBytes = new ByteArray();
			rawImageBytes.position = 0;
			
			var jpegQuality:Number = 80;
			jpeglib.encodeAsync(encodeComplete, rawImageBytes, encodedImageBytes, captureArea.width, captureArea.height, jpegQuality);
			
			captureAreaIndicatorContainer.addEventListener(Event.ENTER_FRAME,onEnterFrame);
		}
		
		protected function onEnterFrame(event:Event):void
		{
			//trace("Encoding progress: " + Math.round(rawImageBytes.position/rawImageBytes.length*100) + "%");	
		}
		
		protected function encodeComplete(o:Object):void
		{
			//trace("Encoding complete:",o);
			captureAreaIndicatorContainer.removeEventListener(Event.ENTER_FRAME,onEnterFrame);
			captureAreaIndicatorContainer.showButtons();
			captureAreaIndicatorContainer.addEventListener(Event.CLOSE,onCaptureIndicatorCloseClick);
			captureAreaIndicatorContainer.addEventListener("download",onDownloadImageClick);
			
			dispatchEvent(new Event('encodeComplete'));
			// disable until current contents of captureAreaIndicatorContainer are canceled or saved
			disable();
		}

		private function onCaptureIndicatorCloseClick(event:Event):void
		{
			removeCaptureAreaContainer();
			enable();
		}

		private function onDownloadImageClick(event:Event):void
		{
			removeCaptureAreaContainer();
			var fref:FileReference = new FileReference();
			var d:Date = new Date();
			fref.save(encodedImageBytes,"shot-"+d.getTime()+".jpg");
			fref.addEventListener(Event.COMPLETE,onSaveComplete);
			fref.addEventListener(Event.CANCEL,onCaptureIndicatorCloseClick);
			
		}
		private function onSaveComplete(event:Event):void
		{
			enable();
		}
		
		/**
		 * reset top left and top right, make sure widths and heights are positive values.
		 */
		private function normalizeSelectionRect(selectionRect:Rectangle):Rectangle
		{
			//trace("selecttionRect:",selectionRect)
			var r:Rectangle = new Rectangle();
			r.x = Math.min(selectionRect.left,selectionRect.right);
			r.y = Math.min(selectionRect.top,selectionRect.bottom);
			r.width = Math.abs(selectionRect.width);
			r.height = Math.abs(selectionRect.height);
			//trace("normalized",r);
			return r;
			
		}
		
	}
}