package;

import kha.math.FastVector2;
import kha.math.FastVector3;
import kha.math.FastMatrix4;

import kha.Assets;
import kha.Scheduler;
import kha.Color;
import kha.Image;
import kha.Framebuffer;
import kha.Shaders;

import kha.graphics4.TextureUnit;
import kha.graphics4.PipelineState;
import kha.graphics4.VertexData;
import kha.graphics4.VertexStructure;
import kha.graphics4.TextureAddressing;
import kha.graphics4.TextureFilter;
import kha.graphics4.MipMapFilter;
import kha.graphics4.CullMode;
import kha.graphics4.CompareMode;
import kha.graphics4.ConstantLocation;
import kha.graphics4.DepthStencilFormat;
import kha.graphics4.TextureFormat;
import kha.graphics4.BlendingFactor;

import haxebullet.Bullet;

import ui.FPStext;

import Input;


class MeshLoader 
{
//---------------------------------------------------------------------------
// Common
//---------------------------------------------------------------------------

	public var PIdiv2:Float = Math.PI / 2;
	public var nPIdiv2:Float = 0-(Math.PI / 2);

	public var timeFPS:Float = (1 / 60);
	public var timeFPSdiv2:Float = (1 / 30);

	public var time:Float = Scheduler.realTime();

//---------------------------------------------------------------------------
// Pipeline setup
//---------------------------------------------------------------------------

	public var pipelineBones:PipelineState;
	public var projectionLocationBones:ConstantLocation;
	public var viewLocationBones:ConstantLocation;
	public var modelLocationBones:ConstantLocation;
	public var bonesLoction:ConstantLocation;
	public var textureLocationBones:TextureUnit;

	public var pipelineDepth:PipelineState;
	public var projectionLocationDepth:ConstantLocation;
	public var viewLocationDepth:ConstantLocation;
	public var modelLocationDepth:ConstantLocation;
	public var bonesLoctionDepth:ConstantLocation;

	public var pipelineStatic:PipelineState;
	public var projectionLocationStatic:ConstantLocation;
	public var viewLocationStatic:ConstantLocation;
	public var modelLocationStatic:ConstantLocation;
	public var textureLocationStatic:TextureUnit;
	public var shadowMapLocation:TextureUnit;
	public var depthBiasLocation:ConstantLocation;

	public var pipelineWater:PipelineState;
	public var projectionLocationWater:ConstantLocation;
	public var modelLocationWater:ConstantLocation;
	public var	offsetLocationWater:ConstantLocation;
	public var scaleLocationWater:ConstantLocation;
	public var textureLocationWater:TextureUnit;
	public var modelViewWater:ConstantLocation;

	public var started:Bool = false;
	public var init:Bool = false;

//---------------------------------------------------------------------------	
// Physics
//---------------------------------------------------------------------------		

	public var trans = BtTransform.create();
	
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

// Jump/Fall
	#if js
		public var m:haxebullet.BtMotionState;
		
		public var fallRigidBody:BtRigidBody;
		public var dynamicsWorld:BtDiscreteDynamicsWorld;
	#else
		//public var m = BtDefaultMotionState.create(BtTransform.create(), BtTransform.create());
		public var m:BtMotionStatePointer;
		public var dynamicsWorld:BtDiscreteDynamicsWorldPointer;
		public var fallRigidBody:BtRigidBodyPointer;
		/*
		public var fallRigidBody = BtRigidBody.create(BtRigidBodyConstructionInfo.create
		(
			0, 
			BtDefaultMotionState.create(BtTransform.create(), BtTransform.create()), 
			BtBvhTriangleMeshShape.create(BtTriangleMesh.create(true, true), false, false), 
			BtVector3.create(0, 0, 0)
		));

	
		public var dynamicsWorld = BtDiscreteDynamicsWorld.create
		(
			BtCollisionDispatcher.create(BtDefaultCollisionConfiguration.create()), 
			BtDbvtBroadphase.create(),  
			BtSequentialImpulseConstraintSolver.create(), 
			BtDefaultCollisionConfiguration.create()
		);
		*/
	#end
	public var jumpHeight = 30;
	public var fallVec3 = BtVector3.create(0,0,0);
	public var jumpVec3 = BtVector3.create(0,30,0);	

//---------------------------------------------------------------------------
// Input:
//---------------------------------------------------------------------------

