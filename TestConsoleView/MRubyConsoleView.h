//
//  MyTextView.h
//  inject_mruby
//
//  Created by koji on 2013/07/20.
//
//

#import <Cocoa/Cocoa.h>

@protocol MRubyExecuter
@required
-(NSString *)execute:(NSString *)code exception:(int *)is_exception;
@end

@interface MRubyConsoleView : NSTextView{
    id<MRubyExecuter> m_executer;
    NSPipe *m_pipe;
//    NSPipe *m_pipeErr;
    NSFileHandle *m_pipeReadHandle;

//    NSFileHandle *m_pipeReadHandleErr;
    
    Boolean m_isButtom;
    NSMutableArray *m_history;
    size_t          m_historyOffset;  //0:current line 1:prev 2:prev of prev...
}

-(void)setExecuter:(id<MRubyExecuter>)executer;

@end
