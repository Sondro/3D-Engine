package;
import OgexData.Node;
import kha.graphics4.Usage;
import kha.graphics4.IndexBuffer;
import kha.graphics4.VertexBuffer;
import kha.graphics4.VertexData;
import kha.graphics4.VertexStructure;
import kha.math.FastMatrix4;
import OgexData.GeometryNode;
import kha.Image;
import kha.Assets;


/**
 * ...
 * @author Joaquin
 */
class MeshExtractor
{
	static var structure:kha.graphics4.VertexStructure;

	static var result:Array<Object3d>;
	static var geometries:Array<OgexData.GeometryObject>;

/////////////////////////////////////////////////////

	static var vertices:Array<Float>;
	static var normals:Array<Float>;
	static var uv:Array<Float>;
	static var indices:Array<Int>;
	static var skin:OgexData.Skin;
	static var textureName:String;
	static var texture:Image;

	static var boneIndexs = new Array<Int>();
	static var boneWeight = new Array<Float>();
		
	static var counter:Int = 0;

	static var vertexBuffer:VertexBuffer;
	static var buffer:kha.arrays.Float32Array;

	static var indexBuffer:kha.graphics4.IndexBuffer;
	static var ibuffer:kha.arrays.Uint32Array;

	static var object3d:Object3d;
			
	static var bones:Array<Bone>;
	static var skeleton:OgexData.Skeleton;
	static var bonesNames:Array<String>;

	static var bone:Bone;

/////////////////////////////////////////////////////

	static var gNode:GeometryNode;
	static var material:OgexData.Material;
	static var path:String;
	static var parts:Array<String>;
	static var name:String;

/////////////////////////////////////////////////////

