//
//  Inc_TermJumpingVC.m
//  OSS2.0-ios-v2
//
//  Created by zzc on 2021/6/24.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//


#import "Inc_TermJumpingVC.h"
#import "Inc_PopJumpView.h"
#import "Inc_BusDeviceView.h"
#import "Inc_ODF_JumpFiber_VM.h"
#import "Inc_JumpSelectODFVC.h"
#import "Inc_JumpSelectDeviceVC.h"

#import "Inc_ODF_JumpFiber_HttpModel.h"


@interface Inc_TermJumpingVC ()<Yuan_BusDevice_ItemDelegate>{
    
    //黑色透明背景view
    UIView *_windowBgView;
    
    Inc_ODF_JumpFiber_VM *_VM;
    
    //顶部名称/ODF
    UIView *_topLine;
    UILabel *_topTip;
    UILabel *_topName;
    
    //底部机房
    //竖线
    UIView *_roomLine;
    //机房
    UILabel *_roomTip;
    //机房名称
    UILabel *_roomLabel;
    //箭头
    UIButton *_rightBtn;
    //一条都能点击
    UIButton *_rightTouchBtn;

    //横线
    UIView *_hLine;
    
    
    //底部ODF名称
    //竖线
    UIView *_bottomLine;
    //ODF
    UILabel *_bottomTip;
    //ODF名称
    UILabel *_bottomName;
    //箭头  显示
    UIButton *_bottomBtn;
    //一条都能点击
    UIButton *_bottomTouchBtn;
    
    //存在跳纤关系的端子数组
    NSMutableArray *_termsJumpArrayTop;
    NSMutableArray *_termsJumpArrayBottom;

    //点击后选中的top/bottom数组
    NSDictionary *_termsDicTop;
    NSDictionary *_termsDicBottom;
    
    
    //top点击的存在跳纤
    BOOL _topIsHaveJump;

    //bottom点击的存在跳纤
    BOOL _bottomIsHaveJump;
    
    
    //两个跳纤端子关系id
    NSString *_relationshipId;
    
    
    //OCC_Equt(光交箱) ODB_Equt(光分箱) ODF_Equt(机架)
    NSString *_deviceResLogicName;
    
    
    //top端子存在跳纤关系对应的bottom端子
    NSDictionary *_bottomDict;
    
    //机房id
    NSString *_roomId;
}

//弹出view
@property (nonatomic, strong) Inc_PopJumpView *popJumpView;

//需要弹出数组
@property (nonatomic, strong) NSMutableArray *dataArray;

//第一个
@property (nonatomic, strong) Inc_BusDeviceView *topDeviceView;
//第二个
@property (nonatomic, strong) Inc_BusDeviceView *bottomDeviceView;



@end

@implementation Inc_TermJumpingVC

- (Inc_PopJumpView *)popJumpView {
    WEAK_SELF;
    if (!_popJumpView) {
        _popJumpView = [[Inc_PopJumpView alloc]initWithFrame:CGRectNull];
        _popJumpView.btnBlock = ^(UIButton * _Nonnull btn) {
            [wself btnClick:btn];
        };
    }
    return _popJumpView;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"端子跳纤";
    
    _VM = Inc_ODF_JumpFiber_VM.shareInstance;
    
    [self createUI];
    [self createDeviceView];

    [self setWindowBgView];
    _windowBgView.hidden = YES;
    _popJumpView.hidden = YES;

    [self Zhang_layouts];
    
    _roomId = _mb_Dict[@"posit_Id"]?:_mb_Dict[@"positId"];
        
}


