//
//  Yuan_ScrollVC.m
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/6/3.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_ScrollVC.h"

// *************

//#import "Yuan_ImageCheckChooseVC.h"             //老版的图片识别 , 已废弃!
#import "Yuan_ImagePickerVC.h"                  //图片拍摄
#import "Yuan_TailorImageVC.h"                  //图片裁剪

#import "Inc_TermJumpingVC.h"                   //zzc 2021-6-25 跳纤

#import "Yuan_OBD_PointsConfigVC.h"             //分光器详细信息业务
#import "Yuan_OBD_Points_DeviceListVC.h"        //分光列表

#import "Inc_TE_ChooseVC.h"                     //端子对调 2021年8月

// *************

#import "Yuan_ScrollCollectView.h"              // 端子盘
#import "Yuan_UnionPhotoTerminalChooseView.h"   // 端子选择View
#import "Yuan_BatchHoldView.h"                  // 批量修改端子状态
#import "MLMenuView.h"                          // 下拉列表


// *************

#import "Yuan_ODF_HttpModel.h"      // 专门做网络请求的类
#import "Inc_NewMB_HttpModel.h"            //新模板接口

#import "Yuan_ODFViewModel.h"
#import "Yuan_PhotoCheckVM.h"
#import "UIImage+FixOrientation.h"
#import "Inc_KP_Config.h"






//zzc 2021-7-8 端子识别指引

#import "Inc_TipPointView.h"
#import "Inc_TerminalTipView.h"

//zzc 2021-8-10 新端子识别配置vc
#import "Inc_ImageCheckNewVC.h"


//zzc 2021-9-2  提示
#import "Inc_CountdownTipsView.h"
//调用相机
#import "LCImagePickerManager.h"

// 倒计时通用view
#import "Yuan_CountDownAlertView.h"

//板卡备注修改
#import "Inc_CardRemarksTipView.h"


static float terminalChooseView_Height = 100;
static float batchHoldView_Height = 130;


typedef NS_ENUM(NSUInteger , Yuan_ScrollState_) {
    Yuan_ScrollState_Photo,
    Yuan_ScrollState_BatchHold,
};


@interface Yuan_ScrollVC ()
<
    UIScrollViewDelegate ,       // scroll
    UIGestureRecognizerDelegate, // 禁止右滑手势
    UIImagePickerControllerDelegate ,
    UINavigationControllerDelegate ,
    MLMenuViewDelegate          // 下拉
>

/** scroll_Collect */
@property (nonatomic,strong) Yuan_ScrollCollectView *scroll_Collect;

/** 端子选择 */
@property (nonatomic , strong) Yuan_UnionPhotoTerminalChooseView * photoTerminalChooseView;

/** 批量操作端子状态View */
@property (nonatomic , strong) Yuan_BatchHoldView * batchHold_2021;

/** 下拉列表  拍照和批量修改 */
@property (nonatomic , strong) MLMenuView * menu;

//zzc 2021-7-8 端子识别指引
@property (nonatomic, strong) Inc_TipPointView  *tipPointView;  //首次进入弹出导航view
@property (nonatomic, strong) Inc_TerminalTipView *terminalTipView; //端子识别前弹出提示view

@property (nonatomic, strong) Inc_CountdownTipsView *countdownTipsView; //弹出提示view

@property (nonatomic, strong) Inc_CardRemarksTipView *remarksTipsView; //备注修改提示view

@end

@implementation Yuan_ScrollVC
{
    
    NSDictionary * _dict;
    
    NSMutableArray * _dataSource;
    
    NSString * _moduleRowQuantity;  // 模块行数
    
    NSString * _moduleColumnQuantity; //模块列数
    
    Important_ _importRule;   //行优 还是 列优  枚举值
    
    Direction_ _dire;  // 上左 上右 下左 下右
    
    
    //工具
    Inc_KP_Config *_CF;
    
    
    
    
    // 2021 新增

    Yuan_ScrollState_ _nowType;
    
    Yuan_ImagePickerVC * _photoConfig;
    
    UIImage * _myImg;

    
    NSArray * _photoCheckDataSource;
    
    NSLayoutConstraint * _photoTerminalConstraint;
    
    Yuan_PhotoCheckVM * _photoVM;
    
    // base64 img
    NSString * _photoCheckBase64Img;
    // 识别回来的矩阵
    NSArray * _photoCheckMatrixArr;
    
    
    // 批量操作端子
    NSLayoutConstraint * _batchHoldConstraint;
    NSLayoutConstraint * _scroll_TopConstraint;
    
    
    //zzc 2021-7-8 端子识别指引
    //黑色透明背景view
    UIView *_windowBgView;
    
    //识别反馈需要原图base64
    NSString *_base64Img;
    //位置信息数组
    NSMutableArray *_terminalImageCheck_Arr;
    //修改前矩阵
    NSMutableArray *_matrix;
    //修改后矩阵
    NSMutableArray *_matrixModified;
    
    //选中修改的端子
    NSMutableArray *_batchHoldArray;


    //模块数据
    NSDictionary * _modularDict;

}

#pragma mark - 初始化构造方法  *** *** *** ***

- (instancetype) initWithDict:(NSDictionary *)dict {
    
    if (self = [super init]) {
        _dict = dict;
        
        // 初始化 加载scrollView 必要的数据
        [self initColumWithDict:dict];
        
    }
    return self;
}

#pragma mark - 懒加载
-(Inc_TipPointView *)tipPointView {
    if (!_tipPointView) {
        WEAK_SELF;
        _tipPointView = [[Inc_TipPointView alloc]initWithFrame:CGRectMake(0, NaviBarHeight, ScreenWidth, Vertical(150))];
        _tipPointView.btnBlock = ^{
            [wself sureBtnClick];
        };
    }
    return _tipPointView;
}

