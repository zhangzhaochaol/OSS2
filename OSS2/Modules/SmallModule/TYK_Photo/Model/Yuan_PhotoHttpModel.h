//
//  Yuan_PhotoHttpModel.h
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/8/24.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 图片上传    120.52.12.12:8005
#define Photo_Http_UpLoad @"http://120.52.12.12:8951/file/upload"

/// 图片下载
#define Photo_Http_DownLoad @"http://120.52.12.12:8951/file/download"

/// 图片删除
#define Photo_Http_Delete @"http://120.52.12.12:8951/file/delete"

/// 获取图片路径  通过路径 , 下载图片
#define Photo_Http_GetList @"http://120.52.12.12:8951/file/getList"

@interface Yuan_PhotoHttpModel : NSObject


/// 获取图片路径  url
+ (void) http_GetList_PhotoURL:(NSDictionary *)param
                       success:(void(^)(NSArray * result))success;


/// 图片上传
+ (void) http_upLoadImg:(UIImage *)img
                imgName:(NSString *)imgName
                  param:(NSDictionary *)dict
                success:(void(^)(id result))success;


/// 图片删除
+ (void) http_deletePhoto:(NSDictionary *)param
                  success:(void(^)(id result))success;



@end

NS_ASSUME_NONNULL_END
