//
//  SaoMiaoTYKViewControllerViewController.h
//  OSS2.0-ios-v2
//
//  Created by 孟诗萌 on 2017/7/6.
//  Copyright © 2017年 青岛英凯利信息科技有限公司. All rights reserved.
//
#import "Inc_BaseVC.h"


typedef void(^QRCodeScaned)(NSString * QRCode);

@interface SaoMiaoTYKViewControllerViewController : Inc_BaseVC
@property (nonatomic, assign) BOOL isGet;
@property (nonatomic, weak) id<ptotocolDelegate> delegate;
@property (nonatomic, assign) BOOL isPushedBy3DTouch;

@property (nonatomic, copy) QRCodeScaned hanlder;


/// 新巡检的扫描二维码
- (instancetype) initWithYuanNewXJ:(void(^)(NSString * scanMsg))scanBlock;
@end
