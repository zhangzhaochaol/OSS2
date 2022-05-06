//
//  INCBaseModel.m
//  ChinaUnicom_Liaoning
//
//  Created by 王旭焜 on 2018/3/21.
//  Copyright © 2018年 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "INCBaseModel.h"
#import <objc/runtime.h>
@interface INCBaseModel ()

@end

@implementation INCBaseModel
+(NEW)create{
    
    return ^ id (NSDictionary * dict){
      
        return [self modelWithDict:dict];
        
    };
    
}
- (instancetype)initWithDict:(NSDictionary *)dict{

    for (NSString * key in dict.allKeys) {
        
        if ([self respondsToSelector:NSSelectorFromString(key)] && ![key isEqualToString:@"hash"]) {
            
            [self setValue:dict[key] forKey:key];
        }else{
            if (![key isEqualToString:@"hash"]) {
#if DEBUG
                printf("%s\n", NSStringFromClass(self.class).UTF8String);
                printf("@property (nonatomic, <#WHAT#>) <#CLASS#> * %s;\n", key.UTF8String);
                
#endif
            }
        }
        
    }
    return self;
}

+ (instancetype)modelWithDict:(NSDictionary *)dict{
    return [[self alloc] initWithDict:dict];
}
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
        
        
        Class clazz = [INCBaseModel class];
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
//                        NSString * json = valueArr.json;
                        [dict setValue:valueArr forKey:key];
                    }
                }
                
            }else if ([value isKindOfClass:clazz]){
                
                NSDictionary * dic = [value performSelector:@selector(makeDictionary)];
                
                [dict setValue:dic forKey:key];
                
            }else{
                
                if (![key isEqualToString:@"coordinate"]) {
                    [dict setValue:value forKey:key];
                }
            }
            
        }
    }
    free(properties);
    return dict;
}


- (NSString *)makeJSON{
    return self.makeDictionary.json;
}

-(NSString *)description{
    return [NSString stringWithFormat:@"<%@:%p>%@", self.class, self, [self makeJSON]];
}
//- (void)encodeWithCoder:(nonnull NSCoder *)coder {
//    
//}
//
//- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder {
//    
//}

@end

@implementation NSObject (INCBaseModel)

@end
