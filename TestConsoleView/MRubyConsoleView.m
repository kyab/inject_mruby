//
//  MyTextView.m
//  inject_mruby
//
//  Created by koji on 2013/07/20.
//
//

#import "MRubyConsoleView.h"
#include <stdio.h>

@implementation MRubyConsoleView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    NSLog(@"initWithFrame");
    return self;
}

-(void)awakeFromNib{
    NSLog(@"MRubyConsoleView awaken from NIB");
    [self setFont:[NSFont userFixedPitchFontOfSize:12]];
    [self setBackgroundColor:[NSColor magentaColor]];
    [self setTextColor:[NSColor whiteColor]];
    [self setInsertionPointColor:[NSColor whiteColor]];
    
    [super insertText:@"> "];
    
    m_history = [[NSMutableArray alloc] init];
    m_historyOffset = 0;

    [self connectSTDOUT];
    
    //maybe we need reopen method to  : http://www.crossbridge.biz/save-to-file-nslog
    //[self connectSTDERR];
}

-(void)connectSTDOUT{
    
    //http://stackoverflow.com/questions/2406204/what-is-the-best-way-to-redirect-stdout-to-nstextview-in-cocoa
    m_pipe = [NSPipe pipe] ;
    m_pipeReadHandle = [m_pipe fileHandleForReading] ;
    
    dup2([[m_pipe fileHandleForWriting] fileDescriptor], fileno(stdout)) ;

    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(handleStdOut:) name: NSFileHandleReadCompletionNotification object: m_pipeReadHandle] ;
    [m_pipeReadHandle readInBackgroundAndNotify] ;
    
}

-(void)handleStdOut:(NSNotification *)notification{
    [m_pipeReadHandle readInBackgroundAndNotify] ;
    
    NSString *str = [[NSString alloc] initWithData: [[notification userInfo] objectForKey: NSFileHandleNotificationDataItem] encoding: NSASCIIStringEncoding] ;
    [super insertText:str];
}



-(void)setExecuter:(id<MRubyExecuter>)executer;{
    m_executer = executer;
}

//(backward)delete
-(void)deleteBackward:(id)sender{

    NSLog(@"deleteBackward");
    NSRange range = self.selectedRange;
    NSRange lineRange = [self.textStorage.string lineRangeForRange:range];
    if (range.location  < lineRange.location+3){
        NSLog(@"begin:%ld, begin(line):%ld",(unsigned long)range.location, (unsigned long)lineRange.location);
    }else{
        [super deleteBackward:sender];
    }
}

// <-
- (void)moveLeft:(id)sender{
    NSLog(@"moveLeft");
    NSRange range = self.selectedRange;
    NSRange lineRange = [self.textStorage.string lineRangeForRange:range];
    if (range.location  < lineRange.location+3){
        NSLog(@"begin:%ld, begin(line):%ld",(unsigned long)range.location, (unsigned long)lineRange.location);
    }else{
        [super moveLeft:sender];
    }
}

//Ctrl + B
- (void)moveBackward:(id)sender{    
    NSLog(@"moveBackward");
    NSRange range = self.selectedRange;
    NSRange lineRange = [self.textStorage.string lineRangeForRange:range];
    if (range.location  < lineRange.location+3){
        NSLog(@"begin:%ld, begin(line):%ld",(unsigned long)range.location, (unsigned long)lineRange.location);
    }else{
        [super moveBackward:sender];
    }
}

//??
-(void)moveWordBackward:(id)sender{
    NSLog(@"moveWordBackword");
    NSRange range = self.selectedRange;
    NSRange lineRange = [self.textStorage.string lineRangeForRange:range];
    if (range.location  < lineRange.location+3){
        NSLog(@"begin:%ld, begin(line):%ld",(unsigned long)range.location, (unsigned long)lineRange.location);
    }else{
        [super moveWordLeft:sender];
    }
}

//Opt + <-
-(void)moveWordLeft:(id)sender{
    NSLog(@"moveWordLeft");
    NSRange range = self.selectedRange;
    NSRange lineRange = [self.textStorage.string lineRangeForRange:range];
    if (range.location  < lineRange.location+3){
        NSLog(@"begin:%ld, begin(line):%ld",(unsigned long)range.location, (unsigned long)lineRange.location);
    }else{
        [super moveWordLeft:sender];
    }
}

