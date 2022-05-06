//
//  Increase_ScanVC.m
//  科信光缆
//
//  Created by zzc on 2021/3/29.
//

#import <AVFoundation/AVFoundation.h>

#import "Increase_ScanVC.h"


// 全屏宽度和全屏高度
#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

#define NaviBarHeight (ScreenHeight >= 812.0 ? 88 : 64)


#define SYSTEM_COLOR @"47B984"   //主题色

@interface Increase_ScanVC ()<AVCaptureMetadataOutputObjectsDelegate,
UINavigationControllerDelegate,
UIImagePickerControllerDelegate,
UIGestureRecognizerDelegate>
{
  
    CGFloat _videoZoomFactor;
    
    UISlider *_slider;
    
}

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *preview;
@property (nonatomic, weak) UIImageView *line;
@property (nonatomic, assign) NSInteger distance;



@end

@implementation Increase_ScanVC

#pragma mark - 初始化构造方法

- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化信息
    [self initInfo];
    //创建控件
    [self creatControl];
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(zoomChangePinchGestureRecognizerClick:)];
    pinchGesture.delegate = self;
    [self.view addGestureRecognizer:pinchGesture];
    
    [self createSlider];
    
    
}
- (void)viewWillAppear:(BOOL)animated {

    //设置参数
    [self setupCamera];
    
    //添加定时器
    [self addTimer];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self stopScanning];
}

- (void)initInfo
{
    //背景色
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationItem.title = @"二维码扫描";

}


- (void)creatControl
{
    CGFloat scanW = ScreenWidth * 0.65;
    CGFloat padding = 10.0f;
    CGFloat labelH = 20.0f;
    CGFloat cornerW = 26.0f;
    CGFloat marginX = (ScreenWidth - scanW) * 0.5;
//    CGFloat tabBarH = 64.0f;
//    CGFloat marginY = (ScreenHeight - scanW - padding - labelH) * 0.5 - tabBarH;
    CGFloat marginY = 250;

    //遮盖视图
    for (int i = 0; i < 4; i++) {
        UIView *cover = [[UIView alloc] initWithFrame:CGRectMake(0, (marginY + scanW) * i, ScreenWidth, marginY + (padding + labelH) * i)];
        if (i == 2 || i == 3) {
            cover.frame = CGRectMake((marginX + scanW) * (i - 2), marginY, marginX, scanW);
        }
        cover.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.0f];
        [self.view addSubview:cover];
    }
    
    //扫描视图
    UIView *scanView = [[UIView alloc] initWithFrame:CGRectMake(marginX, marginY, scanW, scanW)];
    [self.view addSubview:scanView];
    
    //扫描线
    UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, scanW, 2)];
    [self drawLineForImageView:line];
    [scanView addSubview:line];
    self.line = line;
    
    //边框
    UIView *borderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, scanW, scanW)];
    borderView.layer.borderColor = [[UIColor clearColor] CGColor];
    borderView.layer.borderWidth = 1.0f;
    [scanView addSubview:borderView];
    
    //扫描视图四个角
    for (int i = 0; i < 4; i++) {
        CGFloat imgViewX = (scanW - cornerW) * (i % 2);
        CGFloat imgViewY = (scanW - cornerW) * (i / 2);
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(imgViewX, imgViewY, cornerW, cornerW)];
        if (i == 0 || i == 1) {
            imgView.transform = CGAffineTransformRotate(imgView.transform, M_PI_2 * i);
        }else {
            imgView.transform = CGAffineTransformRotate(imgView.transform, - M_PI_2 * (i - 1));
        }
        [self drawImageForImageView:imgView];
        [scanView addSubview:imgView];
    }
    
    //提示标签
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(scanView.frame) + padding *2, ScreenWidth, labelH)];
    label.text = @"将二维码放入框内，并使手机平行于二维码";
    label.font = [UIFont systemFontOfSize:16.0f];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    [self.view addSubview:label];
    


}

