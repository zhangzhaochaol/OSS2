//
//  IWPServerModel.m
//  OSS2.0-ios-v2
//
//  Created by 王旭焜 on 2017/9/1.
//  Copyright © 2017年 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "IWPServerModel.h"

@implementation IWPServerModel
+(instancetype)modelWithDict:(NSDictionary *)dict{
    
    return [[self alloc] initWithDict:dict];
}

-(instancetype)initWithDict:(NSDictionary *)dict{
    
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
    }
    
    return self;
    
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"SCHAME:%@, HOST:%@, PROT:%ld, APPNAME:%@, SERVERNAME:%@, DISPLAYIP:%@",self.schame, self.host, (long)self.port, self.appName, self.serverName, self.displayIP];
}

-(void)setHost:(NSString *)host{
    _host = host;
    
    NSArray * ipaddr = [host componentsSeparatedByString:@"."];
    NSString * ip = @"";
    
    
    for (int i = 0; i < ipaddr.count; i++) {
        
        if (i == 1 || i == 2) {
            ip = [ip stringByAppendingString:@"***."];
        }else{
            ip = [ip stringByAppendingString:[NSString stringWithFormat:@"%@.", ipaddr[i]]];
        }
        
    }
    
    ip = [ip substringWithRange:NSMakeRange(0, ip.length - 1)];
    
    
    self.displayIP = ip;
    
    
}

@end
