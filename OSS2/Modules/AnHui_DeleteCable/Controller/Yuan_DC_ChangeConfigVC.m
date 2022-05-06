//
//  Yuan_DC_ChangeConfigVC.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/1/18.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_DC_ChangeConfigVC.h"
#import "Yuan_DC_ChangeConfigView.h"

#import "Yuan_DC_VM.h"

@interface Yuan_DC_ChangeConfigVC ()

/** 手动 */
@property (nonatomic , strong) Yuan_DC_ChangeConfigView * handle;

/** 自动 */
@property (nonatomic , strong) Yuan_DC_ChangeConfigView * autoo;

/** 背景 */
@property (nonatomic , strong) UIView * backView;


/** 关闭 */
@property (nonatomic , strong) UIButton * cancelBtn;


@end

@implementation Yuan_DC_ChangeConfigVC


{
    
    Yuan_DC_VM * _VM;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _VM = Yuan_DC_VM.shareInstance;
    
    [self UI_init];
}


- (void) UI_init {
    
    _handle = [[Yuan_DC_ChangeConfigView alloc] initWithTitle:@"手动配置"];
    _autoo = [[Yuan_DC_ChangeConfigView alloc] initWithTitle:@"自动配置"];
    
    _cancelBtn = [UIView buttonWithImage:@"DC_guanbi"
                               responder:self
                               SEL_Click:@selector(cancelClick)
                                   frame:CGRectNull];
    
    _handle.vc = self;
    _autoo.vc = self;
    
    if (_VM.isAutoConfigTube) {
        [_autoo mySelect:YES];
        [_handle mySelect:NO];
    }
    else {
        [_autoo mySelect:NO];
        [_handle mySelect:YES];
    }
        
    
    
    _backView = [UIView viewWithColor:UIColor.whiteColor];
    
    [self.view addSubview:_backView];
    
    [_backView addSubviews:@[_handle,_autoo,_cancelBtn]];
    
    [self yuan_LayoutSubViews];
}


- (void) yuan_LayoutSubViews {
    
    
    float limit = Horizontal(10);
    
    [_backView autoSetDimensionsToSize:CGSizeMake(Horizontal(250), Vertical(180))];
    
    [_backView YuanAttributeHorizontalToView:self.view];
    [_backView YuanAttributeVerticalToView:self.view];
    
    [_handle autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:limit];
    [_handle autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [_handle autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    [_handle autoSetDimension:ALDimensionHeight toSize:Vertical(80)];
    
    [_autoo autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:limit];
    [_autoo autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [_autoo autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    [_autoo autoSetDimension:ALDimensionHeight toSize:Vertical(80)];
    
    [_cancelBtn YuanToSuper_Top:limit];
    [_cancelBtn YuanToSuper_Right:limit];
    
}

- (void) cancelClick {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
