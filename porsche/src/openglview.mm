#import <Cocoa/Cocoa.h>
#include <OpenGL/gl.h>
#include <OpenGL/glu.h>
#import "openglview.h"
#include "vmath.h"
#include "car.h"
GLfloat lightAmbient0[]     = {0.0f, 0.0f, 0.0f, 1.0f};
GLfloat lightDiffuse0[]     = {1.0f, 0.0f, 0.0f, 1.0f};
GLfloat lightSpecular0[]    = {1.0f, 0.0f, 0.0f, 1.0f};
GLfloat lightPosition0[]    = {2.0f, 0.0f, 0.0f, 1.0f};

GLfloat materialAmbient[]   = {0.0f, 0.0f, 0.0f, 1.0f};
GLfloat materialDiffuse[]   = {1.0f, 1.0f, 1.0f, 1.0f};
GLfloat materialSpecular[]  = {1.0f, 1.0f, 1.0f, 1.0f};
GLfloat materialShininess   = 50.0f;

GLfloat lightAmbient1[]     = {0.0f, 0.0f, 0.0f, 1.0f};
GLfloat lightDiffuse1[]     = {0.0f, 0.0f, 1.0f, 1.0f};
GLfloat lightSpecular1[]    = {0.0f, 0.0f, 1.0f, 1.0f};
GLfloat lightPosition1[]    = {-2.0f, 0.0f, 0.0f, 1.0f};
/* CVDisplayCallback */
CVReturn MyDisplayLinkCallback(CVDisplayLinkRef, const CVTimeStamp*, const CVTimeStamp*,
                               CVOptionFlags, CVOptionFlags*, void*);

@implementation MyOpenGLView {
    GLfloat rotationAngle;
    @private
        CVDisplayLinkRef displayLink;
}

- (instancetype)initWithFrame:(NSRect)frameRect {


    GLuint attributes[] =
    {
        NSOpenGLPFAWindow,

        // choose among pixelformats capable of rendering to windows
        NSOpenGLPFAAccelerated,
        // require hardware-accelerated pixelformat
        NSOpenGLPFADoubleBuffer,
        // require double-buffered pixelformat
        NSOpenGLPFAColorSize, 24,
        // require 24 bits for color-channels
        NSOpenGLPFAAlphaSize, 8,
        // require an 8-bit alpha channel
        NSOpenGLPFADepthSize, 24,
        // require a 24-bit depth buffer

        NSOpenGLPFAMinimumPolicy,
        // select a pixelformat which meets or exceeds these requirements
        0
    };
        NSOpenGLPixelFormat* pixelformat =
            [ [ NSOpenGLPixelFormat alloc ] initWithAttributes:
                (NSOpenGLPixelFormatAttribute*) attributes ];

        if ( pixelformat == nil )
        {
            NSLog( @"No valid OpenGL pixel format" );
            NSLog( @"matches the attributes specified" );
            // at this point, we'd want to try different sets of

            // pixelformat attributes until we got a match, or decide
            // we couldn't create a proper graphics environment for our
            // application, and exit appropriately
        }
        // now init ourself using NSOpenGLViews
        // initWithFrame:pixelFormat message
        return self = [ super initWithFrame: frameRect
                                pixelFormat: [ pixelformat autorelease ] ];






    // self = [super initWithFrame:frameRect];
    return self;
}

-(CVReturn)getFrameForTime:(const CVTimeStamp*)outputTime
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    if(rotationAngle > 360.0f)
        rotationAngle = rotationAngle - 360.0f;
    rotationAngle += 0.5f;
    [self display];
    [pool release];

    return (kCVReturnSuccess);
}

- (void)dealloc {
freeCar();
    CVDisplayLinkStop(displayLink);
    CVDisplayLinkRelease(displayLink);
    [super dealloc];
}

- (void)drawRect:(NSRect)rect {
    [super drawRect:rect];
    [self display];
}

-(void)prepareOpenGL {
    initializeCar();
    [super prepareOpenGL];
    
    /* setup display link */
    CVDisplayLinkCreateWithActiveCGDisplays(&displayLink);
    CVDisplayLinkSetOutputCallback(displayLink, &MyDisplayLinkCallback, self);
    CVDisplayLinkStart(displayLink);

    NSOpenGLContext *openGLContext = self.openGLContext;
    [openGLContext makeCurrentContext];
        
    /* Scene initialization */
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);

    glClearDepth(1.0f);
    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_LESS);
glDisable(GL_CULL_FACE);
int val;
   glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);
    glEnable(GL_LIGHTING);