-(void)createUI {
    
    //top
    _topLine = [UIView viewWithColor:ColorR_G_B(248, 95, 93)];
    
    _topTip = [UIView labelWithTitle:@"ODF:" isZheH:NO];
    _topTip.font = Font_Yuan(12);
    
    _topName = [UIView labelWithTitle:@"" isZheH:YES];

    if ([_type isEqualToString:@"1"]) {
        _topName.text = _mb_Dict[@"rackName"];
        _deviceResLogicName = @"ODF_Equt";
    }else if ([_type isEqualToString:@"2"]) {
        _topName.text = _mb_Dict[@"occName"];
        _deviceResLogicName = @"OCC_Equt";
    }else if ([_type isEqualToString:@"3"]) {
        _topName.text = _mb_Dict[@"odbName"];
        _deviceResLogicName = @"ODB_Equt";
    }else if ([_type isEqualToString:@"4"]) {
        _topName.text = _mb_Dict[@"name"];
        _deviceResLogicName = @"OBD_Equt";
    }
    
    
    if ([_type isEqualToString:@"1"] || [_type isEqualToString:@"4"]) {
        _topName.font = Font_Yuan(12);
        _topName.textColor = UIColor.lightGrayColor;
        [self.view addSubviews:@[_topLine,_topTip,_topName]];
    }else{
        _topName.font =  Font_Yuan(12);
        _topName.textColor = UIColor.blackColor;
        [self.view addSubviews:@[_topLine,_topName]];

    }
    
    //bottom
    _roomLine = [UIView viewWithColor:ColorR_G_B(248, 95, 93)];
    _roomTip = [UIView labelWithTitle:@"机房:" isZheH:NO];
    _roomTip.font = Font_Yuan(12);
    
    _roomLabel = [UIView labelWithTitle:@"" isZheH:YES];
    _roomLabel.textColor = UIColor.lightGrayColor;
    _roomLabel.font = Font_Yuan(12);

    _rightBtn = [UIView buttonWithImage:@"rightArrow" responder:self SEL_Click:@selector(pushJumpSelectPDFVC) frame:CGRectNull];
    _rightTouchBtn = [UIView buttonWithImage:@"" responder:self SEL_Click:@selector(pushJumpSelectPDFVC) frame:CGRectNull];

    
    
    _hLine = [UIView viewWithColor:UIColor.groupTableViewBackgroundColor];
    
    
    _bottomLine = [UIView viewWithColor:ColorR_G_B(248, 95, 93)];
    
    _bottomTip = [UIView labelWithTitle:@"ODF:" isZheH:NO];
    _bottomTip.font = Font_Yuan(12);
    
    _bottomName = [UIView labelWithTitle:@"" isZheH:YES];
    _bottomName.textColor = UIColor.lightGrayColor;
    _bottomName.font = Font_Yuan(12);

    _bottomBtn = [UIView buttonWithImage:@"rightArrow" responder:self SEL_Click:@selector(pushJumpSelectDeviceVC) frame:CGRectNull];
    _bottomTouchBtn = [UIView buttonWithImage:@"" responder:self SEL_Click:@selector(pushJumpSelectDeviceVC) frame:CGRectNull];

    
    if ([_type isEqualToString:@"1"] || [_type isEqualToString:@"4"]) {
        
        [self.view addSubviews:@[_roomLine,
                                 _roomTip,
                                 _roomLabel,
                                 _rightBtn,
                                 _rightTouchBtn,
                                 _hLine,
                                 _bottomLine,
                                 _bottomTip,
                                 _bottomName,
                                 _bottomBtn,
                                 _bottomTouchBtn]];
    }
    
    if ([_type isEqualToString:@"1"]) {
        _roomLabel.text = _mb_Dict[@"posit"];
        _bottomName.text = _mb_Dict[@"rackName"];
    }
    
    if ([_type isEqualToString:@"4"]) {
        _roomLabel.text = _mb_Dict[@"positName"];
        _bottomName.text = _mb_Dict[@"name"];
    }
    
}

- (void)createDeviceView {
    
    _topDeviceView = [[Inc_BusDeviceView alloc]initWithPieDict:_dict VC:self];
    _topDeviceView.delegate = self;
    _topDeviceView.tag = 10010;
    WEAK_SELF;
    _topDeviceView.httpSuccessBlock = ^{
        [wself getTopShelfId];
    };

    _bottomDeviceView = [[Inc_BusDeviceView alloc]initWithDeviceId:self.deviceId deviceResLogicName:_deviceResLogicName pieId:_dict[@"cnctShelfId"] VC:self];
    _bottomDeviceView.delegate = self;
    _bottomDeviceView.httpSuccessBlock = ^{
        [wself getBottomShelfId:NO];
    };
    _bottomDeviceView.tag = 10011;

    
    _topDeviceView.busDevice_Enum = Yuan_BusDeviceEnum_Normal;
    _bottomDeviceView.busDevice_Enum = Yuan_BusDeviceEnum_Normal;
    
    [self.view addSubviews:@[_topDeviceView,_bottomDeviceView]];
}

