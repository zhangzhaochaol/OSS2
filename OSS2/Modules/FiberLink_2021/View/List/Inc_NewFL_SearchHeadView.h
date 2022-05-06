//
//  Inc_NewFL_SearchHeadView.h
//  OSS2.0-ios-v2
//
//  Created by zzc on 2022/3/17.
//  Copyright © 2022 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSUInteger , HeaderBtnClickNew_) {

    HeaderBtnClickNew_P,           //经过设备
    HeaderBtnClickNew_Show,        //展示与隐藏
    HeaderBtnClickNew_HeaderSearch,    // 放大镜按钮
    HeaderBtnClickNew_Search,          // 下方搜索按钮
    HeaderBtnClickNew_Clear,           // 清空
};


@interface Inc_NewFL_SearchHeadView : UIView


/** 是否展开 */
@property (nonatomic , assign , readonly) BOOL nowIsShow;

/** block */
@property (nonatomic , copy) void (^headerBlock) (HeaderBtnClickNew_ click);



- (void) show ;
- (void) hide ;


- (void) reloadDeviceName:(NSString *) deviceName Type:(HeaderBtnClickNew_) azType;
- (void) clear;

- (NSString *) searchName;






@end

NS_ASSUME_NONNULL_END
