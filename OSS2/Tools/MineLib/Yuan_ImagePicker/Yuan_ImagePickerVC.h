//
//  Yuan_ImagePickerVC.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/1/22.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Yuan_ImagePickerVC : NSObject

- (instancetype)initWithVC:(UIViewController <UIImagePickerControllerDelegate ,
                            UINavigationControllerDelegate> *) vc;

- (void) openLibrary_Success:(void(^)(UIImage * image))image;

- (void) openCarema_Success:(void(^)(UIImage * image))image;

@end

NS_ASSUME_NONNULL_END
