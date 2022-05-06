//
//  PCH_Header.h
//  FTP图影音
//
//  Created by 袁全 on 2020/3/9.
//  Copyright © 2020 袁全. All rights reserved.
//

//#import "OSS2.0_ios_v2-Swift.h" // OC 调用Swift类
#import "PureLayout.h"  //屏幕适配

#import "Yuan_HUD.h"
#import "UIAlert.h"       // 封装的Alert
#import "UIView+WorksInit.h"

#import "UIColor+Colors.h"
#import "IWPColor.h"
#import "Inc_Object.h"
#import "UIView+YuanFrame.h"
#import "NSObject+Yuan_Obj.h"       //非空判断
#import "UIImage+Inc_Category.h"
#import "YuanLayout.h"
#import "PureLayout.h"
#import <Masonry/Masonry.h>
#import "Inc_UserModel.h"
#import "IWPServerService.h"
#import "ptotocolDelegate.h"
#import "Yuan_Enum.h"
// 放置Dict KVC崩溃
//#import "NSMutableDictionary+Yuan_MutableDict.h"
//#import "NSDictionary+Yuan_Dictionary.h"

// 袁全 -- 网络请求封装类
#import "Http.h"
//#import "EasyNavigation.h"

#import "Yuan_Foundation.h"
//#import "UIView+YuanFrame.h"

//#import "Yuan_Enum.h"    //枚举
#import "Yuan_NotificationName.h" //通知 命名

//#import "DingFangService.h"   // 盯防的.h头文件
#import "UIView+Yuan_LayoutPacking.h"
#import "StrUtil.h"
#import "INCView.h"
#import "Yuan_WebService.h"
#import "UIView+Extension.h"
#import "MBProgressHUD.h"
#import "IWPYJCService.h"
#import "IWPTools.h"
#import "INCBarButtonItem.h"
#import "UIView+KC.h"
#import "NSString+Extension.h"
//#import "Inc_KeysManager.h"
//#import "Inc_Push_MB.h"
//#import <SDWebImage/UIImageView+WebCache.h>
#import "MLMenuView.h"               // 下拉列表
#import "Http.h"
//Map
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import <AMapNaviKit/AMapNaviKit.h>
#import <AMapLocationKit/AMapLocationKit.h>

//环信
//#import <Foundation/Foundation.h>
//#import <EaseIMKit/EaseIMKit.h>
//#import <HyphenateChat/HyphenateChat.h>
//#import <EaseCallKit/EaseCallUIKit.h>
//#import <Masonry/Masonry.h>
//#import "EMHeaders.h"
//#import "EMDefines.h"


#import "Inc_BaseVC.h"


typedef enum : NSUInteger {
    IWPPropertiesReadDirectoryBundle,
    IWPPropertiesReadDirectoryDocuments,
    IWPPropertiesReadDirectoryLibrary,
    IWPPropertiesReadDirectoryCache,
} IWPPropertiesReadDirectoryRef;



static NSString * const kDeviceList = @"deviceList";
static NSString * const kDeviceCheck = @"deviceCheck";
static NSString * const kGISLocation = @"GISLocation";
static NSString * const kQRCodeScanner = @"QRCodeScanner";
static NSString * const kCableName = @"cableName";
static NSString * const kCableId = @"cableId";
static NSString * const kCableRfid = @"cableRfid";

static NSString * const kResLogicName = @"resLogicName";

/**
 *  配置文件保存
 */
static NSString * const kPropertiesPath = @"propertiesFiles";
/**
 *  离线图片保存目录
 */
static NSString * const kOfflineImage = @"onlineImage";
/**
 *  在线图片保存目录
 */
static NSString * const kOnlineImage = @"onlineImage";
static NSString * const kImagePath = @"onlineImage";
/**
 *  离线设备数据
 */
static NSString * const kOffilineData = @"offlineData";
/**
 * olt模板相关文件存储目录
 */
static NSString * const kEqutProps = @"equtPropertiesANDImages";
/**
 * 主界面配置文件
 */
static NSString * const kResourceMainProps = @"ResourceMainData";

/* 资源模板 */
static NSString * const kDeviceModel = @"DeviceModel";

/* 机架模板下载目录 */
static NSString * const kCardModelProps = @"cardModelProps";

/* 讯飞语音合成目录 */
static NSString const * kIFlyFileDir = @"kIFlyFileDir";

/* 海康视频存储目录 */
static NSString * const kHIKVideoDir = @"HikVideos";

