#version 450

uniform float uFogDistance = 0.5;  

out float vFogClampedDistance;   
out vec2 texCoord;

void kore() {
   //uFogDistance = 0.5; 
   if(uFogDistance >= 0.0) {                                        
      vFogClampedDistance = clamp(gl_Position.z, 0.0, uFogDistance); 
   }                                                              
}
