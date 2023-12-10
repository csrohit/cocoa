#import <Cocoa/Cocoa.h>
#import "openglview.h"
#import "appdelegate.h"




int main(int argc, const char *argv[]) {
    @autoreleasepool {
        // Create an NSApplication instance
        NSApplication *application = [NSApplication sharedApplication];
        AppDelegate *delegate = [[AppDelegate alloc] init];

        [application setDelegate:delegate];
        [application run];

    }
    return 0;
}