/* 是否下载过图片 */
static NSString * const kIsDownloadImage = @"isDownloadImage";
/* 菜单文件MD5值 */
static NSString * const MenuProps_Mainpage_MD5FileName = @"menuPropsMD5";
/* olt模板配置文件MD5值 */
static NSString * const EqueProps_MD5_FileName = @"equtPropsMD5";

/* 机架模板配置文件MD5对照表 */
static NSString * const cardModelPropsMD5_FileName = @"cardModelPropsMD5";

static NSString * const kMD5FileName = @"md5FileName";
static NSString * const kMD5 = @"md5";


// 12bdc1401bd3f31a1c3da7ff4c1c997b
// 23d3d788b119b15ac9efc3a185176c26
static NSString * const GD_Key = @"f5d1cf9a0baca58f249909c96a17b5db";








// ODB模板信息
static NSString * kODB_MianbanInfo = @"mianBanInfo";
// ODB端子信息
static NSString * kODB_DuanziInfo = @"duanziInfo";
// ODB中的OBD信息
static NSString * kODB_OBDInfo = @"obdInfo";
// ODB中OBD的端子信息
static NSString * kODB_OBD_DuanZiInfo = @"odbDuanZiInfo";
// ODB中端子内容被修改的标记
static NSString * kODB_DuanziInfo_SaveFlag = @"localSaveFlag";
// 是否完成了信息上传
static NSString * kODB_INFO_Upload_Succeed = @"isUploaded";

static NSString * kODB_INFO_ALL_Info_Uploaded = @"isAllUploaded";




#ifndef PCH_Header_h
#define PCH_Header_h


#define DOC_DIR [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
#define REPLACE_HHF(json) (json)
#define AD (AppDelegate *) [UIApplication sharedApplication].delegate


#define DictToString(dict) [dict json]


#define NaviBarHeight (ScreenHeight >= 812.0 ? 88 : 64)
// 距屏幕底边的距离 防止 iphone X 以上的机型会出现底部不适的症状
#define BottomZero  NaviBarHeight == 88 ? 20 : 0
#define HeigtOfTop [StrUtil heightOfTop]
/**
 *  ColorValue_RGB
 *
 *  @param rgbValue 传入的16进制色值,返回颜色 实例: 0x666666
 *
 *  注意事项 : '0x'!
 */
#define ColorValue_RGB(rgbValue)                                   \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0                 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0                  \
alpha:1.0]


#define ColorR_G_B(R,G,B)                                       \
[UIColor colorWithRed:R/255.0                                   \
                green:G/255.0                                   \
                 blue:B/255.0                                   \
                alpha:1.0]


#define Color_V2Red [UIColor mainColor]
#define Color_V2Blue ColorValue_RGB(0x43a5f0)  
#define Color_H5Blue ColorValue_RGB(0x0380FE)


// 普通字体和加粗字体
#define Font_Yuan(R) [UIFont systemFontOfSize:R]
#define Font_Bold_Yuan(R) [UIFont fontWithName:@"Helvetica-Bold" size:R]


// 全屏宽度和全屏高度
#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height
#define ScreenW [UIScreen mainScreen].bounds.size.width
#define ScreenH [UIScreen mainScreen].bounds.size.height

#define IphoneSize_Width(R)  Horizontal(R)
#define IphoneSize_Height(R)  Vertical(R)

//判断是否为 iPhoneXS  Max，iPhoneXS，iPhoneXR，iPhoneX  通过屏幕高判断  当前只处理刘海不用区分机型
#define IS_IPHONE_X  (ScreenHeight == 812.f || ScreenHeight == 896.f)
// IPHONE_X状态栏高度44，其他20
#define SafeAreaStatusBar (IS_IPHONE_X  ? (44) : (20))

/**
 *  屏幕适配宽度
 *  @param R 传入横向的值或宽度
 */
#define Horizontal(R)  (R)*(ScreenWidth)/375


/**
 *  屏幕适配高度
 *  @param R 传入纵向向的值或高度
 */
#define Vertical(R) [YuanLayout YuanLayoutVertical:(R)]


#define AlertShow(view,title,delay,reason) MBProgressHUD * alert = [MBProgressHUD showHUDAddedTo:(view) animated:YES];alert.label.text = (title);alert.mode = MBProgressHUDModeText;alert.animationType = MBProgressHUDAnimationZoomIn;[alert hideAnimated:YES afterDelay:((float)delay)]; alert.detailsLabel.text = reason.length > 0 ? [NSString stringWithFormat:@"原因：%@",reason] : nil

#define WEAK_SELF __weak typeof(self) wself = self;

// OSS2_0 红色全国版
#define V2_Red true
// 黑龙江 蓝色版
#define V1_Blue false


#define v_OSS2 true
#define v_HLJ false






#endif /* PCH_Header_h */
