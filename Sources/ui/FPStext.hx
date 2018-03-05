package ui;

import kha.Scheduler;
import kha.Color;


class FPStext
{	
	public var on = true;
	//public var draw3DText = true;

	public var curFPS:Int = 0;
	public var totalFrames:Int = 0;

	private var elapsedTime:Float = 0;
 	private var previousTime:Float = 0;	
	private var currentTime:Float;
	private var deltaTime:Float;


	public var color = kha.Color.White;
	public var fontSize = 28;
	public var font:kha.Font;
	public var x = 20.0;
	public var y = 20.0;
	public var xMargin:Float;
	
	inline public function new():Void 
	{
		curFPS = 0;
		totalFrames = 0;
		previousTime = 0.0;
		elapsedTime = 0.0;
		xMargin = fontSize * 2;
	}
	
	inline public function update():Void
	{
		currentTime = Scheduler.realTime();
		deltaTime = (currentTime - previousTime);
		previousTime = currentTime;
		
    elapsedTime += deltaTime;		

		if(elapsedTime >= 1.0) 
		{
			curFPS = totalFrames;
			totalFrames = 0;
			elapsedTime = 0;			
		}
	}	

	inline public function init():Void
	{
		xMargin = fontSize * 2;
		//font = kha.Assets.fonts.Oswald_Regular;
		//x = plume.Plm.gameWidth - xMargin;
	}

	inline public function draw(g:kha.graphics2.Graphics):Void
	{	
		if(!on) { return; }	
		g.drawString(Std.string(this.curFPS), x, y);
	}
	
	inline public function updateAndDraw(g:kha.graphics2.Graphics):Void
	{	
		if(!on) { return; }	
		g.color = color;
		g.fontSize = fontSize;
		g.drawString(Std.string(this.curFPS), x, y);

	}

	inline public function render(g2:kha.graphics2.Graphics, ?xTmp:Float, ?yTmp:Float):Void
	{	
		/*
		text.text = Std.string(this.curFPS);
		text.update();
		text.render(g2, x, y);
		*/
	}

	inline public function toggleFPS():Bool
	{	
		if(on) { on = false; return false; }
		if(!on) { on = true; return true; }
		 return true; 
	}
}