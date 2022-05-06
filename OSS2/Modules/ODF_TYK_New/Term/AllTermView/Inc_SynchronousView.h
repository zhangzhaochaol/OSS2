//
//  Inc_SynchronousView.h
//  OSS2.0-ios-v2
//
//  Created by zzc on 2021/6/24.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Inc_SynchronousView : UIView

@property (nonatomic,strong) NSArray *dataArray;

//确认
@property (copy, nonatomic) void(^btnSureBlock)(UIButton * btn);
//取消
@property (copy, nonatomic) void(^btnCancelBlock)(UIButton * btn);


-(void)reloadData;

@end

NS_ASSUME_NONNULL_END
