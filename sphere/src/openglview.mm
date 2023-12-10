/**
 * @file        openglview.mm
 * @description opengl view event handler
 * @author      Rohit Nimkar
 * @version     1.0
 * @date        2023-12-10
 * @copyright   Copyright 2023 Rohit Nimkar
 *
 * @attention
 *  Use of this source code is governed by a BSD-style
 *  license that can be found in the LICENSE file or at
 *  opensource.org/licenses/BSD-3-Clause
 */

#import <Cocoa/Cocoa.h>
#include <OpenGL/gl.h>
#include <OpenGL/glu.h>
#import "openglview.h"

GLfloat globalAmbient[]        = {1.0f, 1.0f, 1.0f, 1.0f};
GLfloat ground[]               = {0.5f, 0.5f, 0.5f, 1.0f};
GLfloat cosmisAmbientDefault[] = {0.2f, 0.2f, 0.2f, 1.0f};
GLfloat black[4]               = {0.0f, 0.0f, 0.0f, 1.0f};
GLfloat *pLightColor0          = black;
GLfloat *pLightColor1           = black;
GLfloat *pLightColor2           = black;
GLfloat lightDispalcement = 2.0f;

GLfloat lightRedAmbient[]        = {0.0f, 0.0f, 0.0f, 1.0f};
GLfloat lightRedDiffuse[]        = {1.0f, 0.0f, 0.0f, 1.0f};
GLfloat lightRedSpecular[]       = {1.0f, 1.0f, 1.0f, 1.0f};
GLfloat lightRedPosition[]       = {0.0f, 0.0f, 0.0f, 1.0f};

GLfloat lightGreenAmbient[]        = {0.0f, 0.0f, 0.0f, 1.0f};
GLfloat lightGreenDiffuse[]        = {0.0f, 1.0f, 0.0f, 1.0f};
GLfloat lightGreenSpecular[]       = {1.0f, 1.0f, 1.0f, 1.0f};
GLfloat lightGreenPosition[]       = {-2.0f, 0.0f, 0.0f, 1.0f};

GLfloat lightBlueAmbient[]        = {0.0f, 0.0f, 0.0f, 1.0f};
GLfloat lightBlueDiffuse[]        = {0.0f, 0.0f, 1.0f, 1.0f};
GLfloat lightBlueSpecular[]       = {1.0f, 1.0f, 1.0f, 1.0f};
GLfloat lightBluePosition[]       = {-2.0f, 0.0f, 0.0f, 1.0f};

GLfloat materialAmbient[]      = {1.0f, 1.0f, 1.0f, 1.0f};
GLfloat materialDiffuse[]      = {1.0f, 1.0f, 1.0f, 1.0f};
GLfloat materialSpecular[]     = {1.0f, 1.0f, 1.0f, 1.0f};
GLfloat materialShininess      = 128.0f;


GLfloat lightAmbient[][4] = 
    {
        {0.0f, 0.0f, 0.0f, 1.0f},
        {0.0f, 0.0f, 0.0f, 1.0f},
        {0.0f, 0.0f, 0.0f, 1.0f},
        {0.0f, 0.0f, 0.0f, 1.0f},
        {0.0f, 0.0f, 0.0f, 1.0f},
        {0.0f, 0.0f, 0.0f, 1.0f}
    };
GLfloat lightDiffuse[][4] = 
    {
        {1.0f, 0.0f, 0.0f, 1.0f},
        {0.0f, 1.0f, 0.0f, 1.0f},
        {0.0f, 0.0f, 1.0f, 1.0f},
        {0.0f, 1.0f, 1.0f, 1.0f},
        {1.0f, 1.0f, 0.0f, 1.0f},
        {1.0f, 0.0f, 1.0f, 1.0f}
    };

GLfloat lightSpecular[][4] = 
    {
        {1.0f, 1.0f, 1.0f, 1.0f},
        {1.0f, 1.0f, 1.0f, 1.0f},
        {1.0f, 1.0f, 1.0f, 1.0f},
        {1.0f, 1.0f, 1.0f, 1.0f},
        {1.0f, 1.0f, 1.0f, 1.0f},
        {1.0f, 1.0f, 1.0f, 1.0f}
    };

GLfloat shininess[][1] = 
{
    {128.0f},
    {128.0f},
    {128.0f},
    {128.0f},
    {128.0f},
    {128.0f}
};

GLfloat* currentLightColor[] = 
    {
        black,
        black,
        black,
        black,
        black,
        black,
    };

GLfloat temp[4];

/* CVDisplayCallback */
CVReturn MyDisplayLinkCallback(CVDisplayLinkRef, const CVTimeStamp*, const CVTimeStamp*,
                               CVOptionFlags, CVOptionFlags*, void*);
extern FILE *gpFile;

