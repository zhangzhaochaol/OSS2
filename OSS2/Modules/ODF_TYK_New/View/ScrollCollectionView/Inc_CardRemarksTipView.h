//
//  Inc_CardRemarksTipView.h
//  OSS2.0-ios-v2
//
//  Created by zzc on 2021/9/8.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
//模块备注
@interface Inc_CardRemarksTipView : UIView

//备注信息
@property (nonatomic, strong) UITextView *textView;

//按钮回调
@property (copy, nonatomic) void(^btnBlock)(UIButton * btn);


//高度
@property (copy, nonatomic) void(^heightBlock)(CGFloat height);

-(void)setNum:(NSString *)num;


@end

NS_ASSUME_NONNULL_END
