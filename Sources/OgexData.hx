package;
import haxe.io.StringInput;
using StringTools;

// OpenGEX parser
// http://opengex.org

class Container 
{

	public var name:String;
	public var children:Array<Node> = [];

	public inline function new() {}
}

class OgexData extends Container 
{

	public var metrics:Array<Metric> = [];
	public var geometryObjects:Array<GeometryObject> = [];
	public var lightObjects:Array<LightObject> = [];
	public var cameraObjects:Array<CameraObject> = [];
	public var materials:Array<Material> = [];

	public var file:StringInput;

////////////////////////////////////////////////////////////
	public var strArr:Array<String> = [];
	public var str:String = '';
	public var str2:String = '';
	public var offset:Int = 0;

	public var metric:Metric;
	public var node:Node;
	public var geoObject:GeometryObject;

	public var key:Key;
	public var mesh:Mesh;
	
	public var skin:Skin;
	public var skel:Skeleton;
	public var boneRefArray:BoneRefArray;
	public var transArray:Array<Transform>;
	public var trans:Transform;

	public var boneCountArray:BoneCountArray;
	public var boneWeightArray:BoneWeightArray;
	public var boneIndexArray:BoneIndexArray;

	public var vertexArray:VertexArray;
	public var indexArray:IndexArray;

	public var lightObject:LightObject;
	public var color:Color;
	public var texture:Texture;

	public var atten:Atten;
	public var param:Param;
	public var cameraObject:CameraObject;
	public var material:Material;

	public var anim:Animation;
	public var track:Track;
	public var ogexTime:OgexTime;
	public var value:Value;
////////////////////////////////////////////////////////////

	public function new(data:String) 
	{
		super();
		file = new StringInput(data);

		try 
		{
			while (true) 
			{
				strArr = readLine();
				switch(strArr[0]) 
				{
					case "Metric":
						metrics.push(parseMetric(strArr));
					case "Node":
						children.push(parseNode(strArr, this));
					case "GeometryNode":
						children.push(parseGeometryNode(strArr, this));
					case "LightNode":
						children.push(parseLightNode(strArr, this));
					case "CameraNode":
						children.push(parseCameraNode(strArr, this));
					case "BoneNode":
						children.push(parseBoneNode(strArr, this));
					case "GeometryObject":
						geometryObjects.push(parseGeometryObject(strArr));
					case "LightObject":
						lightObjects.push(parseLightObject(strArr));
					case "CameraObject":
						cameraObjects.push(parseCameraObject(strArr));
					case "Material":
						materials.push(parseMaterial(strArr));
				}
			}
		}
		catch(ex:haxe.io.Eof) { }

		file.close();
	}

	public inline function getNode(name:String):Node { 
		traverseNodes(function(it:Node) { 
			if (it.name == name) { node = it; }
		});
		return node; 
	}
	public inline function getNodeBy(ref:String):Node { 
		traverseNodes(function(it:Node) { 
			if (it.ref == ref) { node = it; }
		});
		return node; 
	}

	public inline function traverseNodes(callback:Node->Void) {
		for (i in 0...children.length) {
			traverseNodesStep(children[i], callback);
		}
	}
	
	inline function traverseNodesStep(node:Node, callback:Node->Void) {
		callback(node);
		for (i in 0...node.children.length) {
			traverseNodesStep(node.children[i], callback);
		}
	}

	public inline function getGeometryObject(ref:String):GeometryObject {
		for (go in geometryObjects) {
			if (go.ref == ref) return go;
		}
		return null;
	}

	public inline function getCameraObject(ref:String):CameraObject {
		for (co in cameraObjects) {
			if (co.ref == ref) return co;
		}
		return null;
	}

	public inline function getLightObject(ref:String):LightObject {
		for (lo in lightObjects) {
			if (lo.ref == ref) return lo;
		}
		return null;
	}

	public function getMaterial(ref:String):Material {
		for (m in materials) {
			if (m.ref == ref) { return m; }
		}
		return null;
	}

	// Parsing
	inline function readLine():Array<String> {
		str = file.readLine();
		str = StringTools.trim(str);
		strArr = str.split(" ");
		return strArr;
	}

