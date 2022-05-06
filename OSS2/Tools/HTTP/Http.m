//
//  Http.m
//
//  Created by Ryan on 17/3/13.
//  Copyright © 2017年 Yuan. All rights reserved.
//

#import "Http.h"


#import "Yuan_WebService.h"

#pragma mark - 枚举值

typedef NS_ENUM(NSUInteger , HttpPort_) {
    HttpPort_Online,        //线上
    HttpPort_David,         //大为电脑
    HttpPort_zhengXY,       //郑小英电脑
    HttpPort_wangYJ,        //王宇佳电脑
    HttpPort_SunSZ,        //其他
};
 

typedef NS_ENUM(NSUInteger, Http_ZBL_URL_) {
    Http_ZBL_URL_LocalHost,     //龙哥电脑-本地
    Http_ZBL_URL_Online,        //线上正式版 120
};


// 根据枚举值 修改对应后台人员的端口号 -- 王大为接口
static HttpPort_ _httpPortEnum = HttpPort_Online;



// 根据枚举值 修改对应朱贝龙服务
static Http_ZBL_URL_ _zbl_PortEnum = Http_ZBL_URL_Online;

#pragma mark - ------------

@implementation Http

static Http *http = nil;

+ (Http *)shareInstance {
    
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        http = [[self alloc] init];
    });
    return http;
}

+(instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (http == nil) {
            http = [super allocWithZone:zone];
        }
    });
    return http;
}


- (instancetype)copyWithZone:(NSZone *)zone
{
    return http;
}



#pragma mark - URL ---

// 通用查询
+ (NSString *) David_SelectUrl {
    
    #ifdef RELEASE
        _httpPortEnum = HttpPort_Online;
    #endif
    
    switch (_httpPortEnum) {
            
            // 线上接口
        case HttpPort_Online:
            return @"http://120.52.12.12:8951/increase-res-search/";
            break;
            
            // 大为本地接口
        case HttpPort_David:
            return @"http://192.168.1.9:8951/";
            break;
            
            // 郑小英本地接口
        case HttpPort_zhengXY:
            return @"http://192.168.1.28:8951/";
            break;
            
            // 王宇佳本地接口
        case HttpPort_wangYJ:
            return @"http://192.168.1.67:8951/";
            break;
            
            // 其他本地接口  只需要改端口号就行
        case HttpPort_SunSZ:
            return @"http://192.168.1.59:8951/";
            break;
            
        default:
            break;
    }
    
    return @"";
}


// 通用修改
+ (NSString *) David_ModifiUrl {
    
    #ifdef RELEASE
        _httpPortEnum = HttpPort_Online;
    #endif
    
    switch (_httpPortEnum) {
            
            // 线上接口
        case HttpPort_Online:
            return @"http://120.52.12.12:8951/increase-res-operation/";
            break;
            
            // 大为本地接口
        case HttpPort_David:
            return @"http://192.168.1.9:8009/";
            break;
            
            // 郑小英本地接口
        case HttpPort_zhengXY:
            return @"http://192.168.1.28:8009/";
            break;
            
            // 王宇佳本地接口
        case HttpPort_wangYJ:
            return @"http://192.168.1.67:8009/";
            break;
            
            // 其他本地接口  只需要改端口号就行
        case HttpPort_SunSZ:
            return @"http://192.168.1.59:8009/";
            break;
            
        default:
            break;
    }
    
    return @"";
}


// 联通删除
+ (NSString *) David_DeleteUrl {
    
    #ifdef RELEASE
        _httpPortEnum = HttpPort_Online;
    #endif
    
    switch (_httpPortEnum) {
            
            // 线上接口
        case HttpPort_Online:
            return @"http://120.52.12.12:8951/increase-union-common/";
            break;
            
            // 大为本地接口
        case HttpPort_David:
            return @"http://192.168.1.9:8004/";
            break;
            
            // 郑小英本地接口
        case HttpPort_zhengXY:
            return @"http://192.168.1.28:8004/";
            break;
            
            // 王宇佳本地接口
        case HttpPort_wangYJ:
            return @"http://192.168.1.67:8004/";
            break;
            
            // 其他本地接口  只需要改端口号就行
        case HttpPort_SunSZ:
            return @"http://192.168.1.59:8004/";
            break;
            
        default:
            break;
    }
    
    return @"";
}

/// 新增的C语言函数
NSString * David_SelectUrl (NSString * url) {
    return [NSString stringWithFormat:@"%@%@",Http.David_SelectUrl,url];
}


