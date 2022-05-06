//
//  INCBarButtonItem.m
//  INCP&EManager
//
//  Created by 王旭焜 on 2018/9/4.
//  Copyright © 2018年 Tsingtao Increase S&T SY co., ltd. All rights reserved.
//

#import "INCBarButtonItem.h"
#import <objc/runtime.h>
@implementation UIBarButtonItem (INCBarButtonItem)

-(void)setId:(NSString *)id{
    [self willChangeValueForKey:@"id"];
    objc_setAssociatedObject(self, @"id", id, OBJC_ASSOCIATION_RETAIN);
    [self didChangeValueForKey:@"id"];
}
-(NSString *)id{
    id object = objc_getAssociatedObject(self, @"id");
    return object;
}
-(void)setMainView:(UIView *)mainView{
    
    
    
    [self willChangeValueForKey:@"mainView"];
    objc_setAssociatedObject(self, @"mainView", mainView, OBJC_ASSOCIATION_RETAIN);
    [self didChangeValueForKey:@"mainView"];
    
}

-(UIView *)mainView{
    id object = objc_getAssociatedObject(self, @"mainView");
    return object;
}

@end