-(Inc_TerminalTipView *)terminalTipView {
    if (!_terminalTipView) {
        WEAK_SELF;
        _terminalTipView = [[Inc_TerminalTipView alloc]initWithFrame:CGRectMake(Horizontal(30), NaviBarHeight, ScreenWidth - 2 *Horizontal(30), Vertical(320))];
        _terminalTipView.center = self.view.center;
        _terminalTipView.btnBlock = ^(UIButton *btn) {
            [wself tipBtnClick:btn];
        };
    }
    return _terminalTipView;
}

- (Inc_CountdownTipsView *)countdownTipsView {
    
    if (!_countdownTipsView) {
        WEAK_SELF;
        CGRect rect = CGRectMake(Horizontal(30), NaviBarHeight, ScreenWidth - 2 *Horizontal(30), 200);
        _countdownTipsView = [[Inc_CountdownTipsView alloc]initWithFrame:rect
                                                                   title:@"操作提示"
                                                                 message:@"为了验证数据与实际资源的一致性，请对资源修改的端子部分进行拍照。"
                                                                    time:3];
        _countdownTipsView.heightBlock = ^(CGFloat height) {
            wself.countdownTipsView.frame = CGRectMake(Horizontal(30), NaviBarHeight, ScreenWidth - 2 *Horizontal(30), height);
            wself.countdownTipsView.center = wself.view.center;
            
        };
        _countdownTipsView.sureBlock = ^{
            [wself takePhoto];
        };
        _countdownTipsView.cancelBlock = ^{
            [wself tipHiddenCountdownTips:YES];
        };
    }
    return _countdownTipsView;
    
}

-(Inc_CardRemarksTipView*)remarksTipsView {
    if (!_remarksTipsView) {
        WEAK_SELF;
        CGRect rect = CGRectMake(Horizontal(30), NaviBarHeight, ScreenWidth - 2 *Horizontal(30), 200);
        _remarksTipsView = [[Inc_CardRemarksTipView alloc]initWithFrame:rect];

        _remarksTipsView.heightBlock = ^(CGFloat height) {
            wself.remarksTipsView.frame = CGRectMake(Horizontal(30), NaviBarHeight, ScreenWidth - 2 *Horizontal(30), height);
            wself.remarksTipsView.center = wself.view.center;
            
        };
        _remarksTipsView.btnBlock = ^(UIButton * _Nonnull btn) {
            if ([btn.titleLabel.text isEqualToString:@"保存"]) {
//                if ([wself.remarksTipsView.textView.text isEmpty]) {
//                    [YuanHUD HUDFullText:@"请填写备注信息"];
//                }else{
                    //接口调用
                    [wself modifiModularNotes];
//                }
            }else{
                [wself hiddenRemarkView];
            }
        };
        
    }
    
    return _remarksTipsView;
}



- (void)viewDidLoad {
    [super viewDidLoad];

    _photoVM = Yuan_PhotoCheckVM.shareInstance;
    _CF = Inc_KP_Config.sharedInstanced;
    _batchHoldArray = NSMutableArray.array;
    
    self.title = @"端子信息";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self TerminalChooseUI_Init];
    [self BatchHoldUI_Init];
    
    // 发起网络请求
    [self http_Port];
    
    // 切图通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notificationHandler:)
                                                 name: @"CropOK"
                                               object: nil];
    
//    [self naviBarSet];
    __typeof(self)weakSelf = self;
    weakSelf.moreBtnBlock = ^(UIButton * _Nonnull btn) {
        [self menuClick];
    };
    
    

    //zzc 2021-7-8 端子识别指引
    [self setWindowBgView];

  
    
    _windowBgView.hidden = YES;
    _tipPointView.hidden = YES;
   
    _terminalTipView.hidden = YES;
    _countdownTipsView.hidden = YES;
    _remarksTipsView.hidden = YES;
    
    
    //端子保存后改变状态使用
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(http_Port) name:@"OpticTermSuccessful" object:nil];

    
}



- (void) http_Port {
    
    [Yuan_ODF_HttpModel ODF_HttpDetail_Dict:_dict
                               successBlock:^(id  _Nonnull requestData) {
        NSLog(@"requestData:%@",requestData);
        
        NSDictionary * req = requestData;
        
        NSArray * data = req[@"modules"];   // 所有模块的数组
        
        [_dataSource removeAllObjects];
        
        for (NSDictionary * dict in data) {
            [_dataSource addObject:@{dict[@"position"]:dict}];
            
        }
        
        if (_dataSource.count == 0) {
            [[Yuan_HUD shareInstance] HUDFullText:@"未获取到模块数据"];
            return ;
        }
        
        if (!_scroll_Collect) {
            
            [self.view addSubview:self.scroll_Collect];
            [self layoutAllSubViews];
        }
        else {
            [self reload_ScrollCollection];
        }
    }];
}
























#pragma mark - ****** ****** ****** 不用看了 ****** ****** ****** -


#pragma mark - scrollViewDelegate  *** *** ***

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    
    if (scrollView == _scroll_Collect) {
        return;
    }
    
    for (UICollectionView * collection in _scroll_Collect.collectionArray) {
        
        // 当scrollView滑动时 , 把偏移量赋值给collection们 , 但只要x方向的 ,y方向的由tableview自己去控制 , 达到滑动一个collection 所有的collec都跟着动起来.
        
        // 所有才 scrollView == _scroll return , 保证只有collection自己动的时候 ,才会进入这个方法.
        [collection setContentOffset:scrollView.contentOffset];
    }
}



#pragma mark - UI Init *** *** ***

