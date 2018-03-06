package;

import kha.math.FastVector2;
import haxebullet.Bullet;
import kha.graphics4.CullMode;
import kha.Framebuffer;
import kha.Color;
import kha.graphics4.CompareMode;
import kha.graphics4.ConstantLocation;
import kha.graphics4.TextureUnit;
import kha.graphics4.PipelineState;
import kha.graphics4.VertexData;
import kha.graphics4.VertexStructure;
import kha.Assets;
import kha.Shaders;
import kha.input.KeyCode;
import kha.math.FastMatrix4;
import kha.math.FastVector3;
import kha.Scheduler;
import kha.input.Keyboard;
import kha.input.Gamepad;
import kha.graphics4.TextureAddressing;
import kha.graphics4.TextureFilter;
import kha.graphics4.MipMapFilter;
import kha.Image;
import kha.graphics4.DepthStencilFormat;
import kha.graphics4.TextureFormat;
import kha.graphics4.BlendingFactor;

import ui.FPStext;


class MeshLoader 
{
//---------------------------------------------------------------------------	
	//Common
//---------------------------------------------------------------------------
	public var PIdiv2:Float = Math.PI / 2;
	public var nPIdiv2:Float = 0-(Math.PI / 2);

	public var timeFPS:Float = (1 / 60);
	public var timeFPSdiv2:Float = (1 / 30);

	public var time:Float = Scheduler.realTime();
//---------------------------------------------------------------------------
	private var pipelineBones:PipelineState;
	private var projectionLocationBones:ConstantLocation;
	private var viewLocationBones:ConstantLocation;
	private var modelLocationBones:ConstantLocation;
	private var bonesLoction:ConstantLocation;
	private var textureLocationBones:TextureUnit;

	private var pipelineDepth:PipelineState;
	private var projectionLocationDepth:ConstantLocation;
	private var viewLocationDepth:ConstantLocation;
	private var modelLocationDepth:ConstantLocation;
	private var bonesLoctionDepth:ConstantLocation;

	private var pipelineStatic:PipelineState;
	private var projectionLocationStatic:ConstantLocation;
	private var viewLocationStatic:ConstantLocation;
	private var modelLocationStatic:ConstantLocation;
	private var textureLocationStatic:TextureUnit;
	private var shadowMapLocation:TextureUnit;
	private var depthBiasLocation:ConstantLocation;

	private var pipelineWater:PipelineState;
	private var projectionLocationWater:ConstantLocation;
	private var modelLocationWater:ConstantLocation;
	private var	offsetLocationWater:ConstantLocation;
	private var scaleLocationWater:ConstantLocation;
	private var textureLocationWater:TextureUnit;
	private var modelViewWater:ConstantLocation;

	private var started:Bool = false;
	private var init:Bool = false;
//---------------------------------------------------------------------------	
	public var trans:BtTransform = BtTransform.create();
	public var m:haxebullet.BtMotionState;
	
	public var vel:haxebullet.BtVector3;
	public var dir:FastVector2 = new FastVector2(0, 0);
	public var controllerAngle:Float = 0;
	public var cameraAngle:Float = 0;
	public var pos:haxebullet.BtVector3;

	public var cs:Float = 0.0;
	public var sn:Float = 0.0;
	public var px:Float = 0.0;
	public var py:Float = 0.0;

	public var angle:Float = 0.0;

//---------------------------------------------------------------------------
// Keys:
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
	var mesh:Object3d;
	var skeleton:SkeletonD;
	var modelMatrix:FastMatrix4;
	var startModelMatrix:FastMatrix4;

	var obj3d:Array<Object3d>;
	var level:Array<Object3d>;
	var water:Array<Object3d>;

	public var marioAngle:Float = 0.0;
	public var isDirUpdated:Bool = false;
	public var curDir:String = '';
	public var oldDir:String = '';

	public var marioMatrixAngle:Float = -Math.PI/2;

	public var bonesTransformations:haxe.ds.Vector<Float >= new haxe.ds.Vector(32);
	public var currentFrame:Int = 1;
	public var timeElapsed:Float = 0;
	public var lastTime:Float = 0;
	public var velZ:Float = 0;
	
