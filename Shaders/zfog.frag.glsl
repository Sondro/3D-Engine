#version 450
uniform sampler2D tex;

float uFogDistance;
float vFogClampedDistance;   
vec4 textureColor;
vec4 color;

in vec2 texCoord;

//out vec2 texCoord;

void kore() {

   textureColor = texture(tex, vec2(texCoord.s, texCoord.t));       

   if (uFogDistance == 0.0) {                                                                   
      //color = ...use only lighting, not fog
   }                               
   else {                          
      //color = mix(final_color, vec4(0.5,0.5,0.5,1.0), vFogClampedDistance/uFogDistance) * vec4(1.0,1.0,1.0,textureColor.a);  
   }  
}