NSString * David_ModifiUrl (NSString * url) {
    return [NSString stringWithFormat:@"%@%@",Http.David_ModifiUrl,url];
}

NSString * David_DeleteUrl (NSString * url) {
    return [NSString stringWithFormat:@"%@%@",Http.David_DeleteUrl,url];
}





#pragma mark - 朱贝龙接口 地址配置 ---


+ (NSString *) zbl_BaseUrl {
    
    #ifdef RELEASE
        return @"120.52.12.11:8080/im";
    #endif
    
    
    switch (_zbl_PortEnum) {
            
        case Http_ZBL_URL_LocalHost:        //龙哥电脑
            return @"192.168.1.8:8888/im";
            break;
                     
        case Http_ZBL_URL_Online:           //线上服务器
            return @"120.52.12.11:8080/im";
            break;
            
        default:
            break;
    }
    
}



+ (NSString *) zbl_SourceUrl {
    
    #ifdef RELEASE
        return @"120.52.12.12:8951/configur";
    #endif
    
    
    switch (_zbl_PortEnum) {
            
        case Http_ZBL_URL_LocalHost:        //龙哥电脑下载模板等资源
            return @"192.168.1.8:8888/im";
            break;
                     
        case Http_ZBL_URL_Online:           //线上下载模板等资源的
            return @"120.52.12.12:8951/configur";
            break;
            
        default:
            break;
    }
    
}



+ (NSString *) zbl_BaseUrl_Http {
    
    return [NSString stringWithFormat:@"http://%@",Http.zbl_BaseUrl];
}
+ (NSString *) zbl_SourceUrl_Http {
    return [NSString stringWithFormat:@"http://%@",Http.zbl_SourceUrl];
}




/**
 *  封装AFN的POST请求
 *
 *  @param URLString 网络请求地址
 *  @param dict      参数(可以是字典或者nil)
 *  @param succeed   成功后执行success block
 */


#pragma mark - 默认的 Post  **** **** **** ****  智能判障还在用

- (void)POST:(NSString *)URLString
        dict:(NSDictionary *)dict
     succeed:(void (^)(id data))succeed {
    
    
    

    [[Yuan_HUD shareInstance] HUDStartText:@"正在努力加载中.."];
    
    AFHTTPSessionManager *manager = [self managerConfig];

    NSLog(@"-- URL:%@  \nJSON: %@",URLString,dict.json);
    
    [manager POST:URLString parameters:dict progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        // json对象转dict

        NSMutableDictionary *requestDict =
        [NSJSONSerialization JSONObjectWithData:responseObject
                                        options:NSJSONReadingMutableLeaves
                                          error:nil];
        
        // 发送日志
        NSMutableDictionary * mt_Dict = [NSMutableDictionary dictionaryWithDictionary:dict];
        mt_Dict[@"goParams"] = @"1";
        
        [Http.shareInstance httpStatistic:URLString paramJson:mt_Dict];
        
        [[Yuan_HUD shareInstance] HUDHide];
        
        succeed(requestDict);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        
        
        
        [[Yuan_HUD shareInstance] HUDHide];
        [[Yuan_HUD shareInstance] HUDFullText:error.domain];
    }];
    
}




- (void)GET:(NSString *)URLString
       dict:(NSDictionary *)dict
    succeed:(void (^)(id data))succeed {
    
    
    

    [[Yuan_HUD shareInstance] HUDStartText:@"正在努力加载中.."];
    
    AFHTTPSessionManager *manager = [self managerConfig];
    
    [manager GET:URLString
      parameters:dict progress:nil
         success:^(NSURLSessionDataTask *task,
                   id responseObject) {
            
        // 状态栏菊花停止旋转
        
        
        // json对象转dict

        NSMutableDictionary *requestDict =
        [NSJSONSerialization JSONObjectWithData:responseObject
                                        options:NSJSONReadingMutableLeaves
                                          error:nil];
        
        
        [[Yuan_HUD shareInstance] HUDHide];
        succeed(requestDict);
        
    }
         failure:^(NSURLSessionDataTask *task,
                   NSError *error) {
        
        
        
        [[Yuan_HUD shareInstance] HUDHide];
        [[Yuan_HUD shareInstance] HUDFullText:error.domain];
        
    }];
    
    
}



#pragma mark - V2龙哥接口 专用 Post  **** **** **** ****