- (Yuan_ScrollCollectView *)scroll_Collect {
    
    if (!_scroll_Collect) {
        
        int line = [_moduleRowQuantity intValue];  // 行数
        int row = [_moduleColumnQuantity intValue]; //列数
        
        
        _scroll_Collect =
        [[Yuan_ScrollCollectView alloc] initWithLineCount:line
                                                 rowCount:row
                                                Important:_importRule
                                                Direction:_dire
                                               dataSource:_dataSource
                                                  PieDict:_dict
                                                       VC:self] ;
        
        _scroll_Collect.delegate = self;
        _scroll_Collect.scrollEnabled = YES;
        
        _scroll_Collect.backgroundColor = [UIColor whiteColor];
        _scroll_Collect.showsVerticalScrollIndicator = NO;
        _scroll_Collect.showsHorizontalScrollIndicator = NO;
        _scroll_Collect.bounces = NO;
        
        [self terminalChooseBlock];
        [self BatchHold_ChooseBlock];
        
        WEAK_SELF;
        _scroll_Collect.remarkBlock = ^(NSString * _Nonnull num, NSDictionary * _Nonnull dict) {
            NSLog(@"position::%@\ndict:::%@",num,dict);
            _modularDict = dict;
            [wself.remarksTipsView setNum:num];
//            wself.remarksTipsView.textView.text = dict[@"notes"];
            [wself showRemarkView];
            [wself lookModilarNotes];
        };
    }
    return _scroll_Collect;
}


#pragma mark - 屏幕适配

- (void)layoutAllSubViews {
    
    
    _scroll_TopConstraint = [_scroll_Collect YuanMyEdge:Top ToViewEdge:Bottom ToView:_photoTerminalChooseView inset:5];
    [_scroll_Collect autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [_scroll_Collect autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    [_scroll_Collect autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:Vertical(50)];
}


/// 初始化 加载scrollView 必要的数据
/// @param dict 来自端子盘的dict
- (void) initColumWithDict:(NSDictionary *) dict {
    
    // 初始化数据源
    _dataSource = [NSMutableArray array];
    
    // 获取模块行数
    _moduleRowQuantity = dict[@"moduleRowQuantity"];
    
    // 获取模块列数
    _moduleColumnQuantity = dict[@"moduleColumnQuantity"];
    
    
    /// 判断行优 还是 列优
    NSString * noRule = dict[@"noRule"];
    
    if ([noRule isEqualToString:@"1"]) {
        _importRule = Important_Line;  //行优
    }else if([noRule isEqualToString:@"2"]){
        _importRule = Important_row;   //列优
    } else{
        _importRule = Important_Line;  // 默认 行优
    }
    
    
    /// 判断方向
    NSString * noDire = dict[@"noDire"];
    
    if ([noDire isEqualToString:@"1"]) {
        //上左
        _dire = Direction_UpLeft;
    }else if ([noDire isEqualToString:@"2"]){
        //上右
        _dire = Direction_UpRight;
    }else if ([noDire isEqualToString:@"3"]){
        //下左
        _dire = Direction_DownLeft;
    }else if ([noDire isEqualToString:@"4"]){
        //下右
        _dire = Direction_DownRight;
    }else {
        // 默认 上左
        _dire = Direction_UpLeft;
    }
    
    
}



#pragma mark - 禁用右滑手势

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];

    self.navigationController.interactivePopGestureRecognizer.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];

    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
}


// 给该控制器添加协议 <UIGestureRecognizerDelegate>

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    
    return gestureRecognizer != self.navigationController.interactivePopGestureRecognizer;
}












#pragma mark - 2021年 新增图片识别技术 ---


- (void) naviBarSet {
    
    
    
    UIBarButtonItem * rili = [UIView getBarButtonItemWithImageName:@"icon_pplist_gongneng"
                                                               Sel:@selector(menuClick)
                                                                VC:self];
    
    self.navigationItem.rightBarButtonItems = @[rili];
    
}



// 端子识别入口
- (void) startImageCheck {
    
    // 当行数和列数都不为1时 , 证明端子盘的数据有问题 , 需要做端子识别错误提示
    
    int line = [_moduleRowQuantity intValue];  // 行数
    int row = [_moduleColumnQuantity intValue]; //列数
    
    if (line == 1 || row == 1) {
        
        // 端子识别
        Http.shareInstance.statisticEnum = HttpStatistic_ResourceAI;
//        [self  photoClick];
        
        _windowBgView.hidden = NO;
        _terminalTipView.hidden = NO;
        [_terminalTipView startTimer];
        
    }else{
        [UIAlert alertSmallTitle:@"该列框的数据不正确,无法进行识别"];
    }
}


// 调用拍照 入口
- (void) photoClick {
    
    __typeof(self)weakSelf = self;
    _photoConfig = [[Yuan_ImagePickerVC alloc] initWithVC:self];
    
    [_photoConfig openCarema_Success:^(UIImage * _Nonnull image) {
        [weakSelf gotoClips:image];
    }];
}


- (void) gotoClips:(UIImage *)image {
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                 (int64_t)(1 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(),  ^{
        
        Yuan_TailorImageVC * vc = [[Yuan_TailorImageVC alloc] initWithCropImage:image];

        self.definesPresentationContext = true;

        vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        vc.modalPresentationStyle = UIModalPresentationFullScreen;

        [self presentViewController:vc animated:NO completion:^{

        }];
        
    });
    
    
    
    
}


- (void)notificationHandler: (NSNotification *)notification {
    
    UIImage * newImg = notification.object;
    
    // 把刚才拍的 截取过的照片 保存下来
    _myImg = newImg;
    
    // 发送网络请求 识别图片信息
    [self http_PhotoToUnion:newImg];
}


//黑色透明背景
-(void)setWindowBgView {
    _windowBgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    _windowBgView.backgroundColor = [UIColor colorWithRed:30/255.0 green:30/255.0 blue:30/255.0 alpha:0.4];
    _windowBgView.userInteractionEnabled = YES;

    
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    [window addSubview:_windowBgView];
    
    
    [_windowBgView addSubview:self.tipPointView];
    [_windowBgView addSubview:self.terminalTipView];
    [_windowBgView addSubview:self.countdownTipsView];
    [_windowBgView addSubview:self.remarksTipsView];
    
}

