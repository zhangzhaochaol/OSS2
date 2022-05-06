//
//  Yuan_FL_LinkChooseView.h
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/12/1.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Yuan_FL_LinkChooseView : UIView

/** 当前选中的光链路Id */
@property (nonatomic ,copy)  NSString *nowSelectId;


// 验证一共有几个选项 , 并且当前选中的应该是哪个芯
- (void) reloadLink:(NSArray *)optPairLinkList currentOptPairLinkId:(NSString *)currentOptPairLinkId;


// 新版光链路切换时使用
- (void) NewFL_ReloadLink:(NSArray *)optPairLinkList nowSelectIndex:(NSInteger)index;

/** block */
@property (nonatomic ,copy) void(^chooseId_Block)(NSString * linkId , int now_LinkNum);


- (void) firstFiberClick;


@end

NS_ASSUME_NONNULL_END