- (void)V2_POST:(NSString *)URLString
           dict:(NSDictionary *)dict
        succeed:(void (^)(id data))succeed {
    
    
    


    
    NSString * json = dict.json;
    NSLog(@"-- json: %@",json);
    NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
    dictionary[@"jsonRequest"] = json;
    dictionary[@"UID"] = UserModel.uid; 
    
    
    
    
    #ifdef BaseURL
        NSString * baseURL = BaseURL;
    #else
        NSString * baseURL = [NSString stringWithFormat:@"http://%@/",Http.zbl_BaseUrl];
    #endif

   
   
    
    NSString * url = [NSString stringWithFormat:@"%@%@",baseURL,URLString];
    
    NSString * HUDStr = @"正在努力加载中..";
    
    if ([URLString isEqualToString:ODFModel_InitPie]) {
        HUDStr = @"创建模块需要时间过长，请耐心等待...";
    }
    
    
    [[Yuan_HUD shareInstance] HUDStartText:HUDStr];
    

    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];

    manager.requestSerializer = [[AFHTTPRequestSerializer alloc] init];
    manager.responseSerializer = [[AFHTTPResponseSerializer alloc] init];


    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/javascript",@"text/html", nil];

    manager.requestSerializer.timeoutInterval = 600;


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
        
        
        if ([result integerValue] == 0 && success_bool.boolValue == YES) {
            // 成功
            [[Yuan_HUD shareInstance] HUDHide];
            NSString * info_Json = [requestDict objectForKey:@"info"];
            
            info_Json = [info_Json stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
            info_Json = [info_Json stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            info_Json = [info_Json stringByReplacingOccurrencesOfString:@"\t" withString:@""];
            info_Json = [info_Json stringByReplacingOccurrencesOfString:@"\r" withString:@""];
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
                
                succeed(data);
            }
            
        }else {
            NSLog(@"🙁-- 错误日志 : \n%@\nURL:%@\njson:%@",requestDict.json,url.json,dictionary.json);
            // 请求成功 但返回失败
//            @"模块/端子板名称：moduleName要求唯一(统一库中已存在)"
        }
        
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        
        
        
        [[Yuan_HUD shareInstance] HUDHide];
        [[Yuan_HUD shareInstance] HUDFullText:@"无法连接到服务器~"];
    }];
    
}

 


