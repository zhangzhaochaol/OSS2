//
//  Yuan_DOList_HeaderView.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/1/21.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSUInteger , Yuan_DOHeaderType_) {
    Yuan_DOHeaderType_MyOrder,
    Yuan_DOHeaderType_HistoryOrder,
};

@interface Yuan_DOList_HeaderView : UIView

// 级联删除使用
- (instancetype)init_MLD;


// 给两个文字
- (instancetype)initWithFirst:(NSString *)first
                       Second:(NSString *)second;

/** 选中的回调  block */
@property (nonatomic , copy) void (^doHeaderChooseBlock) (Yuan_DOHeaderType_ type);

@end

NS_ASSUME_NONNULL_END
