#version 330 core

uniform sampler2D u_tex0;
uniform vec2 u_tex0Resolution;

uniform vec2 u_resolution;  // Canvas size (width,height) - dimensions of view port
uniform vec2 u_mouse;       // mouse position in screen pixels
uniform float u_time;       // Time in seconds since load


out vec4 fragmentColor;

void main(void)
{
    vec2 st = gl_FragCoord.xy/u_resolution.xy;

    vec4 color = texture(u_tex0, st);

    fragmentColor = color;
}
