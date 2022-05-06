//
//  Yuan_NewFL_AZField.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/2/18.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger , Yuan_NewFL_AZField_) {
   
    Yuan_NewFL_AZField_A,
    Yuan_NewFL_AZField_Z,
    Yuan_NewFL_AZField_P//路过设备

};
@interface Yuan_NewFL_AZField : UIView



/** <#注释#>  block */
@property (nonatomic , copy) void (^AZ_Block) (Yuan_NewFL_AZField_ AZ);


- (instancetype)initWithAZ:(Yuan_NewFL_AZField_) AZ;

- (void) reloadName:(NSString *) name;

// 清空
- (void) clear;

@end


NS_ASSUME_NONNULL_END
