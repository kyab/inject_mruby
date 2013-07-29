//
//  CocoaHijack.h
//  CocoaHijack
//
//  Created by koji on 2013/06/08.
//
//

#import <Foundation/Foundation.h>
#import "ConsoleWindowController.h"
#include "mruby.h"
#include "mruby/compile.h"

@interface CocoaHijack : NSObject{
    NSMenu *m_menuInject;
    NSMenuItem *m_menuFootest;
    NSMenuItem *m_menuExecuteLine;
    NSMenuItem *m_menuConsole;
    NSMenuItem *m_menuSelectView;
    
    mrb_state *mrb;
    mrbc_context *mrb_ctx;
    ConsoleWindowController *m_consoleController;
    
}
+ (CocoaHijack *)sharedCocoaHijack;
- (NSString *)evalString:(NSString *)code exception:(int *)is_exception;
@end
