package com.senocular.display
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import org.flexlite.domUI.layouts.HorizontalLayout;
	
	/**存放两个跳转按钮容器*/
	public class TurnBox extends Sprite
	{
		private var _leftBtn:LeftBtn;
		private var _rightBtn:RightBtn;
		private var _curPage:int=1;
		private var _totalPage:int=1;//当前mc总帧数
		private var _mc:MovieClip;
		private var _layout:HorizontalLayout;
		public function TurnBox()
		{
			super();
		}
		
		public function initView(mc:MovieClip):void
		{
			_mc=mc;
			_totalPage=_mc.totalFrames;
			
			_leftBtn=new LeftBtn;
			_rightBtn=new RightBtn;
			
			this.addChild(_leftBtn);
			this.addChild(_rightBtn);
			_rightBtn.x=_mc.width-_rightBtn.width;
			trace("_rightBtn:",_mc.width,_rightBtn.width,_rightBtn.x);
			
			_leftBtn.gotoAndStop(0);
			_rightBtn.gotoAndStop(0);
			_leftBtn.width=32;
			_leftBtn.height=34;
			_rightBtn.width=32;
			_rightBtn.height=34;
			
			_leftBtn.addEventListener(MouseEvent.MOUSE_DOWN,turnLeftHandler);
			_rightBtn.addEventListener(MouseEvent.MOUSE_DOWN,turnRightHandler);
		}
		
		private function turnLeftHandler(event:MouseEvent):void
		{
			if(event)
			{
				event.stopImmediatePropagation();
			}
			if(_curPage-1>=1)
			{
				_curPage--;
				_mc.gotoAndStop(_curPage);
			}
		}
		
		private function turnRightHandler(event:MouseEvent):void
		{
			if(event)
			{
				event.stopImmediatePropagation();
			}
			if(_curPage+1<=_totalPage)
			{
				_curPage++;
				_mc.gotoAndStop(_curPage);
			}
		}
		
		public function dispose():void
		{
			_leftBtn.removeEventListener(MouseEvent.MOUSE_DOWN,turnLeftHandler);
			_rightBtn.removeEventListener(MouseEvent.MOUSE_DOWN,turnRightHandler);
			
			this.removeChild(_leftBtn);
			this.removeChild(_rightBtn);
			
			_leftBtn=null;
			_rightBtn=null;
		}
	}
}