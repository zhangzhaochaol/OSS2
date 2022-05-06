//
//  Inc_DeviceTitleView.h
//  OSS2.0-ios-v2
//
//  Created by zzc on 2021/8/18.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Inc_DeviceTitleView : UIView


//正反面按钮点击   isJust yes  正面   no 反面
@property (nonatomic , copy) void (^btnClickBlock) (BOOL isJust);


@end

NS_ASSUME_NONNULL_END
