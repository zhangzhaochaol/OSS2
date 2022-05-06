//
//  ExtensionCocoa.m
//  守望者手环
//
//  Created by Ryan on 16/9/6.
//  Copyright © 2016年 Ryan Treem. All rights reserved.
//

#import "ExtensionCocoa.h"
#import "MJExtension.h"
@implementation ExtensionCocoa

+(id)extensionCocoaWithClass:(NSString *)class_ DataDict:(NSDictionary *)dict{

    id class = [[NSClassFromString(class_) alloc]init];
    class = [NSClassFromString(class_) mj_objectWithKeyValues:dict];
    return class;
}

@end
