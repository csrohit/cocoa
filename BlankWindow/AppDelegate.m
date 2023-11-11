//
//  AppDelegate.m
//  BlankWindow
//
//  Created by Rohit Nimkar on 11/11/23.
//

#import "AppDelegate.h"


@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    NSRect frame = NSMakeRect(0, 0, 400, 200);
    self.window = [[NSWindow alloc] initWithContentRect:frame
                                              styleMask:(NSWindowStyleMaskTitled | NSWindowStyleMaskResizable | NSWindowStyleMaskClosable)
                                                backing:NSBackingStoreBuffered
                                                  defer:NO];
    
    [self.window setTitle:@"RTR5: Rohit Nimkar!"];
    
    NSTextField *label = [[NSTextField alloc] initWithFrame:NSMakeRect(50, 100, 300, 30)];
    [label setStringValue:@"My First window in Mac os!"];
    [label setBezeled:NO];
    [label setDrawsBackground:NO];
    [label setEditable:NO];
    [label setSelectable:NO];
    
    [[self.window contentView] addSubview:label];
    
    [self.window makeKeyAndOrderFront:nil];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    NSLog(@"This window is about to close");
}

@end

