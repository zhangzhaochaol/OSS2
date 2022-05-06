//
//  Increase_CaremaVC.h
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/1/22.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, PhotoEnum_) {
    PhotoEnum_Carema,
    PhotoEnum_Library
};

@interface Increase_CaremaVC : NSObject

- (instancetype)initWithVC:(UIViewController <UIImagePickerControllerDelegate ,
                            UINavigationControllerDelegate> *) vc;

- (void) openLibrary;

- (void) openCarema;

@end

NS_ASSUME_NONNULL_END