//获取top列框跳纤端子
- (void)getTopShelfId{
    
    NSDictionary *dic = [_topDeviceView getPieDict];
    NSString *shelfId = dic[@"cnctShelfId"]?:@"";

    [self FindTermOptLineByShelfId:@{@"id":shelfId} isTop:YES isReload:NO];
    
}

//获取bottom列框跳纤端子
- (void)getBottomShelfId:(BOOL)isReload{
    
    NSDictionary *dic = [_bottomDeviceView getPieDict];
    NSString *shelfId = dic[@"cnctShelfId"]?:@"";
    
    [self FindTermOptLineByShelfId:@{@"id":shelfId} isTop:NO isReload:isReload];
    
}

//弹出数据拼接
- (void)setupDataArray {
    _dataArray = [NSMutableArray array];
    
    //ODF
    if ([_type isEqualToString:@"1"]) {
        [_dataArray addObjectsFromArray:@[
            @{@"eqName":_mb_Dict[@"posit"],@"resName":_termsDicTop[@"termName"]},
            @{@"eqName":_roomLabel.text,@"resName":_termsDicBottom[@"termName"]}]];
    }
    //OCC
    else if ([_type isEqualToString:@"2"]){
        [_dataArray addObjectsFromArray:@[
            @{@"eqName":_topName.text,@"resName":_termsDicTop[@"termName"]},
            @{@"eqName":@"",@"resName":_termsDicBottom[@"termName"]}]];
    }
    //ODB
    else if ([_type isEqualToString:@"3"]){
        [_dataArray addObjectsFromArray:@[
            @{@"eqName":_topName.text,@"resName":_termsDicTop[@"termName"]},
            @{@"eqName":@"",@"resName":_termsDicBottom[@"termName"]}]];
    }
    //box
    else if ([_type isEqualToString:@"4"]){
        [_dataArray addObjectsFromArray:@[
            @{@"eqName":_mb_Dict[@"posit"],@"resName":_termsDicTop[@"termName"]},
            @{@"eqName":_roomLabel.text,@"resName":_termsDicBottom[@"termName"]}]];
    }
    
    //存在跳纤关联
    if (_topIsHaveJump || _bottomIsHaveJump) {
        _popJumpView.isHaveJump = YES;
    }else{
        _popJumpView.isHaveJump = NO;
    }
    
    _popJumpView.type = @"1";

    for (NSDictionary *dic in _termsJumpArrayBottom) {
        if ([_termsDicBottom[@"GID"] isEqualToString:dic[@"termId"]]) {
            
            NSDictionary *dict =  dic[@"optLineRelation"][0];
            //两个互为跳纤关系
            if ([_termsDicTop[@"GID"] isEqualToString:dict[@"termId"]]) {
                //linkId  跳纤关系id
                _relationshipId = dict[@"linkId"];
                _popJumpView.type = @"2";
                //解除不需要含有跳纤提示
                _popJumpView.isHaveJump = NO;
            }
        }
    }
    
 
    [self showPopJumpView];
}
#pragma mark devieViewDelegate