//我知道了
- (void)sureBtnClick {
    
    //防止首次进入提示没有结束调用端子识别提示后，首次倒计时结束隐藏window，导致提示隐藏
    if (!_tipPointView.hidden) {
        _windowBgView.hidden = YES;
        _tipPointView.hidden  = YES;
    }
}

//btnClick
- (void)tipBtnClick:(UIButton *)btn{
    if (![btn.titleLabel.text isEqualToString:@"取消"]) {
        //去识别
        [self photoClick];
    }
    _windowBgView.hidden = YES;
    _terminalTipView.hidden  = YES;
}


//提示去拍照
- (void)takePhoto {
    
    LCImagePickerManager *imagePicker = [LCImagePickerManager imagePickerWithType: UIImagePickerControllerSourceTypeCamera didFinishPickImage:^(NSDictionary * _Nonnull dic, UIImage * _Nonnull image) {
        NSLog(@"%@",image);

        UIImage *resultImage = [self makeThumbnailFromImage:image scale:0.5];
        NSData *imageData = UIImageJPEGRepresentation(resultImage, 0.1f);

        resultImage = [UIImage imageWithData:imageData];

        _base64Img = [_CF imageToString:resultImage];
        
        [self tipHiddenCountdownTips:YES];

        [self handleImageData];
        
    } didCancelPickImage:^(UIImagePickerController * _Nonnull picker) {
        NSLog(@"2222222");
        [self tipHiddenCountdownTips:YES];
    }];
    [self.navigationController presentViewController:imagePicker animated:YES completion:^{
        NSLog(@"2222222");
        [self tipHiddenCountdownTips:NO];

    }];
    
    
}


- (UIImage *)makeThumbnailFromImage:(UIImage *)srcImage scale:(double)imageScale {
    UIImage *thumbnail = nil;
    CGSize imageSize = CGSizeMake(srcImage.size.width * imageScale, srcImage.size.height * imageScale);
    if (srcImage.size.width != imageSize.width || srcImage.size.height != imageSize.height)
    {
        UIGraphicsBeginImageContext(imageSize);
        CGRect imageRect = CGRectMake(0.0, 0.0, imageSize.width, imageSize.height);
        [srcImage drawInRect:imageRect];
        thumbnail = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    else
    {
        thumbnail = srcImage;
    }
    return thumbnail;
}

//显示
- (void)tipShowCountdownTips {
    
    _windowBgView.hidden = NO;
    _countdownTipsView.hidden = NO;
    [_countdownTipsView startTimer];
}

//跳过操作
- (void)tipHiddenCountdownTips:(BOOL)isReload {
    _windowBgView.hidden = YES;
    _countdownTipsView.hidden  = YES;
    
    //是否刷新端子盘
    if (isReload) {
        [self http_Port];
    }

}
//显示备注view
- (void)showRemarkView {
    _windowBgView.hidden = NO;
    _remarksTipsView.hidden = NO;
}
//隐藏备注view
-(void)hiddenRemarkView {
    _windowBgView.hidden = YES;
    _remarksTipsView.hidden = YES;
    _remarksTipsView.textView.text = @"";
    [_remarksTipsView.textView resignFirstResponder];

}

// 新端子识别配置

- (void) NewImageCheck_Config:(NSArray *)imageCheckArr
                        image:(UIImage *)image
                    base64Img:(NSString *)base64Img
                       matrix:(NSArray *)MATRIX {
    
    Inc_ImageCheckNewVC * vc = [[Inc_ImageCheckNewVC alloc] initWithImage:image Array:imageCheckArr];
    vc.btnsArray =  [_scroll_Collect getAllBtnS];
    vc.mb_Dict = _mb_Dict;
    vc.datas = _dataSource;
    vc.inLineNums = _scroll_Collect.getInlineNums;
    
    NSInteger line = [_moduleRowQuantity integerValue];  // 行数
    NSInteger row = [_moduleColumnQuantity integerValue]; //列数
    
    [vc configDatasArray:imageCheckArr imgBase64:base64Img matrix:MATRIX];
    
    vc.hangNum = line;
    vc.lieNum = row;
    
    vc.dire = _dire;
    vc.importRuler = _importRule;
    vc.pieDict = _dict;
    
    [vc configDatasArray:imageCheckArr imgBase64:base64Img matrix:MATRIX];
    
    vc.reloadWithPie = ^{
        [self http_Port];
    };
    
    
    Push(self, vc);
}



#pragma mark - ImagePicker Delegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    
    NSString * mediaType = info[UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:@"public.image"]) {
    
        [picker dismissViewControllerAnimated:YES completion:nil];
        
        BOOL isNeedCancelLocation = false;
//        if (INCLocationManager.locationManager.isLocationing == false){
//            isNeedCancelLocation = true;
//        }
        
        
        
        // 子线程做工作
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            UIImage * image = info[UIImagePickerControllerOriginalImage];
            
            
            // 完成后拿到主线程中刷新
            dispatch_async(dispatch_get_main_queue(), ^{
                // 图片压缩
                [self gotoClips:[self scaleImage:image toScale:0.3]];
            });
        });
        
    }
            
}


- (UIImage *)scaleImage:(UIImage * )image toScale:(float)scaleSize {
    
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scaleSize,image.size.height * scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height *scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}


