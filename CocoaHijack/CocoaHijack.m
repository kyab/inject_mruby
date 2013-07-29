//
//  CocoaHijack.m
//  CocoaHijack
//
//  Created by koji on 2013/06/08.
//
//

#import "CocoaHijack.h"
#include "mruby.h"
#include "mruby/compile.h"
#include "mruby/string.h"
#include "mruby/variable.h"
#include "mruby/value.h"

static CocoaHijack *sharedInstance = nil;

@implementation CocoaHijack
+ (CocoaHijack *)sharedCocoaHijack{
    
    @synchronized(self){
        if (sharedInstance == nil){
            [[self alloc] init];
        }
    }
    return sharedInstance;
}

+ (CocoaHijack *)allocWithZone:(NSZone *)zone{
    @synchronized(self){
        if (sharedInstance == nil){
            sharedInstance = [super allocWithZone:zone];
        }
    }
    return sharedInstance;
}
- (CocoaHijack *)init{
    if(self = [super init]){
        NSLog(@"Singleton Object Created");
        [self initMRuby];
    }
    return self;
}

-(void)initMRuby{
    mrb = mrb_open();
    mrb_ctx = mrbc_context_new(mrb);
    mrb_load_string_cxt(mrb, "include KYCocoa", mrb_ctx);
    mrb_load_string_cxt(mrb, "app = NSApplication.sharedApplication", mrb_ctx);
}

- (void)injectMenu{
    NSApplication *app = [NSApplication sharedApplication];
    if (!app){
        NSLog(@"failed to get app");
        return;
    }
    NSLog(@"Got sharedApplication Object");
    NSMenu *mainMenu = [app mainMenu];
    if (!mainMenu){
        NSLog(@"app does not have menu");
        return;
    }
    NSLog(@"Got mainMenu");
    
    NSMenuItem *newTopMenuItem = [mainMenu addItemWithTitle:@"mruby" action:NULL keyEquivalent:@""];
    
    m_menuInject = [[NSMenu alloc] initWithTitle:@"mruby"];
    m_menuFootest =[[NSMenuItem alloc] initWithTitle:@"foo" action:NULL keyEquivalent:@""];
    [m_menuFootest setAction:@selector(foo:)];
    [m_menuFootest setTarget:self];
    [m_menuFootest setEnabled:YES];

    m_menuExecuteLine = [[NSMenuItem alloc] initWithTitle:@"line execute" action:@selector(executeLine:)
                          keyEquivalent:@""];
    [m_menuExecuteLine setTarget:self];
    [m_menuExecuteLine setEnabled:YES];
    
    m_menuConsole = [[NSMenuItem alloc] initWithTitle:@"console"
                                               action:@selector(openConsole:) keyEquivalent:@""];
    [m_menuConsole setTarget:self];
    [m_menuConsole setEnabled:YES];
    
    m_menuSelectView = [[NSMenuItem alloc] initWithTitle:@"select view"
                                                  action:@selector(selectView:) keyEquivalent:@""];
    [m_menuSelectView setTarget:self];
    [m_menuSelectView setEnabled:YES];
    
    [m_menuInject addItem:m_menuFootest];
    [m_menuInject addItem:m_menuExecuteLine];
    [m_menuInject addItem:m_menuConsole];
    [m_menuInject addItem:m_menuSelectView];
    [m_menuInject setAutoenablesItems:NO];
    [newTopMenuItem setSubmenu:m_menuInject];
}
- (void)foo:(id)sender{
    NSLog(@"foo");
    mrb_value ret = mrb_load_string(mrb, "1+1");
    NSLog(@"1 + 1 = %d", mrb_fixnum(ret));
}

//NOP
-(void)executeLine:(id)sender{

}

- (NSString *)evalString:(NSString *)code exception:(int *)is_exception{
    
    int ai = mrb_gc_arena_save(mrb);
    mrb_value r_result = mrb_load_string_cxt(mrb, [code UTF8String], mrb_ctx);
    mrb_value r_result_str;
    NSString *result_str;
    
    if (mrb->exc){
        r_result_str = mrb_funcall(mrb, mrb_obj_value(mrb->exc), "inspect", 0);
        result_str = [NSString stringWithUTF8String:RSTRING_PTR(r_result_str)];
        NSLog(@"oops exception!");
        *is_exception = 1;
        mrb->exc = 0;
    }else{
        r_result_str = mrb_funcall(mrb, r_result, "inspect",0);
        result_str = [NSString stringWithUTF8String:RSTRING_PTR(r_result_str)];
        *is_exception = 0;
    }
    mrb_gc_arena_restore(mrb,ai);
    return result_str;
}

-(void)openConsole:(id)sender{
    m_consoleController = [[ConsoleWindowController alloc] init];
    [m_consoleController showWindow:self];
}