- (void) Yuan_BusDeviceSelectItems:(NSArray <Inc_BusScrollItem *> * )btnsArr
                     nowSelectItem:(Inc_BusScrollItem *) item
                  BusODFScrollView:(Inc_BusDeviceView *)busView {
    
    
    if (busView == _topDeviceView) {
              
        //点击top，底部刷新。防止点击了跳纤端子后，在点击top其它端子，底部关联端子底色没修改问题
        for (Inc_BusScrollItem *itemAll in [_bottomDeviceView getBtns]) {
            [self setTermBackColor:itemAll];
            [itemAll Terminal_JumpFiber_Sympol_IsShow:NO];
            if (_termsJumpArrayBottom.count > 0) {
                for (NSDictionary *dic in _termsJumpArrayBottom) {
                    if ([itemAll.terminalId isEqualToString:dic[@"termId"]]) {
                        [itemAll Terminal_JumpFiber_Sympol_IsShow:YES];
                    }
                }
            }
        }
        
        _topIsHaveJump = NO;

        for (NSDictionary *dic in _termsJumpArrayTop) {
            
            if ([item.terminalId isEqualToString:dic[@"termId"]]) {
                _topIsHaveJump = YES;
                //刷新bottom
                _bottomDict  =  dic[@"optLineRelation"][0];

                //赋值
                _roomLabel.text = _bottomDict[@"roomName"]?:_mb_Dict[@"posit"];
                _bottomName.text = _bottomDict[@"superResName"];
                //当前端子跳纤关系的框= 底部端子框
                if ([_bottomDict[@"shelfId"] isEqualToString:[_bottomDeviceView getPieDict][@"cnctShelfId"]]) {
                       
                    [self getBottomShelfId:YES];
                    
                }else{
                    [_bottomDeviceView removeFromSuperview];
                    
                    //防止二次切换列框渲染背景色
                    __block  BOOL isFirst = YES;
                    
                    _bottomDeviceView = [[Inc_BusDeviceView alloc]initWithDeviceId:_bottomDict[@"superResId"] deviceResLogicName:_deviceResLogicName pieId:_bottomDict[@"shelfId"] VC:self];
                    _bottomDeviceView.delegate = self;
                    [self.view addSubview:_bottomDeviceView];
                    [self Zhang_layouts];
                    WEAK_SELF;
                    _bottomDeviceView.httpSuccessBlock = ^{
                        
                        [wself getBottomShelfId:isFirst];
                        isFirst = NO;
                    };
                }
                
                
            }
            
        }
        //点击背景色
        for (Inc_BusScrollItem *itemAll in btnsArr) {
            [self setTermBackColor:itemAll];
            if (itemAll.index == item.index && itemAll.position == item.position) {
               
                [itemAll configColor:ColorR_G_B(253, 207, 207)];
                [itemAll borderColor:UIColor.clearColor];
            }
            _termsDicTop = item.dict;
        }
        
    }else{
        
        if (_termsDicTop.allKeys > 0) {
            
            if ([_termsDicTop[@"GID"] isEqual:item.dict[@"GID"]]) {
                [YuanHUD HUDFullText:@"不可选择同一端子关联"];
                return;
            }
            
            _bottomIsHaveJump = NO;
            for (NSDictionary *dic in _termsJumpArrayBottom) {
                if ([item.terminalId isEqualToString:dic[@"termId"]]) {
                    _bottomIsHaveJump = YES;
                }
            }
            
            
            for (Inc_BusScrollItem *itemAll in btnsArr) {
                
                [self setTermBackColor:itemAll];
                if (itemAll.index == item.index && itemAll.position == item.position) {
                   
                    [itemAll configColor:ColorR_G_B(253, 207, 207)];
                    [itemAll borderColor:UIColor.clearColor];
                }
                _termsDicBottom = item.dict;
                
                [self setupDataArray];
                _windowBgView.hidden = NO;
                _popJumpView.hidden = NO;
                
            }
            
        }else{
            [YuanHUD HUDFullText:@"请先选择上面端子"];
        }
       
        
    }
        
}



//黑色透明背景
-(void)setWindowBgView {
    _windowBgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    _windowBgView.backgroundColor = [UIColor colorWithRed:30/255.0 green:30/255.0 blue:30/255.0 alpha:0.4];
    _windowBgView.userInteractionEnabled = YES;
  

    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapEvent:)];
    [_windowBgView addGestureRecognizer:tap];
    
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    
    [window addSubview:_windowBgView];
    
    [_windowBgView addSubview:self.popJumpView];
    
}

#pragma mark -zzc  btnClick

- (void)showPopJumpView {
    
    _popJumpView.frame = CGRectMake(0, ScreenHeight - 290, ScreenWidth, 290);
    _popJumpView.dataArray = _dataArray;
    [_popJumpView reloadData];
}

- (void)hidePopJumpView {
    _windowBgView.hidden = YES;
    _popJumpView.hidden  = YES;
    _termsDicTop = nil;
    _termsDicBottom = nil;
    
   //隐藏后重新更新端子的状态
    for (Inc_BusScrollItem *itemAll in [_topDeviceView getBtns]) {
        [self setTermBackColor:itemAll];
        if (_termsJumpArrayTop.count > 0) {
            for (NSDictionary *dic in _termsJumpArrayTop) {
                if ([itemAll.terminalId isEqualToString:dic[@"termId"]]) {
                    [itemAll Terminal_JumpFiber_Sympol_IsShow:YES];
                }
            }
        }
    }
    
    for (Inc_BusScrollItem *itemAll in [_bottomDeviceView getBtns]) {
        [self setTermBackColor:itemAll];
        if (_termsJumpArrayBottom.count > 0) {
            for (NSDictionary *dic in _termsJumpArrayBottom) {
                if ([itemAll.terminalId isEqualToString:dic[@"termId"]]) {
                    [itemAll Terminal_JumpFiber_Sympol_IsShow:YES];
                }
            }
        }
    }
    
}

