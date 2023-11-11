//
//  WindowDelegate.m
//  BlankWindow
//
//  Created by Rohit Nimkar on 11/11/23.
//

#import "MyWindowDelegate.h"
#include <objc/objc.h>
#include <Foundation/Foundation.h>

@implementation MyWindowDelegate

- (BOOL)windowShouldClose:(NSNotification*)notification
{
    NSLog(@"Window should close");
    NSLog(@"%s", __func__);
    // Additional cleanup or handling code can be added here
    return YES;
}
- (void)windowWillClose:(NSNotification*)notification
{
    NSLog(@"Window will close");
    NSLog(@"%s", __func__);
    // Additional cleanup or handling code can be added here
}

- (void)windowDidResize:(NSNotification*)notification
{
    // NSLog(@"Window did resize");
    //  Additional code to handle resizing
}

- (void)windowDidExpose:(NSNotification*)notification
{
    NSLog(@"windowDidExpose");
}

- (void)windowWillMiniaturize:(NSNotification*)notification
{
    NSLog(@"%s", __func__);
}

- (void)windowDidMiniaturize:(NSNotification*)notification
{
    NSLog(@"%s", __func__);
}

- (void)windowDidDeminiaturize:(NSNotification*)notification
{
    NSLog(@"%s", __func__);
}

- (void)windowWillEnterFullScreen:(NSNotification*)notification
{
    NSLog(@"%s", __func__);
}
- (void)windowDidEnterFullScreen:(NSNotification*)notification
{
    NSLog(@"%s", __func__);
}

- (void)windowWillExitFullScreen:(NSNotification*)notification
{
    NSLog(@"%s", __func__);
}

- (void)windowDidExitFullScreen:(NSNotification*)notification
{
    NSLog(@"%s", __func__);
}

// Other NSWindowDelegate methods can be implemented as needed

@end
