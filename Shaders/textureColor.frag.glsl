#version 450

precision mediump float;

uniform sampler2D tex;
in vec2 texCoord;
out vec4 color;

vec4 texcolor;

void kore() {
	texcolor = texture(tex, texCoord.xy);
	color = texcolor;
}
