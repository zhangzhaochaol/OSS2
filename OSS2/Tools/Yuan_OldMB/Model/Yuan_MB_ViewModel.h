//
//  Yuan_MB_ViewModel.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/3/1.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IWPPropertiesReader.h"


NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger{
    TYKDeviceListInsert,
    TYKDeviceListUpdate,
    TYKDeviceListInsertRfid,
    TYKDeviceListUpdateRfid,
    TYKDeviceInfomationTypeDuanZiMianBan_Update,
    TYKDeviceListNoDelete,          //袁全新增 不可以删除
    TYKDevice_NewCheck,             //袁全新增 扫一扫跳转稽查   2021.5.12
}TYKDeviceListControlTypeRef;

@interface Yuan_MB_ViewModel : NSObject

+ (instancetype) viewModel;


/**
 *  總模型
 */
@property (nonatomic, strong) IWPPropertiesSourceModel * model;


@property (nonatomic, assign) TYKDeviceListControlTypeRef controlMode;

/** resLogicName */
@property (nonatomic , copy) NSString * fileName;


// 特殊类型的资源 , 对模板文件做一些微调 , 新增或替换
- (NSArray *) Special_MB_Config:(NSMutableArray *) arr ;


// 对特殊字段进行特殊处理
- (NSMutableDictionary *) Special_MB_KeyConfig:(NSMutableDictionary *) requestDict key:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
