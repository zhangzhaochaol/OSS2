//
//  IWPPopverViewItem.m
//  OSS2.0-ios-v2
//
//  Created by 王旭焜 on 2017/10/9.
//  Copyright © 2017年 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "IWPPopverViewItem.h"
#import "IWPTools.h"
#import <objc/runtime.h>

@implementation IWPPopverViewItem
-(NSDictionary *)makeDictionary{
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    Class class = [self class];
    
    u_int count = 0;
    /* runtime 取出此类的所有属性名 */
    objc_property_t * properties = class_copyPropertyList(class, &count);
    /* 遍历属性 */
    for (int i = 0; i < count; i++) {
        
        /* 创建key */
        NSString * key = [NSString stringWithUTF8String:property_getName(properties[i])];
        id value = nil;
        if ([self respondsToSelector:NSSelectorFromString(key)]) {
            value = [self valueForKeyPath:key];
        }
        
        
        Class clazz = [super class];
        
        if ([key isEqualToString:@"handler"] || [key isEqualToString:@"handlerSelected"]) {
            continue;
        }
        
        if (value) {
            /* 设置值 */
            
            if ([value isKindOfClass:[NSArray class]]) {
                NSArray * valueArr = [value copy];
                
                if (valueArr.count > 0) {
                    if ([valueArr[0] isKindOfClass:clazz]) {
                        
                        NSMutableArray * arr = [NSMutableArray array];
                        
                        for (id model in valueArr) {
                            NSDictionary * modelDict = [model performSelector:@selector(makeDictionary)];
                            [arr addObject:modelDict];
                        }
                        
                        [dict setValue:arr forKey:key];
                        
                    }else{
                        //                        NSString * json = [valueArr makeJson];
                        NSString * json = [valueArr json];
                        [dict setValue:json forKey:key];
                    }
                }
                
            }else if ([value isKindOfClass:clazz]){
                
                NSDictionary * dic = [value performSelector:@selector(makeDictionary)];
                
                [dict setValue:dic forKey:key];
                
            }
            else{
                
                [dict setValue:value forKey:key];
            }
            
        }
    }
    free(properties);
    return dict;
}


- (NSString *)makeJSON{
    return [[self makeDictionary] json];
}

-(NSString *)description{
    return [NSString stringWithFormat:@"%@ - [<%p>:%@]", self.class, self, [self makeJSON]];
}
@end
