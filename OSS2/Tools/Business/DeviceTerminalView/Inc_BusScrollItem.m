//
//  Inc_BusScrollItem.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/2/20.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_BusScrollItem.h"
#import "Yuan_CFConfigVM.h"
@implementation Inc_BusScrollItem

{
    
    NSDictionary * _myDict;
    
    // 我自己的编号
    UILabel * _myNum;
    // 绑定的编号
    UILabel * _bindingNum;
    
    UILabel * _myUnionStateLabel;
    
    BOOL _isNeedChangeState;
    
    
    // 暂时只有 分光器端子绑定时使用 , 显示在右上角 对应的分光器端子编号
    UILabel * _connectNum;
    
    
    // 2021-6-25 新增 , 跳纤的标志
    UIImageView * _jumpFiber_Sympol;
    
    // 2021-7-19 新增 , 端子已经成端的标志
    UIImageView * _chengD_Sympol;
    
    // 2021-7-19 新增 , 端子已经在光链路内的标志
    UIImageView * _inFiberLink_Sympol;
    
    Yuan_CFConfigVM * _VM;
    
    
    BOOL _isNewDict;  // 是否是新的数据源 -- 大为的接口返回的数据
    
}
   


#pragma mark - 初始化构造方法

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        _VM = Yuan_CFConfigVM.shareInstance;
        _canSelect = YES;
        [self UI_Config];
        
        UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc]init];
        [self addGestureRecognizer:gesture];
        [gesture setMinimumPressDuration:0.3];  //长按1秒后执行事件
        [gesture addTarget:self action:@selector(gestureEvent:)];
        
    }
    return self;
}



- (void)setDict:(NSDictionary *)dict {
    
    _myDict = dict;
    _terminalId = dict[@"GID"];
    
    self.layer.borderWidth = 0.5;
    self.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    NSInteger oprStateId = [dict[@"oprStateId"] integerValue];

    
    /*
        TODO:  1. 询问 为何保存后 oprStateId 还是 1 没有成功修改
        TODO:  2. 修改后 应该如何变化 按钮颜色 ??
    */
    
    // 当 端子View 初始化构造器是4的时候 , 则不走颜色
    if (_VM.isInitType_4_Mode) {
        
        self.backgroundColor = ColorR_G_B(232, 232, 232);
        [self setTitleColor:ColorValue_RGB(0x929292)
                   forState:UIControlStateNormal];
        return;
    }
    
    switch (oprStateId) {
        case 2:     //预占
        case 4:     //预释放
        case 5:     //预留
        case 6:     //预选
        case 7:     //备用
        case 11:    //测试
        case 12:    //临时占用
            
            self.backgroundColor = ColorR_G_B(252, 160, 0);
            [self setTitleColor:[UIColor whiteColor]
                       forState:UIControlStateNormal];
            break;
        
        case 3:     //占用
        
            
            self.backgroundColor = ColorR_G_B(147, 222, 113);
            [self setTitleColor:[UIColor whiteColor]
                       forState:UIControlStateNormal];
            break;
        
        case 8:     //停用
        case 10:    //损坏
            
            self.backgroundColor = ColorR_G_B(255, 0, 44);
            [self setTitleColor:[UIColor whiteColor]
                       forState:UIControlStateNormal];
            break;
            
        default:    //1.空闲 9.闲置
            
            self.backgroundColor = ColorR_G_B(232, 232, 232);
            [self setTitleColor:ColorValue_RGB(0x929292)
                       forState:UIControlStateNormal];
            break;
    }
    
    
    
}



// 设置新数据源 , 虽然还用 dict  但需要转换一下
- (void) configNewDict:(NSDictionary *) newDict {
    
    _isNewDict = YES;
    
    NSMutableDictionary * mt_NewDict = [NSMutableDictionary dictionaryWithDictionary:newDict];
    mt_NewDict[@"GID"] = newDict[@"termId"];
    
    // 为新的资源数组赋值
    _opticTermList = mt_NewDict[@"opticTermList"];
    _optLineRelationList = mt_NewDict[@"optLineRelationList"];
    _optPairRouterList = mt_NewDict[@"optPairRouterList"];
    
    _myDict = mt_NewDict;
    _terminalId = mt_NewDict[@"termId"];
    
    self.layer.borderWidth = 0.5;
    self.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    NSInteger oprStateId = [mt_NewDict[@"oprStateId"] integerValue];

    
    /*
        TODO:  1. 询问 为何保存后 oprStateId 还是 1 没有成功修改
        TODO:  2. 修改后 应该如何变化 按钮颜色 ??
    */
    
    // 当 端子View 初始化构造器是4的时候 , 则不走颜色
    if (_VM.isInitType_4_Mode) {
        
        self.backgroundColor = ColorR_G_B(232, 232, 232);
        [self setTitleColor:ColorValue_RGB(0x929292)
                   forState:UIControlStateNormal];
        return;
    }
    
    switch (oprStateId) {
        case 170002:     //预占
        case 170005:     //预释放
        case 170007:     //预留
        case 170014:     //预选
        case 170015:     //备用
        case 170046:     //测试
        case 170187:     //临时占用
            
            self.backgroundColor = ColorR_G_B(252, 160, 0);
            [self setTitleColor:[UIColor whiteColor]
                       forState:UIControlStateNormal];
            break;
        
        case 170003:     //占用
        
            
            self.backgroundColor = ColorR_G_B(147, 222, 113);
            [self setTitleColor:[UIColor whiteColor]
                       forState:UIControlStateNormal];
            break;
        
        case 160014:     //停用
        case 170147:     //损坏
            
            self.backgroundColor = ColorR_G_B(255, 0, 44);
            [self setTitleColor:[UIColor whiteColor]
                       forState:UIControlStateNormal];
            break;
            
        default:        //1.空闲 9.闲置
            
            self.backgroundColor = ColorR_G_B(232, 232, 232);
            [self setTitleColor:ColorValue_RGB(0x929292)
                       forState:UIControlStateNormal];
            break;
    }
    
}