- (void)V2_POST_NoHUD:(NSString *)URLString
                 dict:(NSDictionary *)dict
              succeed:(void (^)(id data))succeed {
    
    
    

    NSString * json = dict.json;
    NSLog(@"-- json: %@",json);
    NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
    dictionary[@"jsonRequest"] = json;
    dictionary[@"UID"] = UserModel.uid;
    

    #ifdef BaseURL
        NSString * baseURL = BaseURL;
    #else
        NSString * baseURL = [NSString stringWithFormat:@"http://%@/",Http.zbl_BaseUrl];
    #endif

   
    [[Yuan_HUD shareInstance] HUDStartText:@"正在努力加载中..."];
    
    NSString * url = [NSString stringWithFormat:@"%@%@",baseURL,URLString];

    // 把配置信息拿出去了
    AFHTTPSessionManager * manager = [self managerConfig];
    
    [manager POST:url parameters:dictionary progress:nil
          success:^(NSURLSessionDataTask *task, id responseObject) {
        
        [[Yuan_HUD shareInstance] HUDHide];
        
        // 状态栏菊花停止旋转
        
        
        // json对象转dict

        NSMutableDictionary *requestDict =
        [NSJSONSerialization JSONObjectWithData:responseObject
                                        options:NSJSONReadingMutableLeaves
                                          error:nil];
        
        NSString * result = requestDict[@"result"];
        NSNumber * success_bool = requestDict[@"success"];
        
        
        if ([result integerValue] == 0 && success_bool.boolValue == YES) {
            // 成功
            
            NSString * info_Json = [requestDict objectForKey:@"info"];
            
            info_Json = [info_Json stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
            info_Json = [info_Json stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            info_Json = [info_Json stringByReplacingOccurrencesOfString:@"\t" withString:@""];
            info_Json = [info_Json stringByReplacingOccurrencesOfString:@"\r" withString:@""];
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
                
                succeed(data);
            }
            
        }else {
            NSLog(@"🙁-- 错误日志 : \n%@",requestDict.json);
            // 请求成功 但返回失败
//            @"模块/端子板名称：moduleName要求唯一(统一库中已存在)"
            NSString * info = requestDict[@"info"];
            if (!info || [info isEqual:[NSNull null]]) {
                info = @"NULL";
            }
            
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        [[Yuan_HUD shareInstance] HUDHide];
        
    }];
    
}





#pragma mark -  V2 支持一次多发的 POST  ---


// 唯一的区别就是参数从dict 变为了 数组
- (void)V2_POST_SendMore:(NSString *)URLString
                   array:(NSArray *)manyDict_Array
                 succeed:(void (^)(id data))succeed {
    
    
    

    
    NSString * json = manyDict_Array.json;
    NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
    dictionary[@"jsonRequest"] = json;
    dictionary[@"UID"] = UserModel.uid;
    
    

    
    #ifdef BaseURL
        NSString * baseURL = BaseURL;
    #else
        NSString * baseURL = [NSString stringWithFormat:@"http://%@/",Http.zbl_BaseUrl];
    #endif


    
    NSString * url = [NSString stringWithFormat:@"%@%@",baseURL,URLString];
    
    NSString * HUDStr = @"正在努力加载中..";
    
    if ([URLString isEqualToString:ODFModel_InitPie]) {
        HUDStr = @"创建模块需要时间过长，请耐心等待...";
    }
    
    
    [[Yuan_HUD shareInstance] HUDStartText:HUDStr];
    
      

    // 把配置信息拿出去了
    AFHTTPSessionManager * manager = [self managerConfig];
    
    [manager POST:url
       parameters:dictionary progress:nil
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
        
        
        if ([result integerValue] == 0 && success_bool.boolValue == YES) {
            // 成功
            
            NSString * info_Json = [requestDict objectForKey:@"info"];
            
            info_Json = [info_Json stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
            info_Json = [info_Json stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            info_Json = [info_Json stringByReplacingOccurrencesOfString:@"\t" withString:@""];
            info_Json = [info_Json stringByReplacingOccurrencesOfString:@"\r" withString:@""];
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
                
                succeed(data);
            }
            
        }else {
            
            // 请求成功 但返回失败
//            @"模块/端子板名称：moduleName要求唯一(统一库中已存在)"
            NSString * info = requestDict[@"info"];
            if (!info || [info isEqual:[NSNull null]]) {
                info = @"NULL";
            }
            [[Yuan_HUD shareInstance] HUDFullText:info?:@"请求出错~"];
            
            
        }
        
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        
        
        
        [[Yuan_HUD shareInstance] HUDHide];
        [[Yuan_HUD shareInstance] HUDFullText:@"无法连接到服务器~"];
    }];
    
}




#pragma mark - managerConfig  ****  ****  ****

- (AFHTTPSessionManager *) managerConfig {
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];

    manager.requestSerializer = [[AFHTTPRequestSerializer alloc] init];
    manager.responseSerializer = [[AFHTTPResponseSerializer alloc] init];


    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/javascript",@"text/html", nil];

    manager.requestSerializer.timeoutInterval = 600;


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

    return manager;
    
}







- (NSString*) removeLastOneChar:(NSString*)origin
{
    NSString* cutted;
    if([origin length] > 0){
        cutted = [origin substringToIndex:([origin length]-1)];// 去掉最后一个","
    }else{
        cutted = origin;
    }
    return cutted;
}



#pragma mark -  大为的接口模式  ---

- (void)DavidJsonPostURL:(NSString *)url
                   Parma:(NSDictionary *)parma
                 success:(void (^) (id result)) success{
    
    
    NSURL *storeURL = [NSURL URLWithString:url];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:storeURL];

    request.HTTPMethod = @"POST";
    
    [request setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:Http.shareInstance.david_Token forHTTPHeaderField:@"token"];

    NSMutableDictionary * mt_Dict = [NSMutableDictionary dictionaryWithDictionary:parma];
    
    NSString * reqDb = [Yuan_WebService
                        webServiceGetDomainCode];
        
    // 如果不需要reqDb  直接改为false就行
    BOOL isNeedReqDb = true;
    
    // 如果里面不存在 reqDb  则加进去 , 存在则不打扰 谢谢
    if (![mt_Dict.allKeys containsObject:@"reqDb"] && isNeedReqDb) {
        mt_Dict[@"reqDb"] = reqDb;
    }
    

        
    request.HTTPBody = [mt_Dict.json dataUsingEncoding:NSUTF8StringEncoding];

    NSLog(@"-- URL:%@  \nJSON: %@",url,mt_Dict.json);
    
    request.timeoutInterval = 120;  //2分钟时间

    NSURLSession *session = [NSURLSession sharedSession];

    
    
    NSString * hudMeg = @"正在努力加载中";

    if ([url containsString:@"increase-res-manage/login"]) {
        hudMeg = @"正在获取用户信息 ...";
    }
    
    [[Yuan_HUD shareInstance] HUDStartText:hudMeg];
    
    
    NSURLSessionDataTask *dataTask =
    [session dataTaskWithRequest:request
               completionHandler:^(NSData * _Nullable data,
                                   NSURLResponse * _Nullable response,
                                   NSError * _Nullable error) {
        
        if (error) {
            NSString * msg = error.description;
            
            
            // GCD做线程通信传值 , 长时间操作在子线程中操作 , 拿到值后回传给主线程使用.
            dispatch_async(dispatch_get_main_queue(), ^{
                [[Yuan_HUD shareInstance] HUDHide];
                [[Yuan_HUD shareInstance] HUDFullText:msg];
                NSLog(@"error 😞: -- %@",msg);
            });
                
            
            return ;
        }
        
        
        if (data) {
            //JSON解析
            NSDictionary *dic =
            [NSJSONSerialization JSONObjectWithData:data
                                            options:NSJSONReadingMutableLeaves
                                              error:nil];
            NSNumber * code = dic[@"code"];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [[Yuan_HUD shareInstance] HUDHide];
                
                
                // 调用 资源统计  **** **** ****
                [self httpStatistic:url paramJson:mt_Dict];
                
                if (success &&
                    code.intValue == 200 &&
                    ![dic[@"data"] isEqual:[NSNull null]]) {
                    
                    
                    if ([dic[@"data"] obj_IsNull]) {
                        
                        [[Yuan_HUD shareInstance] HUDFullText:@"资源类型错误"];
                        return;
                    }
                    
                    success(dic[@"data"]);
                }else {
                    
                     
                    
                    NSLog(@"🙁-- 错误日志 : \n%@\n url:%@ \n json: %@",dic.json , url , mt_Dict.json);
                    NSString * msg = dic[@"msg"];
                    
                    id data = dic[@"data"];
                    
                    if ([data isKindOfClass:[NSString class]]) {
                        
                        NSString * newData = data;
                        
                        if (newData.length > 35) {
                            newData = [newData  substringToIndex:30];
                        }
                        
                        
                        [YuanHUD HUDFullText:[NSString stringWithFormat:@"%@\n%@",msg,newData]];
                    }
                    else {
                        
                        if ([data isKindOfClass:[NSArray class]]) {
                            NSArray * dataArr = data;
                            
                            if (dataArr.count > 0) {
                                NSDictionary * errorDict = dataArr.firstObject;
                                NSString * MESS = errorDict[@"MESS"];
                            
                                [[Yuan_HUD shareInstance] HUDFullText:MESS ?: @"失败,未检测到问题原因_Y"];
                                return;
                            }
                            
                        }
                        NSLog(@"🙁-- 错误日志 : \n%@\n url:%@ \n json: %@",dic.json , url , mt_Dict.json);
                        [[Yuan_HUD shareInstance] HUDFullText:dic.json ?: @"请求出错喽"];
                    }
                    
                    if (!dic) {
                        return;
                    }
                    
                    NSNotification * info_Noti =
                    [[NSNotification alloc] initWithName:@""
                                                  object:nil
                                                userInfo:@{@"info":dic}];
                    
                    [[NSNotificationCenter defaultCenter] postNotification:info_Noti];
                    
                }
            });
            
            
            
        }else{
            NSLog(@"==== 获取数据失败 ====");
            dispatch_async(dispatch_get_main_queue(), ^{
                [[Yuan_HUD shareInstance] HUDHide];
                [[Yuan_HUD shareInstance] HUDFullText:@"未查询到数据"];
            });
        }
    }];

    [dataTask resume];
    
}



