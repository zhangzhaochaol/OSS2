//
//  Yuan_PhotoHttpModel.m
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/8/24.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_PhotoHttpModel.h"
#import "Yuan_WebService.h"




@implementation Yuan_PhotoHttpModel

/// 获取图片路径  url
+ (void) http_GetList_PhotoURL:(NSDictionary *)param
                       success:(void(^)(NSArray * result))success {
    
    
    [[Http shareInstance] POST:Photo_Http_GetList
                          dict:param.mutableCopy
                       succeed:^(id data) {
        
            NSNumber * code = data[@"code"];
            if ([code isEqual:@200]) {

                NSArray * array = data[@"data"][@"content"];
                if (array && array.count > 0) {
                    if (success) {
                        success(array);
                    }
                }
            }
        
    }];
    
    
}


/// 图片上传
+ (void) http_upLoadImg:(UIImage *)img
                imgName:(NSString *)imgName
                  param:(NSDictionary *)dict
                success:(void(^)(id result))success {
    
    
    [[Http shareInstance] V2_POST_Image:img
                                imgName:[NSString stringWithFormat:@"%@.png",imgName ]
                                    URL:Photo_Http_UpLoad
                                  param:dict
                                succeed:^(id data) {
        
        if (success) {
            
            NSNumber * code = data[@"code"];
            if ([code isEqual:@200]) {
                success(data);
            }else {
                NSString * msg = data[@"msg"];
                [[Yuan_HUD shareInstance] HUDFullText:msg ?: @"上传失败"];
            }
        }
        
    }];
        
}


/// 图片删除
+ (void) http_deletePhoto:(NSDictionary *)param
                  success:(void(^)(id result))success {
    
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:param];
    
    [[Http shareInstance] POST:Photo_Http_Delete
                          dict:dict
                       succeed:^(id data) {
        
        if (success) {
            
            NSNumber * code = data[@"code"];
            if ([code isEqual:@200]) {       
                success(data);
            }else {
                NSString * msg = data[@"msg"];
                [[Yuan_HUD shareInstance] HUDFullText:msg ?: @"删除失败"];
            }
        }
    }];
    
}




@end
