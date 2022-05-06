//
//  IWPQcodeScaner.h
//
//  Created by 王旭焜 on 15/10/10.
//  Copyright © 2015年 王旭焜. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
// 123123123


typedef NS_ENUM(NSUInteger, IWPQcodeScanerScanType) {
    IWPQcodeScanerScanTypeQRCode,
    IWPQcodeScanerScanTypeBarCode
};


@interface IWPQcodeScaner : NSObject <AVCaptureMetadataOutputObjectsDelegate>

@property (strong, nonatomic) UIImageView *boxView;
@property (strong, nonatomic) UIImageView *scanLayer;
@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) BOOL addFlag;
@property (assign, nonatomic) int dir;
@property (copy, nonatomic) NSString * hintText;

/** 调取照片 */
@property (nonatomic , strong) UIButton * photoBtn;


@property (strong, nonatomic) UIView *scanView;

typedef void (^setMsgHandler)(NSString *msg);
@property (copy, nonatomic) setMsgHandler callback;

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;

-(BOOL)startReading:(setMsgHandler) setmsg;
-(void)stopReading;
-(void)validate;
-(instancetype)initWithSupperView:(UIView *)scanView;
-(instancetype)initWithSupperView:(UIView *)scanView type:(IWPQcodeScanerScanType)type;
@end
