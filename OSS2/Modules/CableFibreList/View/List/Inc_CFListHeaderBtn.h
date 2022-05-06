//
//  Inc_CFListHeaderBtn.h
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/7/20.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Inc_CFListHeaderBtn : UIButton

- (void) text :(NSString *)text;

/// 配置设备类型和数量
- (void) btnType:(NSString *)btnType
           count:(NSString *)count;

@end

NS_ASSUME_NONNULL_END
