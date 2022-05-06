//
//  Inc_CFListLightVC.h
//  OSS2.0-ios-v2
//
//  Created by zzc on 2021/6/17.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_BaseVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface Inc_CFListLightVC : Inc_BaseVC

//选中光路数据
@property (nonatomic, strong) NSDictionary *selectDic;

/** 模板dict */
@property (nonatomic,strong) NSDictionary *moban_Dict;

//光缆id
@property (nonatomic,strong) NSString *cableId;

@end

NS_ASSUME_NONNULL_END
