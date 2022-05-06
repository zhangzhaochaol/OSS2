//
//  Yuan_NewFL_SearchHeaderView.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/2/18.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger , HeaderBtnClick_) {
    HeaderBtnClick_A,           //A端搜索
    HeaderBtnClick_Z,           //z端搜索
    HeaderBtnClick_Show,        //展示与隐藏
    HeaderBtnClick_HeaderSearch,    // 放大镜按钮
    HeaderBtnClick_Search,          // 下方搜索按钮
    HeaderBtnClick_Clear,           // 清空
};


@interface Yuan_NewFL_SearchHeaderView : UIView

/** 是否展开 */
@property (nonatomic , assign , readonly) BOOL nowIsShow;

/** block */
@property (nonatomic , copy) void (^headerBlock) (HeaderBtnClick_ click);



- (void) show ;
- (void) hide ;


- (void) reloadDeviceName:(NSString *) deviceName Type:(HeaderBtnClick_) azType;
- (void) clear;

- (NSString *) searchName;



@end

NS_ASSUME_NONNULL_END