	inline function readLine2():String {
		str = file.readLine();
		str = StringTools.trim(str);
		return str;
	}

	inline function parseMetric(strArr:Array<String>):Metric {
		metric = new Metric();
		metric.key = strArr[3].split('"')[1];
		str = strArr[5].split("{")[1].split("}")[0];
		if (strArr[4] == "{float") {
			metric.value = Std.parseFloat(str);
		}
		else {
			metric.value = str.split('"')[1];
		}
		return metric;
	}

	inline function parseNode(strArr:Array<String>, parent:Container):Node {
		var n = new Node();
		n.parent = parent;
		n.ref = strArr[1];

		while (true) {
			strArr = readLine();

			switch(strArr[0]) {
				case "Name":
					n.name = parseName(strArr);
				case "Transform":
					n.transform = parseTransform(strArr);
				case "Node":
					n.children.push(parseNode(strArr, n));
				case "GeometryNode":
					n.children.push(parseGeometryNode(strArr, n));
				case "LightNode":
					n.children.push(parseLightNode(strArr, n));
				case "CameraNode":
					n.children.push(parseCameraNode(strArr, n));
				case "BoneNode":
					n.children.push(parseBoneNode(strArr, n));
				case "}":
					break;
			}
		}
		return n;
	}

	inline function parseGeometryNode(strArr:Array<String>, parent:Container):GeometryNode {
		var n = new GeometryNode();
		n.parent = parent;
		n.ref = strArr[1];

		while (true) {
			strArr = readLine();

			switch(strArr[0]) {
				case "Name":
					n.name = parseName(strArr);
				case "ObjectRef":
					n.objectRefs.push(parseObjectRef(strArr));
				case "MaterialRef":
					n.materialRefs.push(parseMaterialRef(strArr));
				case "Transform":
					n.transform = parseTransform(strArr);
				case "Node":
					n.children.push(parseNode(strArr, n));
				case "GeometryNode":
					n.children.push(parseGeometryNode(strArr, n));
				case "LightNode":
					n.children.push(parseLightNode(strArr, n));
				case "CameraNode":
					n.children.push(parseCameraNode(strArr, n));
				case "BoneNode":
					n.children.push(parseBoneNode(strArr, n));
				case "}":
					break;
			}
		}
		return n;
	}

	inline function parseLightNode(strArr:Array<String>, parent:Container):LightNode {
		var n = new LightNode();
		n.parent = parent;
		n.ref = strArr[1];

		while (true) {
			strArr = readLine();

			switch(strArr[0]) {
				case "Name":
					n.name = parseName(strArr);
				case "ObjectRef":
					n.objectRefs.push(parseObjectRef(strArr));
				case "Transform":
					n.transform = parseTransform(strArr);
				case "Node":
					n.children.push(parseNode(strArr, n));
				case "GeometryNode":
					n.children.push(parseGeometryNode(strArr, n));
				case "LightNode":
					n.children.push(parseLightNode(strArr, n));
				case "CameraNode":
					n.children.push(parseCameraNode(strArr, n));
				case "BoneNode":
					n.children.push(parseBoneNode(strArr, n));
				case "}":
					break;
			}
		}
		return n;
	}

	inline function parseCameraNode(strArr:Array<String>, parent:Container):CameraNode {
		var n = new CameraNode();
		n.parent = parent;
		n.ref = strArr[1];

		while (true) {
			strArr = readLine();

			switch(strArr[0]) {
				case "Name":
					n.name = parseName(strArr);
				case "ObjectRef":
					n.objectRefs.push(parseObjectRef(strArr));
				case "Transform":
					n.transform = parseTransform(strArr);
				case "Node":
					n.children.push(parseNode(strArr, n));
				case "GeometryNode":
					n.children.push(parseGeometryNode(strArr, n));
				case "LightNode":
					n.children.push(parseLightNode(strArr, n));
				case "CameraNode":
					n.children.push(parseCameraNode(strArr, n));
				case "BoneNode":
					n.children.push(parseBoneNode(strArr, n));
				case "}":
					break;
			}
		}
		return n;
	}

