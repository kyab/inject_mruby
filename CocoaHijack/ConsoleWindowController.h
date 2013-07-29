//
//  ConsoleWindowController.h
//  inject_mruby
//
//  Created by koji on 2013/07/20.
//
//

#import <Cocoa/Cocoa.h>
#import "MRubyConsoleView.h"
@interface ConsoleWindowController : NSWindowController <MRubyExecuter>{
    IBOutlet MRubyConsoleView *m_consoleView;
}

@end
