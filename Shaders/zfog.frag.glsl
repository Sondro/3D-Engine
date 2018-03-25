#version 450
uniform sampler2D tex;

in float uFogDistance;
in float vFogClampedDistance;   

vec4 textureColor;
vec4 color;

in vec2 texCoord;

//out vec2 texCoord;

void kore() {

   textureColor = texture(tex, texCoord);       

   if (uFogDistance == 0.0) {                                                                   
      //color = ...use only lighting, not fog
   }                               
   else {                          
      color = mix(textureColor, vec4(0.5,0.5,0.5,1.0), vFogClampedDistance/uFogDistance) * vec4(1.0,1.0,1.0,textureColor.a);  
   }  
}