glGetIntegerv(GL_DEPTH_BITS, &val);
   printf("depth: %d\n", val);
    //set up light 0 properties
    glLightfv(GL_LIGHT0, GL_AMBIENT, lightAmbient0);
    glLightfv(GL_LIGHT0, GL_DIFFUSE, lightDiffuse0);
    glLightfv(GL_LIGHT0, GL_SPECULAR, lightSpecular0);
    glLightfv(GL_LIGHT0, GL_POSITION, lightPosition0);
    glEnable(GL_LIGHT0);

    //set up light 1 properties
    glLightfv(GL_LIGHT1, GL_AMBIENT, lightAmbient1);
    glLightfv(GL_LIGHT1, GL_DIFFUSE, lightDiffuse1);
    glLightfv(GL_LIGHT1, GL_SPECULAR, lightSpecular1);
    glLightfv(GL_LIGHT1, GL_POSITION, lightPosition1);
    glEnable(GL_LIGHT1);

    //set up material properties
    glMaterialfv(GL_FRONT, GL_AMBIENT, materialAmbient);
    glMaterialfv(GL_FRONT, GL_DIFFUSE, materialDiffuse);
    glMaterialfv(GL_FRONT, GL_SPECULAR, materialSpecular);
    glMaterialf(GL_FRONT, GL_SHININESS, materialShininess);

    [self reshape];
}

- (void) display
{
    [[self openGLContext] makeCurrentContext];
    CGLLockContext((CGLContextObj)[[self openGLContext] CGLContextObj]);
    
    /*--- draw here ---*/

    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    glTranslatef(0.0f, 0.0f, -5.0f);
    // Draw the rotated triangle
    glRotatef(rotationAngle, 0.0f, 1.0f, 0.0f);
    glRotatef(rotationAngle, 1.0f, 0.0f, 0.0f);
    glRotatef(rotationAngle, 0.0f, 0.0f, 1.0f);
    //[self drawPyramid];
    displayCar();
    /*--- ** ---*/
    glFlush();
    CGLFlushDrawable((CGLContextObj)[[self openGLContext] CGLContextObj]);
    CGLUnlockContext((CGLContextObj)[[self openGLContext] CGLContextObj]);
}

- (void) reshape {
    [super reshape];
    NSRect rect = [self bounds];

    CGLLockContext((CGLContextObj)[[self openGLContext] CGLContextObj]);

    if(rect.size.height < 0)
        rect.size.height = 1;

    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    gluPerspective(45.0f, (GLfloat)rect.size.width / (GLfloat)rect.size.height, 0.1f, 100.0f);
    
    /* @note: while writing this code the following issue is observed hence multiplying by 2
       https://stackoverflow.com/questions/36672935/why-retina-screen-coordinate-value-is-twice-the-value-of-pixel-value 
    */
    glViewport(0, 0, (GLsizei)rect.size.width*2, (GLsizei)rect.size.height*2);
    
    CGLUnlockContext((CGLContextObj)[[self openGLContext] CGLContextObj]);
}

-(void) drawPyramid
{
    glBegin(GL_TRIANGLES);
        //front
        glNormal3f(0.0f, 0.447214f, 0.894427f);
        glVertex3f(0.0f, 1.0f, 0.0f);
        glVertex3f(-1.0f, -1.0f, 1.0f);
        glVertex3f(1.0f, -1.0f, 1.0f);

        //right
        glNormal3f(0.894427f, 0.447214f, 0.0f);
        glVertex3f(0.0f, 1.0f, 0.0f);
        glVertex3f(1.0f, -1.0f, 1.0f);
        glVertex3f(1.0f, -1.0f, -1.0f);

        //far
        glNormal3f(0.0f, 0.447214f, -0.894427f);
        glVertex3f(0.0f, 1.0f, 0.0f);
        glVertex3f(1.0f, -1.0f, -1.0f);
        glVertex3f(-1.0f, -1.0f, -1.0f);

        //left
        glNormal3f(-0.894427f, 0.447214f, 0.0f);
        glVertex3f(0.0f, 1.0f, 0.0f);
        glVertex3f(-1.0f, -1.0f, -1.0f);
        glVertex3f(-1.0f, -1.0f, 1.0f);
    glEnd();
}

- (void)drawRotatedTriangle {
    // Rotate the triangle around the Y-axis

    // Draw a simple triangle
    glBegin(GL_TRIANGLES);
    glColor3f(1.0f, 0.0f, 0.0f); // Red color
    glVertex3f(0.0f, 0.5f, 0.0f);
    glColor3f(0.0f, 1.0f, 0.0f); // Red color
    glVertex3f(-0.5f, -0.5f, 0.0f);
    glColor3f(0.0f, 0.0f, 1.0f); // Red color
    glVertex3f(0.5f, -0.5f, 0.0f);
    glEnd();
    // Increment the rotation angle for the next frame
}
@end

CVReturn MyDisplayLinkCallback(CVDisplayLinkRef displayLink, const CVTimeStamp *now, const CVTimeStamp *outputTime,
                               CVOptionFlags flagsIn, CVOptionFlags *flagsOut, void *displayLinkContext)
{
    CVReturn result = [(MyOpenGLView*)displayLinkContext getFrameForTime:outputTime];
    return (result);
}