//Ctrl + A
- (void)moveToBeginningOfParagraph:(id)sender{
    NSLog(@"moveToBeginningOfParagraph");
    NSRange range = self.selectedRange;
    NSRange lineRange = [self.textStorage.string lineRangeForRange:range];
    lineRange.location += 2;
    lineRange.length = 0;
    [self setSelectedRange:lineRange];
    
}

//Command + <-
-(void)moveToBeginningOfLine:(id)sender{
    NSLog(@"moveToBeginningOfLine:");
    NSRange range = self.selectedRange;
    NSRange lineRange = [self.textStorage.string lineRangeForRange:range];
    lineRange.location += 2;
    lineRange.length = 0;
    [self setSelectedRange:lineRange];
}

-(void)doInsertString:(id)result{
    [super insertText:result];
}

-(void)doInsertStringAndPrompt:(id)result{
    [super insertText:result];
    [super insertNewline:nil];
    [super insertText:@"> "];
}

-(void)insertNewline:(id)sender{
    NSLog(@"insertNewLine");
    
    //make sure to select end of line
    [self setSelectedRange:NSMakeRange(self.string.length,0)];
    
    NSRange range = self.selectedRange;
    NSRange lineRange = [self.textStorage.string lineRangeForRange:range];
    
    if (lineRange.length >= 2){
    	lineRange.location += 2;
    	lineRange.length -= 2;
    }else{
        //User enter on non-prompt line.
        [super insertNewline:sender];
        return;
    }
    
    NSString *line = [self.string substringWithRange:lineRange];
    NSLog(@"line = %@", line);
    if (line.length != 0){
        
        [super insertNewline:sender];
        
        //add to history
        [m_history addObject:line];
        m_historyOffset = 0;
        
        int exception;
        NSString *result = [m_executer execute:line exception:&exception];
        
        //Do not insert text here and use performSelector to do actual insersion in next runloop
        // so that stdout can be outputted as correct order.
        if (!exception){
            [self performSelector:@selector(doInsertString:) withObject:@" => " afterDelay:0.01];
        }
        
        [self performSelector:@selector(doInsertStringAndPrompt:) withObject:result afterDelay:0.01];
    }else{
        //empty line
        [super insertNewline:sender];
        [super insertText:@"> "];
    }
}

-(void)replaceLastLine:(NSString *)line{
    NSRange last = NSMakeRange(self.string.length,0);
    NSRange lineRange = [self.textStorage.string lineRangeForRange:last];
    [self replaceCharactersInRange:lineRange withString:@"> "];
    [super insertText:line];
}

//Up
- (void)moveUp:(id)sender{
    unsigned long index = 0;
    if (m_historyOffset < m_history.count){
        m_historyOffset++;
        NSLog(@"history offset = %zd",m_historyOffset);
        index = m_history.count - m_historyOffset;
        
    }
    
    if (m_history.count > index){
        NSString *line = [m_history objectAtIndex:index];
        [self replaceLastLine:line];
    }

    NSLog(@"moveUp prevented ");
}

//Down
- (void)moveDown:(id)sender{
    unsigned long index = m_history.count;
    if (m_historyOffset >= 1){
        m_historyOffset--;
        NSLog(@"history offset = %zd",m_historyOffset);
        index = m_history.count - m_historyOffset;
    }

    if (m_historyOffset == 0){
        [self replaceLastLine:@""];
    }else if (index > 0){
        NSString *line = [m_history objectAtIndex:index];
        [self replaceLastLine:line];
    }
    
    NSLog(@"moveDown prevented ");
    
}

-(void)viewWillStartLiveResize{
    
    if (self.bounds.size.height == self.visibleRect.origin.y + self.visibleRect.size.height){
        NSLog(@"bottom!");
        m_isButtom = YES;
    }else{
        m_isButtom = NO;
    }
}


-(void)drawRect:(NSRect)dirtyRect{

    if ([self inLiveResize] && m_isButtom){
        NSRange last = NSMakeRange(self.string.length,0);
        [self scrollRangeToVisible:last];
    }

    [super drawRect:dirtyRect];
}


@end
