//
//  Yuan_PhotoService.h
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/8/25.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, PhotoEnum_) {
    PhotoEnum_Carema,
    PhotoEnum_Library
};

@interface Yuan_PhotoService : NSObject

- (void) startLocation;


@property (nonatomic ,assign)  float lat;

@property (nonatomic ,assign)  float lon;



// 打开相机 / 相册
- (void) openCaremaEnum:(PhotoEnum_)enumType
               delegate:(UIViewController
                         <UIImagePickerControllerDelegate ,
                         UINavigationControllerDelegate> *)wself;



/// 通过 resLogicName + Gid + 时间戳的形式 给图片命名
NSString * ImgName (NSString * resLogicName , NSString * gid);


@end

NS_ASSUME_NONNULL_END
