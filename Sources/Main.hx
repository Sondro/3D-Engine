package;

import kha.System;
import kha.input.Mouse;
import kha.SystemImpl;

class Main 
{
	public static var width = 1280;
	public static var height = 720;
	public static var winTitle = '3D Demo';
	public static var winChange:Bool = false;
	public static var clearColor:kha.Color = 0xff93b7e9;
	
	public var inFullScreen:Bool;

	#if js
		public var setCanvas = cast(js.Browser.document.getElementById('khanvas'), js.html.CanvasElement);	
	#end
	
	public static inline function main() { startKha(); }

	//var ignore:Bool = false;
	public static inline function onMouseDown(a:Int,b:Int,c:Int) 
	{
		SystemImpl.notifyOfFullscreenChange(sizeChange,error);
		SystemImpl.requestFullscreen();
	}

	static inline function sizeChange():Void
	{
		#if js
		 if(SystemImpl.isFullscreen()) 
		 {
		  	trace("fullscreen mode");
			 
		  	System.changeResolution(js.Browser.window.screen.availWidth,js.Browser.window.screen.availHeight);
			 game.resize(js.Browser.window.screen.availWidth,js.Browser.window.screen.availHeight);
		  } 
			else 
		 	{
				trace("windowed mode");
				game.resize(width, height);
				System.changeResolution(width, height);
			}
			//trace(js.Browser.window.screen.availWidth+"x"+js.Browser.window.screen.availHeight);
		#end
	}
	static inline function error():Void { trace("fullscreen failed"); }

	static inline function startKha()
	{
		#if js
			//haxe.macro.Compiler.includeFile("../Libraries/Bullet/js/ammo/ammo.wasm.js");
			kha.LoaderImpl.loadBlobFromDescription({ files: ["ammo.js"] }, function(b: kha.Blob) 
			{
				var print = function(s:String) { trace(s); };
				var loaded = function() { print("ammo ready"); };
				untyped __js__("(1, eval)({0})", b.toString());
				untyped __js__("Ammo({print:print}).then(loaded)");
				System.init({title: winTitle, width: width, height: height}, init);
			});
		#else
			System.init({title: winTitle, width: width, height: height}, init);
		#end
	}
	static var game:MeshLoader;
	static inline function init():Void 
	{
		Mouse.get().notify(onMouseDown, onMouseDown, null, null);
		game = new MeshLoader();
		System.notifyOnRender(game.render);
	}
}