//需要点击背景隐藏 打开
-(void)tapEvent:(UITapGestureRecognizer *)gesture {
    [self hidePopJumpView];
}

//popview  按钮点击
- (void)btnClick:(UIButton *)btn {
    if ([btn.titleLabel.text isEqualToString:@"关联"]) {
        NSLog(@"确认关联");
        _VM.jumpFiber_Arr = [NSMutableArray arrayWithObjects:_termsDicTop,_termsDicBottom, nil];
        [_VM combinationJumpFiber];
        WEAK_SELF;
        _VM.successBlock = ^{
          //刷新端子盘
            [wself hidePopJumpView];
            
            [wself getTopShelfId];
            [wself getBottomShelfId:NO];

            
        };
        
    }else if ([btn.titleLabel.text isEqualToString:@"解除关联"]){
        NSLog(@"解除关联");
        [_VM relieveJumpFiber:_relationshipId];
        WEAK_SELF;
        _VM.successBlock = ^{
          //刷新端子盘
            [wself hidePopJumpView];
            
            [wself getTopShelfId];
            [wself getBottomShelfId:NO];

            
        };
        
    }
}


#pragma mark -push
//机房
-(void)pushJumpSelectPDFVC {
    
    Inc_JumpSelectODFVC *vc = [Inc_JumpSelectODFVC new];
    vc.deviceId = self.deviceId;
    WEAK_SELF;
    vc.getODFDicBlock = ^(NSDictionary *dic) {
        NSLog(@"%@",dic);
        [wself setupBottomDeviceView:dic];
    };
    Push(self, vc);
}
 
//odf
-(void)pushJumpSelectDeviceVC {
    
    Inc_JumpSelectDeviceVC *vc = [Inc_JumpSelectDeviceVC new];
    vc.roomId = _roomId?:@"";

    vc.getODFDicBlock = ^(NSDictionary *dic) {
        NSLog(@"%@",dic);
        _bottomName.text = dic[@"name"];
        [_bottomDeviceView removeFromSuperview];

        _bottomDeviceView = [[Inc_BusDeviceView alloc]initWithDeviceId:dic[@"gid"]  deviceResLogicName:[self getResTypeName:dic[@"resTypeId"]] pieId:nil VC:self];
        _bottomDeviceView.delegate = self;
        [self.view addSubview:_bottomDeviceView];
        [self Zhang_layouts];
        WEAK_SELF;
        _bottomDeviceView.httpSuccessBlock = ^{
            
            [wself getBottomShelfId:NO];
            
        };
        
    };
    Push(self, vc);
}


//获取odf设备数据
- (void)setupBottomDeviceView:(NSDictionary *)dic {
    
    _roomLabel.text = dic[@"name"];
    _bottomName.text = @"请点击右侧箭头选择设备";
    [_bottomDeviceView removeFromSuperview];
    _roomId = dic[@"gid"]?:@"";

}



#pragma mark - http

