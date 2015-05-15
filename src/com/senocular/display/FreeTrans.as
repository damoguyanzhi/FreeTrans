package com.senocular.display
{
	import com.MyVideo;
	import com.SoundPlayer;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import langyan.utils.DelayUtil;
	
	import org.flexlite.domUI.components.Button;
	import org.flexlite.domUI.components.CheckBox;
	import org.flexlite.domUI.components.EditableText;
	import org.flexlite.domUI.components.Group;
	import org.flexlite.domUI.components.Label;
	import org.flexlite.domUI.components.TextArea;
	import org.flexlite.domUI.core.UIComponent;
	import org.flexlite.domUI.layouts.VerticalLayout;
	
	public class FreeTrans extends Group
	{
		/**当前child x位置*/
		private var _curChildX:int=0;
		private var _curSprite:CustomSprite;
		/**是否显示菜单*/
		public var isShowMenu:Boolean=true;
		private var _sonBox:Sprite;
		private var defaultTool:TransformTool = new TransformTool();
		public var currTool:TransformTool;
		private var _ui:UIComponent;
		private var _layout:VerticalLayout;
		private var _btnMenu:Group;
		private var _turnBox:Group;
		private var _rotateBtn:Button;
		private var _scaleBtn:Button;
		private var _registerBtn:Button;
		private var _deleteBtn:Button;
		private var _isCreateMenu:Boolean=false;
		private var _isShowRotateBtn:Boolean=false;
		private var __isShowScaleBtn:Boolean=false;
		private var _isShowRegisterBtn:Boolean=false;
		public var customTool:TransformTool = new TransformTool();
		/**控制全屏*/
		private var _controlFull:Function;
		public function FreeTrans(func:Function)
		{
			super();
			_controlFull=func;
			this.doubleClickEnabled=true;
			init();
		}
		
		/**
		 * 添加子项
		 * @param  display     子项
		 * @param  x           坐标x
		 * @param  y           坐标y
		 * @param  fontName    字体(包含文字时才用的上)
		 * @param  type        子容器类型
		 * @param  isMiddle    居中放置
		 * */
		public function addSon(display:DisplayObject=null,x:Number=0,y:Number=0,fontName:String="SimSun",type:String="",isMiddle:Boolean=false):void
		{
			var bmd:BitmapData;
			var bm:Bitmap;
			var customSprite:CustomSprite=new CustomSprite;
			var textField:TextField;
			customSprite.mouseChildren=false;
			if(display is MovieClip)
			{
				customSprite.mc=display as MovieClip;
				customSprite.mc.gotoAndStop(0);
				customSprite.isMc=true;
				customSprite.type="mc";
				customSprite.addChild(display);
				
				_sonBox.addChild(customSprite);
			}
			else if(display is Loader)
			{
				customSprite.addChild(display);
				_sonBox.addChild(customSprite);
			}
			else if(display is Bitmap)
			{
				bm=new Bitmap(photography(display));
				customSprite.addChild(bm);
				customSprite.type="bm";
				_sonBox.addChild(customSprite);
			}
			else if(display is TextArea)
			{
				var content:String;
				var color:uint;
				var size:int;
				var bold:Boolean;
				var italic:Boolean;
				var format:TextFormat;
				var textArea:TextArea;
				var label:Label;
				var fontFamily:String;
				var width:int;
				var height:int;
				
				textArea=display as TextArea;
				content=textArea.text;
				color=textArea.textColor;
				size=EditableText(textArea.textDisplay).size;
				bold=EditableText(textArea.textDisplay).bold;
				italic=EditableText(textArea.textDisplay).italic;
				fontFamily=EditableText(textArea.textDisplay).fontFamily;
				width=textArea.width;
				height=textArea.height;
				
				format=new TextFormat;
				format.color=color;
				format.size=size;
				format.bold=bold;
				format.italic=italic;
				format.font=fontFamily;
				textField=new TextField;
				textField.width=width;
				textField.height=height;
				textField.background=true;
				textField.backgroundColor=0xffffff;
				textField.border=true;
				textField.embedFonts=true;
				textField.multiline=true;
				textField.wordWrap=true;
				textField.selectable=false;
				textField.autoSize="left";
				textField.text=content;	
				textField.setTextFormat(format);
				customSprite.addChild(textField);
				_sonBox.addChild(customSprite);
			}
			else if(display is Button)
			{
				var btn:Button=display as Button;
				customSprite.addChild(btn);
				_sonBox.addChild(customSprite);
				Label(btn.labelDisplay).fontFamily=fontName;
			}
			else if(display is CheckBox)
			{
				var checkBox:CheckBox=display as CheckBox;
				customSprite.addChild(checkBox);
				_sonBox.addChild(customSprite);
				Label(checkBox.labelDisplay).fontFamily=fontName;
			}
			else
			{
				customSprite.addChild(display);
				_sonBox.addChild(customSprite);
			}
			
			if(type=="video" || type=="sound" || type=="ppt")
			{
				//在mc中，如果有多帧，显示翻页，并且关闭旋转功能
				if(type=="ppt" && customSprite.mc.totalFrames>1)
				{
					this.addTurnBox(customSprite);
				}
				customSprite.mouseChildren=true;
				customSprite.type=type;
				customSprite.addEventListener(MouseEvent.MOUSE_DOWN,chooseSpecialHandler);
			}
			if(isMiddle)
			{
				customSprite.x=(this.width-display.width)/2;
				customSprite.y=(this.height-display.height)/2;
			}
			else
			{
				customSprite.x=x;
				customSprite.y=y;
			}
		}
		
		/**开始全屏显示*/
		private function beginFullScreen(customSprite:CustomSprite):void
		{
			var dataVO:Object=new Object;
			dataVO.type=customSprite.type;
			dataVO.content=customSprite.getChildAt(0);
			_controlFull(dataVO);
		}
		
		/**选择 了包含视频，音频的容器*/
		private function chooseSpecialHandler(event:MouseEvent):void
		{
			var sprite:Sprite;
			sprite=event.currentTarget as Sprite;
			_curSprite=event.currentTarget as CustomSprite;
			currTool.target=sprite;
			toolInit();
		}
		
		
		public function photography(photo:DisplayObject,transparent:Boolean = false,fillColor:uint = 0xffffff):BitmapData{
			var tmpRect:Rectangle = photo.getRect(photo);
			var picture:BitmapData = new BitmapData(photo.width,photo.height,transparent,fillColor);
			picture.draw(photo,new Matrix(1,0,0,1,0,0));
			return picture;
		}
		
		
		private function init():void
		{
			_sonBox=new Sprite;
			_ui=new UIComponent;
			this.addElement(_ui);
			
			_ui.addChild(_sonBox);
			_ui.addChild(defaultTool);
			_ui.addChild(customTool);
			
			customTool.raiseNewTargets=true;
			customTool.moveNewTargets=true;
			customTool.moveUnderObjects=false;
			
			customTool.registrationEnabled=true;
			customTool.rememberRegistration=false;
			
			customTool.rotationEnabled=false;
			customTool.constrainRotation=true;
			customTool.constrainRotationAngle=90/4;
			
			customTool.constrainScale=false;
			customTool.maxScaleX=2;
			customTool.maxScaleY=2;
			
			customTool.skewEnabled=true;
			currTool=defaultTool;
			
			this.addEventListener(Event.ADDED_TO_STAGE,addStageHandler);
		}
		
		private function addStageHandler(event:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE,addStageHandler);
			this.addEventListener(MouseEvent.MOUSE_DOWN,select);
			this.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN,addMenuHandler);
		}
		
		
		private var _curChooseSprite:CustomSprite;
		private function select(event:MouseEvent):void 
		{
			var sprite:Sprite;
			var box:Sprite;
			var point:Point=new Point;
			trace("select",event.target);
			if(this.containsElement(_btnMenu))
			{
				this.removeElement(_btnMenu);
			}
			if (event.target is FreeTrans) 
			{
				currTool.target=null;
			}
			else if (event.target is CustomSprite) 
			{
				var customSprite:CustomSprite=event.target as CustomSprite;
				
				sprite=event.target as Sprite;
				currTool.target=sprite;
				point.x=customSprite.width/2;
				point.y=customSprite.height/2;
				toolInit(point);
				
				_curSprite=event.target as CustomSprite;
				_curSprite.isChoose=true;
			}
			//全屏设置
			else if(event.target.parent.parent.parent is TransformTool)
			{
				return;
				var tool:TransformTool=event.target.parent.parent.parent as TransformTool;
				var curSprite:CustomSprite=(tool.target) as CustomSprite;
				_curChooseSprite=curSprite;
				if(curSprite.isChoose)
				{
					trace("fullScreenHandler");
					beginFullScreen(curSprite);
					curSprite.isChoose=false;
					trace("choose");
				}
				else
				{
					curSprite.isChoose=true;
				}
			}
		}
		
		private function addMenuHandler(event:MouseEvent):void
		{
			if(_curSprite && !this.containsElement(_btnMenu) && isShowMenu)
			{
				addControlMenu(event);
			}
		}
		
		// changing tools using the toolChange button
		private function setTool(event:MouseEvent):void {
			
			// get other tool
			var newTool:TransformTool = (currTool == defaultTool) ? customTool : defaultTool;
			
			// make sure moveNewTargets is not set when setting tool this way
			var moveTargets:Boolean=newTool.moveNewTargets;
			newTool.moveNewTargets=false;
			newTool.target=currTool.target;
			newTool.moveNewTargets=moveTargets;
			
			// unset currTool
			currTool.target=null;
			currTool=newTool;
			
			toolInit();
		}
		
		public function toolInit(point:Point=null):void {
			// raise
			currTool.parent.setChildIndex(currTool, currTool.parent.numChildren - 1);
			
			if (currTool==customTool) 
			{
				trace(currTool.boundsCenter.x,currTool.boundsCenter.y);
				currTool.registration=currTool.boundsCenter;
				//currTool.registration=point;
			}
			/*if(point)
			{
			trace("used:",point.x,point.y);
			currTool.registration=point;
			}*/
		}
		
		private function addTurnBox(box:CustomSprite):void
		{
			var btn:RightBtn=new RightBtn;
			var customSprite:CustomSprite=box;
			var turnBox:TurnBox;
			
			turnBox=new TurnBox;
			turnBox.initView(customSprite.mc);
			customSprite.addChild(turnBox);
			
			/*turnBox.width=customSprite.width;*/
			turnBox.height=50;
			turnBox.x=0;
			turnBox.y=5;
			customSprite.isShowTurnBox=true;
		}
		
		/**添加换页层*/
		public function addTurenBox(event:MouseEvent):void
		{
			/*var localX:int=event.localX;
			var localY:int=event.localY;*/
			var content:String;
			var btn:RightBtn=new RightBtn;
			var customSprite:CustomSprite=event.target as CustomSprite;
			var turnBox:TurnBox;
			
			turnBox=new TurnBox;
			turnBox.initView(customSprite.mc);
			customSprite.addChild(turnBox);
			
			turnBox.width=customSprite.width;
			turnBox.height=50;
			turnBox.x=5;
			turnBox.y=5;
			//turnBox.y=customSprite.y+customSprite.height-turnBox.height;
			customSprite.isShowTurnBox=true;
		}
		
		/**添加菜单*/
		public function addControlMenu(event:MouseEvent):void
		{
			var localX:int=event.localX;
			var localY:int=event.localY;
			var content:String;
			
			if(!_isCreateMenu)
			{
				_layout=new VerticalLayout;
				_layout.horizontalAlign="center";
				_btnMenu=new Group;
				
				_deleteBtn=new Button;
				_deleteBtn.name="delete";
				_deleteBtn.label="删除";
				_deleteBtn.width=80;
				
				if(_isShowRotateBtn)
				{
					_rotateBtn=new Button;
					_rotateBtn.width=80;
					_rotateBtn.name="rotate";
					_btnMenu.addElement(_rotateBtn);
				}
				
				if(__isShowScaleBtn)
				{
					_scaleBtn=new Button;
					_scaleBtn.name="scale";
					_scaleBtn.width=80;
					_btnMenu.addElement(_scaleBtn);
				}
				
				if(_isShowRegisterBtn)
				{
					_registerBtn=new Button;
					_registerBtn.width=80;
					_registerBtn.name="register";
					_btnMenu.addElement(_registerBtn);
				}
				_btnMenu.addElement(_deleteBtn);
				
				_btnMenu.x=_curSprite.x+_curSprite.mouseX+5;
				_btnMenu.y=_curSprite.y+_curSprite.mouseY+5;
			}
			
			this.addElement(_btnMenu);
			_btnMenu.addEventListener(MouseEvent.MOUSE_DOWN,controlBtn);
			
			if(_curSprite.isShowScale)
			{
				content="关闭缩放";
				if(!this.currTool.isShowScaleControls)
				{
					this.currTool.addScaleControls();
				}
			}
			else
			{
				content="打开缩放";
				if(this.currTool.isShowScaleControls)
				{
					this.currTool.removeScaleControls();
				}
			}
			
			if(_scaleBtn)
			{
				_scaleBtn.label=content;
			}
			
			if(_curSprite.isShowRotate)
			{
				content="关闭旋转";
				if(!this.currTool.isShowRotateControls)
				{
					this.currTool.addRotateControls();
				}
			}
			else
			{
				content="打开旋转";
				if(this.currTool.isShowRotateControls)
				{
					this.currTool.removeRotateControls();
				}
			}
			
			if(_rotateBtn)
			{
				_rotateBtn.label=content;
			}
			
			if(_curSprite.isShowRegister)
			{
				content="关闭注册点";
				if(!this.currTool.isShowRegistrationControls)
				{
					this.currTool.addRegistrationControls();
				}
			}
			else
			{
				content="打开注册点";
				if(this.currTool.isShowRegistrationControls)
				{
					this.currTool.removeRegistrationControls();
				}
			}
			
			if(_registerBtn)
			{
				_registerBtn.label=content;
			}
		}
		
		private function controlBtn(event:MouseEvent):void
		{
			var name:String;
			var label:String;
			var myVideo:MyVideo;
			var soundPlayer:SoundPlayer;
			if(event.target is Button)
			{
				name=(event.target as Button).name;
				label=(event.target as Button).label;
				if(name=="scale")
				{
					_curSprite.isShowScale=!_curSprite.isShowScale;
					scale(label);
				}
				else if(name=="rotate")
				{
					_curSprite.isShowRotate=!_curSprite.isShowRotate;
					rotate(label);
				}
				else if(name=="delete")
				{
					currTool.target=null;
					this.removeElement(_btnMenu);
					_sonBox.removeChild(_curSprite);
					if(_curSprite.type=="video")
					{
						myVideo=_curSprite.removeChildAt(0) as MyVideo;
						myVideo.dispose();
						myVideo=null;
					}
					else if(_curSprite.type=="sound")
					{
						soundPlayer=_curSprite.removeChildAt(0) as SoundPlayer;
						soundPlayer.dispose();
						soundPlayer=null;
					}
					_curSprite=null;
				}
				else
				{
					_curSprite.isShowRegister=!_curSprite.isShowRegister;
					register(label);
				}
			}
		}
		
		/**删除子项*/
		public function deleteOneRes():void
		{
			var myVideo:MyVideo;
			var soundPlayer:SoundPlayer;
			var bm:Bitmap;
			var mc:MovieClip;
			var curRes:DisplayObject;
			var turnBox:TurnBox;
			if(currTool.target!=null)
			{
				currTool.target=null;
				if(_btnMenu && this.containsElement(_btnMenu))
				{
					this.removeElement(_btnMenu);
				}
				_sonBox.removeChild(_curSprite);
				if(_curSprite.type=="video")
				{
					myVideo=_curSprite.removeChildAt(0) as MyVideo;
					myVideo.dispose();
					myVideo=null;
				}
				else if(_curSprite.type=="sound")
				{
					soundPlayer=_curSprite.removeChildAt(0) as SoundPlayer;
					soundPlayer.dispose();
					soundPlayer=null;
				}
				else if(_curSprite.type=="ppt")
				{
					turnBox=_curSprite.removeChildAt(0) as TurnBox;
					mc=_curSprite.removeChildAt(1) as MovieClip;
					turnBox.dispose();
					mc.stop();
					mc=null;
				}
				else
				{
					curRes=_curSprite.removeChildAt(0);
					if(curRes is MovieClip)
					{
						mc=curRes as MovieClip;
						mc.stop();
						mc=null;
					}
					curRes=null;
				}
				_curSprite=null;
			}
		}
		
		private function rotate(content:String):void
		{
			if(content=="关闭旋转")
			{
				_registerBtn.label="打开旋转";
				currTool.removeRotateControls();
			}
			else
			{
				_registerBtn.label="关闭旋转";
				currTool.addRotateControls();
			}
		}
		
		private function scale(content:String):void
		{
			if(content=="关闭缩放")
			{
				currTool.removeScaleControls();
				_scaleBtn.label="打开缩放";
			}
			else
			{
				currTool.addScaleControls();
				_scaleBtn.label="关闭缩放";
			}
		}
		
		private function register(content:String):void
		{
			if(content=="关闭注册点")
			{
				currTool.removeRegistrationControls();
				_registerBtn.label="打开注册点";
			}
			else
			{
				currTool.addRegistrationControls();
				_registerBtn.label="关闭注册点";
			}
		}
		
		/**销毁,避免内存泄露*/
		public function dispose():void
		{
			var len:int;
			var display:DisplayObject;
			var i:int=0;
			if(_btnMenu && this.containsElement(_btnMenu))
			{
				this.removeElement(_btnMenu);
				_btnMenu.removeEventListener(MouseEvent.MOUSE_DOWN,controlBtn);
				
				for(i=0;i<3;i++)
				{
					display=_btnMenu.getElementAt(0) as Button;
					_btnMenu.removeElementAt(0);
					display=null;
				}
				_btnMenu=null;
			}
			
			if(stage && stage.hasEventListener(MouseEvent.MOUSE_DOWN))
			{
				stage.removeEventListener(MouseEvent.MOUSE_DOWN,select);
			}
			
			this.removeElement(_ui);
			len=_ui.numChildren;
			for(i=0;i<len;i++)
			{
				display=_ui.getChildAt(0);
				_ui.removeChildAt(0);
				if(display is MovieClip)
				{
					var mc:MovieClip=display as MovieClip;
					mc.stop();
					mc=null;
				}
				else if(display is MyVideo)
				{
					var myVideo:MyVideo=display as MyVideo;
					myVideo.dispose();
					myVideo=null;
				}
				else if(display is SoundPlayer)
				{
					var soundPlayer:SoundPlayer=display as SoundPlayer;
					soundPlayer=null;
				}
				else
				{
					display=null;
				}
			}
			_ui=null;
		}
	}
}