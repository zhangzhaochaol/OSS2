//
//  Yuan_OBD_Points_ConnectTipsVC.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/4/20.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_OBD_Points_ConnectTipsVC.h"
#import "Yuan_BlockLabelView.h"

@interface Yuan_OBD_Points_ConnectTipsVC ()

@end

@implementation Yuan_OBD_Points_ConnectTipsVC

{
    
    Yuan_BlockLabelView * _blockView;
    
    UIButton * _cancelBtn;
    
    UILabel * _handsConnect;
    UIButton * _handsConnectBtn;
    
    UILabel * _autoConnect;
    UIButton * _autoConnectBtn;
    
    UIView * _backView;
}



#pragma mark - 初始化构造方法

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self UI_Init];

}

#pragma mark - Click ---


// 取消
- (void) cancelClick {
    
    [self dismissViewControllerAnimated:YES completion:^{
       
        if (_pointTipsBlock) {
            _pointTipsBlock(Yuan_OBD_PointTips_None);
        }
    }];
}


// 手动关联
- (void) handClick {
    
    [UIAlert alertSmallTitle:@"是否选择手动关联?"
                          vc:self
               agreeBtnBlock:^(UIAlertAction *action) {
            
        [self dismissViewControllerAnimated:YES completion:^{
           
            if (_pointTipsBlock) {
                _pointTipsBlock(Yuan_OBD_PointTips_Handle);
            }
        }];
        
    }];
    
    
}


// 自动关联
- (void) autoClick {
    
    [UIAlert alertSmallTitle:@"是否选择自动关联?"
                          vc:self
               agreeBtnBlock:^(UIAlertAction *action) {
            
        [self dismissViewControllerAnimated:YES completion:^{
           
            if (_pointTipsBlock) {
                _pointTipsBlock(Yuan_OBD_PointTips_Auto);
            }
        }];
        
    }];
}


#pragma mark - UI ---


- (void) UI_Init {
    
    _backView = [UIView viewWithColor:UIColor.whiteColor];
    
    _blockView = [[Yuan_BlockLabelView alloc] initWithBlockColor:UIColor.mainColor
                                                           title:@"请选择关联模式"];
    
    _cancelBtn = [UIView buttonWithImage:@"DC_guanbi"
                               responder:self
                               SEL_Click:@selector(cancelClick)
                                   frame:CGRectNull];
    
    
    _handsConnect = [UIView labelWithTitle:@"手动：将两个选择的端子进行关联，只生产一条关联关系" frame:CGRectNull];
    
    _autoConnect = [UIView labelWithTitle:@"自动：以选择的两个端子为起始往后开始进行依次关联，直到分光器或设备的端子全部关联完成。\n新增设备推荐使用此功能。" frame:CGRectNull];
    
    _handsConnect.userInteractionEnabled = YES;
    _autoConnect.userInteractionEnabled = YES;
    
    _handsConnectBtn = [UIView buttonWithTitle:@"手动关联"
                                     responder:self
                                           SEL:@selector(handClick)
                                         frame:CGRectNull];
    
    
    _autoConnectBtn = [UIView buttonWithTitle:@"自动关联"
                                    responder:self
                                          SEL:@selector(autoClick)
                                        frame:CGRectNull];
    
    [self.view addSubview:_backView];
    
    [_backView addSubviews:@[_blockView,
                             _cancelBtn,
                             _handsConnect,
                             _autoConnect]];
    
    [_handsConnect addSubview:_handsConnectBtn];
    [_autoConnect addSubview:_autoConnectBtn];
    
    
    _handsConnect.backgroundColor = ColorValue_RGB(0xe2e2e2);
    _autoConnect.backgroundColor = ColorValue_RGB(0xe2e2e2);
    
    _handsConnect.textColor = UIColor.darkGrayColor;
    _autoConnect.textColor = UIColor.darkGrayColor;
    
    [_handsConnectBtn cornerRadius:5 borderWidth:0 borderColor:nil];
    [_autoConnectBtn cornerRadius:5 borderWidth:0 borderColor:nil];
    
    _handsConnectBtn.backgroundColor = UIColor.mainColor;
    _autoConnectBtn.backgroundColor = UIColor.mainColor;
    
    [_handsConnectBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [_autoConnectBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    
    
    [self yuan_LayoutSubViews];
}


- (void) yuan_LayoutSubViews {
    
    float limit = Horizontal(15);
    
    [_backView YuanAttributeHorizontalToView:self.view];
    [_backView YuanAttributeVerticalToView:self.view];
    [_backView autoSetDimension:ALDimensionWidth toSize:ScreenWidth / 5 * 4];
    [_backView autoSetDimension:ALDimensionHeight toSize:Vertical(350)];
    
    
    [_blockView YuanToSuper_Left:limit];
    [_blockView YuanToSuper_Top:limit];
    [_blockView autoSetDimension:ALDimensionHeight toSize:Vertical(40)];
    
    [_cancelBtn YuanAttributeHorizontalToView:_blockView];
    [_cancelBtn YuanToSuper_Right:limit];
    
    
    [_handsConnect YuanMyEdge:Top ToViewEdge:Bottom ToView:_blockView inset:limit];
    [_handsConnect YuanToSuper_Left:limit];
    [_handsConnect YuanToSuper_Right:limit];
    [_handsConnect autoSetDimension:ALDimensionHeight toSize:Vertical(100)];
    
    
    [_handsConnectBtn YuanToSuper_Right:limit/2];
    [_handsConnectBtn YuanToSuper_Bottom:limit/2];
    [_handsConnectBtn autoSetDimensionsToSize:CGSizeMake(Horizontal(75), Vertical(25))];
    
    
    
    [_autoConnect YuanMyEdge:Top ToViewEdge:Bottom ToView:_handsConnect inset:limit];
    [_autoConnect YuanToSuper_Left:limit];
    [_autoConnect YuanToSuper_Right:limit];
    [_autoConnect YuanToSuper_Bottom:limit];
    
    [_autoConnectBtn YuanToSuper_Right:limit/2];
    [_autoConnectBtn YuanToSuper_Bottom:limit/2];
    [_autoConnectBtn autoSetDimensionsToSize:CGSizeMake(Horizontal(75), Vertical(25))];
    
    
}

@end
