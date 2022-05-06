//
//  Yuan_NewFL_ChooseDeviceView.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/2/19.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSUInteger , ChooseDeviceType_) {
    ChooseDeviceType_Cancel,
    ChooseDeviceType_ODF,       //ODF
    ChooseDeviceType_OCC,       //光交接箱
    ChooseDeviceType_ODB,       //光分纤箱
    ChooseDeviceType_ChengD,    //成端
    ChooseDeviceType_RongX,     //熔纤
};


@interface Yuan_NewFL_ChooseDeviceView : UIView

/** <#注释#>  block */
@property (nonatomic , copy) void (^ChooseDeviceCancelBlock) (ChooseDeviceType_ type);





@end

NS_ASSUME_NONNULL_END