//查询列框中存在跳纤的端子
- (void)FindTermOptLineByShelfId:(NSDictionary *)dict isTop:(BOOL)isTop isReload:(BOOL)isReload{
    
    [Inc_ODF_JumpFiber_HttpModel FindTermOptLineByShelfId:dict successBlock:^(id result) {
        
        if (result) {
            //第一个盘
            if (isTop) {
                _termsJumpArrayTop = [NSMutableArray array];
                [_termsJumpArrayTop addObjectsFromArray:result];

                for (Inc_BusScrollItem *itemAll in [_topDeviceView getBtns]) {
                    //遍历赋业务状态，为了和原状态保存一致
                    [self setTermBackColor:itemAll];
                    //遍历跳纤状态，刷新后都置no
                    [itemAll Terminal_JumpFiber_Sympol_IsShow:NO];
                    if (_termsJumpArrayTop.count > 0) {
                        for (NSDictionary *dic in _termsJumpArrayTop) {
                            if ([itemAll.terminalId isEqualToString:dic[@"termId"]]) {
                                //遍历端子，设置跳纤状态
                                [itemAll Terminal_JumpFiber_Sympol_IsShow:YES];
                            }
                        }
                    }
                }
            }
            //第二个盘
            else {
                _termsJumpArrayBottom = [NSMutableArray array];
                [_termsJumpArrayBottom addObjectsFromArray:result];
                for (Inc_BusScrollItem *itemAll in [_bottomDeviceView getBtns]) {
                    [self setTermBackColor:itemAll];
                    [itemAll Terminal_JumpFiber_Sympol_IsShow:NO];
                    if (_termsJumpArrayBottom.count > 0) {
                        for (NSDictionary *dic in _termsJumpArrayBottom) {
                            if ([itemAll.terminalId isEqualToString:dic[@"termId"]]) {
                                [itemAll Terminal_JumpFiber_Sympol_IsShow:YES];
                            }
                        }
                        if (isReload) {
                            //点击跳纤端子后，对应的端子底色添加标识
                            if ([itemAll.dict[@"GID"] isEqualToString:_bottomDict[@"termId"]]) {
                                [itemAll configColor:ColorR_G_B(253, 207, 207)];
                                [itemAll borderColor:UIColor.clearColor];
                            }
                        }
                    }
                }
            }
        }
    }];
    
}



//端子状态遍历
- (void)setTermBackColor:(Inc_BusScrollItem *)item {
    
    item.layer.borderWidth = 0.5;
    item.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    NSInteger oprStateId = [item.dict[@"oprStateId"] integerValue];

    
    /*
        TODO:  1. 询问 为何保存后 oprStateId 还是 1 没有成功修改
        TODO:  2. 修改后 应该如何变化 按钮颜色 ??
    */
    
    
    
    
    switch (oprStateId) {
        case 2:     //预占
        case 4:     //预释放
        case 5:     //预留
        case 6:     //预选
        case 7:     //备用
        case 11:    //测试
        case 12:    //临时占用
            
            item.backgroundColor = ColorR_G_B(252, 160, 0);
            [item setTitleColor:[UIColor whiteColor]
                       forState:UIControlStateNormal];
            break;
        
        case 3:     //占用
        
            
            item.backgroundColor = ColorR_G_B(147, 222, 113);
            [item setTitleColor:[UIColor whiteColor]
                       forState:UIControlStateNormal];
            break;
        
        case 8:     //停用
        case 10:    //损坏
            
            item.backgroundColor = ColorR_G_B(255, 0, 44);
            [item setTitleColor:[UIColor whiteColor]
                       forState:UIControlStateNormal];
            break;
            
        default:    //1.空闲 9.闲置
            
            item.backgroundColor = ColorR_G_B(232, 232, 232);
            [item setTitleColor:ColorValue_RGB(0x929292)
                       forState:UIControlStateNormal];
            break;
    }
    
    
    
}




//适配

