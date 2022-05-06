//
//  Inc_ConditionSearchView.h
//  OSS2.0-ios-v2
//
//  Created by zzc on 2021/8/13.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Inc_ConditionSearchView : UIView

//根据resLogicName 查询本地json 对应的搜索条件
@property (nonatomic, strong) NSString * resLogicName;

//btn回调   dic  入参
@property (copy, nonatomic) void(^btnBlock)(NSDictionary *dic);

////点击背景
//@property (copy, nonatomic) void(^viewBlock)(void);


- (void)reloadData;

@end

NS_ASSUME_NONNULL_END
