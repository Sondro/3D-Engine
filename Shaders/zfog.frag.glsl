#version 450
uniform sampler2D tex;

uniform float uFogDistance = 0.5;  
in float vFogClampedDistance;   

vec4 textureColor;

in vec2 texCoord;

out vec4 color;

void kore() {

   textureColor = texture(tex, texCoord);       
   color = mix(vec4(0.35,0.335,0.35,1.0), vec4(0.5,0.5,0.5,1.0), vec4(1.0,1.0,1.0,0.5));  
/*
   if (uFogDistance != 0.0) {                                                                   
      //color = ...use only lighting, not fog
   }                               
   else {                          
      color = mix(textureColor, vec4(0.5,0.5,0.5,1.0), vFogClampedDistance/uFogDistance) * vec4(1.0,1.0,1.0,textureColor.a);  
   }  
*/
}
