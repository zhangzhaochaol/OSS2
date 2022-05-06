//
//  Inc_NewMB_VM.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/3/11.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Inc_NewMB_Model.h"

NS_ASSUME_NONNULL_BEGIN

@interface Inc_NewMB_VM : NSObject



+ (Inc_NewMB_VM *) viewModel;



/** 模板详情页 Controller类 */
@property (nonatomic , weak) UIViewController * vc;


// 保存和删除的权限配置
- (NSArray <UIButton *> *) bottomBtns_Enum:(Yuan_NewMB_ModelEnum_) modelEnum
                                    mbDict:(NSDictionary *)mbDict;






// 根据分光器枚举 返回对应的fileName   会持续更新
- (NSString *) fileNameFromEnum: (Yuan_NewMB_ModelEnum_) modelEnum;

// 根据分jsonfile 返回对应的枚举
- (Yuan_NewMB_ModelEnum_ ) EnumFromFileName: (NSString *) jsonFile;

// 根据enum获取旧版resLogicName
- (NSString *) getOldResLogicNameFromEnum:(Yuan_NewMB_ModelEnum_) modelEnum;

// 获取需要过滤的字段   会持续更新
- (NSArray *) getCleanKeys;


// 根据 resLogicName 转 新的type
- (NSString *) getNewTypeFromOldResLogicName:(NSString *) resLogicName;


extern BOOL Authority_Add (NSString * oldResLogicName);
extern BOOL Authority_Delete (NSString * oldResLogicName);
extern BOOL Authority_Modifi (NSString * oldResLogicName);

@end

NS_ASSUME_NONNULL_END
