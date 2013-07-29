//
//  MainController.h
//  inject_mruby
//
//  Created by koji on 2013/07/20.
//
//

#import <Foundation/Foundation.h>
#import "MRubyConsoleView.h"
@interface MainController : NSObject <MRubyExecuter>{
   IBOutlet MRubyConsoleView *mTextView;
}

-(NSString *)execute:(NSString *)code exception:(int *)is_exception;

@end
