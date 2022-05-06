//
//  Increase_OSS2_HomeVC.h
//  javaScript_ObjectC
//
//  Created by yuanquan on 2022/3/10.
//

#import <UIKit/UIKit.h>

#import <AMapNaviKit/AMapNaviKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger , JsToOC_) {
    
    JsToOC_None,        //啥也没干
    JsToOC_Carema,      //调用相机
    JsToOC_Photo,       //调起图库
    JsToOC_QRCode,      //调起扫一扫
    JsToOC_Call,        //打电话
    JsToOC_Message,     //发短信
    JsToOC_Navi,        //导航
    JsToOC_Location,    //定位
};


typedef NS_ENUM(NSUInteger , AMapServiceLocation_) {
    AMapServiceLocation_Meter,      //够用的定位模式
    AMapServiceLocation_Best,       //最好的定位模式
};

@interface Increase_OSS2_HomeVC : UIViewController

// 传入登录相关的信息
- (instancetype)initWithLoginDatas:(NSDictionary *)dict;


/** 是否是测试环境 */
@property (nonatomic , assign) BOOL isTestMode;

/** 是否允许Log输出 */
@property (nonatomic , assign) BOOL isAgreeLog;

@end

NS_ASSUME_NONNULL_END
