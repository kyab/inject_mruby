//
//  AppDelegate.h
//  TestConsoleView
//
//  Created by koji on 2013/07/20.
//
//

#import <Cocoa/Cocoa.h>
#import "MainController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet MainController *controller;

@end
