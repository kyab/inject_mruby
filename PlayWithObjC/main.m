//
//  main.m
//  PlayWithObjC
//
//  Created by koji on 2013/07/18.
//
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

int main(int argc, const char * argv[])
{
	SEL selector = sel_registerName("stringByAppendingString:");
	printf("selector name = %s\n", sel_getName(selector));
    
	id klass = objc_lookUpClass("NSString");
    
	NSString *instance = [NSString stringWithUTF8String:"Hi Hoo!"];
	printf("instance:%s\n",[instance UTF8String]);
	Method method = class_getInstanceMethod(klass, selector);
	if (method){
		const char *encoding = method_getTypeEncoding(method);
		printf("method encoding:%s\n", encoding);
	}else{
		printf("failed to get method:%s\n",sel_getName(selector));
	}

    @autoreleasepool {
        
        // insert code here...
        NSLog(@"Hello, World!");
        
    }
    return 0;
}

