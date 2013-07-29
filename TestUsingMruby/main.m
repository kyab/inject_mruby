//
//  main.m
//  TestUsingMruby
//
//  Created by koji on 2013/06/07.
//
//

#import <Foundation/Foundation.h>
#include <mruby.h>
#include <mruby/compile.h>
#include <mruby/value.h>
#include <mruby/variable.h>
#include <mruby/string.h>
#include <mruby/class.h>

void test_class(mrb_state *mrb){
    
    //getting RClass * from c-string
    struct RClass *foo_class = mrb_class_get(mrb, "Foo");
    
    //convert RClass * to mrb_value
    mrb_value r_class_value = mrb_obj_value(foo_class);
    
    //convert back to RClass * 
    struct RClass * foo_class2 = mrb_class_ptr(r_class_value);
    
    //call new(malloc and initialize)
    mrb_value arg1 = mrb_str_new_cstr(mrb, "foo");
    mrb_class_new_instance(mrb, 1, &arg1, foo_class2);
//
//    mrb_class_new_instance(mrb, 1 ,&arg1, mrb->string_class);
    
//    mrb_value instance = mrb_funcall(mrb, r_class_value, "new", 1, &arg1);

}
                     
mrb_value foo_initialize(mrb_state *mrb, mrb_value self){
    mrb_value str;
    mrb_get_args(mrb, "S", &str);
    printf("Foo#initialize(%s)\n", RSTRING_PTR(str));
    return self;
}

void test_metaclass(mrb_state *mrb){
    struct RClass *bar_class = mrb_define_class(mrb, "Bar", NULL);
    
    //put void pointer in class's instance variable
    void *p = (void *)0x11223344;
    mrb_value bar_class_obj = mrb_obj_value(bar_class);
    mrb_iv_set(mrb, bar_class_obj, mrb_intern_cstr(mrb, "@pointer"), mrb_voidp_value(mrb, p));
    
    //mrb_cv_set??
    
    //create new instance
    mrb_value instance = mrb_class_new_instance(mrb, 0, NULL, bar_class);
    
    //ensure class name is "Bar"
    struct RClass *bar_class2 = mrb_obj_class(mrb, instance);
    printf("class name of instance:%s\n", mrb_class_name(mrb, bar_class2));
    //same : mrb_obj_classname(mrb, instance);
    if (mrb_obj_is_instance_of(mrb, instance, bar_class2)){
        printf("instance of ok\n");
    }
    if (mrb_obj_is_kind_of(mrb, instance, bar_class2)){
        printf("is kind of ok\n");
    }
    
    //get class object from instance, then get pointer from class's instance variable
    mrb_value mrb_bar_class_obj2 = mrb_obj_value(mrb_obj_class(mrb, instance));
    mrb_value rval_pointer = mrb_iv_get( mrb, mrb_bar_class_obj2, mrb_intern_cstr(mrb, "@pointer"));
    if (p == mrb_voidp(rval_pointer)){
        printf("SUCCESS!\n");
    }
    
}

int main(int argc, const char * argv[])
{
    mrb_state *mrb = mrb_open();
    
    mrb_value result = mrb_load_string(mrb, "1+1");
    mrb_int intresult = mrb_fixnum(result);
    NSLog(@"1+1 = %d",intresult);
    
    result = mrb_load_string(mrb, "String.new(\"ffffff\")");
    NSLog(@"String.new = %s",RSTRING_PTR(result));
    
    struct RClass *foo_class = mrb_define_class(mrb, "Foo",NULL);
    mrb_define_method(mrb, foo_class, "initialize", foo_initialize, ARGS_REQ(1));
    test_class(mrb);
    
    test_metaclass(mrb);
    mrb_close(mrb);

    @autoreleasepool {
        
        // insert code here...
        NSLog(@"Hello, World!");
        
    }
    return 0;
}

