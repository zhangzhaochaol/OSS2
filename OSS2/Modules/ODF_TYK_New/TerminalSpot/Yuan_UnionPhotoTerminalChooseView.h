//
//  Yuan_UnionPhotoTerminalChooseView.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/2/2.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Yuan_UnionPhotoTerminalChooseView : UIView


/** 点击确认按钮的点击回调  block */
@property (nonatomic , copy) void (^enterClickBlock) (void);


- (void) reloadDataWithIndex:(NSInteger) index position:(NSInteger)position;

@end

NS_ASSUME_NONNULL_END
