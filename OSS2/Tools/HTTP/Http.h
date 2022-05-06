//
//  Http.h
//  守望者
//
//  Created by Ryan on 17/3/13.
//  Copyright © 2017年 Yuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "HttpPort.m"


#define HTTP_TYK_Normal_Get @"rm!getCommonData.interface"
#define HTTP_TYK_Normal_UpData @"rm!updateCommonData.interface"
#define HTTP_TYK_Normal_Insert @"rm!insertCommonData.interface"
#define HTTP_TYK_Normal_Delete @"rm!deleteCommonData.interface"

typedef void (^httpSuccessBlock)(id result);

typedef NS_ENUM(NSUInteger , HttpStatistic_) {
    
    HttpStatistic_None,             //无
    
    
    HttpStatistic_Login,            //登录 (暂时不用)
    HttpStatistic_Update,           //升级
    
    
    HttpStatistic_Resource,         //资源 新旧模板
    HttpStatistic_ResourceBindQR,   //资源绑定二维码
    HttpStatistic_ResourceAI,       //AI识别
    HttpStatistic_ResourceBatchUpdateTerm,   //批量修改端子状态
    
    
    HttpStatistic_Building,         //楼宇
    HttpStatistic_GIS,              //GIS
    HttpStatistic_RFID,             //RFID 电子标签
    
    
    HttpStatistic_Inspection,       //巡检
    HttpStatistic_SiteManager,      //现场管理
    HttpStatistic_ResInventory,     //资源清查
    HttpStatistic_Other,            //其他
};



@interface Http : NSObject



+ (Http *)shareInstance ;



/** 统计的枚举 */
@property (nonatomic , assign) HttpStatistic_ statisticEnum;




/** 大为接口 登录返回的map */
@property (nonatomic , copy , readonly) NSDictionary * david_LoginDict;

/** token */
@property (nonatomic , copy , readonly) NSString * david_Token;


/// 网络请求封装类 , 随着业务的了解 , 要进一步的增加
/// @param URLString API_URL
/// @param dict 请求的param参数
/// @param succeed 成功的回调
- (void)POST:(NSString *)URLString
        dict:(NSDictionary *)dict
     succeed:(void (^)(id data))succeed;


/// Get请求
- (void)GET:(NSString *)URLString
       dict:(NSDictionary *)dict
    succeed:(void (^)(id data))succeed;

#pragma mark -  V2 通用 POST      主要使用的请求方式  ---
/// V2 专用 Post 请求
- (void)V2_POST:(NSString *)URLString
           dict:(NSDictionary *)dict
        succeed:(void (^)(id data))succeed;



- (void)V2_POST_NoHUD:(NSString *)URLString
                 dict:(NSDictionary *)dict
              succeed:(void (^)(id data))succeed;



/// v2 专业 调用 大为的接口 都是使用 HttpBody 格式的 不走 AFNetWorking
- (void)DavidJsonPostURL:(NSString *)url
                   Parma:(NSDictionary *)parma
                 success:(void (^) (id result)) success;


/// v2 专业 调用 大为的接口 都是使用 HttpBody 格式的 不走 AFNetWorking  array!!!
- (void)DavidJsonPostURL:(NSString *)url
                ParmaArr:(NSArray *)parmaArr
                 success:(void (^) (id result)) success;



/// 没有菊花的调用
- (void)DavidJson_NOHUD_PostURL:(NSString *)url
                          Parma:(NSDictionary *)parma
                        success:(void (^) (id result)) success;


/// v2 大为登录接口
- (void)Oss_2_DaivdLogin:(void(^)(void)) success;


#pragma mark -  V2 支持一次多发的 POST  ---


// 唯一的区别就是参数从dict 变为了 数组
- (void)V2_POST_SendMore:(NSString *)URLString
                   array:(NSArray *)manyDict_Array
                 succeed:(void (^)(id data))succeed;




#pragma mark -  V2 图片上传  ---

- (void) V2_POST_Image:(UIImage *) image
               imgName:(NSString *)imgName
                   URL:(NSString *)postURL
                 param:(NSDictionary *)param
               succeed:(void (^)(id data))succeed;




/// 为了适配老GIS 专用的
- (void) POST:(NSString *)URL
   parameters:(NSDictionary *)parameters
      success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
      failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error))failure;

#pragma mark - URL ---
// 通用查询
+ (NSString *) David_SelectUrl;

// 通用修改
+ (NSString *) David_ModifiUrl;

// 联通删除
+ (NSString *) David_DeleteUrl;


/// 生成对应的C语音函数
extern NSString * David_SelectUrl (NSString * url);
extern NSString * David_ModifiUrl (NSString * url);
extern NSString * David_DeleteUrl (NSString * url);


/// 朱贝龙 地址

// 网络请求
+ (NSString *) zbl_BaseUrl;

// 资源下载
+ (NSString *) zbl_SourceUrl;


+ (NSString *) zbl_BaseUrl_Http;
+ (NSString *) zbl_SourceUrl_Http;

#pragma mark - 资源统计 ---

/** 只有在v2资源搜索的时候 会用到 */
@property (nonatomic , copy) NSString * v2_Res_postURL;

- (void) httpStatistic:(NSString *) fromUrl paramJson:(NSDictionary *) json;

@end
