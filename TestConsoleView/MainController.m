//
//  MainController.m
//  inject_mruby
//
//  Created by koji on 2013/07/20.
//
//

#import "MainController.h"
#include <stdio.h>


@implementation MainController
-(void) awakeFromNib{
    NSLog(@"MainController awaken from NIB");
    [mTextView setExecuter:self];
    
}

-(NSString *)execute:(NSString *)code exception:(int *)is_exception{
    NSString *result = @"echo back : ";
    *is_exception = 0;
    return [result stringByAppendingString:code];
}

-(IBAction)onButton:(id)sender{
    NSLog(@"Pushed!");
    NSRange range;
    range = NSMakeRange ([[mTextView string] length], 0);
    
    [mTextView replaceCharactersInRange: range withString:@"pushed"];
}

-(IBAction)onPrintf:(id)sender{
    printf("Hi from printf");
}



@end
