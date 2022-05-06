//
//  Yuan_LoginService.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/7/19.
//  Copyright © 2021 青岛英凯利信息科技有限公1司. All rights reserved.
//

#import "Yuan_LoginService.h"


// 仅登录接口
static NSString * _httpOnlyLogin = @"pdaLogin!loginOnly.interface";

// 仅获取权限接口
static NSString * _httpOnlyGetPower = @"pdaLogin!getPowers.interface";

@implementation Yuan_LoginService


/// 不用管成功还是失败 后台只是计数
+ (void) http_LoginStatistics {
    
    
    [Http.shareInstance DavidJson_NOHUD_PostURL:@"http://120.52.12.12:8951/increase-gateway/statApi/recordLogin"
                                          Parma:@{@"username":UserModel.userName ?: @""}
                                        success:^(id result) {}];
}




//
/// 单独登录 但不返回权限
+ (void) http_Login:(NSDictionary *) parma
            success:(httpSuccessBlock)success {
    
    
    [Yuan_LoginService httpLoginPost:_httpOnlyLogin
                                 HUD:@"登录中 ..."
                             timeOut:60
                                dict:parma
                             succeed:^(id data) {
            
        
        success(data);
        
    }];
    
}




/// 单独请求权限的接口
+ (void) http_LoginSelectPowers:(NSDictionary *) parma
                        success:(httpSuccessBlock)success {
    
    
    
    [Yuan_LoginService httpLoginPost:_httpOnlyGetPower
                                 HUD:@"请求统一库权限"
                             timeOut:30
                                dict:parma
                             succeed:^(id data) {
            
        success(data);
        
    }];
    
}



#pragma mark - 抽离处理的网络请求 ---

+ (void)httpLoginPost:(NSString *)URLString
                  HUD:(NSString *) hudStr
              timeOut:(float) timeOut
                 dict:(NSDictionary *)dict
              succeed:(void (^)(id data))succeed {
    
    
    

    NSMutableDictionary * dictionary = [NSMutableDictionary dictionaryWithDictionary:dict];

  
    #ifdef BaseURL
        NSString * baseURL = BaseURL;
    #else
        NSString * baseURL = [NSString stringWithFormat:@"http://%@/",Http.zbl_BaseUrl];
    #endif

    
    NSString * url = [NSString stringWithFormat:@"%@%@",baseURL,URLString];
    
    
    [[Yuan_HUD shareInstance] HUDStartText:hudStr];
    

    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];

    manager.requestSerializer = [[AFHTTPRequestSerializer alloc] init];
    manager.responseSerializer = [[AFHTTPResponseSerializer alloc] init];


    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/javascript",@"text/html", nil];

    manager.requestSerializer.timeoutInterval = timeOut;


    //无条件的信任服务器上的证书

    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];

    // 客户端是否信任非法证书

    securityPolicy.allowInvalidCertificates = YES;

    // 是否在证书域字段中验证域名

    securityPolicy.validatesDomainName = NO;

    manager.securityPolicy = securityPolicy;


    // 将参数添加到请求头中

    NSArray *languages = [NSLocale preferredLanguages];
    NSString *currentLanguage = [languages objectAtIndex:0];

    [manager.requestSerializer setValue:currentLanguage forHTTPHeaderField:@"Content-language"];
    
    [manager POST:url parameters:dictionary progress:nil
          success:^(NSURLSessionDataTask *task, id responseObject) {
        
        // 状态栏菊花停止旋转
        
        
        // json对象转dict

        NSMutableDictionary *requestDict =
        [NSJSONSerialization JSONObjectWithData:responseObject
                                        options:NSJSONReadingMutableLeaves
                                          error:nil];
        
        [[Yuan_HUD shareInstance] HUDHide];
        
        NSString * result = requestDict[@"result"];
        NSNumber * success_bool = requestDict[@"success"];
        
        NSString * info_Json = [requestDict objectForKey:@"info"];
        info_Json = [info_Json stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
        info_Json = [info_Json stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        info_Json = [info_Json stringByReplacingOccurrencesOfString:@"\t" withString:@""];
        info_Json = [info_Json stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        
        
        if ([result integerValue] == 0 && success_bool.boolValue == YES) {
            // 成功
            NSData *tempData=[REPLACE_HHF(info_Json) dataUsingEncoding:NSUTF8StringEncoding];
            
            id data =
            [NSJSONSerialization JSONObjectWithData:tempData
                                            options:NSJSONReadingMutableLeaves
                                              error:nil];
            
            if (succeed) {
                
                // 判断数据类型是否错误
                if ([data isEqual:[NSNull null]]) {
                    [[Yuan_HUD shareInstance] HUDFullText:@"数据格式错误 NULL"];
                    return ;
                }
                
                succeed(@{
                    @"result" :result,
                    @"data" : data
                });
                
                NSLog(@"%@", @{
                    @"result" :result,
                    @"data" : data
                }.json);

            }
            
        }
        else {
            if (succeed) {
                
                succeed(@{
                    @"result" :result,
                    @"info" : requestDict[@"info"]
                });
                
                NSLog(@"%@", @{
                    @"result" :result,
                    @"info" : requestDict[@"info"]
                }.json);
            }
        }
        
        
        
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        
        
        
        [[Yuan_HUD shareInstance] HUDHide];
        
        succeed(nil);
    }];
    
}


@end