- (void)DavidJsonPostURL:(NSString *)url
                ParmaArr:(NSArray *)parmaArr
                 success:(void (^) (id result)) success{
    
    
    NSURL *storeURL = [NSURL URLWithString:url];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:storeURL];

    request.HTTPMethod = @"POST";
    
    [request setValue:@"application/json;charset=UTF-8"
   forHTTPHeaderField:@"Content-Type"];
    
    
    request.HTTPBody =  [parmaArr.json dataUsingEncoding:NSUTF8StringEncoding];
    
    request.timeoutInterval = 120;  //2分钟时间
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    [[Yuan_HUD shareInstance] HUDStartText:@"正在努力加载中.."];
        
    NSURLSessionDataTask *dataTask =
    [session dataTaskWithRequest:request
               completionHandler:^(NSData * _Nullable data,
                                   NSURLResponse * _Nullable response,
                                   NSError * _Nullable error) {
            
        if (error) {
            NSString * msg = error.description;
            
            
            // GCD做线程通信传值 , 长时间操作在子线程中操作 , 拿到值后回传给主线程使用.
            dispatch_async(dispatch_get_main_queue(), ^{
                [[Yuan_HUD shareInstance] HUDHide];
                [[Yuan_HUD shareInstance] HUDFullText:msg];
            });
                
            
            return ;
        }
        
        
        if (data) {
            //JSON解析
            NSDictionary *dic =
            [NSJSONSerialization JSONObjectWithData:data
                                            options:NSJSONReadingMutableLeaves
                                              error:nil];
            NSNumber * code = dic[@"code"];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [[Yuan_HUD shareInstance] HUDHide];
                                
                if (success &&
                    code.intValue == 200 &&
                    ![dic[@"data"] isEqual:[NSNull null]]) {
                    
                    success(dic[@"data"]);
                }else {
                    NSLog(@"🙁-- 错误日志 : \n%@",dic.json);
                    NSString * msg = dic[@"msg"];
                    
                    id data = dic[@"data"];
                    
                    if ([data isKindOfClass:[NSString class]]) {
                        
                        NSString * newData = data;
                        
                        if (newData.length > 35) {
                            newData = [newData  substringToIndex:30];
                        }
                        
                        
                        [YuanHUD HUDFullText:[NSString stringWithFormat:@"%@\n%@",msg,newData]];
                    }
                    else {
                        [[Yuan_HUD shareInstance] HUDFullText:msg ?: @"请求出错喽"];
                    }
                }
            });
            
            
            
        }else{
            NSLog(@"==== 获取数据失败 ====");
            dispatch_async(dispatch_get_main_queue(), ^{
                [[Yuan_HUD shareInstance] HUDHide];
                [[Yuan_HUD shareInstance] HUDFullText:@"未查询到数据"];
            });
        }
    }];

    [dataTask resume];
    
}



