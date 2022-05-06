//
//  IWPQcodeScaner.m
//
//  Created by 王旭焜 on 15/10/10.
//  Copyright © 2015年 王旭焜. All rights reserved.
//

#import "IWPQcodeScaner.h"
@interface IWPQcodeScaner ()
@property (nonatomic, assign) BOOL isScanned;
@property (nonatomic, weak) UILabel * hintLabel;


@property (nonatomic, assign) IWPQcodeScanerScanType type;
@end
//123123123
@implementation IWPQcodeScaner
-(instancetype)initWithSupperView:(UIView *)scanView
{
    self = [super init];
    if (self) {
        
        _type = IWPQcodeScanerScanTypeQRCode;
        self.scanView = scanView;
        self.captureSession = nil;
        self.addFlag = YES;
        self.dir = 5;
 
    }
    
    return self;
}



-(instancetype)initWithSupperView:(UIView *)scanView type:(IWPQcodeScanerScanType)type{
    
    if (self = [self initWithSupperView:scanView]) {
        _type = type;
    }
    
    return self;
}

- (BOOL)startReading:(setMsgHandler)setmsg
{
    _isScanned = false;
    self.callback = setmsg;
    NSError *error;

    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];

    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if (!input) {
        
        
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"无法访问相机" message:@"请确认是否开启了相机访问权限" preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            
        }]];
        
        Present(UIApplication.sharedApplication.keyWindow.rootViewController, alert);
    
        return NO;
    }
    
    
    
    
    

    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];

    self.captureSession = [[AVCaptureSession alloc] init];

    [self.captureSession addInput:input];

    [self.captureSession addOutput:captureMetadataOutput];

    dispatch_queue_t dispatchQueue = dispatch_queue_create("myQueue", NULL);

    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];

    
    NSMutableArray * types = [NSMutableArray array];
    
    if (_type == IWPQcodeScanerScanTypeQRCode) {
        [types addObject:AVMetadataObjectTypeQRCode];
    }else{
        [types addObjectsFromArray:@[AVMetadataObjectTypeEAN13Code,
                                                         AVMetadataObjectTypeEAN8Code,
                                                         AVMetadataObjectTypeUPCECode,
                                                         AVMetadataObjectTypeCode39Code,
                                                         AVMetadataObjectTypeCode39Mod43Code,
                                                         AVMetadataObjectTypeCode93Code,
                                                         AVMetadataObjectTypeCode128Code,
                                                         AVMetadataObjectTypePDF417Code]];;
    }
    

//    [captureMetadataOutput setMetadataObjectTypes:@[AVMetadataObjectTypeUPCECode, AVMetadataObjectTypeCode39Code,AVMetadataObjectTypeCode39Mod43Code,AVMetadataObjectTypeEAN13Code,AVMetadataObjectTypeEAN8Code,AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeCode128Code,AVMetadataObjectTypePDF417Code,AVMetadataObjectTypeQRCode,AVMetadataObjectTypeAztecCode,AVMetadataObjectTypeInterleaved2of5Code,AVMetadataObjectTypeITF14Code,AVMetadataObjectTypeDataMatrixCode]];
    
    
    captureMetadataOutput.metadataObjectTypes = types;
    
    self.videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];

    [self.videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];

    [self.videoPreviewLayer setFrame:self.scanView.layer.bounds];

    [self.scanView.layer addSublayer:self.videoPreviewLayer];
    

    
//    captureMetadataOutput.rectOfInterest = CGRectMake(0,0,1,1);

    CGFloat x = 0,y = 0,w = 50,h = 50, margin = ScreenWidth / 10.f;
    
    x = margin;
    y = self.scanView.bounds.size.height * .2f;
    w = self.scanView.bounds.size.width - margin * 2;
    h = w;
    
    
    
    self.boxView = [[UIImageView alloc] initWithFrame:CGRectMake(x,y,w,h)];
    
//    self.boxView.layer.borderColor = [UIColor colorWithHexString:@"#ccc"].CGColor;
//    self.boxView.layer.borderWidth = 2.0f;
    
    self.boxView.image = [UIImage Inc_imageNamed:@"scanner"];
    
