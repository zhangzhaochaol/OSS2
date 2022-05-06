//
//  QRCodeUtil.h
//  OSS2.0-ios-v2
//
//  Created by 孟诗萌 on 2017/11/8.
//  Copyright © 2017年 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QRCodeUtil : NSObject
-(NSString *)generateCRC:(NSString *)str;
@end
