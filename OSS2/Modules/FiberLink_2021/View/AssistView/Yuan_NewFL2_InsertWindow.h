//
//  Yuan_NewFL2_InsertWindow.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/10/25.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger , InsertWindowFromType_) {
    InsertWindowFromType_Links,         //光链路
    InsertWindowFromType_Routes,        //局向光纤
};


@interface Yuan_NewFL2_InsertWindow : UIView

- (instancetype)initWithFrame:(CGRect)frame Enum:(InsertWindowFromType_) Enum ;

/** 选择哪个进行插入?  block */
@property (nonatomic , copy) void (^insertTypeBlock) (BOOL isInsertRoute);


@end

NS_ASSUME_NONNULL_END