//    self.boxView.backgroundColor = [UIColor greenColor];
    
    CGFloat x1 = 0 ,y1 = 0, w1 = 0,h1 = 0;
    x1 = self.scanView.bounds.origin.x;
    y1 = self.scanView.bounds.origin.y;
    w1 = self.scanView.bounds.size.width;
    h1 = self.scanView.bounds.size.height;
    
    captureMetadataOutput.rectOfInterest = CGRectMake(y1/y, x1/x, h1/h, w1/w);

    
    NSLog(@"%@", NSStringFromCGRect(captureMetadataOutput.rectOfInterest));
    
    
    
    x = 0,y = 0,w = 50,h = 50;
    
    UIImageView * images1 = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, w, h)];
    images1.image = [UIImage Inc_imageNamed:@"barsacn_left_top"];
    [self.boxView addSubview:images1];
    
    y = self.boxView.frame.size.height - h;
    
    UIImageView * images2 = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, w, h)];
    images2.image = [UIImage Inc_imageNamed:@"barsacn_left_bottom"];
    [self.boxView addSubview:images2];
    
    x = self.boxView.frame.size.width - w;
    y = 0;
    UIImageView * images3 = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, w, h)];
    images3.image = [UIImage Inc_imageNamed:@"barsacn_right_top"];
    [self.boxView addSubview:images3];
    
    y = self.boxView.frame.size.height - h;
    
    UIImageView * images4 = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, w, h)];
    images4.image = [UIImage Inc_imageNamed:@"barsacn_right_bottom"];
    [self.boxView addSubview:images4];
    
    
    
    [self.scanView addSubview:self.boxView];
    

    
    UILabel * hintLabel = [UILabel new];
    self.hintLabel = hintLabel;
    x = 0;
    y = CGRectGetMaxY(self.boxView.frame) + 5.f;
    w = self.scanView.bounds.size.width;
    h = 40;
    hintLabel.frame = CGRectMake(x, y, w, h);
    hintLabel.font = [UIFont systemFontOfSize:17];
    hintLabel.textColor = [UIColor colorWithHexString:@"#eee"];
    hintLabel.textAlignment = NSTextAlignmentCenter;
    hintLabel.shadowColor = [UIColor blackColor];
    hintLabel.shadowOffset = CGSizeMake(1, 1);
    hintLabel.text = _hintText.length > 0 ? _hintText : @"请将扫描窗口对准二维码";
    [self.scanView addSubview:hintLabel];
    
    
    w = 50;
    h = 40;
    x = 0;
    y = 0;
    
    
    UIButton * turnOnLight = [UIButton buttonWithType:UIButtonTypeCustom];

    turnOnLight.frame = CGRectMake(x,y,w,h);
    [turnOnLight setTitle:@"开灯" forState: UIControlStateNormal];
    [turnOnLight setTitle:@"关灯" forState: UIControlStateSelected];

    [turnOnLight addTarget:self action:@selector(turnOnTurnOffLight:) forControlEvents:UIControlEventTouchUpInside];
    
    
