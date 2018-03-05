package;
import kha.Assets;
import kha.Canvas;
import kha.Image;
import kha.Shaders;
import kha.graphics4.CompareMode;
import kha.graphics4.IndexBuffer;
import kha.graphics4.PipelineState;
import kha.graphics4.TextureUnit;
import kha.graphics4.Usage;
import kha.graphics4.VertexBuffer;
import kha.graphics4.VertexData;
import kha.graphics4.VertexStructure;
import kha.math.FastMatrix4;

/**
 * ...
 * @author Joaquin
 */
enum Chanel {
	Color;
	Depth;
}
class RenderTexture
{
	static var initialized:Bool = false;
	static var colorPipline:PipelineState = new PipelineState();
	static var depthPipline:PipelineState = new PipelineState();
	static var textureColorPos:TextureUnit;
	static var textureDepthPos:TextureUnit;
	static var transformColorPos:kha.graphics4.ConstantLocation;
	static var transformDepthPos:kha.graphics4.ConstantLocation;

	static var projection:FastMatrix4;
	static var projection_ortho00:FastMatrix4 = FastMatrix4.orthogonalProjection(0, Main.width, Main.height, 0, -2, 1000);
	static var projection_ortho01:FastMatrix4 = FastMatrix4.orthogonalProjection(0, Main.width, 0, Main.height, -2, 1000);

	public static var structure:VertexStructure;
	public static var vertexes:kha.arrays.Float32Array;
	public static var indexes:kha.arrays.Uint32Array;

	public static var g:kha.graphics4.Graphics;	
	
	//static var vertexBuffer:VertexBuffer;
	//static var indexBuffer:IndexBuffer;

	static var vertexBuffer:VertexBuffer = new VertexBuffer(4, structure, Usage.StaticUsage);
	static var indexBuffer:IndexBuffer = new IndexBuffer(6, Usage.StaticUsage);

	public static var vertices:kha.arrays.Float32Array;
	public static var indices:kha.arrays.Uint32Array;

	public static inline function updateProjections():Void 
	{
		projection_ortho00 = FastMatrix4.orthogonalProjection(0, Main.width, Main.height, 0, -2, 1000);
		projection_ortho01 = FastMatrix4.orthogonalProjection(0, Main.width, 0, Main.height, -2, 1000);
	}
	
	public static inline function renderTo(aTarget:Canvas,aImage:Image, aX:Float, aY:Float, aScale:Float,aChanel:Chanel,aClear:Bool)
	{
		if (!initialized)
		{
			structure = new VertexStructure();
			structure.add("pos", VertexData.Float3);
			structure.add("uv", VertexData.Float2);
			
			//colorPipline = new PipelineState();
			colorPipline.inputLayout = [structure];
			colorPipline.vertexShader = Shaders.texture_vert;
			colorPipline.fragmentShader = Shaders.textureColor_frag;

			colorPipline.compile();
			textureColorPos = colorPipline.getTextureUnit("tex");
			transformColorPos=colorPipline.getConstantLocation("mvp");
			
			//depthPipline = new PipelineState();
			depthPipline.inputLayout = [structure];
			depthPipline.vertexShader = Shaders.texture_vert;
			depthPipline.fragmentShader = Shaders.textureDepth_frag;
		
			depthPipline.compile();
			textureDepthPos = depthPipline.getTextureUnit("tex");
			transformDepthPos=depthPipline.getConstantLocation("mvp");
			//vertexBuffer = new VertexBuffer(4, structure, Usage.StaticUsage);
			//indexBuffer = new IndexBuffer(6, Usage.StaticUsage);
			
			vertexes = vertexBuffer.lock();
    	for (i in 0...vertexes.length) { vertexes.set(i, vertexes[i]); }
    	vertexBuffer.unlock();

			indexes = indexBuffer.lock();
    	for (i in 0...indexes.length) { indexes[i] = indexes[i]; }
    	
			indexBuffer.unlock();	

			indexes = indexBuffer.lock();
			indexes.set(0, 0);
			indexes.set(1, 1);
			indexes.set(2, 2);
			indexes.set(3, 1);
			indexes.set(4, 3);
			indexes.set(5, 2);
			indexBuffer.unlock();
			
			if (aTarget.g4.renderTargetsInvertedY()) 
			{
				projection = projection_ortho00;
			} else {
				projection = projection_ortho01;
			}
		}
		
		vertexes = vertexBuffer.lock();
		vertexes.set(0, aX);
		vertexes.set(1, aY);
		vertexes.set(2, 1);
		vertexes.set(3, 0);
		vertexes.set(4, 1);
		
		vertexes.set(5, aX+aImage.width*aScale);
		vertexes.set(6, aY);
		vertexes.set(7, 1);
		vertexes.set(8, 1);
		vertexes.set(9, 1);
		
		vertexes.set(10, aX);
		vertexes.set(11, aY+aImage.height*aScale);
		vertexes.set(12, 1);
		vertexes.set(13, 0);
		vertexes.set(14, 0);
		
		vertexes.set(15, aX+aImage.width*aScale);
		vertexes.set(16, aY+aImage.height*aScale);
		vertexes.set(17, 1);
		vertexes.set(18, 1);
		vertexes.set(19, 0);
		
		vertexBuffer.unlock();
		
		g = aTarget.g4;
		
		
		g.begin();
		if(aClear) g.clear();
		g.setVertexBuffer(vertexBuffer);
		g.setIndexBuffer(indexBuffer);
		if(aChanel==Chanel.Color){
			g.setPipeline(colorPipline);
			g.setTexture(textureColorPos, aImage);
			g.setMatrix(transformColorPos,projection);
		}else {
			g.setPipeline(depthPipline);
			g.setTexture(textureDepthPos, aImage);
			g.setMatrix(transformDepthPos,projection);
		}
		g.drawIndexedVertices();
		g.end();
	}
	
}