//
//  Yuan_NewFL_SearchListVC.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/2/18.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_BaseVC.h"

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSUInteger , NewFL_EnterType_) {
    NewFL_EnterType_Link,       //光链路入口
    NewFL_EnterType_Route,      //局向入口
};

@interface Yuan_NewFL_SearchListVC : Inc_BaseVC

- (instancetype)initWithEnterType:(NewFL_EnterType_)enterType;


// 根据特殊规则筛选 , 没有上方的搜索框  点击是回调
- (instancetype)initWithEnterType:(NewFL_EnterType_)enterType
                      selectBlock:(void(^)(id data))block;


// 根据特殊规则筛选 , 没有上方的搜索框  点击是回调
- (instancetype)initWithEnterType:(NewFL_EnterType_)enterType
                             dict:(NSDictionary *)rulerDict
                      selectBlock:(void(^)(id data))block;


/** 光路内 光链路个数 */
@property (nonatomic , assign) NSInteger numberOfLinks;


@end

NS_ASSUME_NONNULL_END