- (NSDictionary *)dict {
    
    NSMutableDictionary * mt_Dict = [NSMutableDictionary dictionaryWithDictionary:_myDict];
    
    mt_Dict[@"btnIndex"] = [Yuan_Foundation fromInteger:_index];
    mt_Dict[@"btnPosition"] = [Yuan_Foundation fromInteger:_position];
    
    _myDict = mt_Dict;
    
    
    return _myDict;
}


/// 传入起始或终止数组 返回右上角显示的数组
/// @param array 起始或终止数组
/// @param myId 我的 端子Id
- (NSString *) circleArray:(NSMutableArray *)array
                      myId:(NSString *)myId{
    
    
    NSString * pairNo = @"";
    
    
    for (NSDictionary * singleDeviceMap in array) {
        
        NSString * resId = singleDeviceMap[@"resId"];
        
        if ([resId isEqualToString:myId]) {
            pairNo = singleDeviceMap[@"pairNo"];
            break;
        }
        
    }
    
    
    return pairNo ?: @"";
    
}


/// 修改业务状态 ID 让按钮改变颜色
/// @param oprStateId oprStateId
- (void) change_OprStateId:(NSString *)oprStateId {
    
    
    
    NSInteger oprStateId_Switch = [oprStateId integerValue];

    
    /*
        TODO:  1. 询问 为何保存后 oprStateId 还是 1 没有成功修改
        TODO:  2. 修改后 应该如何变化 按钮颜色 ??
    */
    
    switch (oprStateId_Switch) {
        case 2:     //预占
        case 4:     //预释放
        case 5:     //预留
        case 6:     //预选
        case 7:     //备用
        case 11:    //测试
        case 12:    //临时占用
            
            self.backgroundColor = ColorR_G_B(252, 160, 0);
            [self setTitleColor:[UIColor whiteColor]
                       forState:UIControlStateNormal];
            break;
        
        case 3:     //占用
        
            
            self.backgroundColor = ColorR_G_B(147, 222, 113);
            [self setTitleColor:[UIColor whiteColor]
                       forState:UIControlStateNormal];
            break;
        
        case 8:     //停用
        case 10:    //损坏
            
            self.backgroundColor = ColorR_G_B(255, 0, 44);
            [self setTitleColor:[UIColor whiteColor]
                       forState:UIControlStateNormal];
            break;
            
        default:    //1.空闲 9.闲置
            
            self.backgroundColor = ColorR_G_B(232, 232, 232);
            [self setTitleColor:ColorValue_RGB(0x929292)
                       forState:UIControlStateNormal];
            break;
    }
    
    
    // 需要把端子的 dict 状态也一并重置 不然 再次点进去 端子状态显示不变

    NSMutableDictionary * newDict = [NSMutableDictionary dictionaryWithDictionary:_myDict];
    
    newDict[@"oprStateId"] = oprStateId;
    
    _myDict = newDict;
    
}


/// 配置我的按钮的编号
/// @param num 编号 通过for循环创建
- (void) configMyNum:(int) num {
    
    // 显示 01 02 11 12 等两位有效数字
    _myNum.text = [NSString stringWithFormat:@"%2d",num];
    
}


/// 绑定对应的纤芯的编号
/// @param num 纤芯编号
- (void) configBindingNum:(NSString *) num
                     from:(configBindingNumFrom_)type{
    
    _bindingNum.text = num;
    
    if (type == configBindingNumFrom_HTTP) {
        _bindingNum.textColor = UIColor.orangeColor;
    }else {
        _bindingNum.textColor = ColorValue_RGB(0x3CB371);
    }
    
}