- (void)DavidJson_NOHUD_PostURL:(NSString *)url
                          Parma:(NSDictionary *)parma
                        success:(void (^) (id result)) success{
    
    
    NSURL *storeURL = [NSURL URLWithString:url];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:storeURL];

    request.HTTPMethod = @"POST";
    
    [request setValue:@"application/json;charset=UTF-8"
   forHTTPHeaderField:@"Content-Type"];
    

    NSMutableDictionary * mt_Dict = [NSMutableDictionary dictionaryWithDictionary:parma];
    
    NSString * reqDb = [Yuan_WebService
                        webServiceGetDomainCode];
        
    // 如果里面不存在 reqDb  则加进去 , 存在则不打扰 谢谢
    if (![mt_Dict.allKeys containsObject:@"reqDb"]) {
        mt_Dict[@"reqDb"] = reqDb;
    }

        
    request.HTTPBody = [mt_Dict.json dataUsingEncoding:NSUTF8StringEncoding];

    NSLog(@"-- URL:%@  \nJSON: %@",url,mt_Dict.json);
    
    request.timeoutInterval = 120;  //2分钟时间

    NSURLSession *session = [NSURLSession sharedSession];
    

    
    NSURLSessionDataTask *dataTask =
    [session dataTaskWithRequest:request
               completionHandler:^(NSData * _Nullable data,
                                   NSURLResponse * _Nullable response,
                                   NSError * _Nullable error) {
        
        if (error) {

            // GCD做线程通信传值 , 长时间操作在子线程中操作 , 拿到值后回传给主线程使用.
            dispatch_async(dispatch_get_main_queue(), ^{
                [[Yuan_HUD shareInstance] HUDHide];

            });
                

            return ;
        }
        
        
        if (data) {
            //JSON解析
            NSDictionary *dic =
            [NSJSONSerialization JSONObjectWithData:data
                                            options:NSJSONReadingMutableLeaves
                                              error:nil];
            NSNumber * code = dic[@"code"];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [[Yuan_HUD shareInstance] HUDHide];

                
                if (success &&
                    code.intValue == 200 &&
                    ![dic[@"data"] isEqual:[NSNull null]]) {
                    
                    
                    if ([dic[@"data"] obj_IsNull]) {
                        
                        return;
                    }
                    
                    success(dic[@"data"]);
                }else {
                    
                    
                    
                    NSLog(@"🙁-- 错误日志 : \n%@",dic.json);
                    
                    id data = dic[@"data"];
                    
                    if ([data isKindOfClass:[NSString class]]) {
                        
                        NSString * newData = data;
                        
                        if (newData.length > 35) {
                            newData = [newData  substringToIndex:30];
                        }
                    
                    }
                    else {
                        
                        if ([data isKindOfClass:[NSArray class]]) {
                            NSArray * dataArr = data;
                            
                            if (dataArr.count > 0) {
                            
                                return;
                            }
                            
                        }
                        
                    }
                    
                    if (!dic) {
                        return;
                    }
                    
                    NSNotification * info_Noti =
                    [[NSNotification alloc] initWithName:@""
                                                  object:nil
                                                userInfo:@{@"info":dic}];
                    
                    [[NSNotificationCenter defaultCenter] postNotification:info_Noti];
                    
                }
            });
            

            
        }else{
            NSLog(@"==== 获取数据失败 ====");
            dispatch_async(dispatch_get_main_queue(), ^{
                [[Yuan_HUD shareInstance] HUDHide];
            });
        }
    }];

    [dataTask resume];
    
}



