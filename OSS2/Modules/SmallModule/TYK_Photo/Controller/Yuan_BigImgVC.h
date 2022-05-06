//
//  Yuan_BigImgVC.h
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/8/25.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Yuan_BigImgVC : UIViewController

// 根据image 查看图片
- (instancetype) initWithImg:(UIImage *)img;

// 根据url查看图片
- (instancetype) initWithImgUrl:(NSString *)url;

@end

NS_ASSUME_NONNULL_END
