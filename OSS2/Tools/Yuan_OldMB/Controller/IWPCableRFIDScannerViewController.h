//
//  IWPCableRFIDScannerViewController.h
//  OSS2.0-ios-v2
//
//  Created by 王旭焜 on 2016/7/8.
//  Copyright © 2016年 青岛英凯利信息科技有限公司. All rights reserved.
//


@protocol IWPCableRFIDScannerDelegate <NSObject>
-(void)cableWithDict:(NSDictionary *)dict;
@end

typedef void(^DidCommitRFID)(NSString * RFID);

@interface IWPCableRFIDScannerViewController : Inc_BaseVC
@property (nonatomic, strong) NSDictionary * cableInfo;
@property (nonatomic, weak) id <IWPCableRFIDScannerDelegate> delegate;
/**
 提交RFID后调用的代码段
 */
@property (nonatomic, copy) DidCommitRFID handler;
/**
 已存在的RFID
 */
@property (nonatomic, copy) NSString * RFID;
@end
