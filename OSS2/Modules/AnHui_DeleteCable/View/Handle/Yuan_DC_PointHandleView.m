//
//  Yuan_DC_PointHandleView.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/1/12.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_DC_PointHandleView.h"




static NSString * pointName = @"resName";
static NSString * pointAddr = @"regionName";
static NSString * pointType = @"resType";


@implementation Yuan_DC_PointHandleView


{
    UIButton * _cancelBtn;      //关闭按钮
    
    UILabel * _resType;  //资源图标
    
    UILabel * _resName;         //资源名称
    
    UILabel * _resAddress;      //资源地址
    
    UIView * _line;             //分割线
    
    UIButton * _getRoute;       //获取附近线路按钮
    UIButton * _getSubRoute;    //获取附近非本线路的资源按钮
    
    
    UIButton * _deleteCable;    //撤缆按钮
 
    UIButton * _connectStartEndDeviceBtn;    //关联起始设备按钮

    void (^_handleBlocks) (DC_PointHandle_ handleType);
    
    NSLayoutConstraint * _getRouteConstraint;       //获取线路
    NSLayoutConstraint * _getSubRouteConstraint;    //获取下属线路
    NSLayoutConstraint * _deleteCableConstraint;    //撤缆
    
    
 
}



#pragma mark - 初始化构造方法

- (instancetype)initWithBtnHandlesBlock:(void(^)(DC_PointHandle_ handleType))handleBlock {
    
    if (self = [super init]) {
        _handleBlocks = handleBlock;

        [self UI_Init];
    }
    return self;
}


#pragma mark - method ---

- (void) btnsHide {
    
    _line.hidden = YES;
    _getRoute.hidden = YES;
    _getSubRoute.hidden = YES;
    _deleteCable.hidden = YES;
    _connectStartEndDeviceBtn.hidden = YES;
    
}


  

- (void) reloadHandleDict:(NSDictionary *)dict dcType:(DC_AnnoPointType_)dcType{
    
    _myDict = dict;
    
    _resName.text = dict[pointName] ?: @"";
    _resAddress.text = dict[pointAddr] ?: @"";
    _resType.text = [NSString stringWithFormat:@"[%@]",dict[@"resTypeName"]] ?: @"";
    
    // 散点资源点
    if (dcType == DC_AnnoPointType_circleRadiusPoint) {
        
        float limit = Horizontal(15);
        float btnWidth = (ScreenWidth - (limit * 3)) / 2 ;
        
        _getRouteConstraint.active = NO;
        _getRouteConstraint = [_getRoute autoSetDimension:ALDimensionWidth toSize:btnWidth];
        
        _getSubRouteConstraint.active = NO;
        _getSubRouteConstraint = [_getSubRoute autoSetDimension:ALDimensionWidth toSize:btnWidth + limit];
        
        
        
        
        // 隐藏其他三种按钮
        _deleteCable.hidden = YES;
        _connectStartEndDeviceBtn.hidden = YES;
        
    }
    
    
    // 起始终止设备
    if (dcType == DC_AnnoPointType_StartEndPoint) {
        
        float limit = Horizontal(15);
        
        _deleteCableConstraint.active = NO;
        [_deleteCable YuanToSuper_Left:limit];
        
        // 隐藏其他四种按钮
        _getRoute.hidden = YES;
        _getSubRoute.hidden = YES;
        _connectStartEndDeviceBtn.hidden = YES;
        
        
        _resName.text = dict[@"name"] ?: @"";
        _resType.text = [NSString stringWithFormat:@"[%@]",dict[@"type"]] ?: @"";
    }
    
}




#pragma mark - 点击事件 ---

// 获取线路
- (void) getRouteClick {
    
    if (!_handleBlocks) return;
    
    [UIAlert alertSmallTitle:@"是否获取该资源点的关联线路"
               agreeBtnBlock:^(UIAlertAction *action) {
        _handleBlocks(DC_PointHandle_GetRoute);
    }];
    
}


// 获取其他线路按钮
- (void) getAnotherLinesSourceClick {
    
    if (!_handleBlocks) return;
    
    [UIAlert alertSmallTitle:@"是否获取该资源点的其他线路"
               agreeBtnBlock:^(UIAlertAction *action) {
        _handleBlocks(DC_PointHandle_GetAnotherLines);
    }];
    
}