//pulling from F-Script source code.
#define ESCAPE '\033'
-(void)selectView:(id)sender{

    id        view;
    
    NSDate   *distantFuture = [NSDate distantFuture];
    NSView   *selectedView;
    
    NSRect infoRect = NSMakeRect(0, 0, 290, 100);
    NSTextView *infoView = [[[NSTextView alloc] initWithFrame:NSZeroRect] autorelease];
    [infoView setEditable:NO];
    [infoView setSelectable:NO];
    [infoView setDrawsBackground:NO];
    [infoView setTextColor:[NSColor whiteColor]];
    [infoView setFont:[NSFont controlContentFontOfSize:10]];
    [infoView setTextContainerInset:NSMakeSize(4, 4)];
    [infoView setVerticallyResizable:NO];
    
    NSMutableParagraphStyle *paragraphStyle = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
    [paragraphStyle setLineBreakMode:NSLineBreakByTruncatingTail];
    [infoView setDefaultParagraphStyle:paragraphStyle];
    
    NSPanel *infoWindow = [[[NSPanel alloc] initWithContentRect:infoRect styleMask:NSHUDWindowMask /*| NSTitledWindowMask*/ | NSUtilityWindowMask backing:NSBackingStoreBuffered defer:NO] autorelease];
    [infoWindow setLevel:NSFloatingWindowLevel];
    [infoWindow setContentView:infoView];
    
    // NSWindow *focusWindow = [[[NSWindow alloc] initWithContentRect:NSZeroRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO] autorelease];
    
    NSWindow *focusWindow = [[NSWindow alloc] initWithContentRect:NSZeroRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO] ;
    
    [focusWindow setBackgroundColor:[NSColor selectedTextBackgroundColor]];
    [focusWindow setAlphaValue:0.7];
    [focusWindow setIgnoresMouseEvents:YES];
    
    NSCursor *cursor = [NSCursor crosshairCursor];
    [cursor push];
    
    selectedView = nil;
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuWillSendAction:) name:NSMenuWillSendActionNotification object:nil];
    NSEvent *event;
    do
    {
        [cursor push];
        event = [NSApp nextEventMatchingMask:/*~0*/NSAnyEventMask untilDate:distantFuture inMode:NSEventTrackingRunLoopMode dequeue:YES];
        [cursor pop];
        if ([event type] == NSMouseMoved)
        {
            view = nil;
           
            NSInteger  windowCount;
            NSInteger *windows;
            NSCountWindows(&windowCount);
            windows = malloc(windowCount*sizeof(NSInteger));
            NSWindowList(windowCount, windows);
            
            for (unsigned i = 0; i < windowCount; i++)
            {
                NSWindow *window = [NSApp windowWithWindowNumber:windows[i]];
                if (window && window != focusWindow && window != infoWindow)
                {
                    view = [[[window contentView] superview] hitTest:[window convertScreenToBase:[NSEvent mouseLocation]]];
                    if (view) break;
                }
            }
            
            free(windows);
            
            if (view)
            {
                NSRect rectInWindowCoordinates = [view convertRect:[view visibleRect] toView:nil];;
                NSRect rectInScreenCoordinates;
                NSSize size = NSMakeSize(220,21);
                rectInScreenCoordinates.size = rectInWindowCoordinates.size;
                rectInScreenCoordinates.origin = [[view window] convertBaseToScreen:rectInWindowCoordinates.origin];
                
                if ([focusWindow parentWindow] != [view window])
                {
                    [[focusWindow parentWindow] removeChildWindow:focusWindow];
                    [[view window] addChildWindow:focusWindow ordered:NSWindowAbove];
                }
                [focusWindow setFrame:rectInScreenCoordinates display:YES];
                
                NSPoint origin = NSMakePoint([NSEvent mouseLocation].x+12, [NSEvent mouseLocation].y-size.height-9);
                [infoWindow setFrame:NSMakeRect(origin.x, origin.y, size.width, size.height) display:YES animate:NO];
                [infoView setString:[NSString stringWithFormat:@"%@: %p", [view class], view]];
                
                [infoWindow orderFront:nil];
            }
            else
            {
                [[focusWindow parentWindow] removeChildWindow:focusWindow];
                [focusWindow orderOut:nil];
                [infoWindow orderOut:nil];
            }
        }
        
    }
    while ( [event type] != NSLeftMouseDown && selectedView == nil && !([event type] == NSKeyDown && [[event characters] characterAtIndex:0] == ESCAPE) );
    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSMenuWillSendActionNotification object:nil];
    [cursor pop];
    [[focusWindow parentWindow] removeChildWindow:focusWindow];
    [focusWindow close];
    [infoWindow close];
    
    selectedView = view;
    
    if ( !([event type] == NSKeyDown && [[event characters] characterAtIndex:0] == ESCAPE) )
    {
        if (selectedView){
            NSLog(@"View selected %@",selectedView);
        }
//        if (selectedView == nil)
//            view = [[[[event window] contentView] superview] hitTest:[event locationInWindow]];
//        else
//            view = selectedView;
//        
//        [self setRootObject:view];
//        [selectedView release];
//        [[self window] performSelector:@selector(makeKeyAndOrderFront:) withObject:nil afterDelay:0];
        [NSApp activateIgnoringOtherApps:YES];
    }

}

/* 
  LLDB debugging sample.
 
 (lldb) expr (char)[[NSBundle bundleWithPath:@"/Users/koji/work/mruby/inject_mruby/build/inject_mruby/Build/Products/Debug/CocoaHijack.framework"] load]
 (char) $0 = '\x01'
 (lldb) expr (CocoaHijack *)[CocoaHijack sharedCocoaHijack]
 (CocoaHijack *) $1 = 0x00000001086191f0
 (lldb) expr [$1 foo]
 2013-06-09 01:50:20.400 Safari[57233:303] foo
 
*/

@end
