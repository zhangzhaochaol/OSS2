//
//  Inc_NewMB_DetailVC.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/3/10.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_BaseVC.h"
#import "Inc_NewMB_Model.h"
#import "Inc_NewMB_VM.h"
NS_ASSUME_NONNULL_BEGIN



typedef NS_ENUM(NSUInteger , Yuan_NewMB_Enum_) {
    Yuan_NewMB_Enum_Add,
    Yuan_NewMB_Enum_Delete,
    Yuan_NewMB_Enum_Modifi,
    Yuan_NewMB_Enum_Select,
};


@protocol Yuan_NewMB_DetailDelegate <NSObject>

- (void) reloadSearchName:(NSString *) searchName
                 EnumType:(Yuan_NewMB_Enum_)enumType;


@end


@interface Inc_NewMB_DetailVC : Inc_BaseVC


/** 外部列表搜索的索引 */
@property (nonatomic , copy) NSString * listSearchName;

/** delegate */
@property (nonatomic , weak) id <Yuan_NewMB_DetailDelegate> delegate;


- (instancetype)initWithDict:(NSDictionary *) cellDict
        Yuan_NewMB_ModelEnum:(Yuan_NewMB_ModelEnum_) resLogicName_Enum ;


/** 保存的回调 (部分模块使用)  block */
@property (nonatomic , copy) void (^saveBlock) (NSDictionary * saveDict);




#pragma mark - 只有当资源需要特殊参数处理时使用 , 通常不要使用一下参数 ---

/** 当保存时 需要传特殊参数 */
@property (nonatomic , copy) NSDictionary * modifyDict;

/** 当新增时 需要传特殊参数 */
@property (nonatomic , copy) NSDictionary * insertDict;

/** 当删除时 需要传特殊参数 */
@property (nonatomic , copy) NSDictionary * deleteDict;


#pragma mark - 复制功能使用

@property (assign,nonatomic) BOOL isCopy;
//复制的设备id，查询模版信息使用
@property (nonatomic ,copy)  NSString *gId;

@end

NS_ASSUME_NONNULL_END