// 撤缆
- (void) deleteCableClick {
    
    if (!_handleBlocks) return;
    
    _handleBlocks(DC_PointHandle_DeleteCable);
    /*
    if ([INCUserInfomation sharedInformation].isFirstDelete) {
        [self alertSmallTitleWithButton:@"⚠️撤缆后无法恢复，请确定进行操作" btnTitle:@"本次操作不再提示" agreeBtnBlock:^(UIAlertAction *action) {
            _handleBlocks(DC_PointHandle_DeleteCable);
        }];
    }else{
        _handleBlocks(DC_PointHandle_DeleteCable);
    }
     */
    
}


// 关闭
- (void) cancelClick {
    
    if (!_handleBlocks) return;
    _handleBlocks(DC_PointHandle_Cancel);
}



// 关联起始终止设备
- (void) connectSEDeviceClick {
    
    if (!_handleBlocks) return;
    _handleBlocks(DC_PointHandle_ConnectDevice);
}





#pragma mark - UI ---

- (void) UI_Init {
    
    self.backgroundColor = UIColor.whiteColor;
    
    _cancelBtn = [UIView buttonWithImage:@"DC_guanbi"
                               responder:self
                               SEL_Click:@selector(cancelClick)
                                   frame:CGRectNull];
    
    _resType = [UIView labelWithTitle:@"[资源类型]" frame:CGRectNull];
    
    _resName = [UIView labelWithTitle:@"资源名称" frame:CGRectNull];
    _resName.font = Font_Bold_Yuan(16);
    _resName.numberOfLines = 0;//根据最大行数需求来设置
    _resName.lineBreakMode = NSLineBreakByTruncatingTail;
    
    
    _resAddress = [UIView labelWithTitle:@"资源地址" frame:CGRectNull];
    _resAddress.textColor = ColorValue_RGB(0x666666);
    
    _line = [UIView viewWithColor:ColorValue_RGB(0xe2e2e2)];
    
    
    // 获取线路 getRouteClick
    _getRoute = [UIView buttonWithTitle:@"获取线路"
                              responder:self
                                    SEL:@selector(getRouteClick)
                                  frame:CGRectNull];
    
    
    // 获取其他线路
    _getSubRoute = [UIView buttonWithTitle:@"其他线路"
                                 responder:self
                                       SEL:@selector(getAnotherLinesSourceClick)
                                     frame:CGRectNull];
    
    
    // 撤缆
    _deleteCable = [UIView buttonWithImage:@"DC_chelan"
                                 responder:self
                                 SEL_Click:@selector(deleteCableClick)
                                     frame:CGRectNull];
    
    
    
    
    
    // 关联起始设备
    _connectStartEndDeviceBtn = [UIView buttonWithTitle:@"关联设备"
                                             responder:self
                                                   SEL:@selector(connectSEDeviceClick)
                                                 frame:CGRectNull];
    

    
    
    
    [_getRoute cornerRadius:5 borderWidth:0 borderColor:UIColor.whiteColor];
    _getRoute.backgroundColor = UIColor.mainColor;
    [_getRoute setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    
    [_getSubRoute cornerRadius:5 borderWidth:0 borderColor:UIColor.whiteColor];
    _getSubRoute.backgroundColor = UIColor.mainColor;
    [_getSubRoute setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    
    // 撤缆
    [_deleteCable cornerRadius:5 borderWidth:0 borderColor:UIColor.whiteColor];
    _deleteCable.backgroundColor = ColorValue_RGB(0xe2e2e2);
    
    
    // 关联起始终止设备
    [_connectStartEndDeviceBtn cornerRadius:5 borderWidth:0 borderColor:UIColor.whiteColor];
    _connectStartEndDeviceBtn.backgroundColor = UIColor.mainColor;
    [_connectStartEndDeviceBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    
    
 
    
    [self addSubviews:@[_cancelBtn,
                        _resType,
                        _resName,
                        _resAddress,
                        _line]];
    
    
    NSArray * btnsArr = @[_getRoute,                  //获取线路
                          _getSubRoute,               //获取子线路
                          //_connectStartEndDeviceBtn,     //关联起始终止设备
                          _deleteCable];              //撤缆
    
    for (UIButton * btn in btnsArr) {
        btn.titleLabel.font = Font(13);
    }
    
    
    
    [self addSubviews:btnsArr];
    
    [self yuan_LayoutSubViews];
}


- (void) yuan_LayoutSubViews {
    
    float limit = Horizontal(15);
    
    [_cancelBtn autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:limit/2];
    [_cancelBtn autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:limit/2];
    
    // 图片
    [_resType autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:limit * 2];
    [_resType autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:limit];
    
    // 资源
    [_resName YuanAttributeHorizontalToView:_resType];
    [_resName autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:_resType withOffset:limit];
    [_resName YuanToSuper_Right:limit];
    

    
    // 地址
    [_resAddress autoConstrainAttribute:ALAttributeLeft toAttribute:ALAttributeLeft ofView:_resName withMultiplier:1.0];
    [_resAddress autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_resName withOffset:5];
    
    
    [_line autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:limit];
    [_line autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:limit];
    [_line autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_resAddress withOffset:limit];
    [_line autoSetDimension:ALDimensionHeight toSize:1];
    
    
    
    float btnWidth = ScreenWidth / 4;
    float btnLimit = btnWidth / 5;
    float btnHeight = Vertical(35);
    
    // 获取线路
    [_getRoute autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:btnLimit];
    [_getRoute autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_line withOffset:limit];
    _getRouteConstraint = [_getRoute autoSetDimension:ALDimensionWidth toSize:btnWidth];
    [_getRoute autoSetDimension:ALDimensionHeight toSize:btnHeight];
    
    
    // 获取其他线路
    [_getSubRoute YuanMyEdge:Left ToViewEdge:Right ToView:_getRoute inset:btnLimit];
    [_getSubRoute YuanAttributeHorizontalToView:_getRoute];
    _getSubRouteConstraint = [_getSubRoute autoSetDimension:ALDimensionWidth toSize:btnWidth];
    [_getSubRoute autoSetDimension:ALDimensionHeight toSize:btnHeight];
    
    
    
//    [_connectStartEndDeviceBtn YuanAttributeHorizontalToView:_getRoute];
//    [_connectStartEndDeviceBtn autoSetDimensionsToSize:CGSizeMake(btnWidth, Vertical(35))];
//    [_connectStartEndDeviceBtn autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:_getSubRoute withOffset:btnLimit];
    
    
    [_deleteCable YuanAttributeHorizontalToView:_getRoute];
    [_deleteCable autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:btnLimit];
    
    _deleteCableConstraint = [_deleteCable autoPinEdge:ALEdgeLeft
                                                toEdge:ALEdgeRight
                                                ofView:_getSubRoute
                                            withOffset:btnLimit];
    
    [_deleteCable autoSetDimension:ALDimensionHeight toSize:Vertical(35)];
    
}



//zzc
- (void) alertSmallTitleWithButton:(NSString *)title
                          btnTitle:(NSString *)btnTitle
           agreeBtnBlock:(void(^)(UIAlertAction *action))block  {
    
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:@"" preferredStyle:UIAlertControllerStyleAlert];
    
    UIButton *btn = [UIView buttonWithTitle:btnTitle responder:self SEL:@selector(btnClick:) frame:CGRectMake(Horizontal(15), Vertical(55), Horizontal(140), 20)];
    [btn setImage:[UIImage Inc_imageNamed:@"XJ_icon_CheckBox_normal"] forState:UIControlStateNormal];
    [btn setImage:[UIImage Inc_imageNamed:@"XJ_icon_CheckBox_selected"] forState:UIControlStateSelected];
    
    [alertController.view addSubview:btn];

    // Create the actions.
    UIAlertAction *IKnowAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        // 把点击事件回调给调用的界面
        if (block) {
            block(action);
        }
    }];
    
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        //什么也不做
    }];
    
    
    // Add the actions.
    [alertController addAction:IKnowAction];
    [alertController addAction:cancelAction];
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
    
    
    
    
}

- (void)btnClick:(UIButton *)btn {

//    [[INCUserInfomation sharedInformation] setIsFirstDelete:btn.selected];
//    btn.selected = !btn.selected;

}


@end
