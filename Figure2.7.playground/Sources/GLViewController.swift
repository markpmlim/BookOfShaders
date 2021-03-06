
import Cocoa
import OpenGL.GL3

public class SPOpenGLView: NSOpenGLView {
    let shader = GLShader()
    var quadVAO: GLuint = 0
    var stopClock =  Clock()
    var resolutionLoc: GLint = 0
    var mouseLoc: GLint = 0
    var mouseCoords: [GLfloat] = [0.0, 0.0]
    var timeLoc: GLint = 0
    let preferredFramesPerSecond = 60       // user can change this value
    
    // This is required
    public override init?(frame frameRect: NSRect,
                          pixelFormat format: NSOpenGLPixelFormat?) {

        super.init(frame: frameRect, pixelFormat: format)
        let glContext = NSOpenGLContext(format: pixelFormat!,
                                        share: nil)
        //Swift.print("OpenGLView init")
        self.pixelFormat = pixelFormat!
        self.openGLContext = glContext
        //Swift.print(self.openGLContext)
        self.openGLContext!.makeCurrentContext()
    }
    
    // This is also required
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func prepareOpenGL() {
        //Swift.print("prepareOpenGL")
        super.prepareOpenGL()
        // Test to ensure the OpenGL vertex and fragment shaders
        // are compiled into a program.
        var shaderIDs = [GLuint]()
        var shaderID = shader.compileShader(filename: "shader.vs",
                                            shaderType: GLenum(GL_VERTEX_SHADER))
        shaderIDs.append(shaderID)
        shaderID = shader.compileShader(filename: "shader.fs",
                                        shaderType: GLenum(GL_FRAGMENT_SHADER))
        shaderIDs.append(shaderID)
        shader.createAndLinkProgram(shaders: shaderIDs)
        resolutionLoc = glGetUniformLocation(shader.program, "u_resolution")
        mouseLoc = glGetUniformLocation(shader.program, "u_mouse")
        timeLoc = glGetUniformLocation(shader.program, "u_time")
        Swift.print("resolution:", resolutionLoc)
        Swift.print("Mouse:", mouseLoc)
        Swift.print("Time:", timeLoc)
        // The geometry of the quad is embedded in the vertex shader
        // but OpenGL needs to bind a vertex array object (VAO).
        glGenVertexArrays(1, &quadVAO)

        Timer.scheduledTimer(timeInterval: 1.0/TimeInterval(preferredFramesPerSecond),
                             target: self,
                             selector: #selector(SPOpenGLView.scheduledDraw),
                             userInfo: nil,
                             repeats: true)
    }

    override public func reshape() {
        //Swift.print("reshape")
        super.reshape()
        self.render(elapsedTime: stopClock.timeElapsed())
    }

     override public func draw(_ dirtyRect: NSRect) {
        self.render(elapsedTime: stopClock.timeElapsed())
     }

    func handleMouseClick(at point: NSPoint) {
        mouseCoords[0] = GLfloat(point.x)
        mouseCoords[1] = GLfloat(point.y)
        //Swift.print("mouse coords:", mouseCoords)
    }

    override public func mouseDown(with event: NSEvent) {
        let mousePoint = self.convert(event.locationInWindow,
                                      from: nil)
        handleMouseClick(at: mousePoint)
    }

    override public func mouseDragged(with event: NSEvent) {
        let mousePoint = self.convert(event.locationInWindow,
                                    from: nil)
        handleMouseClick(at: mousePoint)
    }

    // This will be called every 1/60s.
    func scheduledDraw() {
        self.render(elapsedTime: stopClock.timeElapsed())
    }

    /*
     This function don't get called at regular intervals.
     To add a NStimer.
     */
    func render(elapsedTime: Double) {
        //Swift.print(elapsedTime)
        openGLContext!.makeCurrentContext()
        CGLLockContext(openGLContext!.cglContextObj!)

        glClear(GLenum(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))
        glViewport(0, 0, GLsizei(frame.width), GLsizei(frame.height))
        // Set the background to gray to indicate the render method had been
        // called in case the shaders are not working properly.
        glClearColor(0.5, 0.5, 0.5, 1.0)

        shader.use()
        glBindVertexArray(quadVAO)
        glUniform2f(resolutionLoc,
                    GLfloat(frame.width), GLfloat(frame.height))
        glUniform1f(timeLoc, GLfloat(elapsedTime))
        glUniform2fv(mouseLoc, 1, mouseCoords)
        glDrawArrays(GLenum(GL_TRIANGLE_STRIP), 0, 4)
        glBindVertexArray(0)
        glUseProgram(0)

        openGLContext!.update()
        // we're double buffered so need to flush to screen
        openGLContext!.flushBuffer()
        CGLUnlockContext(openGLContext!.cglContextObj!)
    }

 }

public final class SPViewController: NSViewController {
 
    // This must be implemented
    override public func loadView() {
        //Swift.print("loadView")
        let frameRect = NSRect(x: 0, y: 0,
                               width: 480, height: 270)
        self.view = NSView(frame: frameRect)

        let pixelFormatAttrsBestCase: [NSOpenGLPixelFormatAttribute] = [
            UInt32(NSOpenGLPFADoubleBuffer),
            UInt32(NSOpenGLPFAAccelerated),
            UInt32(NSOpenGLPFABackingStore),
            UInt32(NSOpenGLPFADepthSize), UInt32(24),
            UInt32(NSOpenGLPFAOpenGLProfile), UInt32(NSOpenGLProfileVersion3_2Core),
            UInt32(0)
        ]
        
        let pf = NSOpenGLPixelFormat(attributes: pixelFormatAttrsBestCase)
        if (pf == nil) {
            fatalError("Couldn't init OpenGL at all, sorry :(")
        }
        let openGLView = SPOpenGLView(frame: frameRect,
                                      pixelFormat: pf)
        self.view.addSubview(openGLView!)
        //Swift.print(self.openGLView)
    }

    override public func viewDidLoad() {
        //Swift.print("viewDidLoad")
        super.viewDidLoad()
    }
 }

class Clock {
    private static var kNanoSecondConvScale: Double = 1.0e-9
    private var machTimebaseInfoRatio: Double = 0
    private var startTime = 0.0

    init() {
        var timebaseInfo = mach_timebase_info_data_t()
        timebaseInfo.numer = 0
        timebaseInfo.denom = 0
        let err = mach_timebase_info(&timebaseInfo)
        if err != KERN_SUCCESS {
            Swift.print(">> ERROR: \(err) getting mach timebase info!")
        } // if
        else
        {
            let numer = Double(timebaseInfo.numer)
            let denom = Double(timebaseInfo.denom)
            
            // This gives the resolution
            machTimebaseInfoRatio = Clock.kNanoSecondConvScale * (numer/denom)
            startTime = Double(mach_absolute_time())        // in nano seconds
        } // else
    }

    // Return the elapsed time in seconds
    func timeElapsed() -> Double {
        let currentTime = Double(mach_absolute_time())      // in nano seconds
        let elapsedTime = currentTime - startTime           // in nano seconds
        return elapsedTime * machTimebaseInfoRatio          // in seconds
    }
}