@implementation MyOpenGLView {
    @private
        GLfloat angleRed;
        GLfloat angleGreen;
        GLfloat angleBlue;
        CVDisplayLinkRef displayLink;
        GLUquadric* pQuadric;

}

    - (instancetype)initWithFrame:(NSRect)frameRect {

        GLuint attributes[] =
        {
            NSOpenGLPFAWindow,
            NSOpenGLPFAAccelerated,
            NSOpenGLPFADoubleBuffer,
            NSOpenGLPFAColorSize, 24,
            NSOpenGLPFAAlphaSize, 8,
            NSOpenGLPFADepthSize, 24,
            NSOpenGLPFAMinimumPolicy,
            0
        };

        NSOpenGLPixelFormat* pixelformat =
            [ [ NSOpenGLPixelFormat alloc ] initWithAttributes:
                (NSOpenGLPixelFormatAttribute*) attributes ];

        if ( pixelformat == nil )
        {
            /* 
                failed to find requested pixel formats
                We can try requesting the different pixel formats instead
                If we are still not able to create a proper rendering context
                then gracefully exit the application
            */
            fprintf(gpFile, "No valid OpenGL pixel format" );
            [NSApp stop:self];
        }
        
        /* Initialize View with obtained pixel format */
        return self = [ super initWithFrame: frameRect
                                pixelFormat: [ pixelformat autorelease ] ];
    }

    -(CVReturn)getFrameForTime:(const CVTimeStamp*)outputTime
    {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        [self display];
        [self updateScene];
        [pool release];

        return (kCVReturnSuccess);
    }

    - (void)dealloc {
        if (nullptr != pQuadric)
        {
            gluDeleteQuadric(pQuadric);
            pQuadric = nullptr;
        }

        CVDisplayLinkStop(displayLink);
        CVDisplayLinkRelease(displayLink);
        [super dealloc];
    }

    - (void)drawRect:(NSRect)rect {
        [super drawRect:rect];
        [self display];
    }

    -(void)prepareOpenGL {
        /*---- Load models --*/

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
        glShadeModel(GL_SMOOTH);
        glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);

        //set up light 0 properties
        glLightfv(GL_LIGHT0, GL_AMBIENT, lightRedAmbient);
        glLightfv(GL_LIGHT0, GL_DIFFUSE, lightRedDiffuse);
        glLightfv(GL_LIGHT0, GL_SPECULAR, lightRedSpecular);
        glLightfv(GL_LIGHT0, GL_POSITION, lightRedPosition);

        //set up light 1 properties
        glLightfv(GL_LIGHT1, GL_AMBIENT, lightGreenAmbient);
        glLightfv(GL_LIGHT1, GL_DIFFUSE, lightGreenDiffuse);
        glLightfv(GL_LIGHT1, GL_SPECULAR, lightGreenSpecular);
        glLightfv(GL_LIGHT1, GL_POSITION, lightGreenPosition);

        glLightfv(GL_LIGHT2, GL_AMBIENT, lightBlueAmbient);
        glLightfv(GL_LIGHT2, GL_DIFFUSE, lightBlueDiffuse);
        glLightfv(GL_LIGHT2, GL_SPECULAR, lightBlueSpecular);
        glLightfv(GL_LIGHT2, GL_POSITION, lightBluePosition);

        //set up material properties
        glMaterialfv(GL_FRONT, GL_AMBIENT, materialAmbient);
        glMaterialfv(GL_FRONT, GL_DIFFUSE, materialDiffuse);
        glMaterialfv(GL_FRONT, GL_SPECULAR, materialSpecular);
        glMaterialf(GL_FRONT, GL_SHININESS, materialShininess);

        glEnable(GL_LIGHTING);
        glEnable(GL_LIGHT0);
        glEnable(GL_LIGHT1);
        glEnable(GL_LIGHT2);

        /* Initialize quadric */
        pQuadric = gluNewQuadric();
        [self reshape];
    }

    -(BOOL)acceptsFirstResponder
    {
        [[self window] makeFirstResponder:self];
        return (YES);
    }

    -(void)keyDown:(NSEvent *)event {
        int key = [[event characters] characterAtIndex:0];
        [[self openGLContext] makeCurrentContext];
        CGLLockContext((CGLContextObj)[[self openGLContext] CGLContextObj]);
        switch(key)
        {
            case 27:
                [[self window] close];
                break;
            
            case 'F':
            case 'f':
                [[self window] toggleFullScreen:self];
                break;

            case 'r':
            case 'R':
                static bool bIsLight0Enabled = false;
                if(false == bIsLight0Enabled)
                {
                    [self toggleLighting];
                    glEnable(GL_LIGHT0);
                    pLightColor0 = lightRedDiffuse;
                    [self toggleLighting];
                }
                else
                {    
                    [self toggleLighting];
                    glDisable(GL_LIGHT0);
                    pLightColor0 = black;
                    [self toggleLighting];
                }
                bIsLight0Enabled = !bIsLight0Enabled;
                break;

            case 'g':
            case 'G':
                static bool bIsLight1Enabled = false;
                if(false == bIsLight1Enabled)
                {
                    [self toggleLighting];
                    glEnable(GL_LIGHT1);
                    pLightColor1 = lightGreenDiffuse;
                    [self toggleLighting];
                }
                else
                {
                    [self toggleLighting];
                    glDisable(GL_LIGHT1);
                    pLightColor1 = black;
                    [self toggleLighting];
                }
                bIsLight1Enabled = !bIsLight1Enabled;
                break;
            case 'b':
            case 'B':
                static bool bIsLight2Enabled = false;
                if(false == bIsLight2Enabled)
                {
                    [self toggleLighting];
                    glEnable(GL_LIGHT1);
                    pLightColor2 = lightBlueDiffuse;
                    [self toggleLighting];
                }
                else
                {
                    [self toggleLighting];
                    glDisable(GL_LIGHT1);
                    pLightColor2 = black;
                    [self toggleLighting];
                }
                bIsLight2Enabled = !bIsLight2Enabled;
                break;
            case 'L':
            case 'l':
                [self toggleLighting];
                break; 
            case 'm':
            case 'M':
                static bool bIsCosmicEnabled = false;
                if(false == bIsCosmicEnabled)
                {
                    [self toggleLighting];
                    glLightModelfv(GL_LIGHT_MODEL_AMBIENT, globalAmbient);
                    [self toggleLighting];
                }
                else
                {
                    [self toggleLighting];
                    glLightModelfv(GL_LIGHT_MODEL_AMBIENT, cosmisAmbientDefault);
                    [self toggleLighting];
                }
                bIsCosmicEnabled = !bIsCosmicEnabled;
        }
        CGLFlushDrawable((CGLContextObj)[[self openGLContext] CGLContextObj]);
        CGLUnlockContext((CGLContextObj)[[self openGLContext] CGLContextObj]);
    }

    - (void)toggleLighting
    {
        static bool bIsLightingEnabled = false;
        if(false == bIsLightingEnabled)
        {
            glEnable(GL_LIGHTING);
        }
        else {
            glDisable(GL_LIGHTING);
        }
        bIsLightingEnabled = !bIsLightingEnabled;
    }
   
        
    - (void) display
    {
        [[self openGLContext] makeCurrentContext];
        CGLLockContext((CGLContextObj)[[self openGLContext] CGLContextObj]);
        
        /*--- draw here ---*/

        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        glMatrixMode(GL_MODELVIEW);
        glLoadIdentity();

        glColor3f(1.0f, 1.0f, 1.0f);
 
        glLoadIdentity();

        glMaterialfv(GL_FRONT, GL_EMISSION, black);
        glMaterialfv(GL_FRONT, GL_DIFFUSE, materialDiffuse);
        gluSphere(pQuadric, 1.0f, 50, 50); // it will create all normals for you

        glMaterialfv(GL_FRONT, GL_DIFFUSE, black);
        glPushMatrix();
        glRotatef(angleRed, 0.0f, 1.0f, 0.0f);
        glTranslatef(0.0f, 0.0f, lightDispalcement);
        glLightfv(GL_LIGHT0, GL_POSITION, black);
        glMaterialfv(GL_FRONT, GL_EMISSION, lightRedDiffuse);
        gluSphere(pQuadric, 0.1f, 40, 40); // it will create all normals for you
        glPopMatrix();
        
        glPushMatrix();
        glRotatef(angleRed, 0.0f, 0.0f, 1.0f);
        glTranslatef(lightDispalcement, 0.0f, 0.0f);
        glLightfv(GL_LIGHT1, GL_POSITION, black);
        glMaterialfv(GL_FRONT, GL_EMISSION, lightGreenDiffuse);
        gluSphere(pQuadric, 0.1f, 40, 40); // it will create all normals for you
        glPopMatrix();


        glPushMatrix();
        glRotatef(angleRed, 1.0f, 0.0f, 0.0f);
        glTranslatef(0.0f, lightDispalcement, 0.0f);
        glLightfv(GL_LIGHT2, GL_POSITION, black);
        glMaterialfv(GL_FRONT, GL_EMISSION, lightBlueDiffuse);
        gluSphere(pQuadric, 0.1f, 40, 40); // it will create all normals for you
        glPopMatrix();

        /*--- ** ---*/
        glFlush();
        CGLFlushDrawable((CGLContextObj)[[self openGLContext] CGLContextObj]);
        CGLUnlockContext((CGLContextObj)[[self openGLContext] CGLContextObj]);
    }


    - (void)updateScene
    {
        angleRed += 0.5f;
        if(angleRed > 360.0f)
        {
            angleRed -= 360.0f;
        }
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
    
    gluLookAt(0.0, 2.0, 6.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0);

    /* @note: while writing this code the following issue is observed hence multiplying by 2
       https://stackoverflow.com/questions/36672935/why-retina-screen-coordinate-value-is-twice-the-value-of-pixel-value 
    */
    glViewport(0, 0, (GLsizei)rect.size.width*2, (GLsizei)rect.size.height*2);
    
    CGLUnlockContext((CGLContextObj)[[self openGLContext] CGLContextObj]);
}
@end

CVReturn MyDisplayLinkCallback(CVDisplayLinkRef displayLink, const CVTimeStamp *now, const CVTimeStamp *outputTime,
                               CVOptionFlags flagsIn, CVOptionFlags *flagsOut, void *displayLinkContext)
{
    CVReturn result = [(MyOpenGLView*)displayLinkContext getFrameForTime:outputTime];
    return (result);
}