	inline function parseBoneNode(strArr:Array<String>, parent:Container):BoneNode {
		var n = new BoneNode();
		n.parent = parent;
		n.ref = strArr[1];

		while (true) {
			strArr = readLine();

			switch(strArr[0]) {
				case "Name":
					n.name = parseName(strArr);
				case "Transform":
					n.transform = parseTransform(strArr);
				case "BoneNode":
					n.children.push(parseBoneNode(strArr, n));
				case "Animation":
					n.animation = parseAnimation(strArr);
				case "}":
					break;
			}
		}
		return n;
	}

	function parseGeometryObject(strArr:Array<String>):GeometryObject {
		geoObject = new GeometryObject();
		geoObject.ref = strArr[1].split("\t")[0];
		while (true) {
			strArr = readLine();

			switch(strArr[0]) {
				case "Mesh":
					geoObject.mesh = parseMesh(strArr);
				case "}":
					break;
			}
		}
		return geoObject;
	}

	inline function parseMesh(strArr:Array<String>):Mesh {
		mesh = new Mesh();
		mesh.primitive = strArr[3].split('"')[1];
		while (true) {
			strArr = readLine();

			switch(strArr[0]) {
				case "VertexArray":
					mesh.vertexArrays.push(parseVertexArray(strArr));
				case "IndexArray":
					mesh.indexArray = parseIndexArray(strArr);
				case "Skin":
					mesh.skin = parseSkin(strArr);
				case "}":
					break;
			}
		}
		return mesh;
	}

	inline function parseSkin(strArr:Array<String>):Skin {
		skin = new Skin();
		while (true) {
			strArr = readLine();

			switch(strArr[0]) {
				case "Transform":
					skin.transform = parseTransform(strArr);
				case "Skeleton":
					skin.skeleton = parseSkeleton(strArr);
				case "BoneCountArray":
					skin.boneCountArray = parseBoneCountArray(strArr);
				case "BoneIndexArray":
					skin.boneIndexArray = parseBoneIndexArray(strArr);
				case "BoneWeightArray":
					skin.boneWeightArray = parseBoneWeightArray(strArr);
				case "}":
					break;
			}
		}
		return skin;
	}

	inline function parseSkeleton(strArr:Array<String>):Skeleton {
		skel = new Skeleton();
		while (true) {
			strArr = readLine();

			switch(strArr[0]) {
				case "BoneRefArray":
					skel.boneRefArray = parseBoneRefArray(strArr);
				case "Transform":
					skel.transforms = parseTransformArray(strArr);
				case "}":
					break;
			}
		}
		return skel;
	}

	inline function parseBoneRefArray(strArr:Array<String>):BoneRefArray {
		boneRefArray = new BoneRefArray();
		readLine2(); readLine2(); readLine2();
		str = readLine2();
		str = StringTools.replace(str, " ", "");
		boneRefArray.refs = str.split(",");
		readLine2(); readLine2();
		return boneRefArray;
	}

	inline function parseTransformArray(strArr:Array<String>):Array<Transform> {
		transArray = new Array<Transform>();
		readLine2(); readLine2(); readLine2();
		while (true) {
			trans = new Transform();
			str = readLine2();
			str = StringTools.replace(str, "{", "");
			str = StringTools.replace(str, "}", "");
			strArr = str.split(",");
			offset = strArr[strArr.length - 1] == "" ? 1 : 0;
			for (i in 0...strArr.length - offset) trans.values.push(Std.parseFloat(strArr[i]));
			transArray.push(trans);
			if (offset == 0) { break; }
		}
		readLine2(); readLine2();
		return transArray;
	}

	inline function parseBoneCountArray(strArr:Array<String>):BoneCountArray {
		boneCountArray = new BoneCountArray();
		readLine2(); readLine2(); readLine2();
		while (true) 
		{
			str = readLine2();
			str = StringTools.replace(str, " ", "");
			strArr = str.split(",");
			offset = strArr[strArr.length - 1] == "" ? 1 : 0;
			for (i in 0...strArr.length - offset) { boneCountArray.values.push(Std.parseInt(strArr[i])); }
			if (offset == 0) { break; }
		}
		readLine2(); readLine2();
		return boneCountArray;
	}