- (void) V2_POST_Image:(UIImage *) image
               imgName:(NSString *)imgName
                   URL:(NSString *)postURL
                 param:(NSDictionary *)param
               succeed:(void (^)(id data))succeed{
    
    
    NSString * fileName = @"file";
    
    if ([postURL containsString:@"unionAiApi/uploadPhoto"]) {
        fileName = @"photoFile";
    }
    
    AFHTTPSessionManager *manager = [self managerConfig];
    
//    NSString * URL = [NSString stringWithFormat:@"%@%@?code=%@",BaseURL_Auto(nil), @"upload", [AppDelegate.DELEGATE.domainCode componentsSeparatedByString:@"/"].firstObject];
    
    [[Yuan_HUD shareInstance] HUDStartText:@"正在上传图片..."];
    
    
    [manager POST:postURL parameters:param constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        NSData *imageData = UIImageJPEGRepresentation(image, .1f);
        // 上传图片，以文件流的格式
        [formData appendPartWithFileData:imageData name:fileName fileName:imgName mimeType:@"image/jpeg"];
        // @"multipart/form-data"
        // @"image/jpeg"
        
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        
        // 上传成功的回调
        [[Yuan_HUD shareInstance] HUDHide];
        
        if (succeed) {
            
            NSMutableDictionary *requestDict =
            [NSJSONSerialization JSONObjectWithData:responseObject
                                            options:NSJSONReadingMutableLeaves
                                              error:nil];
            
            succeed(requestDict);
        }
        
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        // 上传失败的回调
        [[Yuan_HUD shareInstance] HUDHide];
        [[Yuan_HUD shareInstance] HUDFullText:@"请检查网络"];
    }];
    
    
}



/// v2 大为登录接口
- (void)Oss_2_DaivdLogin:(void(^)(void)) success {
    
    
    
    NSDictionary * dict = @{@"account":UserModel.userName, // UserModel.userName
                            @"password":UserModel.passWord, // UserModel.password
                            @"isCaptcha": @"0"};
    
    NSString * login_Url = @"http://120.52.12.12:8951/increase-res-manage/login";
    
    [self DavidJsonPostURL:login_Url
                     Parma:dict
                   success:^(id result) {
            
        NSDictionary * dict = (NSDictionary*)result;
        
        [YuanHUD HUDHide];
        
        if (dict.count > 0) {
            _david_LoginDict = dict;
            _david_Token = dict[@"token"];
        }
        
        
        
        if (success) {
            success();
        }
    }];
    
}




#pragma mark - 资源统计 ---


