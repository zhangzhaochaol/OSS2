//
//  Inc_BusDeviceView.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/2/20.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Inc_BusODFScrollView.h"
@class Inc_BusDeviceView;
NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSUInteger , Yuan_BusDeviceEnum_) {
    Yuan_BusDeviceEnum_Normal,          //普通
    Yuan_BusDeviceEnum_NewFL,           //新版 光纤光路 光链路 2021年3月
    Yuan_BusDeviceEnum_NewFL_Exchange,  //新版 光纤光路 节点替换
    Yuan_BusDeviceEnum_OBD_Bind,        //新版 OBD端子和设备端子绑定
    Yuan_BusDeviceEnum_JumpFiber,       //跳纤 2021-6-24
    Yuan_BusDeviceEnum_NewImageCheck,   //新版端子识别
};



typedef NS_ENUM(NSUInteger , Yuan_BusHttpPortEnum_) {
    Yuan_BusHttpPortEnum_Old,      //走老接口 请求端子 , 端子中自带模板数据 , 但没有那三个数组的数据
    Yuan_BusHttpPortEnum_New,      //大为新接口 , 当点击端子时 , 需要去请求一遍端子数据 , 再跳转模板
};


@protocol Yuan_BusDevice_ItemDelegate <NSObject>



@optional

/// item的点击事件 返回 全部的按钮和当前点击的按钮
- (void) Yuan_BusDeviceSelectItems:(NSArray <Inc_BusScrollItem *> * )btnsArr
                     nowSelectItem:(Inc_BusScrollItem *) item
                  BusODFScrollView:(Inc_BusDeviceView *)busView;

@end



@interface Inc_BusDeviceView : UIView

/// 根据设备Id 请求下属端子盘 , 再根据第一个端子盘请求下属端子信息  -- 构造器1
- (instancetype)initWithDeviceId:(NSString *)deviceId
                      deviceDict:(NSDictionary *)deviceDict
                              VC:(UIViewController *)vc;



/// 根据端子盘信息 , 查询下属端子  -- 构造器2
- (instancetype)initWithPieDict:(NSDictionary *)pieDict
                              VC:(UIViewController *)vc;



/// 根据已知的设备Id 和 端子盘Id , 查询对应的端子盘信息  -- 构造器3
/// 目前支持的设备类型 : OCC_Equt(光交箱) ODB_Equt(光分箱) ODF_Equt(机架)
/// 如果没有 pieId 则认为不需要指定显示端子盘 , 走通常端子选择方式
- (instancetype)initWithDeviceId:(NSString *)deviceId
              deviceResLogicName:(NSString *)deviceResLogicName
                           pieId:( NSString * _Nullable )pieId
                              VC:(UIViewController *)vc;




/// 直接跳过网络请求初始化端子盘 -- 构造器4  
- (instancetype) initWithLineCount:(int)lineCount
                          rowCount:(int)rowCount
                         Important:(Important_)import
                         Direction:(Direction_)dire
                        dataSource:(NSArray *)dataSource
                           PieDict:(NSDictionary *)pieDict
                                VC:(UIViewController *)VC;


/** 枚举类型 */
@property (nonatomic , assign) Yuan_BusDeviceEnum_ busDevice_Enum;


/** 请求新接口 还是老接口 */
@property (nonatomic , assign) Yuan_BusHttpPortEnum_ busHttp_Enum;


/** 代理 */
@property (nonatomic , weak) id <Yuan_BusDevice_ItemDelegate> delegate;


/** 端子盘内数据请求成功的回调  block */
@property (nonatomic , copy) void (^httpSuccessBlock) (void);

/** 长按回调  block */
@property (nonatomic , copy) void (^terminalLongPressBlock) (NSDictionary * btnDict);

/** 端子点击事件回调  block */
@property (nonatomic , copy) void (^terminalBtnClickBlock) (NSDictionary * terminalDict);


// 当前选中的盘的名字  例如 正面一框
- (NSString *) nowSelectPieName;


// 获取所有按钮 
- (NSArray <Inc_BusScrollItem *> * ) getBtns;

// 获取所有按钮 , 是按绑卡顺序排列的btn
- (NSArray <Inc_BusScrollItem *> * ) getArrangementBtn;

// 获取所有端子GID
- (NSArray *) getAllTerminalIds;


/// 获取当前的端子盘(列框) 信息
- (NSDictionary *) getPieDict;

#pragma mark - 2021.6.17 新增 ---

/// 控制传入的端子 高亮或取消高亮
- (void) letTerminal_Ids:(NSArray *) TerminalIdsArr isHighLight:(BOOL)isHighLight;

/// 控制传入的端子 高亮或取消高亮   目前光缆段和承载业务共同端子使用
- (void) letTerminal_IdsCableAndBear:(NSArray *) TerminalIdsArr isHighLight:(BOOL)isHighLight;


#pragma mark - 2022.4.19 新增 ---

// 根据传入的端子id , 让该端子移动到用户可视区域.
- (void) show_theTerminal_inBusDevice:(NSString *) terminalId;


@end

NS_ASSUME_NONNULL_END
