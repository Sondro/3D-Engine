package;

import OgexData.BoneNode;
import OgexData.Node;
/**
 * ...
 * @author Joaquin
 */
class SkeletonLoader
{
	public var skeletons:Array<SkeletonD>;
	
	public static var skeleton:SkeletonD = null;
	public static var boneNode:BoneNode;
	public static var bone:Bone;

	public static inline function getSkeleton(data:OgexData):Array<SkeletonD> 
	{
		var skeletons = new Array();
		for(child in data.children)
		{
			findSkeleton(child, skeletons, null);
		}
		return skeletons;
	}
	static inline function findSkeleton(aNode:Node,skeletons:Array<SkeletonD>,current:Bone)
	{
		skeleton = null;
		for (node in aNode.children) 
		{
			if (Std.is(node, BoneNode))
			{
				boneNode = cast node;
				if (skeleton == null && current == null) {
					skeleton = new SkeletonD();
					skeleton.ID = aNode.ref;
					skeletons.push(skeleton);
				}
				bone = createBone(boneNode);
				if (current != null)
				{
					current.addChild(bone);
				}else {
					skeleton.bones.push(bone);
				}
				findSkeleton(boneNode, skeletons, bone);
			}
		}
	}
	
	static private inline function createBone(boneNode:BoneNode) :Bone
	{
		var bone:Bone = new Bone();
		bone.id = boneNode.ref;
		if(boneNode.animation!=null)
		{
			bone.animated=true;
			bone.animations = boneNode.animation.track.value.key.values;
		}else{
			bone.animated=false;
		//	bone.animations = boneNode.transform.values;

		}
		return bone;
	}
	
}