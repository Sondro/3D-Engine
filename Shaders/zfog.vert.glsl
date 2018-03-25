#version 450

out float uFogDistance;  

out float vFogClampedDistance;   
out vec2 texCoord;

void kore() {
   if(uFogDistance >= 0.0) {                                        
      vFogClampedDistance = clamp(gl_Position.z, 0.0, uFogDistance); 
   }                                                              
}