- (void) httpStatistic:(NSString *) fromUrl paramJson:(NSDictionary *) json {
    
    
    
    NSString * realname = UserModel.userInfo[@"realname"]; //ad.userInfo[@"realname"]
    NSString * username = UserModel.userName; //UserModel.userName
    NSString * reqDb = Yuan_WebService.webServiceGetDomainCode;
    
    NSString * serviceName = @"OSS2.0";
    NSString * requestUrl = fromUrl ?: @"";

    NSString * funName = @"";
    NSString * moduleName = @"";
    NSNumber * durationTime = [NSNumber numberWithInt:arc4random() % 5000 + 1];
    NSString * router = @"";
    
    
    switch (_statisticEnum) {
            
        case HttpStatistic_None:
            moduleName = @"";
            break;
            
        case HttpStatistic_Login:           // 登录
            moduleName = @"Login";
            break;
            
        case HttpStatistic_Update:          // 升级   Update
            moduleName = @"Update";
            break;
            
        case HttpStatistic_Resource:        // 统一库资源    Resource
        case HttpStatistic_ResourceBindQR:
        case HttpStatistic_ResourceAI:
            moduleName = @"Resource";
            break;
            
        case HttpStatistic_Building:        // 楼宇   Building
            moduleName = @"Building";
            break;
            
        case HttpStatistic_GIS:             //GIS   GIS
            moduleName = @"GIS";
            break;
            
        case HttpStatistic_RFID:            //统一库扫一扫 , 电子锁等 RFID
            moduleName = @"RFID";
            break;
            
        case HttpStatistic_Inspection:      //巡检    Inspection
            moduleName = @"Inspection";
            break;
            
        case HttpStatistic_SiteManager:     //现场管理  SiteManager
            moduleName = @"SiteManager";
            break;
            
        case HttpStatistic_ResInventory:    //资源清查  ResInventory
            moduleName = @"ResInventory";
            break;
            
        case HttpStatistic_Other:           //其他    Other
            moduleName = @"Other";
            break;
            
        default:
            break;
    }
    
    
    router = moduleName;
    
    if (_statisticEnum == HttpStatistic_ResourceAI) {
        funName = @"AI";
        router = [NSString stringWithFormat:@"%@/AI",moduleName];
    }
    
    if (_statisticEnum == HttpStatistic_ResourceBindQR) {
        funName = @"BindQRCode";
        router = [NSString stringWithFormat:@"%@/BindQRCode",moduleName];
    }
    
    if (_statisticEnum == HttpStatistic_ResourceBatchUpdateTerm) {
        funName = @"BatchUpdateTerm";
        router = [NSString stringWithFormat:@"%@/BatchUpdateTerm",moduleName];
    }
    
    NSMutableDictionary * mtDict = NSMutableDictionary.dictionary;

    mtDict[@"userRealName"] = realname;
    mtDict[@"username"] = username;
    mtDict[@"provinceCode"] = reqDb;
    mtDict[@"serviceName"] = serviceName;
    mtDict[@"requestUrl"] = requestUrl;
    mtDict[@"moduleName"] = moduleName;
    mtDict[@"durationTime"] = durationTime;
    mtDict[@"router"] = router;
    mtDict[@"ipAddress"] = [Yuan_Foundation getIpAddress];
    // 固定
    mtDict[@"machineNum"] = @"2";
    
    if (funName.length > 0) {
        mtDict[@"funName"] = funName;
    }
    
        
    if (json.count > 0) {
        mtDict[@"params"] = [NSString stringWithFormat:@"%@",json.json];
    }
    

    
    
    
    if (reqDb.length == 0) {
        return;
    }
    
   
    NSString * url = @"http://120.52.12.12:8951/increase-gateway/statApi/accessStat";
    
    
    NSLog(@"-- %@",mtDict);
    
    [Http httpStatistic:url Parma:mtDict success:^(id result) {
        NSLog(@"锚点统计成功");
    }];

}


+ (void)httpStatistic:(NSString *)url
                Parma:(NSDictionary *)parma
              success:(void (^) (id result)) success{
    
    
    NSURL *storeURL = [NSURL URLWithString:url];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:storeURL];

    request.HTTPMethod = @"POST";
    
    [request setValue:@"application/json;charset=UTF-8"
   forHTTPHeaderField:@"Content-Type"];
    
        
    request.HTTPBody = [parma.json dataUsingEncoding:NSUTF8StringEncoding];

    request.timeoutInterval = 120;  //2分钟时间

    NSURLSession *session = [NSURLSession sharedSession];

    
    NSURLSessionDataTask *dataTask =
    [session dataTaskWithRequest:request
               completionHandler:^(NSData * _Nullable data,
                                   NSURLResponse * _Nullable response,
                                   NSError * _Nullable error) {
        
        if (data) {
            //JSON解析
            NSDictionary *dic =
            [NSJSONSerialization JSONObjectWithData:data
                                            options:NSJSONReadingMutableLeaves
                                              error:nil];
            NSNumber * code = dic[@"code"];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                

                
                if (success &&
                    code.intValue == 200 &&
                    ![dic[@"data"] isEqual:[NSNull null]]) {
                    
                    success(dic[@"data"]);
                }
                else {
                    NSLog(@"--- 接口统计失败");
                }
            });
        }
    }];

    [dataTask resume];
    
}



- (void) POST:(NSString *)URL
   parameters:(NSDictionary *)parameters
      success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
      failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure{
    
    AFHTTPSessionManager *manager = [self managerConfig];
    
    NSLog(@"😄\n url:%@ \n json: %@",parameters.json , URL );
    
    
    [manager POST:URL
       parameters:parameters
         progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if (success) {
                
                NSMutableDictionary *requestDict =
                [NSJSONSerialization JSONObjectWithData:responseObject
                                                options:NSJSONReadingMutableLeaves
                                                  error:nil];
                
                success(task,requestDict);
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if (failure) {
                failure(task,error);
            }
     }];
    
}

@end
