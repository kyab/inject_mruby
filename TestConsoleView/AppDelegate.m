//
//  AppDelegate.m
//  TestConsoleView
//
//  Created by koji on 2013/07/20.
//
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)dealloc
{
    NSLog(@"AppDelegate dealloc");
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    NSLog(@"applicationWillTerminate");
}

@end
