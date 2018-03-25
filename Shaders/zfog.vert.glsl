#version 450

float uFogDistance;       
float vFogClampedDistance;   
out vec2 texCoord;

void kore() {
   if(uFogDistance >= 0.0) {                                        
      vFogClampedDistance = clamp(gl_Position.z, 0.0, uFogDistance); 
   }                                                              
}