	inline function parseBoneIndexArray(strArr:Array<String>):BoneIndexArray {
		boneIndexArray = new BoneIndexArray();
		readLine2(); readLine2(); readLine2();
		while (true) 
		{
			str = readLine2();
			str = StringTools.replace(str, " ", "");
			strArr = str.split(",");
			offset = strArr[strArr.length - 1] == "" ? 1 : 0;
			for (i in 0...strArr.length - offset) { boneIndexArray.values.push(Std.parseInt(strArr[i])); }
			if (offset == 0) { break; }
		}
		readLine2(); readLine2();
		return boneIndexArray;
	}

	inline function parseBoneWeightArray(strArr:Array<String>):BoneWeightArray {
		boneWeightArray = new BoneWeightArray();
		readLine2(); readLine2(); readLine2();
		while (true) 
		{
			str = readLine2();
			str = StringTools.replace(str, " ", "");
			strArr = str.split(",");
			offset = strArr[strArr.length - 1] == "" ? 1 : 0;
			for (i in 0...strArr.length - offset) { boneWeightArray.values.push(Std.parseFloat(strArr[i])); }
			if (offset == 0) { break; }
		}
		readLine2(); readLine2();
		return boneWeightArray;
	}

	inline function parseVertexArray(strArr:Array<String>):VertexArray {
		vertexArray = new VertexArray();
		vertexArray.attrib = strArr[3].split('"')[1];
		readLine2();
		str = readLine2();
		vertexArray.size = Std.parseInt(str.split("[")[1].split("]")[0]);
		readLine2();
		
		while (true) 
		{
			// TODO: unify float[] {} parsing
			str = readLine2();
			str = StringTools.replace(str, "{", "");
			str = StringTools.replace(str, "}", "");
			strArr = str.split(",");
			offset = strArr[strArr.length - 1] == "" ? 1 : 0;
			for (i in 0...strArr.length - offset) { vertexArray.values.push(Std.parseFloat(strArr[i])); }
			if (offset == 0) { break; }
		}
		readLine2(); readLine2();
		return vertexArray;
	}

	inline function parseIndexArray(strArr:Array<String>):IndexArray {
		indexArray = new IndexArray();
		readLine2();
		str = readLine2();
		indexArray.size = Std.parseInt(str.split("[")[1].split("]")[0]);
		readLine2();
		while (true) 
		{
			str = readLine2();
			str = StringTools.replace(str, "{", "");
			str = StringTools.replace(str, "}", "");
			strArr = str.split(",");
			offset = strArr[strArr.length - 1] == "" ? 1 : 0;
			for (i in 0...strArr.length - offset) { indexArray.values.push(Std.parseInt(strArr[i])); }
			if (offset == 0) break;
		}
		readLine2(); readLine2();
		return indexArray;
	}

	inline function parseLightObject(strArr:Array<String>):LightObject 
	{
		lightObject = new LightObject();
		lightObject.ref = strArr[1];
		lightObject.type = strArr[4].split('"')[1];
		while (true) 
		{
			strArr = readLine();

			switch(strArr[0]) 
			{
				case "Color":
					lightObject.color = parseColor(strArr);
				case "Atten":
					lightObject.atten = parseAtten(strArr);
				case "}":
					break;
			}
		}
		return lightObject;
	}

	inline function parseColor(strArr:Array<String>):Color 
	{
		color = new Color();
		color.attrib = strArr[3].split('"')[1];
		for (i in 5...strArr.length) 
		{
			str = strArr[i];
			str = StringTools.replace(str, "{", "");
			str = StringTools.replace(str, "}", "");
			str = StringTools.replace(str, ",", "");
			color.values.push(Std.parseFloat(str));
		}
		return color;
	}
	inline function parseTexture(strArr:Array<String>):Texture 
	{
		texture = new Texture();
		texture.attrib = strArr[3].split('"')[1];
		readLine();
		strArr = readLine();
		str = strArr[1];
		str = StringTools.replace(str, "{", "");
		str = StringTools.replace(str, "}", "");
		str = StringTools.replace(str, "\"", "");
		texture.path=str;
		
		return texture;
	}

