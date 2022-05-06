//
//  BaseModel.m
//  守望者
//
//  Created by Ryan on 17/3/22.
//  Copyright © 2017年 Yuan. All rights reserved.
//

#import "BaseModel.h"
#import "ExtensionCocoa.h"

@implementation BaseModel

-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
    
    
}

- (id)valueForUndefinedKey:(NSString *)key {
    
    return @"";
    
}


+ (id)Json:(NSDictionary *)dict {
    
    id class = [[self alloc] init];
    
    class =  [self mj_objectWithKeyValues:dict];
    
    return class;
}

@end
