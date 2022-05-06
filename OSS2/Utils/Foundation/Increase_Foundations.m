 //
//  Increase_Foundations.m
//  javaScript_ObjectC
//
//  Created by yuanquan on 2022/3/11.
//

#import "Increase_Foundations.h"

@implementation Increase_Foundations

/// 移除字符串中的空格
+ (NSString *)removeSpaceAndNewline:(NSString *)str {
    
    NSString *temp = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return temp;
}



/// 判断字符串是否为纯数字
+ (BOOL)isNumber:(NSString *)strValue {
    
    if (strValue == nil || [strValue length] <= 0)
    {
        return NO;
    }
    
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789."] invertedSet];
    NSString *filtered = [[strValue componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    
    if (![strValue isEqualToString:filtered])
    {
        return NO;
    }
    return YES;
}


/// json 解析
NSString * json (id data) {
    
    if ([NSJSONSerialization isValidJSONObject:data]) {
        
        NSError * error = nil;
        
        NSData * myData = [NSJSONSerialization dataWithJSONObject:data options:0 error:&error];
        
        if (error == nil) {
            
            NSString * json = [[NSString alloc] initWithData:myData
                                                    encoding:NSUTF8StringEncoding];
            
            return json;
        }
        
    }
    
    return nil;
}

@end
