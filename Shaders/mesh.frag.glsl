#version 450

precision mediump float;

uniform sampler2D tex;
in vec3 norm;
in vec2 texCoord;

out vec4 color;

vec4 texcolor;
vec3 lightdir = vec3(-0.2, 0.5, -0.3);

void kore() {
	texcolor = texture(tex, texCoord.xy);
	color = texcolor * vec4(dot(norm, lightdir) * vec3(1.0, 1.0, 1.0) + vec3(0.75), 1.0);
}
