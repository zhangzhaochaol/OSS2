//
//  Inc_TipPointView.h
//  OSS2.0-ios-v2
//
//  Created by zzc on 2021/7/8.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@interface Inc_TipPointView : UIView

//按钮回调
@property (copy, nonatomic) void(^btnBlock)(void);

@end

NS_ASSUME_NONNULL_END