	public var input:Input;

//---------------------------------------------------------------------------
// Meshes
//---------------------------------------------------------------------------

	public var mesh:Object3d;
	public var skeleton:SkeletonD;
	public var modelMatrix:FastMatrix4;
	public var startModelMatrix:FastMatrix4;

	public var obj3d:Array<Object3d>;
	public var level:Array<Object3d>;
	public var water:Array<Object3d>;

	public var actorAngle:Float = 0.0;
	public var isDirUpdated:Bool = false;
	public var curDir:String = '';
	public var oldDir:String = '';

	public var actorMatrixAngle:Float = 0 - (Math.PI / 2);

//	public var bonesTransformations:haxe.ds.Vector<Float> = new haxe.ds.Vector(32);
	public var bonesTransformations:kha.arrays.Float32Array = new kha.arrays.Float32Array(32);

	public var currentFrame:Int = 1;
	public var timeElapsed:Float = 0;
	public var lastTime:Float = 0;
	public var velZ:Float = 0;
	
	public var shadowMap:Image;
	public var depthMap:Image;
	public var finalTarget:Image;
	public var blur:Image;

//---------------------------------------------------------------------------
// Scale
//---------------------------------------------------------------------------
	static inline var scale = 0.225;
	static inline var scaleCollisions = 0.0225;
	
	public var scaleMatrix:kha.math.FastMatrix4 = FastMatrix4.scale(scale,scale,scale);

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
// Shadow
//---------------------------------------------------------------------------
	
	public var biasMatrixTrans_00 = FastMatrix4.translation(0.5,0.5,0.5).multmat(FastMatrix4.scale(0.5,0.5,0.5));

//---------------------------------------------------------------------------
// UI
//---------------------------------------------------------------------------
	public var g2:kha.graphics2.Graphics;

	public var fontColor:kha.Color = kha.Color.White;
	public var loaded:Int = 0;		
	public var fontSize:Int = 64;
	public var loadStr:String = 'Loading... ';
	public var extractStr:String = 'Extracting Meshes... ';

	public var fps:FPStext = new FPStext();

//---------------------------------------------------------------------------


