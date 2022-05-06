//
//  Inc_NewMB_PushVM.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/11/18.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Yuan_NewMB_Enum.h"
#import <AMapNaviKit/AMapNaviKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Inc_NewMB_PushVM : NSObject    <AMapNaviCompositeManagerDelegate>


- (instancetype)initWithEnum:(Yuan_NewMB_ModelEnum_) Enum
                      MbDict:(NSDictionary *) dict
                          vc:(UIViewController *) vc;


// 在右侧是否显示导航栏按钮
- (BOOL) isHaveRightNaviMenu;


// 入口个数
- (NSArray *) MenuTitleArr;

// 点击了哪个入口
- (void) MenuSelectorIndex:(NSInteger) index;


- (NSDictionary *) getOldKeys;

@end

NS_ASSUME_NONNULL_END