/// 当特殊状况 , 不显示端子序号 需要显示其他状态时 使用 , 暂时是 initType = 4 的时候
- (void) configTerminalText:(NSString *) text color:(UIColor *) color {
    
    _myNum.text = text ?: @"";
    
    _myNum.textColor = color;
    
}

#pragma mark -  按钮的长按手势  ---

- (void) gestureEvent:(UILongPressGestureRecognizer *)gesture {
    
    if (_isNewDict) {
        [YuanHUD HUDFullText:@"新接口端子数据未配置长按事件"];
        return;
    }
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:BusScrollItemLongPressNotification
                                                            object:nil
                                                          userInfo:_myDict];
    }
}




#pragma mark -  UI  ---

- (void) UI_Config {
    
    _myNum = [UIView labelWithTitle:@"01" frame:CGRectNull];
    _bindingNum = [UIView labelWithTitle:@"" frame:CGRectNull];
    
    _myNum.font = Font_Bold_Yuan(14); //加粗
    _bindingNum.font = Font_Bold_Yuan(12);
    
    _myNum.textColor = UIColor.blackColor;
    _bindingNum.textColor = ColorValue_RGB(0x3CB371);
    
    // 纤芯连接的号
    _connectNum = [UIView labelWithTitle:@" " frame:CGRectNull];
    _connectNum.textColor = UIColor.blueColor;
    _connectNum.font = Font_Yuan(12);
    
    // 跳纤的标志绿点
    _jumpFiber_Sympol = [UIImageView imageViewWithImg:[UIImage Inc_imageNamed:@"ODF_New_JFSympol"]
                                                frame:CGRectNull];
    _jumpFiber_Sympol.hidden = YES;
    
    
    // 端子已成端的标志
    _chengD_Sympol = [UIImageView imageViewWithImg:[UIImage Inc_imageNamed:@"ODF_New_chengduan"]
                                             frame:CGRectNull];
    _chengD_Sympol.hidden = YES;
    
    
    
    // 端子已经在光路中的标志
    _inFiberLink_Sympol = [UIImageView imageViewWithImg:[UIImage Inc_imageNamed:@"ODF_New_guanglu"]
                                                  frame:CGRectNull];
    _inFiberLink_Sympol.hidden = YES;
    
    
    
    [self addSubviews:@[_myNum,
                        _bindingNum,
                        _connectNum,
                        _jumpFiber_Sympol,
                        _chengD_Sympol,
                        _inFiberLink_Sympol]];
    
    [self layoutAllSubViews];
}


#pragma mark - 屏幕适配

- (void)layoutAllSubViews {
    
    float limit = Horizontal(3);
    
    [_myNum autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:limit];
    [_myNum autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:limit];
    
    [_bindingNum autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:limit];
    [_bindingNum autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:limit];
    
    [_connectNum YuanToSuper_Top:limit];
    [_connectNum YuanToSuper_Right:limit];
    
    
    [_jumpFiber_Sympol YuanToSuper_Right:Horizontal(5)];
    [_jumpFiber_Sympol YuanToSuper_Bottom:Horizontal(5)];
    
    [_chengD_Sympol YuanToSuper_Left:0];
    [_chengD_Sympol YuanToSuper_Top:0];
    
    [_inFiberLink_Sympol YuanToSuper_Right:Horizontal(5)];
    [_inFiberLink_Sympol YuanToSuper_Top:Horizontal(5)];
}


#pragma mark - 颜色配置 ---

- (void) configColor:(UIColor *)color {
    
    self.backgroundColor = color;
    
}

- (void) borderColor:(UIColor *)borderColor {
    
    [self cornerRadius:0 borderWidth:1 borderColor:borderColor];
}



#pragma mark - 其他配置 ---

/// 暂时只有(分光器端子) 绑定时使用
- (void) config_ConnectNum:(NSString *) connectNum {
    
    _connectNum.text = connectNum;
}


/// 是否显示(跳纤)的标志 -- 底部的小绿点
- (void) Terminal_JumpFiber_Sympol_IsShow:(BOOL) isShow_JF_Sympol {
    
    // 是否显示
    _jumpFiber_Sympol.hidden = !isShow_JF_Sympol;
}


/// 是否显示成端标志 -- 左上角
- (void) Terminal_ChengD_Sympol_IsShow:(BOOL) isShow_ChengD_Sympol {
    
    _chengD_Sympol.hidden = !isShow_ChengD_Sympol;
}


/// 是否显示端子在光路内标志 -- 右上角
- (void) Terminal_InFiberLink_Sympol_IsShow:(BOOL) isShow_inFiberLink_Sympol {
    
    _inFiberLink_Sympol.hidden = !isShow_inFiberLink_Sympol;
}

@end