//    [self.scanView addSubview:turnOnLight];
    
    // 寻找扫描视图所属控制器
    UIResponder *next = [self.scanView nextResponder];
    UIViewController * vc = nil;
    do {
        if ([next isKindOfClass:[UIViewController class]]) {
            vc = (UIViewController *)next;
        }
        next = [next nextResponder];
    } while (next != nil);
    
    // 给该控制器的 navgation 添加开关灯按钮
    vc.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:turnOnLight];

    
    
    self.scanLayer = [[UIImageView alloc] initWithImage:[UIImage Inc_imageNamed:@"barscan_cursor"]];
    self.scanLayer.frame = CGRectMake(5, 0, self.boxView.bounds.size.width, 20.f);
    self.scanLayer.backgroundColor = [UIColor clearColor];
    
    [self.boxView addSubview:self.scanLayer];
    [self validate];
    
    

    [self.captureSession startRunning];
    [self creatCover];
    return YES;
    
    
}
-(void)creatCover{
    CGFloat x,y,w,h;
    
    UIColor * bakColor = [UIColor colorWithHexString:@"#7f000000"];
    
    x = CGRectGetMinX(self.boxView.frame);
    y = 0;
    w = self.boxView.frame.size.width;
    h = CGRectGetMinY(self.boxView.frame);
    UIView * coverTop = [[UIView alloc] initWithFrame:CGRectMake(x,y,w,h)];
    [self.scanView addSubview:coverTop];
    coverTop.backgroundColor = bakColor;
    
    x = 0;
    w  = CGRectGetMinX(self.boxView.frame);
    h = self.scanView.bounds.size.height;
    UIView * coverLeft = [[UIView alloc] initWithFrame:CGRectMake(x,y,w,h)];
    coverLeft.backgroundColor = bakColor;
    [self.scanView addSubview:coverLeft];
    
    x = CGRectGetMaxX(self.boxView.frame);
    UIView * coverRight = [[UIView alloc] initWithFrame:CGRectMake(x,y,w,h)];
    coverRight.backgroundColor = bakColor;
    [self.scanView addSubview:coverRight];
    
    
    x = CGRectGetMinX(self.boxView.frame);
    y = CGRectGetMaxY(self.boxView.frame);
    w = self.scanView.bounds.size.width - 2 * x;
    h = self.scanView.bounds.size.height - y;
    UIView * coverBottom = [[UIView alloc] initWithFrame:CGRectMake(x,y,w,h)];
    coverBottom.backgroundColor = bakColor;
    [self.scanView addSubview:coverBottom];
    
    [self.scanView bringSubviewToFront:self.hintLabel];
}
-(void)turnOnTurnOffLight:(UIButton *)sender{
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (sender.selected) {
        if ([device hasTorch]) {
            [device lockForConfiguration:nil];
            [device setTorchMode: AVCaptureTorchModeOff];
            [device unlockForConfiguration];
        }
    }else{
        
        if ([device hasTorch]) {
            [device lockForConfiguration:nil];
            [device setTorchMode: AVCaptureTorchModeOn];
            [device unlockForConfiguration];
        }
    }
    
    sender.selected = !sender.selected;
}
-(void)validate{
    if (self.timer) {
        self.timer = nil;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.02f target:self selector:@selector(moveScanLayer:) userInfo:nil repeats:YES];
    }else{
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.02f target:self selector:@selector(moveScanLayer:) userInfo:nil repeats:YES];
    }
}

-(void)setHintText:(NSString *)hintText{
    _hintText = hintText;
    self.hintLabel.text = hintText;
}

-(void)stopReading{
    [self.timer invalidate];
    [self.captureSession stopRunning];
    
    AVCaptureMetadataOutput *captureMetadataOutput = self.captureSession.outputs.firstObject;
    
    
    [captureMetadataOutput setMetadataObjectsDelegate:nil queue:NULL];
    self.captureSession = nil;
    [self.scanLayer removeFromSuperview];
    [self.videoPreviewLayer removeFromSuperlayer];
}


#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{

    if (metadataObjects != nil && [metadataObjects count] > 0 && !_isScanned) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
       
        _isScanned = true;
        NSLog(@"%@", [[NSString alloc] initWithData:[[metadataObj stringValue] dataUsingEncoding:NSASCIIStringEncoding] encoding:NSUTF8StringEncoding]);
        
        
        
        [self performSelectorOnMainThread:@selector(transMsgToPreView:) withObject:[metadataObj stringValue] waitUntilDone:NO];
        
        [self performSelectorOnMainThread:@selector(stopReading) withObject:nil waitUntilDone:NO];
    }
}

-(void)transMsgToPreView:(NSString *)msg
{
    self.callback(msg);
    
    [self stopReading];
}

- (void)moveScanLayer:(NSTimer *)timer{
    CGRect frame = self.scanLayer.frame;
    if (frame.origin.y > self.boxView.frame.size.height - frame.size.height) {
        self.dir = -5;
    } else if (frame.origin.y <= 0) {
        self.dir = 5;
    }
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.3];
    frame.origin.y += self.dir;
    self.scanLayer.frame = frame;
    [UIView commitAnimations];
}







@end
