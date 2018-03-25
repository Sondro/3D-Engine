package;

import kha.input.Keyboard;
import kha.input.KeyCode;

import kha.input.Gamepad;

import kha.math.FastMatrix4;
import MeshLoader;

class Input
{
	public var meshLoader:MeshLoader;

//---------------------------------------------------------------------------
// Key Events:
//---------------------------------------------------------------------------

	public var R:Bool = false;
	public var F1:Bool = false;

	public var left:Bool = false;
	public var right:Bool = false;
	public var forward:Bool = false;
	public var backward:Bool = false;
	public var jump:Bool = false;
	public var rotateCameraLeft:Bool = false;
	public var rotateCameraRight:Bool = false;
	public var rotateJustCameraLeft:Bool = false;
	public var rotateJustCameraRight:Bool = false;

//---------------------------------------------------------------------------
// Gamepad
//---------------------------------------------------------------------------
	
	public var virtualGamepad:VirtualGamepad;	

	public inline function new():Void 
	{ 
		
		Keyboard.get().notify(onKeyDown, onKeyUp, onKeyPress);

		kha.input.Gamepad.get(0).notify(onAxis, onButton);
		virtualGamepad = new VirtualGamepad(Main.width, Main.height);
		virtualGamepad.addStick(0, 1,  150, Main.height - 150, 150);
		virtualGamepad.addButton(0, Main.width - 150, Main.height - 150, 150);
		virtualGamepad.notify(onAxis, onButton);
	}

	private inline function onAxis(aId:Int,aValue:Float):Void{
			if(aId == 0)
			{
				right = false;
				left = false;
				rotateCameraLeft = false;
				rotateCameraRight = false;
				if(aValue > 0.5)
				{
					right = true;
					rotateCameraLeft = true;
				} else
				if(aValue < -0.5)
				{
					left = true;
					rotateCameraRight = true;
				}
				
			}
			if(aId == 1)
			{
				forward = false;
				backward = false;
				if(aValue>0.5)
				{
					forward = true;
				} else
				if(aValue < -0.5)
				{
					backward = true;
				}
			}
			if(aId == 2)
			{
				rotateJustCameraLeft = false;
				rotateJustCameraRight = false;
				if(aValue > 0.5)
				{
					rotateJustCameraLeft = true;
				}
				else if(aValue < -0.5)
				{
					rotateJustCameraRight = true;
				}
			}
	}
//---------------------------------------------------------------------------

	private inline function onButton(aId:Int,aValue:Float):Void
	{
		//jump = (aId == 0 &&aValue>0);
	}

