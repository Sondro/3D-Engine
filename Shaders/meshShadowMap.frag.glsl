#version 450

precision mediump float;

uniform sampler2D tex;
uniform sampler2D shadowMap;
in vec3 norm;
in vec2 texCoord;
in vec4 shadowCoord;
out vec4 color;

vec4 texcolor;
vec3 lightdir;
float visibility = 1.0;
float z;

void kore() {
	texcolor = texture(tex, texCoord.xy);
	lightdir = vec3(-0.2, 0.5, -0.3);
	if(visibility != 1.0) { 
		visibility = 1.0; 
	}
	if(shadowCoord.x>0 && shadowCoord.x<1 && shadowCoord.y>0 && shadowCoord.y<1) {
		z = texture(shadowMap, shadowCoord.xy).r;
		if(z <  shadowCoord.z) {
			visibility = z + 0.1 * (1.-z);
		}
	}
	color = texcolor * vec4(dot(norm, lightdir) * vec3(1.0, 1.0, 1.0) + vec3(0.7 * visibility), 1.0);
	
}
