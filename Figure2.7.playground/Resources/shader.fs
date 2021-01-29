#version 330 core

uniform vec2 u_resolution;  // Canvas size (width,height) - dimensions of view port
uniform vec2 u_mouse;       // mouse position in screen pixels
uniform float u_time;       // Time in seconds since load


out vec4 fragmentColor;

void main(void)
{
    fragmentColor = vec4(abs(sin(u_time)),0.0,0.0,1.0);
}
