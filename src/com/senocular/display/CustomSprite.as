package com.senocular.display
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	
	import org.flexlite.domUI.components.Button;

	public class CustomSprite extends Sprite
	{
		/**注册点*/
		public var isShowRegister:Boolean=true;
		/**旋转*/
		public var isShowRotate:Boolean=true;
		/**缩放*/
		public var isShowScale:Boolean=true;
		
		public var type:String="";
		
		private var _leftBtn:Button;
		private var _rightBtn:Button;
		private var _curPage:int=1;
		private var _totalPage:int=1;//当前mc总帧数
		private var _mc:MovieClip;
		
		/**是否显示两个跳转按钮,ppt才有*/
		public var isShowTurnBox:Boolean;
		public var isMc:Boolean;//里面存放的是movieclip
		public var mc:MovieClip;
		public function CustomSprite()
		{
			super();
		}
	}
}