- (void) http_PhotoToUnion:(UIImage *) image {
    
    [Yuan_ODF_HttpModel ODF_HttpImageToUnion:image
                                successBlock:^(id  _Nonnull requestData) {
        NSDictionary * result = requestData;
        
        NSNumber * code = result[@"code"];
        
        if (code.intValue != 200) {
            [[Yuan_HUD shareInstance] HUDFullText:@"请求失败"];
            return;
        }
        
        NSDictionary * data = result[@"data"];
        
//        if (![data[@"data"] isKindOfClass:NSDictionary.class]) {
//            [[Yuan_HUD shareInstance] HUDFullText:@"请求失败"];
//            return;
//        }
        
        id content = data[@"content"];
        
        if (![content isKindOfClass:NSDictionary.class]) {
            [[Yuan_HUD shareInstance] HUDFullText:@"请求失败"];
            return;
        }
        
        NSString * IMG_LABELED = content[@"IMG_LABELED"];
        
        if (!IMG_LABELED) {
            [[Yuan_HUD shareInstance] HUDFullText:@"图片识别失败"];
            return;
        }
        
//        NSArray * TXT_COORDINATED = content[@"TXT_COORDINATED"];
        NSArray * TXT_COORDINATED = content[@"TXT_COORDINATED_WITH_FIX"];
        NSArray * MATRIX = content[@"MATRIX"];
        
        
        if (!TXT_COORDINATED || TXT_COORDINATED.count == 0) {
            [[Yuan_HUD shareInstance] HUDFullText:@"图片识别失败"];
            return;
        }
        
        _photoCheckDataSource = TXT_COORDINATED ?: @[];
        _photoCheckMatrixArr = MATRIX ?: @[];
        _photoCheckBase64Img = IMG_LABELED ?: @"";
        
//        UIImage * getImage = [Yuan_ODFViewModel dataURL2Image:IMG_LABELED];
        
        
        // 过去的端子识别
//        [_scroll_Collect btns_Union_PhotoArray:TXT_COORDINATED
//                                         image:getImage
//                                     base64Img:_photoCheckBase64Img
//                                        matrix:_photoCheckMatrixArr];
         
        
        // 新端子识别
        [self NewImageCheck_Config:_photoCheckDataSource
                             image:image
                         base64Img:_photoCheckBase64Img
                            matrix:_photoCheckMatrixArr];
//        [self NewImageCheck_Config:_photoCheckDataSource
//                             image:getImage
//                         base64Img:_photoCheckBase64Img
//                            matrix:_photoCheckMatrixArr]；

    }];
    
}




#pragma mark - 图片识别回调

// 将回调的结果返回去
- (void) http_Reback {
    
    
    [Yuan_ODF_HttpModel ODF_HttpImageToUnionBatchHold_TxtCoordinated:_terminalImageCheck_Arr
                                                             base64Img:_base64Img
                                                                matrix:_matrix
                                                        matrixModified:_matrixModified
                                                          successBlock:^(id  _Nonnull requestData) {
        NSLog(@"已完成回调%@",requestData);
        

    }];
}


//处理 反馈需要数据 数据
- (void) handleImageData {
        
    _terminalImageCheck_Arr = NSMutableArray.array;
    _matrix = NSMutableArray.array;
    _matrixModified = NSMutableArray.array;

    //通过端子盘获取所以端子
    NSArray *termImageArray = [_scroll_Collect getAllBtnS];
    
    //模块端子数
    NSInteger lineNums = [_scroll_Collect getInlineNums];
    
    //创建端子数空串数组  后期进行替换使用  类似12个空串
    NSMutableArray *numArray = NSMutableArray.array;
    for (int i = 0 ; i<lineNums; i++) {
        [numArray addObject:@""];
    }

    //创建模块空串数组 类似 6 * 12 个空串
    for (int i = 0 ; i<_dataSource.count; i++) {
        
        [_matrix addObject:numArray];
        
    }
    
    
    //遍历所有端子拼接数据
    for (Yuan_terminalBtn *btn in termImageArray) {
      
        NSString *class = [self getTermClass:btn];

        NSDictionary *dic = @{
            @"class":class,
            @"desc":[self getTermState:btn],
            @"right":@0,
            @"left":@0,
            @"top":@0,
            @"bottom":@0
        };
        
        [_terminalImageCheck_Arr addObject:dic];
        
                
        NSInteger position = btn.position;
        NSInteger index = btn.index;
        
        //端子修改前数组
        for (int k = 0; k<_matrix.count; k++) {
            
            if (k == position - 1) {
                
                NSMutableArray *arr = [NSMutableArray arrayWithArray:_matrix[k]];
                for (int m = 0; m<arr.count; m++) {
                    if (m == index -1) {
                        [arr replaceObjectAtIndex:m withObject:class];
                        [_matrix replaceObjectAtIndex:k withObject:arr];
                    }
                }
            }
        }
    }
    //处理修改后端子数组
    [_matrixModified addObjectsFromArray:_matrix];
    
    for (Yuan_terminalBtn *termBtn in _batchHoldArray) {
        
        for (int n = 0; n<_matrixModified.count; n++) {
            
            if (termBtn.position == n + 1) {
                
                NSMutableArray *arr = [NSMutableArray arrayWithArray:_matrixModified[n]];
                
                for (int l = 0; l<arr.count; l++) {
                    if (l == termBtn.index -1) {
                        
                        NSString *str = @"u";
                        if ([_photoVM.selectOprState isEqualToString:@"■ 占用"]) {
                            str = @"p";
                        }
                        
                        [arr replaceObjectAtIndex:l withObject:str];
                        [_matrixModified replaceObjectAtIndex:n withObject:arr];
                    }
                }
                
            }
        }
        
    }
    
    [self http_Reback];
    
}

//端子状态遍历
- (NSString *)getTermState:(Yuan_terminalBtn *)item {
    
    NSInteger oprStateId = [item.dict[@"oprStateId"] integerValue];

    if (oprStateId == 3) {
        return @"占用";
    }else{
        return @"闲置";
    }
    
    return @"";
    
}

//端子状态遍历
- (NSString *)getTermClass:(Yuan_terminalBtn *)item {
    
    NSInteger oprStateId = [item.dict[@"oprStateId"] integerValue];

    if (oprStateId == 3) {
        return @"p";
    }else{
        return @"u";
    }
    
    return @"";
    
}

// MARK: 批量操作 端子列表

