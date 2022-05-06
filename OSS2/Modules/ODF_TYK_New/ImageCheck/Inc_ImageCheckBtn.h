//
//  Inc_ImageCheckBtn.h
//  OSS2.0-ios-v2
//
//  Created by zzc on 2021/8/10.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Inc_ImageCheckBtn : UIButton

//当前按钮数据
@property (nonatomic, strong) NSDictionary *dic;
//按钮显示状态
@property (nonatomic, strong) NSString *title;
//文字颜色
@property (nonatomic, strong) UIColor *titleColor;

//是正常按钮还是增强识别后按钮  yes 正常
@property (nonatomic ) BOOL isNomal;

@end

NS_ASSUME_NONNULL_END
