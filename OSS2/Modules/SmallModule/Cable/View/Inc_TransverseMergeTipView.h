//
//  Inc_TransverseMergeTipView.h
//  OSS2.0-ios-v2
//
//  Created by zzc on 2021/9/16.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Inc_TransverseMergeTipView : UIView

//第1个光缆段数据
@property (nonatomic, strong) NSDictionary *firstDic;
//第2个光缆段数据
@property (nonatomic, strong) NSDictionary *secendDic;

//按钮回调
@property (nonatomic, copy) void (^btnClick)(UIButton *btn, NSDictionary *postDic);


@end

NS_ASSUME_NONNULL_END
