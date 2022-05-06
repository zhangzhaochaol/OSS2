//
//  Inc_NewMB_Presenter.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/6/22.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Inc_NewMB_Presenter : NSObject

+ (Inc_NewMB_Presenter *) presenter;


/** 详情界面 vc */
@property (nonatomic , weak) UIViewController * detailVC;


#pragma mark - 纤芯衰耗系数判断 optPair ---

/** 纤芯衰耗系数计算结果 的后续响应  block */
@property (nonatomic , copy) void (^optPair_ConfigBlock) (NSDictionary * dict);

/** 光缆段长度 */
@property (nonatomic , copy) NSString * cableLength;


#pragma mark - 新模板特殊字段的判断 ---

/// 当前字段是否需要特殊判断
- (BOOL) theKeyIsInSpecial:(NSString *) key;

/// 当 NewMB_Item 进行赋值时的特殊判断
- (NSString *) NewMB_Item_ModelConfigKey:(NSString *) key
                                    dict:(NSDictionary *) dict;



#pragma mark - 纤芯衰耗 ---

// 纤芯衰耗字段的 '-' 负号判断
- (NSString *) lightAttenuationCoefficient_Config:(NSString *) textField_Txt;

// 纤芯的 衰耗系数特殊判断 -- 下属标注
- (NSString *) optPair_SpecialConfig:(NSString *) textField_Txt ;

// 判断值是否是数值
- (BOOL) isNumbers:(NSString *) textField_Txt;

// 跳转光纤光路
- (void) PushToFiberLink:(NSDictionary *) dict;

// 跳转局向光纤
- (void) PushToFiberRoute:(NSDictionary *) dict;

// 跳转纤芯配置
- (void) PushToCFConfig:(NSDictionary *)dict;

// 跳转模块配置
- (void) PushToModule:(NSDictionary *)dict;

#pragma mark - 反地理编码 ---

// 反地理编码
- (void) reGeocodeSearch:(CLLocationCoordinate2D) coor
                 success:(void (^) (NSString * address)) block;








/// 根据 设备数字代码 转 设备英文代码
+ (NSString *) DeviceNumCode_To_DeviceEnglishCode: (NSString *) DeviceNumCode;

@end

NS_ASSUME_NONNULL_END
