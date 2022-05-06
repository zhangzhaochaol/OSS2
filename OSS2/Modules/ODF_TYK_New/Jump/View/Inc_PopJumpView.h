//
//  Inc_PopJumpView.h
//  OSS2.0-ios-v2
//
//  Created by zzc on 2021/6/24.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@interface Inc_PopJumpView : UIView


@property (nonatomic,strong) NSArray *dataArray;

// 1 关联   2 解除关联
@property (nonatomic, strong) NSString *type;

//关联  解除关联
@property (copy, nonatomic) void(^btnBlock)(UIButton * btn);

//是否含有跳纤  用于判断是否显示提示
@property (nonatomic) BOOL isHaveJump;

-(void)reloadData;


@end

NS_ASSUME_NONNULL_END