	var shadowMap:Image;
	var depthMap:Image;
	var finalTarget:Image;
	var blur:Image;
//---------------------------------------------------------------------------
// Scale
//---------------------------------------------------------------------------
	static inline var scale = 0.225;
	static inline var scaleCollisions = 0.0225;
	
	public var scaleMatrix:kha.math.FastMatrix4 = FastMatrix4.scale(scale,scale,scale);
//---------------------------------------------------------------------------
// Gamepad
//---------------------------------------------------------------------------
	public var virtualGamepad:VirtualGamepad;	
//---------------------------------------------------------------------------
	public var cameraMatrix:kha.math.FastMatrix4;
	public var projection:kha.math.FastMatrix4;
	public var projection00:kha.math.FastMatrix4 = FastMatrix4.orthogonalProjection(-30,25,-30,25,-1500,1000);
	public var projection01_window:kha.math.FastMatrix4 = FastMatrix4.perspectiveProjection(45 , Main.width / Main.height, 0.1, 5000);

	public var g:kha.graphics4.Graphics;
	public var g4_2:kha.graphics4.Graphics2;

	public var clear:Bool = true;
	public var biasMatrix:kha.math.FastMatrix4;

	public var lookVec3z = new FastVector3(0, 1, 0);
	public var lookVec3a = new FastVector3(0, 0, 0);
	public var lookVec3b = new FastVector3(0, 0, 0);
	public var lookVec3c = new FastVector3(0, 0, 0);
	public var lookVec3d = new FastVector3(0, 0, 0);
//---------------------------------------------------------------------------
// Physics
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------	
	//Jump/Fall
//---------------------------------------------------------------------------		
	#if js
		public var fallRigidBody:BtRigidBody;
		public var dynamicsWorld:BtDiscreteDynamicsWorld;
	#else
	public var fallRigidBody:BtRigidBody = BtRigidBody.create(BtRigidBodyConstructionInfo.create
	(
		0, 
		BtDefaultMotionState.create(BtTransform.create(), BtTransform.create()), 
		BtBvhTriangleMeshShape.create(BtStridingMeshInterface, false, false), 
		BtVector3.create(0, 0, 0)
	));

	public var dynamicsWorld:BtDiscreteDynamicsWorld = BtDiscreteDynamicsWorld.create
	(
		BtCollisionDispatcher.create(BtDefaultCollisionConfiguration.create()), 
		BtDbvtBroadphase.create(),  
		BtSequentialImpulseConstraintSolver.create(), 
		BtDefaultCollisionConfiguration.create()
	);
	#end
	public var jumpHeight = 30;
	public var fallVec:haxebullet.BtVector3 = BtVector3.create(0,0,0);
	public var jumpVec:haxebullet.BtVector3 = BtVector3.create(0,30,0);	
//---------------------------------------------------------------------------
// Shadow
//---------------------------------------------------------------------------
	public var biasMatrixTrans_00 = FastMatrix4.translation(0.5,0.5,0.5).multmat(FastMatrix4.scale(0.5,0.5,0.5));
//---------------------------------------------------------------------------
// UI
//---------------------------------------------------------------------------	
	public var g2:kha.graphics2.Graphics;
	public var loaded:Int = 0;		
	public var fontSize:Int = 64;
	public var loadStr:String = 'Loading... ';
	public var extractStr:String = 'Extracting Meshes... ';


	public var fontColor:kha.Color = kha.Color.White;

	public inline function new() { Assets.loadFont("mainfont",onFontloaded); }