	public static inline function extract(aData:OgexData,aSkeletons:Array<SkeletonD>):Array<Object3d> 
	{
		/*
		 var structure:kha.graphics4.VertexStructure;

		 var result:Array<Object3d>;
		 var geometries:Array<OgexData.GeometryObject>;

/////////////////////////////////////////////////////

		 var vertices:Array<Float>;
		 var normals:Array<Float>;
		 var uv:Array<Float>;
		 var indices:Array<Int>;
		 var skin:OgexData.Skin;
		 var textureName:String;
		 var texture:Image;

		 var boneIndexs = new Array<Int>();
		 var boneWeight = new Array<Float>();
		
		 var counter:Int = 0;

		 var vertexBuffer:VertexBuffer;
		 var buffer:kha.arrays.Float32Array;

		 var indexBuffer:kha.graphics4.IndexBuffer;
		 var ibuffer:kha.arrays.Uint32Array;

		 var object3d:Object3d;
			
		 var bones:Array<Bone>;
		 var skeleton:OgexData.Skeleton;
		 var bonesNames:Array<String>;

		 var bone:Bone;

/////////////////////////////////////////////////////

		 var gNode:GeometryNode;
		 var material:OgexData.Material;
		 var path:String;
		 var parts:Array<String>;
		 var name:String;

/////////////////////////////////////////////////////
		
		//var skining:OgexData.Skin; //unused
	*/

		structure = new VertexStructure();
		structure.add('pos', VertexData.Float3);
		structure.add('normal', VertexData.Float3);
		structure.add('uv',VertexData.Float2);
		if(aSkeletons != null && aSkeletons.length != 0)
		{
			structure.add('weights',VertexData.Float4);
			structure.add('boneIndex',VertexData.Float4);
		}
		
		geometries = aData.geometryObjects;
		result = new Array<Object3d>();
		
		for(geomtry in geometries) 
		{
			vertices = geomtry.mesh.vertexArrays[0].values;
			normals = geomtry.mesh.vertexArrays[1].values;
			uv = geomtry.mesh.vertexArrays[2].values;
			indices = geomtry.mesh.indexArray.values;
			skin = geomtry.mesh.skin;
			textureName = null;
			for(child in aData.children)
			{
				 textureName = getTextureName(child,aData,geomtry.ref);
				 if(textureName!=null) { break; }
			}
			if(textureName == null || textureName == "")
			{
				continue;
			}
			texture = cast Reflect.field(Assets.images,textureName);
			if(texture != null) { texture.generateMipmaps(3); }

			boneIndexs=new Array<Int>();
			boneWeight=new Array<Float>();
			
			if(aSkeletons !=null && aSkeletons.length != 0)
			{
				counter=0;

				for(numAffectingBones in skin.boneCountArray.values)
				{
					for(i in 0...numAffectingBones)
					{
						boneIndexs.push(skin.boneIndexArray.values[counter+i]);
						boneWeight.push(skin.boneWeightArray.values[counter+i]);
					}
					counter+=numAffectingBones;
					if(numAffectingBones>4) { throw "implementation limited to 4 bones per vertex"; }
					for(i in numAffectingBones...4) //fill up to 4 bones per vertex
					{
						boneIndexs.push(0);
						boneWeight.push(0);
					}
				}
			}
			
			vertexBuffer = new VertexBuffer(vertices.length, structure, Usage.StaticUsage);
			buffer = vertexBuffer.lock();
			if(aSkeletons != null && aSkeletons.length != 0)
			{
				for (i in 0...Std.int(vertices.length / 3)) 
				{
					buffer.set(i * 16 + 0, vertices[i * 3 + 0]);
					buffer.set(i * 16 + 1, vertices[i * 3 + 1]);
					buffer.set(i * 16 + 2, vertices[i * 3 + 2]);
					buffer.set(i * 16 + 3, normals[i * 3 + 0]);
					buffer.set(i * 16 + 4, normals[i * 3 + 1]);
					buffer.set(i * 16 + 5, normals[i * 3 + 2]);
					buffer.set(i * 16 + 6, uv[i*2+0]);
					buffer.set(i * 16 + 7, 1-uv[i*2+1]);
					buffer.set(i * 16 + 8, boneWeight[i * 4 + 0]);
					buffer.set(i * 16 + 9, boneWeight[i * 4 + 1]);
					buffer.set(i * 16 + 10, boneWeight[i * 4 + 2]);
					buffer.set(i * 16 + 11, boneWeight[i * 4 + 3]);
					buffer.set(i * 16 + 12, boneIndexs[i * 4 + 0]);
					buffer.set(i * 16 + 13, boneIndexs[i * 4 + 1]);
					buffer.set(i * 16 + 14, boneIndexs[i * 4 + 2]);
					buffer.set(i * 16 + 15, boneIndexs[i * 4 + 3]);
				}
			}
			else
			{
				for (i in 0...Std.int(vertices.length / 3)) 
				{
					buffer.set(i * 8 + 0, vertices[i * 3 + 0]);
					buffer.set(i * 8 + 1, vertices[i * 3 + 1]);
					buffer.set(i * 8 + 2, vertices[i * 3 + 2]);
					buffer.set(i * 8 + 3, normals[i * 3 + 0]);
					buffer.set(i * 8 + 4, normals[i * 3 + 1]);
					buffer.set(i * 8 + 5, normals[i * 3 + 2]);
					buffer.set(i * 8 + 6, uv[i*2+0]);
					buffer.set(i * 8 + 7, 1-uv[i*2+1]);
				}
			}
			vertexBuffer.unlock();
			
			indexBuffer = new IndexBuffer(indices.length, Usage.StaticUsage);
			ibuffer = indexBuffer.lock();
			for (i in 0...indices.length) { ibuffer[i] = indices[i]; }
			indexBuffer.unlock();
			object3d = new Object3d();
			
			if(aSkeletons!=null&&aSkeletons.length!=0)
			{
				bones = new Array();
				skeleton = skin.skeleton;
				bonesNames = skeleton.boneRefArray.refs;
				for (name in bonesNames) 
				{
					for(sk in aSkeletons) 
					{
						bone = sk.getBone(name);
						if (bone != null) 
						{
							bones.push(bone);
							break;
						}
					}
				}
			
				if(bones.length != bonesNames.length) { throw "some skined bones not found `v('~')v´"; }
				for(i in 0...skeleton.transforms.length) 
				{
					bones[i].bindTransform = FastMatrix4.empty();
					Bone.matrixFromArray(skeleton.transforms[i].values, 0, bones[i].bindTransform);
				}
				
				//skining = new Skinning(bones);
				//object3d.skin = skining;
				object3d.skin = new Skinning(bones);
			}

			object3d.vertexBuffer = vertexBuffer;
			object3d.indexBuffer = indexBuffer;
				
			object3d.animated=(aSkeletons != null && aSkeletons.length != 0);
			object3d.texture = texture;
			result.push(object3d);
		}
		return result;
	}
	static function getTextureName(aNode:Node,aData:OgexData,aRef:String):String
	{
		if(Std.is(aNode,GeometryNode))
		{
			gNode = cast aNode;
			if(aRef == gNode.objectRefs[0])
			{
				material = aData.getMaterial(gNode.materialRefs[0]);
				if(material.texture.length == 0) { return ""; }
				path = material.texture[0].path;
				parts = path.split("/");
				return { parts[parts.length-1].split(".")[0]; }
			}
		}
		
		for(node in aNode.children)
		{
			name = getTextureName(node,aData,aRef);
			if( name != null ) return name;	
		}
		return null;
	}
}