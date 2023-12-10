#import "appdelegate.h"
#import "openglview.h"
#include "bridge.h"


@implementation AppDelegate
{
    @private
        NSWindow *window;
        MyOpenGLView *openGLView;
        FILE* gpFile;
}
    
    -(void)applicationDidFinishLaunching:(NSNotification*)aNotification
    {

        //open/create log file
        gpFile = fopen("log.txt", "w");
        if(gpFile == NULL)
        {
            [self release];
            [NSApp terminate:self];
        }

        fprintf(gpFile, "-------------------------------------------------------------\n");
        fprintf(gpFile, "-> program started successfully\n");
        fprintf(gpFile, "-------------------------------------------------------------\n");

        //window size
        NSRect rect = NSMakeRect(0.0, 0.0, WIN_WIDTH, WIN_HEIGHT);
        
        //create window
        window = [[NSWindow alloc] initWithContentRect:rect
            styleMask:NSWindowStyleMaskTitled |
                      NSWindowStyleMaskClosable |
                      NSWindowStyleMaskMiniaturizable |
                      NSWindowStyleMaskResizable
            backing:NSBackingStoreBuffered
            defer:NO
        ];

        //set window properties
        [window setTitle:@WINDOW_TITLE];
        [window center];

        openGLView = [[MyOpenGLView alloc] initWithFrame:window.contentView.frame];

        //set view
        [window setContentView:openGLView];

        //set window delegate
        [window setDelegate:self];

        [window makeKeyAndOrderFront:openGLView];
    }

    -(void)applicationWillTerminate:(NSNotification*)aNotification
    {
        NSLog(@"Application is about to terminate");
        //code
        if(gpFile)
        {
            fprintf(gpFile, "-------------------------------------------------------------\n");
            fprintf(gpFile, "-> program terminated successfully\n");
            fprintf(gpFile, "-------------------------------------------------------------\n");
            fclose(gpFile);
            gpFile = NULL;
        }
    }

    -(void)windowWillClose:(NSNotification*)aNotification
    {
        [NSApp terminate:self];
    }

    - (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
        return true;
    }

    -(void)dealloc
    {
        [openGLView release];
        [window release];
        [super dealloc];
    }

@end


