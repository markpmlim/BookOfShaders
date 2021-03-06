These OpenGL playgrounds are written to support the fragment shaders that are listed in the book “Book of Shaders”

Rationale for this project:

As mentioned in the book, there are a number of environments that uses OpenGL, OpenGL ES or WebGL. Among the environments mentioned are Processing, openFrameworks and Cinder and Three.js

For macOS/iOS programmers, XCode playgrounds is another alternative. The playground feature of the Xcode IDE supports programs which can run shaders written in Apple's MSL (Metal Shading Language) as well as GLSL (OpenGL Shading Language) shaders.

Note: The source code of XCode playgrounds must be written in the Swift programming language. The MSL/GLSL shader source code must be loaded and compiled using code written in Swift.

Only a few examples from the pdf version of the book have been tested using an XCode playground.


How to re-use the playgrounds for testing

The vertex shader, "shader.vs" is written to output a canvas that will be used by the fragment shader "shader.fs". This source code of "shader.vs" does not need to be modified at all since no uniforms are passed to the vertex shader in the examples from the "Book of Shaders".

TMost of the source code of the file "shader.fs" can be removed and replaced except for the first line and the last line. The OpenGL support code listed in GLViewController.swift instantiates a 3.2 OpenGL Core Profile context.

Hence the line:

#version 330

should not be removed.

The built-in variable "gl_FragColor" is not supported in OpenGL Core Profile and must be replaced with a user-defined variable. The "fragmentColor" is chosen for this set of playgrounds. In addition, an output variable must be declared in the fragment shader source:


out vec4 fragmentColor;

The user could change the size of the live view; refer to the function "loadView" with the GLViewController.swift file.


The Swift source code of the playground expects both the shader files to be in the "Resources" sub-folder of the playground package which incidentally is a special folder.


To support the loading of graphic files (Chapter on Image Processing), changes are required to the source file "GLViewController.swift"; ref: Figure5.2.playground.

XCode playgrounds, unlike a normal XCode project, only supports the Swift programming language. Third-party source code like FreeImage, SOIL, ASSIMP etc. are usually written in C++ and therefore cannot be imported into and compiled in these playgrounds.

Fortunately, macOS/iOS has a class of objects named "GLKTextureLoader" which can be used to facilitate the loading and instantiation of OpenGL texture ids.

There is a function "LoadTexture" in the "Figure5.2.playground" calls the "GLKTextureLoader" class function "textureWithContentsOfFile:options:error" to read and return an OpenGL texture id. The graphic file like the shader files should be in the "Resources" sub-folder of the playground package.

Two functions, "prepareOpenGL" & "render" must be modified to ensure the texture id of the instantiated texture object is passed correctly to the fragment shader.

BTW, cubemap textures can be instantiated and their texture ids returned to the caller via the "name" property of the GLKTextureInfo object. Naturally, changes need to be made to the source files "GLViewController", "shader.vs" and "shader.fs"


https://thebookofshaders.com/


Requirements:

Developed with Swift3.x, XCode 8.x, macOS Sierra (10.12.x)
The playground should be able to run under XCode 8.0, macOS El Capitan (10.11.x)

To run on Xcode 9.x or later will require some modifications because of changes to the Swift interfaces.

