//
//  TYKDeviceInfoMationViewController.h
//  OSS2.0-ios-v2
//
//  Created by 孟诗萌 on 2017/8/15.
//  Copyright © 2017年 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_BaseVC.h"
#import "ptotocolDelegate.h"
#import "Yuan_MB_ViewModel.h"

@class IWPViewModel;
@class IWPPropertiesSourceModel;

@protocol TYKDeviceInfomationDelegate <NSObject>
@optional
/**
 *  删除设备
 *
 *  @param dict    要被删除的设备信息
 *  @param vcClass 发出该请求页面的类对象
 */
-(void)deleteDeviceWithDict:(NSDictionary *)dict withViewControllerClass:(Class)vcClass;

/**
 *  新添加的标石
 *
 *  @param dict 标石数据
 */
-(void)newMarkStoneWithDict:(NSDictionary <NSString *, NSString *>*)dict;
/**
 *  新添加的引上点
 *
 *  @param dict 引上点数据
 */
-(void)newLedupWithDict:(NSDictionary <NSString *, NSString *>*)dict;
/**
 *  新添加的电杆
 *
 *  @param dict 电杆数据
 */
-(void)newPoleWithDict:(NSDictionary <NSString *,NSString *>*)dict;
/**
 *  新添加的井
 *
 *  @param dict 井的数据
 */
-(void)newWellWithDict:(NSDictionary <NSString *,NSString *>*)dict;
/**
 *  常规新增设备
 *
 *  @param dict 设备数据
 */
-(void)newDeciceWithDict:(NSDictionary <NSString *,NSString *>*)dict;

/**
 *  3DTouch相关点击事件
 *
 *  @param index 事件下标
 */
-(void)rowActionWithIndex:(NSInteger)index;

/**
 新的撑点
 
 
 */
-(void)newSupportingPoints:(NSDictionary <NSString *, NSString *>*)dict;
/**
 * 新离线光缆保存
 */
-(void)newOfflineCableWithDict:(NSDictionary *)dict isNewDevice:(BOOL)isAdd;
/**
 * 接收到新在线转离线子的设备信息
 */
-(void)didReciveANewOnlineToOfflineSubDevice:(NSDictionary *)dict isAdd:(BOOL)isAdd;


/**
 接收到了新的定位资源中离线资源的保存信息
 
 @param dict  要保存的离线资源字典
 @param isAdd 是否为新增
 */
-(void)didReciveANewDeviceOnMap:(NSDictionary *)dict isTakePhoto:(BOOL)isTakePhoto;
@end


//NS_CLASS_DEPRECATED_IOS(2_0, 7_0, "IWPDeviceInfoMationViewController is deprecated. Use IWPDeviceInfomation_NEW_ViewController") __TVOS_PROHIBITED
@interface TYKDeviceInfoMationViewController : Inc_BaseVC<ptotocolDelegate>
/**
 *  代理，遵循IWPDeviceInfomationDelegate协议的对象
 */
@property (nonatomic, weak) id <TYKDeviceInfomationDelegate> delegate;
/**
 *  正文视图
 */
@property (nonatomic, weak) UIScrollView * contentView;
/**
 *  3DTouch, 按钮标题
 */
@property (nonatomic, strong) NSArray * btnTitles;
/**
 *  是否离线模式
 */
@property (nonatomic, assign) BOOL isOffline;
/**
 *  是否为下属设备
 */
@property (nonatomic, assign) BOOL isSubDevice;
/**
 *  设备数组
 */
@property (nonatomic, strong) NSArray * devices;

/* 2017年02月22日 添加，适应工单的增修 */

/**
 2017年03月02日，修改为： #工单号#接收人1#接收人2...#
 */
@property (nonatomic, copy) NSString * taskId;

/**
 经度
 */
@property (nonatomic, copy) NSString * generatorLongitude;

/**
 纬度
 */
@property (nonatomic, copy) NSString * generatorLatitude;

/**
 机房所属维护区域
 */
@property (nonatomic, copy) NSString * generatorRetion;

@property (nonatomic, assign) BOOL isInWorkOrder;

/*2018年05月25日 OLT端子面板，仅OLT显示查看路由*/
@property (nonatomic, copy) NSString * sourceFileName;


/** 声明 袁全声明 点击保存后的回调 , 只有 OCC 和 ODF 可以使用 的block */
@property (nonatomic ,copy) void(^Yuan_ODFOCC_Block)(NSDictionary * changeDict);


/** 声明 袁全声明 点击保存后回调 , 只有光缆段纤芯配置模块使用 的block */
@property (nonatomic ,copy) void(^Yuan_CFBlock)(NSDictionary * changeDict);


/** 从扫一扫跳转稽核的 类型Id */
@property (nonatomic , copy) NSString * Yuan_NewCheckId;



-(void)configContentViewsWithModel:(IWPViewModel *)dict;
/**
 *  对象方法，初始化方法
 *
 *  @param controlMode 页面功能
 *  @param model       配置文件主模型
 *  @param viewModel   nil, 实际开发中已不再使用
 *  @param dict        若有设备信息（可以为详细设备信息或初始设备信息）
 *  @param fileName    配置文件名
 */
-(instancetype)initWithControlMode:(TYKDeviceListControlTypeRef)controlMode
                     withMainModel:(IWPPropertiesSourceModel *)model
                     withViewModel:(NSArray <IWPViewModel *> *)viewModel
                      withDataDict:(NSDictionary *)dict
                      withFileName:(NSString *)fileName NS_EXTENSION_UNAVAILABLE_IOS("Use UIAlertController instead.");

/**
 *  类方法，初始化方法
 *
 *  @param controlMode 页面功能
 *  @param model       配置文件主模型
 *  @param viewModel   nil, 实际开发中已不再使用
 *  @param dict        若有设备信息（可以为详细设备信息或初始设备信息）
 *  @param fileName    配置文件名
 */
+(instancetype)deviceInfomationWithControlMode:(TYKDeviceListControlTypeRef)controlMode
                                 withMainModel:(IWPPropertiesSourceModel *)model
                                 withViewModel:(NSArray <IWPViewModel *> *)viewModel
                                  withDataDict:(NSDictionary *)dict
                                  withFileName:(NSString *)fileName NS_EXTENSION_UNAVAILABLE_IOS("Use UIAlertController instead.");
-(BOOL)isSubDevice;
-(void)dismisSelf;

//盘所在子框的所有盘ID的字典
@property(strong,nonatomic)NSDictionary* cardIDMap;
//当前盘CODE
@property(assign,nonatomic)NSInteger card_code;
//当前OLT设备信息,为了对端/跳接关系用
@property(strong,nonatomic)NSDictionary *equDic;
//当前设备类型，区分OLT和分光器设备
@property(strong,nonatomic)NSString *equType;
@property (nonatomic, weak) id<ptotocolDelegate> OBDdelegate;
/**
 *  請求用字典
 */
@property (nonatomic, strong) NSMutableDictionary * requestDict;
/**
 *  是否是机房下属设备
 */
@property (assign,nonatomic)BOOL isGenSSSB;


/** tube 管孔时 , 如果是从子孔进入的 ,保存时 会在requestDict中 新增 isFather = 2的字段*/
@property (nonatomic ,assign) BOOL isNeed_isFather;

/** 管孔的父id */
@property (nonatomic ,copy)  NSString *fatherPore_Id;

/** 保存成功的回调  block */
@property (nonatomic , copy) void (^savSuccessBlock) (void);


// 复制功能使用
@property (assign,nonatomic) BOOL isCopy;
@property (nonatomic ,copy)  NSString *gId;

@end

