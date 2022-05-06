//
//  IWPServerService.m
//  OSS2.0-ios-v2
//
//  Created by 王旭焜 on 2017/9/1.
//  Copyright © 2017年 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "IWPServerService.h"
#import "IWPServerModel.h"
#import "MBProgressHUD.h"
static IWPServerService * service = nil;

@interface IWPServerService ()
@end

@implementation IWPServerService

+(instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (service == nil) {
            service = [super allocWithZone:zone];
            
            [service gettingLink:nil];
        }
    });
    return service;
}

+(instancetype)sharedService{

    return [[self alloc] init];
}

-(void)serverList:(dispatch_block_t)block{
    
    if (_servers == nil) {
        [self gettingLink:block];
    }else{
        if (block) {
            block();
        }
    }
    
    
}

-(id)copyWithZone:(NSZone *)zone{
    return service;
}
-(id)mutableCopyWithZone:(NSZone *)zone{
    return service;
}


// Mark: 获取服务器地址

- (void)gettingLink:(dispatch_block_t)block{
    

    // 读取data文件
#ifdef DEBUG
    NSData * data = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"serverTest" ofType:@"data"]];
#else
    NSData * data = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"serverRelease" ofType:@"data"]];
#endif
    
    
    
    // 转为base64字符串
    NSString * base64Str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    // 解base64为data
    NSData * json = [[NSData alloc] initWithBase64EncodedString:base64Str options:0];
  
    if (json) {
        
        
        NSLog(@"%@", [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding]);
        
        
        NSError * err = nil;
        NSArray * servers = [NSJSONSerialization JSONObjectWithData:json options:NSJSONReadingAllowFragments error:&err];
        
        if (err) {
            _errMessage = err.localizedDescription;
            NSLog(@"%@", _errMessage);
        }else{
            
            [self createServerList:servers];
            
            if (block) {
                block();
            }
            
        }
        
    }
    
    
}

-(void)createServerList:(NSArray *)servers{
    
    NSMutableArray * links = [NSMutableArray array];
    
    for (NSDictionary * dict in servers) {
        
        IWPServerModel * model = [IWPServerModel modelWithDict:dict];
        
        [links addObject:model];
        
    }
    
    _servers = links;
    
}

- (NSData *)dataFromHexString:(NSString *)str{
    const char *chars = [str UTF8String];
    NSUInteger i = 0, len = str.length;
    
    NSMutableData *data = [NSMutableData dataWithCapacity:len / 2];
    char byteChars[3] = {'\0','\0','\0'};
    unsigned long wholeByte;
    
    while (i < len) {
        byteChars[0] = chars[i++];
        byteChars[1] = chars[i++];
        wholeByte = strtoul(byteChars, NULL, 16);
        [data appendBytes:&wholeByte length:1];
    } 
    
    NSLog(@"data = %@", data);
    
    return data; 
}

-(NSData*)stringToByte:(NSString*)string
{
    NSString *hexString=[[string uppercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSLog(@"%lu", (unsigned long)hexString.length);
    
    if ([hexString length]%2!=0) {
        return nil;
    }
    Byte tempbyt[1]={0};
    NSMutableData* bytes=[NSMutableData data];
    for(int i=0;i<[hexString length];i++)
    {
        unichar hex_char1 = [hexString characterAtIndex:i]; ////两位16进制数中的第一位(高位*16)
        int int_ch1;
        if(hex_char1 >= '0' && hex_char1 <='9')
            int_ch1 = (hex_char1-48)*16;   //// 0 的Ascll - 48
        else if(hex_char1 >= 'A' && hex_char1 <='F')
            int_ch1 = (hex_char1-55)*16; //// A 的Ascll - 65
        else
            return nil;
        i++;
        
        unichar hex_char2 = [hexString characterAtIndex:i]; ///两位16进制数中的第二位(低位)
        int int_ch2;
        if(hex_char2 >= '0' && hex_char2 <='9')
            int_ch2 = (hex_char2-48); //// 0 的Ascll - 48
        else if(hex_char2 >= 'A' && hex_char2 <='F')
            int_ch2 = hex_char2-55; //// A 的Ascll - 65
        else
            return nil;
        
        tempbyt[0] = int_ch1+int_ch2;  ///将转化后的数放入Byte数组里
        [bytes appendBytes:tempbyt length:1];
    }
    
    
    
    return bytes;
}



-(void)setCurrentLink:(IWPServerModel *)model{
    
    _link = nil;
    _link = [NSString stringWithFormat:@"%@:%ld/%@", model.host, (long)model.port, model.appName];
    
    NSLog(@"%@", _link);
}



@end