- (void)setupCamera
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //初始化相机设备
        self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
 
        //初始化输入流
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
        
        //初始化输出流
        AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
        //设置代理，主线程刷新
        [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        
        //初始化链接对象
        self.session = [[AVCaptureSession alloc] init];
        //高质量采集率
        [self.session setSessionPreset:AVCaptureSessionPresetHigh];
        
        if ([self.session canAddInput:input]) [self.session addInput:input];
        if ([self.session canAddOutput:output]) [self.session addOutput:output];
        
        //条码类型（二维码/条形码）
        output.metadataObjectTypes = [NSArray arrayWithObjects:AVMetadataObjectTypeAztecCode, AVMetadataObjectTypeDataMatrixCode, AVMetadataObjectTypeQRCode,AVMetadataObjectTypePDF417Code,AVMetadataObjectTypeCode128Code,AVMetadataObjectTypeEAN13Code,AVMetadataObjectTypeEAN8Code, nil];

        //更新界面
        dispatch_async(dispatch_get_main_queue(), ^{
            self.preview = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
            self.preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
            self.preview.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
            [self.view.layer insertSublayer:self.preview atIndex:0];
            [self.session startRunning];
        });
    });
}

- (void)addTimer
{
    _distance = 0;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.01f target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)timerAction
{
    if (_distance++ > ScreenWidth * 0.65) _distance = 0;
    _line.frame = CGRectMake(0, _distance, ScreenWidth * 0.65, 2);
}

- (void)removeTimer
{
    [_timer invalidate];
    _timer = nil;
}

#pragma mark - btnClick

//照明按钮点击事件
- (void)lightBtnOnClick:(UIButton *)btn
{
    //判断是否有闪光灯
    if (![_device hasTorch]) {
        [self alert:@"当前设备没有闪光灯，无法开启照明功能"];
        return;
    }
    
    btn.selected = !btn.selected;
    
    [_device lockForConfiguration:nil];
    if (btn.selected) {
        [_device setTorchMode:AVCaptureTorchModeOn];
    }else {
        [_device setTorchMode:AVCaptureTorchModeOff];
    }
    [_device unlockForConfiguration];
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    //扫描完成
    if ([metadataObjects count] > 0) {
        NSString *contentStr = [[metadataObjects firstObject] stringValue];
            
            [_session stopRunning];
            
            self.showCodeBlock(contentStr);
            [self.navigationController popViewControllerAnimated:YES];
        
      
    }
}

- (void)stopScanning
{
    [_session stopRunning];
    _session = nil;
    [_preview removeFromSuperlayer];
    [self removeTimer];
}

-(void)alert:(NSString *)title{
    [self alertSmallTitle:title];
}

//绘制角图片
- (void)drawImageForImageView:(UIImageView *)imageView
{
    UIGraphicsBeginImageContext(imageView.bounds.size);

    //获取上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    //设置线条宽度
    CGContextSetLineWidth(context, 6.0f);
    //设置颜色
    CGContextSetStrokeColorWithColor(context, [UIColor.greenColor CGColor]);
    //路径
    CGContextBeginPath(context);
    //设置起点坐标
    CGContextMoveToPoint(context, 0, imageView.bounds.size.height);
    //设置下一个点坐标
    CGContextAddLineToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, imageView.bounds.size.width, 0);
    //渲染，连接起点和下一个坐标点
    CGContextStrokePath(context);
    
    imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

//绘制线图片
- (void)drawLineForImageView:(UIImageView *)imageView
{
    CGSize size = imageView.bounds.size;
    UIGraphicsBeginImageContext(size);

    //获取上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    //创建一个颜色空间
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    //设置开始颜色
    const CGFloat *startColorComponents = CGColorGetComponents([UIColor.greenColor CGColor]);
    //设置结束颜色
    const CGFloat *endColorComponents = CGColorGetComponents([[UIColor grayColor] CGColor]);
    //颜色分量的强度值数组
    CGFloat components[8] = {startColorComponents[0], startColorComponents[1], startColorComponents[2], startColorComponents[3], endColorComponents[0], endColorComponents[1], endColorComponents[2], endColorComponents[3]
    };
    //渐变系数数组
    CGFloat locations[] = {0.0, 1.0};
    //创建渐变对象
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, 2);
    //绘制渐变
    CGContextDrawRadialGradient(context, gradient, CGPointMake(size.width * 0.5, size.height * 0.5), size.width * 0.25, CGPointMake(size.width * 0.5, size.height * 0.5), size.width * 0.5, kCGGradientDrawsBeforeStartLocation);
    //释放
    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(gradient);
    
    imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}