- (void) BatchHoldUI_Init {
    
    
    
    _batchHold_2021 = [[Yuan_BatchHoldView alloc] init];
    
    [_batchHold_2021 cornerRadius:10 borderWidth:1 borderColor:ColorValue_RGB(0xf2f2f2)];
    
    [self.view addSubview:_batchHold_2021];
    
    _batchHold_2021.hidden = YES;
    
    [_batchHold_2021 YuanToSuper_Left:5];
    [_batchHold_2021 YuanToSuper_Right:5];
    [_batchHold_2021 YuanToSuper_Top:NaviBarHeight + 5];
    _batchHoldConstraint = [_batchHold_2021 autoSetDimension:ALDimensionHeight
                                                      toSize:0];
    
    __typeof(self)weakSelf = self;
    
    _batchHold_2021.BatchHold_StateBlock = ^(BatchHold_ holdType) {
        
        switch (holdType) {
            case BatchHold_Cancel:  //取消
                
                [weakSelf BatchHold_Hide];
                break;
            
            case BatchHold_Enter:
                [weakSelf BatchHold_EnterClick];
                break;
            
            case BatchHold_Clear:
                [weakSelf BatchHold_ClearClick];
                break;
                
            default:
                break;
        }
        
    };
    
}



- (void) BatchHold_Show {
    
    _batchHold_2021.hidden = NO;
    _batchHoldConstraint.active = NO;
    _batchHoldConstraint = [_batchHold_2021 autoSetDimension:ALDimensionHeight
                                                      toSize:Vertical(batchHoldView_Height)];
    
    _scroll_TopConstraint.active = NO;
    _scroll_TopConstraint = [_scroll_Collect YuanMyEdge:Top ToViewEdge:Bottom ToView:_batchHold_2021 inset:5];
    
    [_scroll_Collect BatchHold_Start:YES];
}



- (void) BatchHold_Hide {
    
    _batchHold_2021.hidden = YES;
    _batchHoldConstraint.active = NO;
    _batchHoldConstraint = [_batchHold_2021 autoSetDimension:ALDimensionHeight toSize:0];
    
    
    _scroll_TopConstraint.active = NO;
    _scroll_TopConstraint = [_scroll_Collect YuanMyEdge:Top ToViewEdge:Bottom ToView:_batchHold_2021 inset:5];
    
    // 清空
    [_scroll_Collect clear_BatchHold];
    [_scroll_Collect BatchHold_Start:NO];
}


// 保存的点击事件
- (void) BatchHold_EnterClick {
    
    [UIAlert alertSmallTitle:@"是否保存" agreeBtnBlock:^(UIAlertAction *action) {
        [_scroll_Collect BatchHold_Save];
    }];
}

// 清空的点击事件
- (void) BatchHold_ClearClick {
    
    [UIAlert alertSmallTitle:@"是否清空" agreeBtnBlock:^(UIAlertAction *action) {
        [_scroll_Collect clear_BatchHold];
    }];
}


- (void) BatchHold_ChooseBlock {
    
    __typeof(self)weakSelf = self;
    
    // 保存成功后的回调
    weakSelf->_scroll_Collect.BatchHold_SaveBlock = ^(NSArray * _Nonnull batchHoldArray) {
        
        [_batchHoldArray addObjectsFromArray: batchHoldArray];
        [self tipShowCountdownTips];
    };
    
    
    
    // 点击保存按钮时的回调
    weakSelf->_scroll_Collect.BatchHold_SaveClick_TipsShow = ^{
        [self BatchHold_FiberTips];
    };
    
}


- (void) reload_ScrollCollection {
    
    int line = [_moduleRowQuantity intValue];  // 行数
    int row = [_moduleColumnQuantity intValue]; //列数
    
    [_scroll_Collect reloadLineCount:line
                            rowCount:row
                           Important:_importRule
                           Direction:_dire
                          dataSource:_dataSource
                             PieDict:_dict
                                  VC:self] ;
}



// 批量修改端子接口
- (void) BatchHold_FiberTips {

    __block Yuan_CountDownAlertView * CountDownAlertView =
    [[Yuan_CountDownAlertView alloc] initWithSecond:3
                                        headerTitle:@"提示"
                                          detailMsg:@"修改端子状态时 , 会同时修改纤芯状态"];
    
    
    
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    [window addSubview:CountDownAlertView];
    
    __weak Yuan_CountDownAlertView * CountDownAlertViewCopy = CountDownAlertView;
    
    CountDownAlertViewCopy.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    CountDownAlertViewCopy.CountDownAlertBlock = ^{
        
        [CountDownAlertView removeFromSuperview];
        CountDownAlertView = nil;
        
        // 调用保存接口
        [_scroll_Collect http_BatchHold_Save];
    };
}


#pragma mark - 分光器跳转业务 ---

- (void) OBD_Equt {
    
    
    Inc_NewMB_HttpPort * port = [Inc_NewMB_HttpPort ModelEnum:Yuan_NewMB_ModelEnum_obd];
    
    NSString * eqpId_Type = _dict[@"eqpId_Type"] ?: @"";
    
    switch (eqpId_Type.intValue) {
        
        case 1: //odf
            eqpId_Type = @"302";
            break;
        
        case 2: //光交接
            eqpId_Type = @"703";
            break;
        
        case 3: //odb 分纤箱
            eqpId_Type = @"704";
            break;
            
        case 4: //box 综合箱
            eqpId_Type = @"205";
            break;
            
        default:
            break;
    }
    
    NSDictionary * selectParam = @{
        
        @"pageSize" : @"-1",
        @"pageNum" : @"-1",
        @"positId" : _dict[@"eqpId_Id"] ?: @"",
        @"positTypeId" : eqpId_Type
    };
    
    
    [Yuan_ODF_HttpModel http_findOptResList:selectParam successBlock:^(id  _Nonnull requestData) {
        
        NSArray * resultArr = requestData[@"content"];
        
        if (resultArr.count == 0) {
            
            [YuanHUD HUDFullText:@"该设备下无所属分光器"];
            return;
        }
        else {
            [self OBD_Equt_JumpWithArr:resultArr];
        }
        
    }];
    
    
//    [Inc_NewMB_HttpModel HTTP_NewMB_SelectWithURL:port.Select
//                                              Dict:selectParam
//                                           success:^(id  _Nonnull result) {
//
//        NSArray * resultArr = result;
//
//        if (resultArr.count == 0) {
//
//            [YuanHUD HUDFullText:@"该设备下无所属分光器"];
//            return;
//        }
//        else {
//            [self OBD_Equt_JumpWithArr:resultArr];
//        }
//
//    }];
    
}