	public inline function update() 
	{

		//Reset position
		if(R) 
		{
			Main.app.modelMatrix._30 = Main.app.startModelMatrix._30;
			Main.app.modelMatrix._31 = Main.app.startModelMatrix._31;
			Main.app.modelMatrix._32 = Main.app.startModelMatrix._32;
		/*
		//Approx, traced values:
			Main.app.modelMatrix._30 = 0;
			Main.app.modelMatrix._31 = 72.5;
			Main.app.modelMatrix._32 = 1200;
		*/
		/*
			Main.app.modelMatrix._00 = Main.app.startModelMatrix._00;
			Main.app.modelMatrix._01 = Main.app.startModelMatrix._01;
			Main.app.modelMatrix._02 = Main.app.startModelMatrix._02;
			Main.app.modelMatrix._03 = Main.app.startModelMatrix._03;

			Main.app.modelMatrix._10 = Main.app.startModelMatrix._10;
			Main.app.modelMatrix._11 = Main.app.startModelMatrix._11;
			Main.app.modelMatrix._12 = Main.app.startModelMatrix._12;
			Main.app.modelMatrix._13 = Main.app.startModelMatrix._13;
	
			Main.app.modelMatrix._20 = Main.app.startModelMatrix._20;
			Main.app.modelMatrix._21 = Main.app.startModelMatrix._21;
			Main.app.modelMatrix._22 = Main.app.startModelMatrix._22;
			Main.app.modelMatrix._23 = Main.app.startModelMatrix._23;
			
			Main.app.modelMatrix._30 = Main.app.startModelMatrix._30;
			Main.app.modelMatrix._31 = Main.app.startModelMatrix._31;
			Main.app.modelMatrix._32 = Main.app.startModelMatrix._32;
			Main.app.modelMatrix._33 = Main.app.startModelMatrix._33;
	*/

		}

		if(F1) 
		{
			Main.app.fps.toggleFPS();
			F1 = false;
		}

		if(rotateCameraLeft || rotateJustCameraLeft) 
		{ 
			Main.app.cameraAngle -= 0.02; 
			Main.app.isDirUpdated = false;
 		}
		else if(rotateCameraRight || rotateJustCameraRight) 
		{ 
			Main.app.cameraAngle += 0.02; 	
			Main.app.isDirUpdated = false;
		}

		if(left || right|| forward || backward)
		{	
			if(left) 
			{
				Main.app.dir.y += 1;
				Main.app.curDir = 'left';
				Main.app.isDirUpdated = false;
			}
			if(right) 
			{
				Main.app.dir.y -= 1;
				Main.app.curDir = 'right';
				Main.app.isDirUpdated = false;
			}
			if(forward) 
			{
				Main.app.dir.x -= 1;
				Main.app.curDir = 'forward';
			}
			if(backward) 
			{
				Main.app.dir.x += 1;
				Main.app.curDir = 'back';
				Main.app.controllerAngle = Main.app.cameraAngle; 
			}
			else { Main.app.controllerAngle = Main.app.actorAngle; }

			Main.app.oldDir = Main.app.curDir;

			if(Main.app.isDirUpdated != true)
			{
				Main.app.dir = Main.app.dir.mult(10);
		 
				Main.app.cs = Math.cos(-Main.app.cameraAngle+Main.app.PIdiv2);
				Main.app.sn = Math.sin(-Main.app.cameraAngle+Main.app.PIdiv2);
				Main.app.px = Main.app.dir.x * Main.app.cs-Main.app.dir.y * Main.app.sn;
				Main.app.py = Main.app.dir.x * Main.app.sn+Main.app.dir.y * Main.app.cs;

				trace('Main.app.cs: ' + Main.app.cs + ' Main.app.sn: ' + Main.app.sn + ' Main.app.px: ' + Main.app.px + ' Main.app.py: ' + Main.app.py);

				Main.app.dir.x = Main.app.px+Main.app.vel.x() * 0.9;
				Main.app.dir.y = Main.app.py+Main.app.vel.z() * 0.9;
		
				if(Main.app.dir.length > 20)
				{
					Main.app.dir.normalize();
					Main.app.dir = Main.app.dir.mult(20);
				}
			}
			else 
			{
				Main.app.dir = Main.app.dir.mult(10);
		 
				Main.app.cs = Math.cos(-Main.app.cameraAngle+Main.app.PIdiv2);
				Main.app.sn = Math.sin(-Main.app.cameraAngle+Main.app.PIdiv2);
				Main.app.px = Main.app.dir.x * Main.app.cs-Main.app.dir.y * Main.app.sn;
				Main.app.py = Main.app.dir.x * Main.app.sn+Main.app.dir.y * Main.app.cs;

				trace('cs: ' + Main.app.cs + ' sn: ' + Main.app.sn + ' px: ' + Main.app.px + ' py: ' + Main.app.py);

				Main.app.dir.x = Main.app.px+Main.app.vel.x() * 0.9;
				Main.app.dir.y = Main.app.py+Main.app.vel.z() * 0.9;
		
				if(Main.app.dir.length > 20)
				{
					Main.app.dir.normalize();
					Main.app.dir = Main.app.dir.mult(20);
				}
			}
			Main.app.fallRigidBody.activate(true);
			Main.app.angle = Math.atan2(Main.app.dir.y,Main.app.dir.x);
			
			if(Main.app.angle != Main.app.actorAngle) 
			{
				Main.app.modelMatrix = Main.app.modelMatrix.multmat(FastMatrix4.rotationZ(Main.app.actorAngle - Main.app.angle));
				Main.app.actorMatrixAngle += Main.app.actorAngle - Main.app.angle;
				Main.app.actorAngle = Main.app.angle;
			}
		}

	//if(jump && Main.app.vel.y() <= 0)
		if(jump)
		{
			Main.app.jumpVec3.setX(Main.app.vel.x());
			//Main.app.jumpVec3.setY(jumpHeight);
			Main.app.jumpVec3.setZ(Main.app.vel.z());

			Main.app.fallRigidBody.setLinearVelocity(Main.app.jumpVec3);
		}
	}

	public inline function render():Void
	{
		if(!left && !right && !forward && !backward)
		{
			Main.app.skeleton.setFrame(43);
		}
	}
	inline function onKeyPress(aText:String) 
	{
		
	}

	inline function onKeyUp(aCode:KeyCode) 
	{
		//Reset actor Pos
		if (aCode == KeyCode.R)
		{
			R = false;
		}

		if (aCode == KeyCode.F1)
		{
			F1 = false;
		}

		if (aCode == KeyCode.Left || aCode == KeyCode.A)
		{
			left = false;
			rotateCameraRight = false;
		}
		if (aCode == KeyCode.Right || aCode == KeyCode.D)
		{
			right = false;
			rotateCameraLeft = false;
		}
		if (aCode == KeyCode.Up || aCode == KeyCode.W)
		{
			forward = false;
		}
		if (aCode == KeyCode.Down || aCode == KeyCode.S)
		{
			backward = false;
		}
		if(aCode == KeyCode.Space || aCode == KeyCode.O || aCode == KeyCode.Numpad9)
		{
			jump = false;
		}
		if(aCode == KeyCode.Q)
		{
			rotateJustCameraRight = false;
		}
		if(aCode == KeyCode.E)
		{
			rotateJustCameraLeft = false;
		}
	}
	
	inline function onKeyDown(aCode:KeyCode) 
	{
		if (aCode == KeyCode.R)
		{
			R = true;
		}
		if (aCode == KeyCode.F1)
		{
			F1 = true;
		}

		if (aCode == KeyCode.Left && !left || aCode == KeyCode.A && !left)
		{
			left = true;
			rotateCameraRight = true;
		}
		if (aCode == KeyCode.Right && !right || aCode == KeyCode.D && !right)
		{
			right = true;
			rotateCameraLeft = true;
		}
		if (aCode == KeyCode.Up && !forward || aCode == KeyCode.W && !forward) //|| kha.Mouse.
		{
			forward = true;
		}
		if (aCode == KeyCode.Down && !backward || aCode == KeyCode.S && !backward)
		{
			backward = true;
		}
		if(aCode == KeyCode.Space && !jump || aCode == KeyCode.O && !jump || aCode == KeyCode.Numpad9 && !jump)
		{
			jump = true;
		}
		if(aCode == KeyCode.Q)
		{
			rotateJustCameraRight = true;
		}
		if(aCode == KeyCode.E)
		{
			rotateJustCameraLeft = true;
		}

	}
}