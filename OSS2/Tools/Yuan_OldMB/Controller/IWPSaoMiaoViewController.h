//
//  IWPSaoMiaoViewController.h
//  OSS2.0-ios-v2
//
//  Created by 王旭焜 on 2016/6/18.
//  Copyright © 2016年 青岛英凯利信息科技有限公司. All rights reserved.
//



typedef void(^QRCodeScaned)(NSString * QRCode);
typedef void(^ScannedInfo)(NSDictionary * dict);
@interface IWPSaoMiaoViewController : Inc_BaseVC
@property (nonatomic, assign) BOOL isGet;
@property (nonatomic, weak) id<ptotocolDelegate> delegate;
@property (nonatomic, assign) BOOL isPushedBy3DTouch;
/**
 是否不验证二维码，2018年03月06日 重庆需求，2018年03月06日 开始，仅在ODB离线中指定为TRUE
 */
@property (nonatomic, assign) BOOL isNotVerfyQRCode;
@property (nonatomic, copy) QRCodeScaned hanlder;
@property (nonatomic, copy) ScannedInfo scannedInfo;
@end