//查看模块备注信息
-(void)lookModilarNotes {
    
    Inc_NewMB_HttpPort * port = [Inc_NewMB_HttpPort ModelEnum:Yuan_NewMB_ModelEnum_obd];

    NSDictionary * postDict = @{
        @"id" : _modularDict[@"moduleId"]?:@"",
        @"type" : @"module"
    };
    
    [Inc_NewMB_HttpModel HTTP_NewMB_SelectDetailsFromIdWithURL:port.SelectFrom_IdType
                                                           Dict:postDict
                                                        success:^(id  _Nonnull result) {
        
        if (result) {
            
            NSArray * resultArr = result;
            NSDictionary * dic = resultArr.firstObject;

            self.remarksTipsView.textView.text = dic[@"notes"]?:@"";
        }
       
        
        
    }];
}

//修改模块备注
-(void)modifiModularNotes {
    
    Inc_NewMB_HttpPort * port = [Inc_NewMB_HttpPort ModelEnum:Yuan_NewMB_ModelEnum_obd];

   
    NSDictionary *dic = @{
        @"gid":_modularDict[@"moduleId"]?:@"",
        @"notes":_remarksTipsView.textView.text?:@""
    };
    
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    
    
    postDict[@"resType"] = @"module";
    postDict[@"datas"] = @[dic]; //必须要过滤一些不传的字段
    
    
    
    
    [Inc_NewMB_HttpModel HTTP_NewMB_ModifiWithURL:port.Modifi
                                             Dict:postDict
                                          success:^(id  _Nonnull result) {
        
        if (result) {
            [self hiddenRemarkView];
        }
        
        
    }];
    
}



- (void) OBD_Equt_JumpWithArr:(NSArray *) datas {
    
    Yuan_OBD_Points_DeviceListVC * vc = [[Yuan_OBD_Points_DeviceListVC alloc] init];
    
    self.definesPresentationContext = true;
    
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    
    [self presentViewController:vc animated:NO completion:^{
        
        // 只让 view半透明 , 但其上方的其他view不受影响
        vc.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    }];
    
    [vc reloadData:datas];
    
    
    vc.choose_OBD = ^(NSDictionary * _Nonnull dict) {
      
        if (dict.count != 0) {
         
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                         (int64_t)(1 * NSEC_PER_SEC)),
                           dispatch_get_main_queue(),  ^{
                
                [self chooseOBD_Dict:dict];
            });
        }
    };
}



- (void) chooseOBD_Dict:(NSDictionary *) obd_Dict {
    
    
    NSString * obd_id = obd_Dict[@"resId"];
    
    
    NSString * eqpId_Id = _dict[@"eqpId_Id"];
    
    NSString * eqpId_Type = _dict[@"eqpId_Type"] ?: @"";
    
    switch (eqpId_Type.intValue) {
        
        case 1: //odf
            eqpId_Type = @"302";
            break;
        
        case 2: //光交接
            eqpId_Type = @"703";
            break;
        
        case 3: //odb 分纤箱
            eqpId_Type = @"704";
            break;
            
        case 4: //box 综合箱
            eqpId_Type = @"205";
            break;
            
        default:
            break;
    }
    
    
    
    
    Yuan_OBD_PointsConfigVC * obd_Config =
    [[Yuan_OBD_PointsConfigVC alloc] initWith_OBD_Id:obd_id
                                            deviceId:eqpId_Id
                                          deviceType:eqpId_Type
                                          deviceDict:_mb_Dict];
    
    Push(self, obd_Config);
}



// MARK: 选择端子


- (void) TerminalChooseUI_Init {
    
    __typeof(self)weakSelf = self;
    
    _photoTerminalChooseView = [[Yuan_UnionPhotoTerminalChooseView alloc] init];
    [self.view addSubview:_photoTerminalChooseView];
    
    _photoTerminalChooseView.hidden = YES;
    
    [_photoTerminalChooseView YuanToSuper_Left:0];
    [_photoTerminalChooseView YuanToSuper_Right:0];
    [_photoTerminalChooseView YuanToSuper_Top:NaviBarHeight];
    _photoTerminalConstraint = [_photoTerminalChooseView autoSetDimension:ALDimensionHeight
                                                                   toSize:0];
    
    
    
    // 当成功选择完两个点之后 , 再去执行操作
    _photoTerminalChooseView.enterClickBlock = ^{
        [weakSelf terminalChooseEnterClick];
    };
    
}


- (void) terminalChooseEnterClick  {
    
    // 结束端子校验
    [self TerminalChooseUI_hide];
    
    // 重新为所有端子赋值
    [_scroll_Collect PhotoCheckEnd:@[]];
}




- (void) TerminalChooseUI_Show {
    
    _photoTerminalChooseView.hidden = NO;
    _photoTerminalConstraint.active = NO;
    _photoTerminalConstraint = [_photoTerminalChooseView autoSetDimension:ALDimensionHeight
                                                                   toSize:Vertical(terminalChooseView_Height)];
    
    _scroll_TopConstraint.active = NO;
    _scroll_TopConstraint = [_scroll_Collect YuanMyEdge:Top ToViewEdge:Bottom ToView:_photoTerminalChooseView inset:5];
}


