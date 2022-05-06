//
//  Inc_TE_ChooseVC.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/8/17.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_TE_ChooseVC.h"
#import "Inc_TE_ExchangeVC.h"

// *****
#import "Inc_TE_ChooseTopView.h"
#import "Inc_DeviceTitleView.h"     // 正反面切换


// *****
#import "Inc_TE_HttpModel.h"
#import "Inc_TE_ViewModel.h"

@interface Inc_TE_ChooseVC ()

/** 选择A B 端子 */
@property (nonatomic , strong) Inc_TE_ChooseTopView * topView;

/** 全部端子盘View */
@property (nonatomic , strong) Inc_BusAllColumnView * allColumnView;

@end

@implementation Inc_TE_ChooseVC

{
    NSString * _device_GID;
    BusAllColumnType_ _deviceType;
    
    Inc_TE_ViewModel * _VM;
    
    UIButton * _enterBtn;
    UIButton * _cancelBtn;
    
    
}


#pragma mark - 初始化构造方法

- (instancetype)initWithDeviceId:(NSString *)GID deviceType:(BusAllColumnType_) type{
    
    if (self = [super init]) {
        
        _deviceType = type;
        _device_GID = GID;
        _VM = Inc_TE_ViewModel.shareInstance;
        
        [_VM destroy];
    }
    return self;
}


- (void)viewDidLoad {
    
    [super viewDidLoad];

    [self UI_Init];
    [self block_Init];
    
    [self naviBarSet];
}


#pragma mark - btnClick ---

- (void) enterClick {
    
    if (!_VM.Terminal_A_Dict || !_VM.Terminal_B_Dict) {
        [YuanHUD HUDFullText:@"请选择完 A B 端子后, 在进行端子对调"];
        return;
    }
    
    
    NSString * msg = @"是否确认, AB端子进行端子对调?";
    
    
    NSString * oprStateId_A = _VM.Terminal_A_Dict[@"oprStateId"];
    NSString * oprStateId_B = _VM.Terminal_B_Dict[@"oprStateId"];
    
    if ((oprStateId_A.intValue == 1 && oprStateId_B.intValue == 3) ||
        (oprStateId_A.intValue == 3 && oprStateId_B.intValue == 1) ) {
        
        msg = @"是否确认, AB端子进行端子对调?";
    }
    else {
        msg = @"对调的两个端子状态应为空闲和占用，当前选择的端子不符合此状态，是否强制对调?";
    }
    
    
    
    [UIAlert alertSmallTitle:msg agreeBtnBlock:^(UIAlertAction *action) {
       
        Inc_TE_ExchangeVC * exchangeVC = [[Inc_TE_ExchangeVC alloc] init];
        Push(self, exchangeVC);
        
        // 对调成功 刷新界面
        exchangeVC.TE_SuccessBlock = ^{
            
            [self TE_Success];
        };
        
    }];
}


- (void) cancelClick {

    [UIAlert alertSmallTitle:@"是否退出端子对调?" agreeBtnBlock:^(UIAlertAction *action) {
        Pop(self);
    }];
}


- (void) block_Init {
    
    __typeof(self)weakSelf = self;
    
    weakSelf->_allColumnView.yuan_BusDeviceSelectItemBlock =
    ^(NSArray<Inc_BusScrollItem *> * _Nonnull btnsArr,
      Inc_BusScrollItem * _Nonnull item,
      Inc_BusDeviceView * _Nonnull busView) {
        

        [_topView reloadWithDict:item.dict];
    };


}


- (void) TE_Success {

    [_VM destroy];

    
    [_topView clear];
    [_allColumnView reloadAllDatas];
}


#pragma mark - UI_Init

- (void) UI_Init {
    
    
    _topView = [[Inc_TE_ChooseTopView alloc] initWithEnum:TE_ChooseTop_HalfScreen];
    
    _enterBtn = [UIView buttonWithTitle:@"确定"
                              responder:self
                                    SEL:@selector(enterClick)
                                  frame:CGRectNull];
    
    [_enterBtn cornerRadius:5 borderWidth:0 borderColor:nil];
    _enterBtn.backgroundColor = UIColor.mainColor;
    [_enterBtn setTitleColor:UIColor.whiteColor forState:0];
    
    CGRect allColunmFrame = CGRectMake(0, NaviBarHeight + Vertical(70), ScreenWidth, ScreenHeight - NaviBarHeight - Vertical(70));
    
    _allColumnView = [[Inc_BusAllColumnView alloc] initWithFrame:allColunmFrame
                                                          isPush:NO
                                                        deviceId:_device_GID
                                                         busType:_deviceType
                                                  busDevice_Enum:Yuan_BusDeviceEnum_Normal
                                                    busHttp_Enum:Yuan_BusHttpPortEnum_New
                                                              vc:self];
    
    
    [self.view addSubviews:@[_topView , _enterBtn , _allColumnView]];
    [self yuan_LayoutSubViews];
}


- (void) yuan_LayoutSubViews {
    
    
    [_topView YuanToSuper_Left:0];
    [_topView YuanToSuper_Top:NaviBarHeight];
    
    [_topView Yuan_EdgeWidth:ScreenWidth / 4 * 3];
    [_topView Yuan_EdgeHeight:Vertical(50)];
    
    [_enterBtn YuanAttributeHorizontalToView:_topView];
    [_enterBtn YuanToSuper_Right:Horizontal(15)];
    
    [_enterBtn YuanMyEdge:Left
               ToViewEdge:Right
                   ToView:_topView
                    inset:Horizontal(15)];
}


- (void) naviBarSet {
    
    Inc_DeviceTitleView * titleView = [[Inc_DeviceTitleView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth/3 * 2, Vertical(35))];
    
    
    titleView.btnClickBlock = ^(BOOL isJust) {
        
        _allColumnView.isShowJust = isJust;
    };
    
    self.navigationItem.titleView = titleView;
    
}



@end
