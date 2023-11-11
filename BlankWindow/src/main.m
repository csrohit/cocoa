//
//  main.m
//  BlankWindow
//
//  Created by Rohit Nimkar on 11/11/23.
//

#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"

/* Program entry point */
int main(int argc, const char* argv[])
{
    @autoreleasepool
    {
        /* Handle of the application, handles main loop and windows/menus
         https://developer.apple.com/documentation/appkit/nsapplication
         shared class function initializes the display environment and connects to
         the window server & display server
         */
        NSApplication* application = [NSApplication sharedApplication];
        AppDelegate*   appDelegate = [[AppDelegate alloc] init];
        [application setDelegate:appDelegate];

        /* Start the main application loop */
        [application run];
    }
    return 0;
}