	public inline function start(): Void 
	{ 
//---------------------------------------------------------------------------
// FPS
//---------------------------------------------------------------------------
		fps.font = loadingFont;
		fps.fontSize = fontSize;
		fps.init();
		fps.x = Main.width - fps.xMargin;
//---------------------------------------------------------------------------
// Input
//---------------------------------------------------------------------------	
		input = new Input();

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
		
		level = MeshExtractor.extract(data, null);

//---------------------------------------------------------------------------
// Water setup
//---------------------------------------------------------------------------
	
		var dataWater = new OgexData(Assets.blobs.water_ogex.toString());
		water = MeshExtractor.extract(dataWater, null);

		trace("meshes loaded");
	
		shadowMap = Image.createRenderTarget(256,256,TextureFormat.DEPTH16);
		depthMap = Image.createRenderTarget(Main.width,Main.height,TextureFormat.DEPTH16);
		//depthMap.setDepthStencilFrom
		finalTarget = Image.createRenderTarget(Main.width,Main.height,TextureFormat.RGBA32,DepthStencilFormat.DepthOnly,2);
		//finalTarget.setDepthStencilFrom(depthMap);
		blur = Image.createRenderTarget(Std.int(Main.width/4),Std.int(Main.height/4),TextureFormat.RGBA32,DepthStencilFormat.DepthOnly,2);

			
		var collisionMesh = BtTriangleMesh.create(true, false);
		
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
			input.virtualGamepad.resize(width, height);
			//finalTarget.unload();
			//finalTarget = Image.createRenderTarget(width,height,TextureFormat.RGBA32,DepthStencilFormat.DepthOnly,2);
		}
	}
	public inline function update() 
	{
		fps.update();

		dynamicsWorld.stepSimulation(timeFPS);
		m = fallRigidBody.getMotionState();
		m.getWorldTransform(trans);

		vel = fallRigidBody.getLinearVelocity();
		
		if(dir.x != 0) { dir.x = 0; }
		if(dir.y != 0) { dir.y = 0; }

		modelMatrix._30 = cast pos.x() * 10;
		modelMatrix._31 = cast pos.y() * 10;
		modelMatrix._32 = cast pos.z() * 10;
		
		input.update();
	
		//dir.normalize()

		velZ = vel.y();

		fallVec3.setX(dir.x);
		//fallVec3.setY(vel.y());
		fallVec3.setY(velZ);		
		fallVec3.setZ(dir.y);

		fallRigidBody.setLinearVelocity(fallVec3);
		isDirUpdated = true;
	}


	public inline function render(frame:Framebuffer): Void 
	{	
		if(loaded >= 100) 
		{	
//---------------------------------------------------------------------------
// 	Time & frames
//---------------------------------------------------------------------------			

			time = Scheduler.realTime();
			timeElapsed  += time - lastTime;
			lastTime = time;

			if(timeElapsed > timeFPSdiv2) 
			{
				timeElapsed = 0;
				skeleton.setFrame(18+ ++currentFrame%15);
			}

			input.render();

			
//---------------------------------------------------------------------------
// 	Shape shadow
//---------------------------------------------------------------------------			
	
			lookVec3a.x = modelMatrix._30-200;
			lookVec3a.y = modelMatrix._31+400;
			lookVec3a.z = modelMatrix._32;
			lookVec3b.x = modelMatrix._30;
			lookVec3b.y = modelMatrix._31+25;
			lookVec3b.z = modelMatrix._32;


			cameraMatrix = FastMatrix4.lookAt
			(
				lookVec3a, 
				lookVec3b, 
				lookVec3z
			);
		

			projection = projection00;
			g = shadowMap.g4;

// /*
			for(mesh in obj3d)
			{
				g.begin();

				if(clear)
				{
					g.clear(Main.clearColor, Math.POSITIVE_INFINITY);
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

// */
			biasMatrix = biasMatrixTrans_00;
			biasMatrix = biasMatrix.multmat(projection).multmat(cameraMatrix);		

//---------------------------------------------------------------------------

			projection = projection01_window;
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

//---------------------------------------------------------------------------

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

		//	*/

//---------------------------------------------------------------------------

			//RenderTexture.renderTo(finalTarget,shadowMap,0,0,0.2,RenderTexture.Channel.Color,true);

			fps.totalFrames++;
			fps.draw(g2);
			g2.end();

			RenderTexture.renderTo(frame,finalTarget,0,0,1,RenderTexture.Channel.Color,true);

		}
		else if(fontLoaded)
		{
			if(loaded == 0) 
			{
				g2 = frame.g2;
				g2.font = loadingFont;
				g2.fontSize = fontSize;
				g2.color = fontColor;
			}
			//if(animI > loadAnim[0].length) { animI = 0; } else { animI++; }

			loaded = Std.int(Assets.progress * 100);
			g2.begin(true);	
			
			if(startExtracting) 
			{ 
				g2.drawString(loadStr + loaded +"%", (Main.width/2) - (loadStr.length + 6) * (g2.fontSize/6),(Main.height/2.5)-(g2.fontSize/2));
				g2.fontSize = Std.int(fontSize / 1.25);
				g2.drawString(extractStr, (Main.width/2) - (extractStr.length) * (g2.fontSize/6),(Main.height/2)-(g2.fontSize/2));
				g2.fontSize = fontSize;
			}
			else 
			{ 
				g2.drawString(loadStr + loaded +"%", (Main.width/2) - (loadStr.length + 6) * (g2.fontSize/6),(Main.height/2.5)-(g2.fontSize/2));
				//g2.drawString(loadAnim[animI], (Main.width/2) - (loadAnim[0].length) * (g2.fontSize),(Main.height/2)-(g2.fontSize/2)); 
			}
			g2.end();
		}		
	}
//---------------------------------------------------------------------------
//	Load & Start onLoad
//---------------------------------------------------------------------------

//var loadAnim = ['/','-','\"','|']; var animI = 0;
	
	var fontLoaded:Bool;
	var loadingFont:kha.Font;
	var loadingFontStr:String = 'mainfont';

	var startExtracting:Bool;
	
	public inline function onFontLoad(font:kha.Font):Void
	{
		loadingFont = font;
		fontLoaded = true;
		Assets.loadEverything(start);
	}

	//public inline function onLoad(blob:kha.Blob) { Assets.loadEverything(start); }

	public inline function new():Void 
	{ 
		Assets.loadFont(loadingFontStr,onFontLoad); 
	 //Assets.loadBlob("./dolpSS00.png",onLoad);
	}
}