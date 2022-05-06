//
//  Yuan_DC_TubeHandleView.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/1/12.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Yuan_DC_TubeHandleView : UIView

/** 关闭  block */
@property (nonatomic , copy) void (^cancelBlock) (void);

- (void) reloadWithArray:(NSArray *)dataArray ;

- (void) pipeName:(NSString *)name ;

/** 最终选择的管孔数据  block */
@property (nonatomic , copy) void (^chooseTubeBlock) (NSDictionary * tubeDict);

@end

NS_ASSUME_NONNULL_END