- (void) TerminalChooseUI_hide {
    
    // 端子校验过程结束
    _photoVM.isChooseTerminalMode = NO;
    
    _photoTerminalChooseView.hidden = YES;
    _photoTerminalConstraint.active = NO;
    _photoTerminalConstraint =  [_photoTerminalChooseView autoSetDimension:ALDimensionHeight toSize:0];
    
    
    _scroll_TopConstraint.active = NO;
    _scroll_TopConstraint = [_scroll_Collect YuanMyEdge:Top ToViewEdge:Bottom ToView:_photoTerminalChooseView inset:5];
    
}


#pragma mark - TerminalChooseBlock ---

- (void) terminalChooseBlock {
    
    __typeof(self)weakSelf = self;
    
    // 当点击了核查按钮后
    _scroll_Collect.reConfigClickBlock = ^(NSDictionary * _Nonnull dict) {
//        [weakSelf pushToImageCheckChooseVC:dict];
    };
    
    
    // 当 配置 1,2端子状态下 , 点击端子的回调
    _scroll_Collect.terminalBtnClick_Block = ^(NSInteger index, NSInteger position) {
        [weakSelf terminalIndex:index position:position];
    };
    
}






/// 当配置 1,2 端子模式下 , 选择
/// @param index 第几个
/// @param position 绑卡数
- (void) terminalIndex:(NSInteger)index position:(NSInteger)position {
    
    [_photoTerminalChooseView reloadDataWithIndex:index position:position];

}

    
- (void)dealloc {
    
    _photoVM.isChooseTerminalMode = NO;
    
}
    


#pragma mark - 端子对调 入口 ---
- (void) Terminal_ExchangeMode {
    
    

    
    BusAllColumnType_ type = BusAllColumnType_OCC;
    
    NSString * resLogicName = _mb_Dict[@"resLogicName"];
    
    if ([resLogicName isEqualToString:@"ODF_Equt"]) {
        type = BusAllColumnType_ODF;
    }
    
    if ([resLogicName isEqualToString:@"ODB_Equt"]) {
        type = BusAllColumnType_ODB;
    }
    
    
    Inc_TE_ChooseVC * TE = [[Inc_TE_ChooseVC alloc] initWithDeviceId:_mb_Dict[@"GID"] deviceType:type];

    
    Push(self, TE);
}

    
#pragma mark - 下拉 ---

// 下拉菜单
-(MLMenuView *)menu {
    
    if (_menu == nil) {
        
        NSArray * menuItems;
        
        if ([_dict[@"eqpId_Type"] isEqualToString:@"4"]) {
            menuItems = @[@"端子识别",
                          @"批量修改",
                          @"分光器"
            ];
        }else{
            menuItems = @[@"端子识别",
                          @"批量修改",
                          @"分光器",
                          @"端子跳纤",
                          @"端子对调"
            ];
        }
        
        
        float menuWidth = IphoneSize_Width(120);
        
        CGRect menuRect =  CGRectMake(ScreenWidth - menuWidth - 10,
                                      0,
                                      menuWidth,
                                      0);
        
        MLMenuView * menuView =
        [[MLMenuView alloc] initWithFrame:menuRect
                               WithTitles:menuItems
                           WithImageNames:nil
                    WithMenuViewOffsetTop:NaviBarHeight
                   WithTriangleOffsetLeft:menuWidth
                            triangleColor:UIColor.whiteColor];
        
        
        _menu = menuView;
        
        menuView.separatorOffSet = 0;
        menuView.separatorColor = [UIColor colorWithHexString:@"#eee"];
        [menuView brightColor:UIColor.lightGrayColor radius:10 offset:CGSizeMake(2, 2) opacity:1.f];
        [menuView setMenuViewBackgroundColor:[UIColor whiteColor]];
        menuView.titleColor = [UIColor colorWithHexString:@"#333"];
        menuView.font = [UIFont systemFontOfSize:12];
        
        [menuView setCoverViewBackgroundColor:UIColor.clearColor];
        menuView.delegate = self;
    }
    
    return _menu;
    
}



- (void) menuClick {
    
    [self.menu showMenuEnterAnimation:MLAnimationStyleTop];
}


- (void)menuView:(MLMenuView *)menu didselectItemIndex:(NSInteger)index {
    
    
    switch (index) {
        
            // 端子识别
        case 0:
            [self startImageCheck];
            break;
        
            // 批量修改
        case 1:
            [self BatchHold_Show];
            break;
            
            // 分光器
        case 2:
            [self OBD_Equt];
            break;
            
            //端子跳纤
        case 3:
            [self termJump];
            break;
            
            //端子对调
        case 4:
            [self Terminal_ExchangeMode];
            break;
            
        default:
            break;
    }
    
    
    
    
    
}
    


#pragma mark - 端子跳纤

- (void)termJump {
    
    if ([_dict[@"eqpId_Type"] isEqualToString:@"1"] || [_dict[@"eqpId_Type"] isEqualToString:@"4"]) {
        if ([_mb_Dict[@"posit_Type"] isEmptyString] || [_mb_Dict[@"posit_Type"] isEqualToString:@"0"]) {
            [YuanHUD HUDFullText:@"无安置地点类型不可查看跳纤"];
            return ;
        }
    }
    
    //通过posit_Type区别放置点和机房
    if ([_mb_Dict[@"posit_Type"] isEqualToString:@"2"] || [_mb_Dict[@"positTypeId"] isEqualToString:@"2080004"]) {
        [YuanHUD HUDFullText:@"安置地点类型为放置点不可查看跳纤"];
        return ;
    }
    Inc_TermJumpingVC *vc = [[Inc_TermJumpingVC alloc]init];
    vc.type = _dict[@"eqpId_Type"] ?: @"";
    vc.deviceId = _dict[@"eqpId_Id"];
    vc.mb_Dict = _mb_Dict;
    vc.dict = _dict;

    Push(self, vc);
    
}


@end
