//
//  ConsoleWindowController.m
//  inject_mruby
//
//  Created by koji on 2013/07/20.
//
//

#import "CocoaHijack.h"
#import "ConsoleWindowController.h"

@implementation ConsoleWindowController

- (id)init{
    self = [super initWithWindowNibName:@"ConsoleWindow"];
    if (self){
        NSLog(@"success to load");
        
        
    }
    NSLog(@"loaded nib : %@", [self windowNibName]);
    return self;
}

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    [m_consoleView setExecuter:self];
    
}

-(NSString *)execute:(NSString *)code exception:(int *)is_exception{
//    NSString *result = @"echo back : ";
//    return [result stringByAppendingString:code];
    
    return [[CocoaHijack sharedCocoaHijack] evalString:code exception:is_exception];
}

@end