-(void)Zhang_layouts {
    
    
    CGFloat nameHeight = 0;
    if ([_type isEqualToString:@"1"] || [_type isEqualToString:@"4"]) {
        nameHeight = Vertical(60);
    }
    
    [_topLine YuanToSuper_Left:Horizontal(5)];
    [_topLine YuanToSuper_Top:Vertical(9) + NaviBarHeight];
    [_topLine autoSetDimensionsToSize:CGSizeMake(3, Vertical(12))];
    //odf
    if ([_type isEqualToString:@"1"] || [_type isEqualToString:@"4"]) {
        [_topTip autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:_topLine withOffset:Horizontal(5)];
        [_topTip YuanToSuper_Top:NaviBarHeight];
        [_topTip autoSetDimensionsToSize:CGSizeMake(Horizontal(30), Vertical(30))];
        
        [_topName YuanToSuper_Top:NaviBarHeight];
        [_topName autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:_topTip withOffset:Horizontal(5)];
        [_topName autoSetDimension:ALDimensionHeight toSize:Vertical(30)];
        [_topName YuanToSuper_Right:Horizontal(10)];
        
    }
    //其他不需要显示机房和odf
    else{
        [_topName YuanToSuper_Top:NaviBarHeight];
        [_topName autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:_topLine withOffset:Horizontal(5)];
        [_topName autoSetDimension:ALDimensionHeight toSize:Vertical(30)];
        [_topName YuanToSuper_Right:Horizontal(10)];
    }
    
    
    [_topDeviceView YuanToSuper_Top:NaviBarHeight +Vertical(30)];
    [_topDeviceView YuanToSuper_Left:0];
    [_topDeviceView YuanToSuper_Right:0];
    [_topDeviceView autoSetDimension:ALDimensionHeight toSize:Vertical(40) *7];
    
    
    if ([_type isEqualToString:@"1"] || [_type isEqualToString:@"4"]) {
        
        [_roomLine YuanToSuper_Left:Horizontal(5)];
        [_roomLine autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_topDeviceView withOffset:Vertical(9)];
        [_roomLine autoSetDimensionsToSize:CGSizeMake(3, Vertical(12))];
        
        [_roomTip autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:_roomLine withOffset:Horizontal(5)];
        [_roomTip autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_topDeviceView];
        [_roomTip autoSetDimensionsToSize:CGSizeMake(Horizontal(30), Vertical(30))];

        [_roomLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_topDeviceView];
        [_roomLabel autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:_roomTip withOffset:Horizontal(5)];
        [_roomLabel autoSetDimension:ALDimensionHeight toSize:Vertical(30)];
        [_roomLabel YuanToSuper_Right:Horizontal(30)];
        
        [_rightBtn YuanToSuper_Right:Horizontal(10)];
        [_rightBtn YuanAttributeHorizontalToView:_roomLabel];

        [_rightTouchBtn autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_topDeviceView];
        [_rightTouchBtn autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:_roomTip withOffset:0];
        [_rightTouchBtn autoSetDimension:ALDimensionHeight toSize:Vertical(30)];
        [_rightTouchBtn YuanToSuper_Right:Horizontal(10)];
        
        [_hLine autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_roomLabel withOffset:-1];
        [_hLine autoSetDimension:ALDimensionHeight toSize:1];
        [_hLine YuanToSuper_Right:0];
        [_hLine YuanToSuper_Left:0];
        
        
        [_bottomLine YuanToSuper_Left:Horizontal(5)];
        [_bottomLine autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_roomLabel withOffset:Vertical(9)];
        [_bottomLine autoSetDimensionsToSize:CGSizeMake(3, Vertical(12))];
        
        [_bottomTip autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:_bottomLine withOffset:Horizontal(5)];
        [_bottomTip autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_roomLabel];
        [_bottomTip autoSetDimensionsToSize:CGSizeMake(Horizontal(30), Vertical(30))];

        [_bottomName autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_roomLabel];
        [_bottomName autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:_bottomTip withOffset:Horizontal(5)];
        [_bottomName autoSetDimension:ALDimensionHeight toSize:Vertical(30)];
        [_bottomName YuanToSuper_Right:Horizontal(30)];
        
        [_bottomBtn YuanToSuper_Right:Horizontal(10)];
        [_bottomBtn YuanAttributeHorizontalToView:_bottomName];
        
        [_bottomTouchBtn autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_roomLabel];
        [_bottomTouchBtn autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:_bottomTip withOffset:Horizontal(0)];
        [_bottomTouchBtn autoSetDimension:ALDimensionHeight toSize:Vertical(30)];
        [_bottomTouchBtn YuanToSuper_Right:Horizontal(10)];
    }
    
    
    
    [_bottomDeviceView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_topDeviceView withOffset:nameHeight];
    [_bottomDeviceView YuanToSuper_Left:0];
    [_bottomDeviceView YuanToSuper_Right:0];
    [_bottomDeviceView autoSetDimension:ALDimensionHeight toSize:Vertical(40) *7 + Vertical(30)];//+30  包含模块选择高度

}


//resTypeId 转 resLogicName
-(NSString *)getResTypeName:(NSString *)resTypeId {
    
    NSString *resLogicName;
    
    if ([resTypeId isEqualToString:@"302"]) {
        resLogicName = @"ODF_Equt";
    }else if ([_type isEqualToString:@"703"]) {
        resLogicName = @"OCC_Equt";
    }else if ([_type isEqualToString:@"704"]) {
        resLogicName = @"ODB_Equt";
    }
    
    return resLogicName;
}





@end