	public var fps:FPStext = new FPStext();
//---------------------------------------------------------------------------
	public inline function start(): Void 
	{ 
//---------------------------------------------------------------------------
// FPS
//---------------------------------------------------------------------------
		fps.font = loadFont;
		fps.fontSize = fontSize;
		fps.init();
		fps.x = Main.width - fps.xMargin;
//---------------------------------------------------------------------------
// Input
//---------------------------------------------------------------------------	
		Keyboard.get().notify(onKeyDown, onKeyUp, onKeyPress);
		kha.input.Gamepad.get(0).notify(onAxis, onButton);
		virtualGamepad = new VirtualGamepad(Main.width, Main.height);
		virtualGamepad.addStick(0, 1,  150, Main.height - 150, 150);
		virtualGamepad.addButton(0, Main.width - 150, Main.height - 150, 150);
		virtualGamepad.notify(onAxis, onButton);
//---------------------------------------------------------------------------
// Collision
//---------------------------------------------------------------------------	
		startExtracting = true;

		var collisionConfiguration = BtDefaultCollisionConfiguration.create();
		var dispatcher = BtCollisionDispatcher.create(collisionConfiguration);
		var broadphase = BtDbvtBroadphase.create();
		var solver = BtSequentialImpulseConstraintSolver.create();
		dynamicsWorld = BtDiscreteDynamicsWorld.create(dispatcher, broadphase, solver, collisionConfiguration);
		dynamicsWorld.setGravity(BtVector3.create(0,-50,0));
//---------------------------------------------------------------------------
// Rig n Bones	
//---------------------------------------------------------------------------	
		Scheduler.addTimeTask(update, 0, timeFPS);

		var data = new OgexData(Assets.blobs.mario_ogex.toString());
	
		var sk = SkeletonLoader.getSkeleton(data);
		obj3d = MeshExtractor.extract(data, sk);
		skeleton = sk[0];
		data = new OgexData(Assets.blobs.untitled_ogex.toString());
//---------------------------------------------------------------------------
// Stage		
//---------------------------------------------------------------------------
		level = MeshExtractor.extract(data,null);
//---------------------------------------------------------------------------
// Water setup
//---------------------------------------------------------------------------
	
		var dataWater = new OgexData(Assets.blobs.water_ogex.toString());
		water = MeshExtractor.extract(dataWater,null);

		trace("meshes loaded");
	
		shadowMap = Image.createRenderTarget(256,256,TextureFormat.DEPTH16);
		depthMap = Image.createRenderTarget(Main.width,Main.height,TextureFormat.DEPTH16);
		//depthMap.setDepthStencilFrom
		finalTarget = Image.createRenderTarget(Main.width,Main.height,TextureFormat.RGBA32,DepthStencilFormat.DepthOnly,2);
		//finalTarget.setDepthStencilFrom(depthMap);
		blur = Image.createRenderTarget(Std.int(Main.width/4),Std.int(Main.height/4),TextureFormat.RGBA32,DepthStencilFormat.DepthOnly,2);

			
		var collisionMesh:BtTriangleMesh = BtTriangleMesh.create(true,false);
		
		var totalTriangles;
		var vertexes;
		var indexes;
			
		var index1;
		var	index2;
		var index3;

		//var objLen = data.geometryObjects.length;
		//var sumTris = Std.int(obj.mesh.indexArray.values.length / 3);
	
		for(obj in data.geometryObjects) 
		{
			totalTriangles = Std.int(obj.mesh.indexArray.values.length / 3);
			vertexes = obj.mesh.vertexArrays[0].values;
			indexes = obj.mesh.indexArray.values;
			
			for(i in 0...totalTriangles)
			{
				index1 = indexes[i * 3+0];
				index2 = indexes[i * 3+1];
				index3 = indexes[i * 3+2];
				collisionMesh.addTriangle
				(
					BtVector3.create(vertexes[index1 * 3+0] * scaleCollisions,vertexes[index1 * 3+1] * scaleCollisions,vertexes[index1 * 3+2] * scaleCollisions),
					BtVector3.create(vertexes[index2 * 3+0] * scaleCollisions,vertexes[index2 * 3+1] * scaleCollisions,vertexes[index2 * 3+2] * scaleCollisions),
					BtVector3.create(vertexes[index3 * 3+0] * scaleCollisions,vertexes[index3 * 3+1] * scaleCollisions,vertexes[index3 * 3+2] * scaleCollisions),
					true
				);
			}
		}

///////////////////////////////////////////////////////////////////////
//	Physics:
///////////////////////////////////////////////////////////////////////
		var groundShape = BtBvhTriangleMeshShape.create(collisionMesh,true,true);
		var groundTransform = BtTransform.create();
		groundTransform.setIdentity();
		groundTransform.setOrigin(BtVector3.create(0, -1, 0));
		var centerOfMassOffsetTransform = BtTransform.create();
		centerOfMassOffsetTransform.setIdentity();
		var groundMotionState = BtDefaultMotionState.create(groundTransform, centerOfMassOffsetTransform);
		var groundRigidBodyCI = BtRigidBodyConstructionInfo.create(0, groundMotionState, groundShape, BtVector3.create(0, 0, 0));
		
		var groundRigidBody = BtRigidBody.create(groundRigidBodyCI);
		groundRigidBody.setCollisionFlags(BtCollisionObject.CF_STATIC_OBJECT);
		dynamicsWorld.addRigidBody(groundRigidBody);

		var fallShape = BtCapsuleShape.create(1,1);
		var fallTransform = BtTransform.create();
		fallTransform.setIdentity();
		fallTransform.setOrigin(BtVector3.create(0, 10, 120.0));
		var centerOfMassOffsetFallTransform = BtTransform.create();
		centerOfMassOffsetFallTransform.setIdentity();
		var fallMotionState = BtDefaultMotionState.create(fallTransform, centerOfMassOffsetFallTransform);

		var fallInertia = BtVector3.create(0, 0, 0);
		fallShape.calculateLocalInertia(1, fallInertia);
		var fallRigidBodyCI = BtRigidBodyConstructionInfo.create(1, fallMotionState, fallShape, fallInertia);

		fallRigidBody = BtRigidBody.create(fallRigidBodyCI);
		fallRigidBody.setAngularFactor(BtVector3.create(0,1,0));
		dynamicsWorld.addRigidBody(fallRigidBody);
		fallRigidBody.activate(true);

///////////////////////////////////////////////////////////////////////
//	Bones:
///////////////////////////////////////////////////////////////////////
		var structure = new VertexStructure();
		structure.add('pos', VertexData.Float3);
		structure.add('normal', VertexData.Float3);
		structure.add('uv',VertexData.Float2);
		structure.add('weights',VertexData.Float4);
		structure.add('boneIndex',VertexData.Float4);
		pipelineBones = new PipelineState();
		pipelineBones.cullMode = CullMode.Clockwise;
		pipelineBones.inputLayout = [structure];
		pipelineBones.vertexShader = Shaders.meshBones_vert;
		pipelineBones.fragmentShader = Shaders.mesh_frag;
		pipelineBones.depthWrite = true;
		pipelineBones.depthMode = CompareMode.Less;
	
		pipelineBones.compile();
		
		projectionLocationBones = pipelineBones.getConstantLocation("projection");
		viewLocationBones = pipelineBones.getConstantLocation("view");
		modelLocationBones = pipelineBones.getConstantLocation("model");
		bonesLoction = pipelineBones.getConstantLocation("bones");
		textureLocationBones = pipelineBones.getTextureUnit("tex");

///////////////////////////////////////////////////////////////////////
//	Shadow:
///////////////////////////////////////////////////////////////////////
		pipelineDepth = new PipelineState();
		pipelineDepth.cullMode = CullMode.Clockwise;
		
		pipelineDepth.inputLayout = [structure];
		pipelineDepth.vertexShader = Shaders.meshBones_vert;
		pipelineDepth.fragmentShader = Shaders.mesh_frag;
		pipelineDepth.depthWrite = true;
		pipelineDepth.depthMode = CompareMode.Less;

		pipelineDepth.compile();
		
		projectionLocationDepth = pipelineDepth.getConstantLocation("projection");
		viewLocationDepth = pipelineDepth.getConstantLocation("view");
		modelLocationDepth = pipelineDepth.getConstantLocation("model");
		bonesLoctionDepth = pipelineDepth.getConstantLocation("bones");

///////////////////////////////////////////////////////////////////////
//	Stage:
///////////////////////////////////////////////////////////////////////

		structure = new VertexStructure();
		structure.add('pos', VertexData.Float3);
		structure.add('normal', VertexData.Float3);
		structure.add('uv',VertexData.Float2);
		pipelineStatic = new PipelineState();
		pipelineStatic.cullMode = CullMode.Clockwise;
		pipelineStatic.inputLayout = [structure];
		pipelineStatic.vertexShader = Shaders.mesh_vert;
		pipelineStatic.fragmentShader = Shaders.meshShadowMap_frag;
		pipelineStatic.depthWrite = true;
		pipelineStatic.depthMode = CompareMode.Less;
		pipelineStatic.compile();
		
		projectionLocationStatic = pipelineStatic.getConstantLocation("mvp");
		modelLocationStatic = pipelineStatic.getConstantLocation("model");
		textureLocationStatic = pipelineStatic.getTextureUnit("tex");
		shadowMapLocation = pipelineStatic.getTextureUnit("shadowMap");
		depthBiasLocation = pipelineStatic.getConstantLocation("depthBias");

///////////////////////////////////////////////////////////////////////
//	Water:
///////////////////////////////////////////////////////////////////////
		structure = new VertexStructure();
		structure.add('pos', VertexData.Float3);
		structure.add('normal', VertexData.Float3);
		structure.add('uv',VertexData.Float2);
		pipelineWater = new PipelineState();
		pipelineWater.cullMode = CullMode.Clockwise;
		pipelineWater.inputLayout = [structure];
		pipelineWater.vertexShader = Shaders.water_vert;
		pipelineWater.fragmentShader = Shaders.water_frag;
		pipelineWater.depthWrite = true;
		pipelineWater.depthMode = CompareMode.Less;
		
		pipelineWater.blendSource = BlendingFactor.SourceAlpha;
		pipelineWater.blendDestination = BlendingFactor.InverseSourceAlpha;
		pipelineWater.alphaBlendSource = BlendingFactor.SourceAlpha;
		pipelineWater.alphaBlendDestination = BlendingFactor.InverseSourceAlpha;
	
		pipelineWater.compile();
		
		projectionLocationWater = pipelineWater.getConstantLocation("mvp");
		modelLocationWater = pipelineWater.getConstantLocation("model");
		textureLocationWater = pipelineWater.getTextureUnit("tex");
		offsetLocationWater = pipelineWater.getConstantLocation("offset");
		scaleLocationWater = pipelineWater.getConstantLocation("scale");
		modelViewWater = pipelineWater.getConstantLocation("mv");
		
		modelMatrix = (FastMatrix4.rotationX(nPIdiv2)).multmat(scaleMatrix);

///////////////////////////////////////////////////////////////////////
//	Assign start position for restart:
///////////////////////////////////////////////////////////////////////
		startModelMatrix = modelMatrix;
		pos = trans.getOrigin();
		startModelMatrix._30 = cast pos.x() * 10;
		startModelMatrix._31 = cast pos.y() * 10;
		startModelMatrix._32 = cast pos.z() * 10;
///////////////////////////////////////////////////////////////////////

		started = true;
	}

