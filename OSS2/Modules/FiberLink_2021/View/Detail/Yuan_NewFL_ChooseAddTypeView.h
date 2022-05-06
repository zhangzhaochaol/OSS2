//
//  Yuan_NewFL_ChooseAddTypeView.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/2/23.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger , NewFL_ChooseAddType_) {
    NewFL_ChooseAddType_Cancel,
    NewFL_ChooseAddType_ChengDuan,
    NewFL_ChooseAddType_RongJie,
};

@interface Yuan_NewFL_ChooseAddTypeView : UIView

/**   block */
@property (nonatomic , copy) void (^chooseAddTypeBlock) (NewFL_ChooseAddType_ type);

@end

NS_ASSUME_NONNULL_END