	inline function parseAtten(strArr:Array<String>):Atten 
	{
		atten = new Atten();
		atten.curve = strArr[3].split('"')[1];
		while(true) 
		{
			strArr = readLine();

			switch(strArr[0]) 
			{
				case "Param":
					atten.params.push(parseParam(strArr));
				case "}":
					break;
			}
		}
		return atten;
	}

	inline function parseParam(strArr:Array<String>):Param 
	{
		param = new Param();
		param.attrib = strArr[3].split('"')[1];
		str = strArr[5];
		str = StringTools.replace(str, "{", "");
		str = StringTools.replace(str, "}", "");
		param.value = Std.parseFloat(str);
		return param;
	}

	inline function parseCameraObject(strArr:Array<String>):CameraObject 
	{
		cameraObject = new CameraObject();
		cameraObject.ref = strArr[1].split("\t")[0];
		while (true) 
		{
			strArr = readLine();
			switch(strArr[0]) 
			{
				case "Param":
					cameraObject.params.push(parseParam(strArr));
				case "}":
					break;
			}
		}
		return cameraObject;
	}

	inline function parseMaterial(strArr:Array<String>):Material 
	{
		material = new Material();
		material.ref = strArr[1];
		while (true) {
			strArr = readLine();

			switch(strArr[0]) {
				case "Name":
					material.name = parseName(strArr);
				case "Color":
					material.colors.push(parseColor(strArr));
				case "Texture":
					material.texture.push(parseTexture(strArr));
				case "Param":
					material.params.push(parseParam(strArr));
				case "}":
					break;
			}
		}
		return material;
	}

	inline function parseName(strArr:Array<String>):String {
		return strArr[2].split('"')[1];
	}

	inline function parseObjectRef(strArr:Array<String>):String {
		return strArr[2].split("}")[0].substr(1);
	}

	inline function parseMaterialRef(strArr:Array<String>):String {
		return strArr[5].split("}")[0].substr(1);
	}

	inline function parseTransform(strArr:Array<String>):Transform {
		// TODO: Correct value parsing
		trans = new Transform();
		if (strArr.length > 1) { trans.ref = strArr[1]; }
		readLine2(); readLine2(); readLine2();
		str = readLine2().substr(1);
		str += readLine2();
		str += readLine2();
		var str2 = readLine2();
		str += str2.substr(0, str2.length - 2);
		strArr = str.split(",");
		for (i in 0...strArr.length) 
		{
			var j = Std.int(i / 4);
			var k = i % 4;
			trans.values.push(Std.parseFloat(strArr[j + k * 4]));
		}
		readLine2(); readLine2();
		return trans;
	}

	inline function parseAnimation(strArr:Array<String>):Animation 
	{
		anim = new Animation();
		while (true) 
		{
			strArr = readLine();
			switch(strArr[0]) {
				case "Track":
					anim.track = parseTrack(strArr);
				case "}":
					break;
			}
		}
		return anim;
	}

	inline function parseTrack(strArr:Array<String>):Track 
	{
		track = new Track();
		track.target = strArr[3].substr(0, strArr[3].length - 2);
		while (true) 
		{
			strArr = readLine();
			switch(strArr[0]) 
			{
				case "Time":
					track.time = parseTime(strArr);
				case "Value":
					track.value = parseValue(strArr);
				case "}":
					break;
			}
		}
		return track;
	}

	inline function parseTime(strArr:Array<String>):OgexTime 
	{
		ogexTime = new OgexTime();
		while (true) 
		{
			strArr = readLine();

			switch(strArr[0]) 
			{
				case "Key":
					ogexTime.key = parseKey(strArr);
				case "}":
					break;
			}
		}
		return ogexTime;
	}

	inline function parseValue(strArr:Array<String>):Value 
	{
		value = new Value();
		while (true) 
		{
			strArr = readLine();
			switch(strArr[0]) 
			{
				case "Key":
					value.key = parseKey(strArr);
				case "}":
					break;
			}
		}
		return value;
	}