	var width:Int = Main.width;
	var height:Int = Main.height;

	public inline function resize(width:Int,height:Int)
	{
		if(this.width != width&&this.height != height)
		{
			this.width = width;
			this.height = height;
			virtualGamepad.resize(width, height);
			//finalTarget.unload();
			//finalTarget = Image.createRenderTarget(width,height,TextureFormat.RGBA32,DepthStencilFormat.DepthOnly,2);
		}
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
				}else
				if(aValue < -0.5)
				{
					rotateJustCameraRight = true;
				}
			}
	}
	private inline function onButton(aId:Int,aValue:Float):Void
	{
		//jump = (aId == 0 &&aValue>0);
	}

	inline public function update() 
	{
		fps.update();

		dynamicsWorld.stepSimulation(timeFPS);
		m = fallRigidBody.getMotionState();
		m.getWorldTransform(trans);

		//pos = trans.getOrigin();

		vel = fallRigidBody.getLinearVelocity();
		
		if(dir.x != 0) { dir.x = 0; }
		if(dir.y != 0) { dir.y = 0; }

		modelMatrix._30 = cast pos.x() * 10;
		modelMatrix._31 = cast pos.y() * 10;
		modelMatrix._32 = cast pos.z() * 10;
		
		//Reset position
		if(R) 
		{
			modelMatrix._30 = startModelMatrix._30;
			modelMatrix._31 = startModelMatrix._31;
			modelMatrix._32 = startModelMatrix._32;
		/*
			modelMatrix._30 = 0;
			modelMatrix._31 = 72.5;
			modelMatrix._32 = 1200;
		*/
		/*
			modelMatrix._00 = startModelMatrix._00;
			modelMatrix._01 = startModelMatrix._01;
			modelMatrix._02 = startModelMatrix._02;
			modelMatrix._03 = startModelMatrix._03;

			modelMatrix._10 = startModelMatrix._10;
			modelMatrix._11 = startModelMatrix._11;
			modelMatrix._12 = startModelMatrix._12;
			modelMatrix._13 = startModelMatrix._13;
	
			modelMatrix._20 = startModelMatrix._20;
			modelMatrix._21 = startModelMatrix._21;
			modelMatrix._22 = startModelMatrix._22;
			modelMatrix._23 = startModelMatrix._23;
			
			modelMatrix._30 = startModelMatrix._30;
			modelMatrix._31 = startModelMatrix._31;
			modelMatrix._32 = startModelMatrix._32;
			modelMatrix._33 = startModelMatrix._33;
	*/

		}

		if(F1) 
		{
			fps.toggleFPS();
			F1 = false;
		}

		if(rotateCameraLeft||rotateJustCameraLeft) 
		{ 
			cameraAngle -= 0.02; 
			isDirUpdated = false;
 		}
		else if(rotateCameraRight||rotateJustCameraRight) 
		{ 
			cameraAngle += 0.02; 	
			isDirUpdated = false;
		}

		if(left || right|| forward || backward)
		{	
			if(left) 
			{
				dir.y += 1;
				curDir = 'left';
				isDirUpdated = false;
			}
			if(right) 
			{
				dir.y -= 1;
				curDir = 'right';
				isDirUpdated = false;
			}
			if(forward) 
			{
				dir.x -= 1;
				curDir = 'forward';
			}
			if(backward) 
			{
				dir.x += 1;
				curDir = 'back';
				controllerAngle = cameraAngle; 
			}
			else { controllerAngle = marioAngle; }

			oldDir = curDir;

			if(isDirUpdated != true)
			{
				dir = dir.mult(10);
		 
				cs = Math.cos(-cameraAngle+PIdiv2);
				sn = Math.sin(-cameraAngle+PIdiv2);
				px = dir.x * cs-dir.y * sn;
				py = dir.x * sn+dir.y * cs;

				trace('cs: ' + cs + ' sn: ' + sn + ' px: ' + px + ' py: ' + py);

				dir.x = px+vel.x() * 0.9;
				dir.y = py+vel.z() * 0.9;
		
				if(dir.length > 20)
				{
					dir.normalize();
					dir = dir.mult(20);
				}
			}
			else 
			{
				dir = dir.mult(10);
		 
				cs = Math.cos(-cameraAngle+PIdiv2);
				sn = Math.sin(-cameraAngle+PIdiv2);
				px = dir.x * cs-dir.y * sn;
				py = dir.x * sn+dir.y * cs;

				trace('cs: ' + cs + ' sn: ' + sn + ' px: ' + px + ' py: ' + py);

				dir.x = px+vel.x() * 0.9;
				dir.y = py+vel.z() * 0.9;
		
				if(dir.length > 20)
				{
					dir.normalize();
					dir = dir.mult(20);
				}
			}

			fallRigidBody.activate(true);
			angle = Math.atan2(dir.y,dir.x);
			
			if(angle != marioAngle) 
			{
				modelMatrix = modelMatrix.multmat(FastMatrix4.rotationZ(marioAngle-angle));
				marioMatrixAngle += marioAngle-angle;
				marioAngle = angle;
			}
		}

	//if(jump && vel.y() <= 0)
		if(jump)
		{
			jumpVec.setX(vel.x());
			//jumpVec.setY(jumpHeight);
			jumpVec.setZ(vel.z());

			fallRigidBody.setLinearVelocity(jumpVec);
		}
		//dir.normalize()

		velZ = vel.y();

		fallVec.setX(dir.x);
		//fallVec.setY(vel.y());
		fallVec.setY(velZ);		
		fallVec.setZ(dir.y);

		fallRigidBody.setLinearVelocity(fallVec);
		isDirUpdated = true;
	}


	inline function onKeyPress(aText:String) 
	{
		
	}

	inline function onKeyUp(aCode:KeyCode) 
	{
		//Reset Mario Pos
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
		if (aCode == KeyCode.Up && !forward || aCode == KeyCode.W && !forward)//|| kha.Mouse.
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

	public inline function render(frame:Framebuffer): Void 
	{	
		if(loaded >= 100) 
		{	
			time = Scheduler.realTime();
			timeElapsed  += time - lastTime;
			lastTime = time;

			if(timeElapsed > timeFPSdiv2) 
			{
				timeElapsed = 0;
				skeleton.setFrame(18+ ++currentFrame%15);
			}

			if(!left && !right && !forward && !backward)
			{
				skeleton.setFrame(43);
			}
			
			lookVec3a.x = modelMatrix._30-200;
			lookVec3a.y = modelMatrix._31+400;
			lookVec3a.z = modelMatrix._32;
			lookVec3b.x = modelMatrix._30;
			lookVec3b.y = modelMatrix._31+25;
			lookVec3b.z = modelMatrix._32;

			//render shadow
			cameraMatrix = FastMatrix4.lookAt
			(
				lookVec3a, 
				lookVec3b, 
				lookVec3z
			);
	
			projection = projection00;
			g = shadowMap.g4;
			
			for(mesh in obj3d)
			{
				g.begin();

				if(clear)
				{
					g.clear(null, Math.POSITIVE_INFINITY);
					clear = false;
				}

			//Render Shadow
				g.setPipeline(pipelineDepth);
				g.setMatrix(projectionLocationDepth, projection);
				g.setMatrix(viewLocationDepth, cameraMatrix);
				
				g.setMatrix(modelLocationDepth,
					modelMatrix.multmat
					(
						FastMatrix4.rotationZ(cameraAngle+PIdiv2)).multmat(FastMatrix4.translation(0,0,-25)
					)
				);

			//Char Bones Shadow
				g.setFloats(bonesLoctionDepth,mesh.skin.getBonesTransformations());

				g.setIndexBuffer(mesh.indexBuffer);
				g.setVertexBuffer(mesh.vertexBuffer);
				g.drawIndexedVertices();
				
				g.end();
			}

			biasMatrix = biasMatrixTrans_00;
			biasMatrix = biasMatrix.multmat(projection).multmat(cameraMatrix);		
			
			g = finalTarget.g4;
			clear = true;

			lookVec3c.x = modelMatrix._30+Math.sin(cameraAngle) * 200;
			lookVec3c.y = modelMatrix._31+100;
			lookVec3c.z = modelMatrix._32+Math.cos(cameraAngle) * 200;

			cameraMatrix = FastMatrix4.lookAt(
				lookVec3c, 
				lookVec3b, 
				lookVec3z
			);

			projection = projection01_window;
			//FastMatrix4.orthogonalProjection(-25,25,-25,25,-1500,1000);
			
			for(mesh in level)
			{
				g.begin();
				
				if(clear)
				{
					g.clear(Main.clearColor, Math.POSITIVE_INFINITY);
					clear = false;
				}

				g.setPipeline(pipelineStatic);
				g.setMatrix(projectionLocationStatic,projection.multmat(cameraMatrix).multmat(scaleMatrix));
				g.setMatrix(modelLocationStatic,scaleMatrix);
				g.setTexture(textureLocationStatic,mesh.texture);
				g.setTextureParameters(textureLocationStatic,TextureAddressing.Repeat,TextureAddressing.Repeat,TextureFilter.LinearFilter,TextureFilter.LinearFilter,MipMapFilter.LinearMipFilter);
				
				g.setMatrix(depthBiasLocation,biasMatrix.multmat(scaleMatrix));
				g.setTexture(shadowMapLocation,shadowMap);
				g.setTextureParameters(shadowMapLocation,TextureAddressing.Clamp,TextureAddressing.Clamp,TextureFilter.PointFilter,TextureFilter.PointFilter,MipMapFilter.NoMipFilter);
		
				g.setIndexBuffer(mesh.indexBuffer);
				g.setVertexBuffer(mesh.vertexBuffer);
				g.drawIndexedVertices();
				g.end();	
			}
			
		//	/*
			for(mesh in obj3d)
			{
				g.begin();
				
				g.setPipeline(pipelineBones);
				g.setMatrix(projectionLocationBones, projection);
				g.setMatrix(viewLocationBones, cameraMatrix);
				g.setMatrix(modelLocationBones,modelMatrix.multmat(FastMatrix4.translation(0,0,-25)));
				g.setTexture(textureLocationBones,mesh.texture);
				
				g.setFloats(bonesLoction,mesh.skin.getBonesTransformations());
			
				g.setIndexBuffer(mesh.indexBuffer);
				g.setVertexBuffer(mesh.vertexBuffer);
				g.drawIndexedVertices();
				g.end();
			}
		//	*/


			for(mesh in water)
			{
				g.begin();
				
				g.setPipeline(pipelineWater);
				g.setMatrix(projectionLocationWater,projection.multmat(cameraMatrix).multmat(FastMatrix4.translation(0,-40,0)).multmat(FastMatrix4.scale(8,8,8).multmat(FastMatrix4.rotationX(nPIdiv2))));
				g.setMatrix(modelLocationWater,FastMatrix4.translation(0,0,-40).multmat(FastMatrix4.scale(8,8,8).multmat(FastMatrix4.rotationY(nPIdiv2))));
				g.setMatrix(modelViewWater,cameraMatrix.inverse());
				g.setTexture(textureLocationWater,Assets.images.waterNormal);
				g.setTextureParameters(textureLocationWater,TextureAddressing.Repeat,TextureAddressing.Repeat,TextureFilter.LinearFilter,TextureFilter.LinearFilter,MipMapFilter.NoMipFilter);
				
				g.setFloat2(offsetLocationWater,Scheduler.time()/60,Scheduler.time()/60);
				g.setFloat2(scaleLocationWater,16,16);
				
				g.setIndexBuffer(mesh.indexBuffer);
				g.setVertexBuffer(mesh.vertexBuffer);
				g.drawIndexedVertices();
				
				g.end();	
			}

			//RenderTexture.renderTo(finalTarget,shadowMap,0,0,0.2,RenderTexture.Channel.Color,true);

			fps.totalFrames++;
			fps.draw(g2);
			g2.end();

			RenderTexture.renderTo(frame,finalTarget,0,0,1,RenderTexture.Channel.Color,true);

		}
		else if(fontLoaded)
		{
			//g2.transformation = kha.math.FastMatrix3.scale(2,2); //scale 50%
			if(loaded == 0) 
			{
				g2 = frame.g2;
				g2.font = loadFont;
				g2.fontSize = fontSize;
				g2.color = fontColor;
			}

			loaded = Std.int(Assets.progress * 100);
			
			g2.begin(true);	
			
			if(startExtracting) 
			{ 
				g2.drawString(loadStr + loaded +"%", (Main.width/2) - (loadStr.length + 6) * (g2.fontSize/6),(Main.height/2.5)-(g2.fontSize/2));
				g2.fontSize = Std.int(fontSize / 1.25);
				g2.drawString(extractStr, (Main.width/2) - (extractStr.length) * (g2.fontSize/6),(Main.height/2)-(g2.fontSize/2));
				g2.fontSize = fontSize;
			}
			else { g2.drawString(loadStr + loaded +"%", (Main.width/2) - (loadStr.length + 6) * (g2.fontSize/6),(Main.height/2.5)-(g2.fontSize/2)); }
			//else { g2.drawString(loadStr + loaded +"%", (Main.width/2) - (loadStr.length + 3) * (g2.fontSize/6),(Main.height/2)-(g2.fontSize/2)); }
			
			g2.end();
		}	
		
	}

	var miniCharAnimation = ['/','-','\"','|'];
	//var loadCounter:Int = 0;
	var fontLoaded:Bool;
	var loadFont:kha.Font;
	var startExtracting:Bool;
	
	inline function onFontloaded(font:kha.Font)
	{
		loadFont = font;
		fontLoaded = true;
		Assets.loadEverything(start);
	}
}