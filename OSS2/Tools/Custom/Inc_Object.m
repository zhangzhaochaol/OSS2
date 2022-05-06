//
//  Inc_Object.m
//  javaScript_ObjectC
//
//  Created by yuanquan on 2022/4/19.
//

#import "Inc_Object.h"
static NSString * kError = nil;
@implementation NSObject (Inc_Object)

-(NSString *)json{
    
    if ([NSJSONSerialization isValidJSONObject:self]) {
        
        NSError * error = nil;
        
        NSData * data = [NSJSONSerialization dataWithJSONObject:self options:0 error:&error];
        
        if (error == nil) {
            
            NSString * json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            return json;
        }else{
            
            kError = [NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"{\"error\":\"%@\"}", error.localizedDescription]];
            
            return kError;
        }
        
    }else{
        
        return @"无法解析的数据类型";
    }
}


-(NSString *)json_Yuan{
    
    if ([NSJSONSerialization isValidJSONObject:self]) {
        
        NSError * error = nil;
        
        NSData * data = [NSJSONSerialization dataWithJSONObject:self options:0 error:&error];
        
        if (error == nil) {
            
            NSString * json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            return json;
        }else{
            
            kError = [NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"{\"error\":\"%@\"}", error.localizedDescription]];
            
            return kError;
        }
        
    }else{
        
        return @"无法解析的数据类型";
    }
}

-(id)object{
    NSData * data = nil;
    
    if ([self isKindOfClass:[NSString class]]) {
        data = [(NSString *)self dataUsingEncoding:NSUTF8StringEncoding];
    }else if ([self isKindOfClass:[NSData class]]){
        data = (NSData *)self;
    }else{
        
        
        NSString * error = [NSString stringWithFormat:@"JSON - 错误的数据类型：%@", self];
        kError = error;
        NSLog(@"%@", error);
        
        return nil;
    }
    
    if (data) {
        
        NSError * error = nil;
        
        id obj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        
        if (error == nil) {
            return obj;
        }else{
            
            kError = error.localizedDescription;
            return @{@"error":error.localizedDescription};
        }
        
    }else{
        kError = [NSString stringWithFormat:@"JSON - 错误的数据类型：%@", self];
        return @{@"error":kError};
    }
}



- (NSString *)sdkPath {
    
    if (![self isKindOfClass:[NSString class]]) {
        return @"";
    }
    
    NSString * path = @"OSS2_SDKImage";
    
    return [NSString stringWithFormat:@"%@/%@",path,self];
    
}

@end
