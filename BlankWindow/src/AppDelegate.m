//
//  AppDelegate.m
//  BlankWindow
//
//  Created by Rohit Nimkar on 11/11/23.
//

#import "AppDelegate.h"
#import "MyWindowDelegate.h"
#include <AppKit/AppKit.h>
#include <Foundation/Foundation.h>
#include <objc/objc.h>

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification*)aNotification
{
    /* https://developer.apple.com/documentation/appkit/nsapplicationdelegate/1428385-applicationdidfinishlaunching
     */
    NSLog(@"Application has finished launching but did not receive any event");
    // Insert code here to initialize your application
    NSRect frame = NSMakeRect(0, 0, 400, 200);
    self.window  = [[NSWindow alloc] initWithContentRect:frame
                                              styleMask:(NSWindowStyleMaskTitled | NSWindowStyleMaskResizable | NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable)
                                                backing:NSBackingStoreBuffered
                                                  defer:NO];

    MyWindowDelegate* windowDelegate = [[MyWindowDelegate alloc] init];
    [self.window setDelegate:windowDelegate];

    [self.window setTitle:@"RTR5: Rohit Nimkar!"];

    NSTextField* label = [[NSTextField alloc] initWithFrame:NSMakeRect(50, 100, 300, 30)];
    [label setStringValue:@"My First window in Mac os!"];
    [label setBezeled:NO];
    [label setDrawsBackground:NO];
    [label setEditable:NO];
    [label setSelectable:NO];

    [[self.window contentView] addSubview:label];

    [self.window makeKeyAndOrderFront:nil];
}

- (void)applicationWillTerminate:(NSNotification*)aNotification
{
    // Insert code here to tear down your application
    NSLog(@"This window is about to close");
}

- (void)applicationWillFinishLaunching:(NSNotification*)notification
{
    NSLog(@"Application is about to finish loading");
    /* Register for AppleEventHandlers here
     https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ScriptableCocoaApplications/SApps_handle_AEs/SAppsHandleAEs.html#//apple_ref/doc/uid/20001239
     */
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication*)sender
{
    NSLog(@"%s", __func__);
    return YES;
}

- (void)applicationWillBecomeActive:(NSNotification*)notification
{
    NSLog(@"Application is about to become active");
}

- (void)applicationDidBecomeActive:(NSNotification*)notification
{
    NSLog(@"Application is became active");
}

- (void)applicationWillResignActive:(NSNotification*)notification
{
    NSLog(@"Application is about to become inactive");
}

- (void)applicationDidResignActive:(NSNotification*)notification
{
    NSLog(@"Application has become inactive");
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication*)sender
{
    NSLog(@"Application should be terminated");
    return NSTerminateNow;
}

@end
