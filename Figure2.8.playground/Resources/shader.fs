#version 330 core

uniform vec2 u_resolution;  // Canvas size (width,height) - dimensions of view port
uniform vec2 u_mouse;       // mouse position in screen pixels
uniform float u_time;       // Time in seconds since load


out vec4 fragmentColor;

void main(void)
{
    vec2 st = gl_FragCoord.xy/u_resolution;
    fragmentColor = vec4(st, 0.0, 1.0);
}