// UISlider
-(void)createSlider {
    
    /// 创建Slider 设置Frame
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(30,  ScreenHeight - NaviBarHeight  - 40 - 20 , ScreenWidth - 60, 20)];
    _slider = slider;
    /// 添加Slider
    [self.view addSubview:slider];
    
    /// 属性配置
    // minimumValue  : 当值可以改变时，滑块可以滑动到最小位置的值，默认为0.0
    slider.minimumValue = 1.0;
    // maximumValue : 当值可以改变时，滑块可以滑动到最大位置的值，默认为1.0
    slider.maximumValue = 6.0;
    // 当前值，这个值是介于滑块的最大值和最小值之间的，如果没有设置边界值，默认为0-1；
    slider.value = 1;
    // minimumTrackTintColor : 小于滑块当前值滑块条的颜色，默认为蓝色
    slider.minimumTrackTintColor = [UIColor whiteColor];
    // maximumTrackTintColor: 大于滑块当前值滑块条的颜色，默认为白色
    slider.maximumTrackTintColor = [UIColor whiteColor];
    // thumbTintColor : 当前滑块的颜色，默认为白色
    slider.thumbTintColor = [UIColor whiteColor];
    
    [slider addTarget:self action:@selector(sliderValueDidChanged:) forControlEvents:UIControlEventValueChanged];
    
}

-(void)sliderValueDidChanged:(UISlider *)slider {
    
    NSLog(@"%f",slider.value);
    NSError *error = nil;

    if ([self.device lockForConfiguration:&error] ) {
        [self.device rampToVideoZoomFactor:slider.value withRate:2];//rate越大，动画越慢
        [self.device unlockForConfiguration];
    }
    
    
}

#pragma mark -焦距缩放
//最小缩放值
- (CGFloat)minZoomFactor
{
    CGFloat minZoomFactor = 1.0;
    if (@available(iOS 11.0, *)) {
        minZoomFactor = self.device.minAvailableVideoZoomFactor;
    }
    return minZoomFactor;
}
 
//最大缩放值
- (CGFloat)maxZoomFactor
{
    CGFloat maxZoomFactor = self.device.activeFormat.videoMaxZoomFactor;
    if (@available(iOS 11.0, *)) {
        maxZoomFactor = self.device.maxAvailableVideoZoomFactor;
    }
    
    if (maxZoomFactor > 6) {
        maxZoomFactor = 6;
    }
    return maxZoomFactor;
}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]]){
        _videoZoomFactor = self.device.videoZoomFactor;
    }
    return YES;
}
//缩放手势
- (void)zoomChangePinchGestureRecognizerClick:(UIPinchGestureRecognizer *)pinchGestureRecognizer
{
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateBegan ||
        pinchGestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
        CGFloat currentZoomFactor = _videoZoomFactor * pinchGestureRecognizer.scale;
        
        [self changeFactor:currentZoomFactor];
    }
    else
    {
        
    }
}
-(void) changeFactor:(CGFloat)currentZoomFactor{
    if (currentZoomFactor < self.maxZoomFactor &&
        currentZoomFactor > self.minZoomFactor){
        
        NSError *error = nil;
        if ([self.device lockForConfiguration:&error] ) {
            //            dispatch_async(dispatch_get_main_queue(), ^{
            [self.device rampToVideoZoomFactor:currentZoomFactor withRate:2];//rate越大，动画越慢
            _slider.value = currentZoomFactor;
            //                self.device.videoZoomFactor = currentZoomFactor;//无动画
            [self.device unlockForConfiguration];
            //            });
            NSLog(@"%f",currentZoomFactor);
        }
        else {
            NSLog( @"Could not lock device for configuration: %@", error );
        }
    }
}



- (void) alertSmallTitle:(NSString *)title {
    
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:@"" preferredStyle:UIAlertControllerStyleAlert];
    // Create the actions.
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    
    // Add the actions.
    [alertController addAction:cancelAction];
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
}


@end