	inline function parseKey(strArr:Array<String>):Key 
	{
		key = new Key();
		if (strArr.length > 2) 
		{ // One str
			key.values.push(Std.parseFloat(strArr[2].substr(1)));
			for (i in 3...strArr.length - 2) 
			{
				key.values.push(Std.parseFloat(strArr[i]));
			}
			key.values.push(Std.parseFloat(strArr[strArr.length - 1].substr(0, strArr[strArr.length - 1].length - 3)));
		}
		else 
		{ // Multi str
			readLine2(); readLine2(); readLine2();
			while (true) 
			{
				str = readLine2();
				str = StringTools.replace(str, "{", "");
				str = StringTools.replace(str, "}", "");
				strArr = str.split(",");
				offset = strArr[strArr.length - 1] == "" ? 1 : 0;
				for (i in 0...strArr.length - offset) { key.values.push(Std.parseFloat(strArr[i])); }
				if (offset == 0) { break; }
			}
			readLine2();readLine2();
		}
		return key;
	}
}

class Metric {

	public var key:String;
	public var value:Dynamic;

	public inline function new() {}
}

class Node extends Container {

	public var parent:Container;
	public var ref:String;
	public var objectRefs:Array<String> = [];
	public var transform:Transform;

	public inline function new() { super(); }
}

class GeometryNode extends Node {

	public var materialRefs:Array<String> = [];

	public inline function new() { super(); }
}

class LightNode extends Node {

	public inline function new() { super(); }
}

class CameraNode extends Node {

	public inline function new() { super(); }
}

class BoneNode extends Node {

	public var animation:Animation;

	public inline function new() { super(); }
}

class GeometryObject {

	public var ref:String;
	public var mesh:Mesh;

	public inline function new() {}
}

class LightObject {

	public var ref:String;
	public var type:String;
	public var color:Color;
	public var atten:Atten;

	public inline function new() {}
}

class CameraObject {

	public var ref:String;
	public var params:Array<Param> = [];

	public inline function new() {}
}

class Material {

	public var ref:String;
	public var name:String;
	public var colors:Array<Color> = [];
	public var texture:Array<Texture>=[];
	public var params:Array<Param> = [];

	public inline function new() {}
}
class Texture
{
	public var attrib:String;
	public var path:String = "";

	public inline function new() {}
}

class Transform {

	public var ref:String = "";
	public var values:Array<Float> = [];

	public inline function new() {}
}

class Mesh {

	public var primitive:String;
	public var vertexArrays:Array<VertexArray> = [];
	public var indexArray:IndexArray;
	public var skin:Skin;

	public inline function new() {}

	public inline function getArray(attrib:String):VertexArray {
		for (va in vertexArrays) 
		{
			if (va.attrib == attrib) { return va; }
		}
		return null;
	}
}

class Skin {

	public var transform:Transform;
	public var skeleton:Skeleton;
	public var boneCountArray:BoneCountArray;
	public var boneIndexArray:BoneIndexArray;
	public var boneWeightArray:BoneWeightArray;

	public inline function new() {}
}

class Skeleton {

	public var boneRefArray:BoneRefArray;
	public var transforms:Array<Transform>;

	public inline function new() {}
}

class BoneRefArray {

	public var refs:Array<String> = [];

	public inline function new() {}
}

class BoneCountArray {

	public var values:Array<Int> = [];

	public inline function new() {}
}

class BoneIndexArray {

	public var values:Array<Int> = [];

	public inline function new() {}
}

class BoneWeightArray {

	public var values:Array<Float> = [];

	public inline function new() {}
}

class VertexArray {

	public var attrib:String;
	public var size:Int;
	public var values:Array<Float> = [];

	public inline function new() {}
}

class IndexArray {

	public var size:Int;
	public var values:Array<Int> = [];

	public inline function new() {}
}

class Color {

	public var attrib:String;
	public var values:Array<Float> = [];

	public inline function new() {}
}

class Atten {

	public var curve:String;
	public var params:Array<Param> = [];

	public inline function new() {}
}

class Param {

	public var attrib:String;
	public var value:Float;

	public inline function new() {}
}

class Animation {

	public var track:Track;
	public var target:String;

	public inline function new() {}
}

class Track {

	public var target:String;
	public var time:OgexTime;
	public var value:Value;

	public inline function new() {}
}

class OgexTime {

	public var key:Key;

	public inline function new() {}
}

class Value {

	public var key:Key;

	public inline function new() {}
}

class Key {

	public var size = 0;
	public var values:Array<Float> = [];

	public inline function new() {}
}
