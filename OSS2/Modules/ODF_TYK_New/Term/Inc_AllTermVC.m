//
//  Inc_AllTermVC.m
//  OSS2.0-ios-v2
//
//  Created by zzc on 2021/6/16.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_AllTermVC.h"
#import "Inc_AlltermCell.h"
#import "Inc_headCell.h"

#import "MLMenuView.h"               // 下拉列表

#import "Inc_NewFL_HttpModel1.h"

//端子
#import "Inc_BusDeviceView.h"
#import "Inc_BusScrollItem.h"
#import "Inc_Push_MB.h"

//全部端子view
#import "Inc_BusAllColumnView.h"

//titleView
#import "Inc_DeviceTitleView.h"



@interface Inc_AllTermVC ()
<
    UIScrollViewDelegate,
    MLMenuViewDelegate,
    Yuan_BusDevice_ItemDelegate,
    UITableViewDelegate,
    UITableViewDataSource
>
{
        
    //黑色透明背景view
    UIView *_windowBgView;
    
    //选中的dic  光路、光缆段、承载业务单独使用
    NSDictionary *_selectDic;
    
    //详情按钮前view
    UIView *_lineView;
    //head底部横线
    UIView *_hlineView;
    //名称
    NSString * _resLogicName;
    
    
    //示例图
    UIImageView *_examplesImage;
    //存放光缆段或者承载业务
    UIView *_headCableView;
    
    //选择菜单index
    NSInteger _menuIndex;
    
    
    //光缆段或承载业务
    UIView *_headCView;
    //光缆段或承载业务名称
    UILabel *_hLable;
    UIButton *_detailBtnC;
    UIView *_headL;
    
    
    
    //查看级别
    UIScrollView *_levelScrollView;
    //一干
    NSMutableArray *_levelArray1;
    //二杆
    NSMutableArray *_levelArray2;
    //本地网
    NSMutableArray *_levelArray3;
    //接入段
    NSMutableArray *_levelArray4;
    
    //一干-反
    NSMutableArray *_levelArray1B;
    //二杆-反
    NSMutableArray *_levelArray2B;
    //本地网-反
    NSMutableArray *_levelArray3B;
    //接入段-反
    NSMutableArray *_levelArray4B;
    

    
    //一干 二干 本地网  接入段对应数量  正/反
    NSArray *_levelCountArray;
    NSArray *_levelCountArrayB;

    //存放级别btn
    NSMutableArray *_levelBtn;
    
    
    //存储正面还是反面  yes：反
    BOOL _isBack;
    //当前选中哪个btn
    NSInteger _levelIndex;
    
    
//    //记录上一个选择的菜单是否是 光缆段和承载业务 默认不是
//    BOOL  _menuIndexLast;
    
    //光缆段和承载业务共存
    UIView *_headAllView;
    //光缆段名称
    UILabel *_cableLable;
    UIButton *_cableDetailBtn;
    UIView *_cableL;
    
    //承载业务名称
    UILabel *_bearLable;
    UIButton *_bearDetailBtn;
    UIView *_bearL;
    
    /*
     光缆段和承载业务共存使用
     */
    //选中的dic 光缆段选中数据
    NSDictionary *_selectDicCable;
    //选中的dic 承载业务选中数据
    NSDictionary *_selectDicBear;

}


//光路
@property (nonatomic, strong) UIView *headView;
@property (nonatomic, strong) UITableView *headTableView;
//关联该光路的端子列表
@property (nonatomic, strong) NSMutableArray *headArray;

//光路列表
@property (nonatomic, strong) UITableView *tableView;
//光路列表data
@property (nonatomic, strong) NSMutableArray *dataArray;
//光缆段列表data
@property (nonatomic, strong) NSMutableArray *cableArray;
//承载业务列表data
@property (nonatomic, strong) NSMutableArray *carryingArray;

/**
 弹出菜单
 */
@property (nonatomic, strong) MLMenuView * menu;


//全部端子盘
@property (nonatomic, strong) Inc_BusAllColumnView *busAllColumnView;

@property (nonatomic, strong) Inc_DeviceTitleView *titleView;
@end

@implementation Inc_AllTermVC

#pragma mark - 懒加载

-(NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}


-(NSMutableArray *)headArray {
    if (!_headArray) {
        _headArray = [NSMutableArray array];
    }
    return _headArray;
}



#pragma mark - life

- (void)viewDidLoad {
    [super viewDidLoad];

    _menuIndex = 0;
//    _menuIndexLast = NO;
    
    _resLogicName = @"opticalPath";
    
    [self setUpTitleView];

    //光路列表
    [self.view addSubview:self.tableView];
   
    [self initArray];
    
    //titleView
    [self naviSet];
    
    [self.view addSubview:self.busAllColumnView];
    

    //window 黑色
    [self setWindowBgView];
    _windowBgView.hidden = YES;
    _tableView.hidden = YES;
    _examplesImage.hidden = YES;
    
    
    //查询设备下端子成端、光路、跳纤状态
//    [self Http_GetTermSData:@{
//        @"id":self.deviceId,
//        @"type":[self getType:self.type]
//    }];
    //head
    [self setUpHeadView];
    [self setUpHeadCView];
    [self setUpHeadLevelView];
    [self setUpHeadAllView];


    [self Zhang_Layouts];
}

//光缆段或承载业务
- (void)setUpHeadCView {
    _headCView= [UIView viewWithColor:UIColor.whiteColor];
    _headCView.frame = CGRectMake(0, NaviBarHeight, ScreenWidth, Vertical(40));
    
    _detailBtnC = [UIView buttonWithTitle:@"详情" responder:self SEL:@selector(headCBtnClick) frame:CGRectMake(ScreenWidth - 55, Vertical(10), 40, Vertical(20))];
    _detailBtnC.titleLabel.font = Font_Yuan(15);
    _detailBtnC.tag = 10101;
    [_detailBtnC setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [_detailBtnC setBackgroundColor: ColorR_G_B(254, 124, 124)];
    [_detailBtnC setCornerRadius:3 borderColor:UIColor.clearColor borderWidth:1];
    
    _hLable = [UIView labelWithTitle:@"" isZheH:YES];
    _hLable.frame = CGRectMake(10, 0, ScreenWidth - 65, _headCView.height);
    _hLable.font = Font_Yuan(15);
    _hLable.textColor = UIColor.blackColor;
    
    _headL = [UIView viewWithColor:UIColor.groupTableViewBackgroundColor];
    _headL.frame = CGRectMake(_hLable.width, 0, 1, _headCView.height);
    
    UIView *headH = [UIView viewWithColor:UIColor.groupTableViewBackgroundColor];
    headH.frame = CGRectMake(0, _headCView.height-1, ScreenWidth, 1);

    
    
    [self.view addSubview:_headCView];

    [_headCView addSubviews:@[_hLable,_headL,_detailBtnC,headH]];
    
    [self hideHeadCView];
}

//级别
- (void)setUpHeadLevelView{
    
    CGFloat width = (ScreenWidth - Horizontal(20) - Horizontal(30))/4;

    
    _levelScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, NaviBarHeight, ScreenWidth, 40)];
//    _levelScrollView.backgroundColor = [UIColor greenColor];
    _levelScrollView.contentSize = CGSizeMake(_levelCountArray.count * width + Horizontal(50), 40);
    _levelScrollView.bounces = YES;
    _levelScrollView.indicatorStyle = UIScrollViewIndicatorStyleDefault;
    //设置是否只允许横向或纵向（YES）滚动，默认允许双向
//    _levelScrollView.directionalLockEnabled = YES;
    _levelScrollView.bouncesZoom = YES;
    //设置委托
    _levelScrollView.delegate = self;
    
    [self.view addSubview:_levelScrollView];
    
    for (int i = 0; i<_levelCountArray.count; i++) {
        
        UIButton *levelBtn = [UIView buttonWithTitle:[NSString stringWithFormat:@"%@",_levelCountArray[i]] responder:self SEL:@selector(levelBtnClick:) frame:CGRectMake(Horizontal(10) +(width + Horizontal(10))*i, 8, width, 24)];
        levelBtn.tag = 100100+i;
      
        [levelBtn setBackgroundColor:UIColor.groupTableViewBackgroundColor];
        [levelBtn setTitleColor:HexColor(@"#bbbbbb") forState:UIControlStateNormal];
        [levelBtn setCornerRadius:3 borderColor:HexColor(@"#bbbbbb") borderWidth:1];

        levelBtn.titleLabel.font = Font_Yuan(13);
        
        [_levelScrollView addSubview:levelBtn];
        
        if (i == 0) {
            [self levelBtnClick:levelBtn];
        }
        
        [_levelBtn addObject: levelBtn];
    }
    
    UIView *lineView = [UIView viewWithColor:UIColor.groupTableViewBackgroundColor];
    lineView.frame = CGRectMake(0, _levelScrollView.height-1, _levelScrollView.width, 1);
    
    [_levelScrollView addSubview:lineView];
    
    
    [self hideLevelView];
}

//光缆段或承载业务
- (void)setUpHeadAllView {
    
    _headAllView= [UIView viewWithColor:UIColor.whiteColor];
    _headAllView.frame = CGRectMake(0, NaviBarHeight, ScreenWidth, Vertical(40)*2);
    
    _cableDetailBtn = [UIView buttonWithTitle:@"详情" responder:self SEL:@selector(headCBtnClick) frame:CGRectMake(ScreenWidth - 55, Vertical(10), 40, Vertical(20))];
    _cableDetailBtn.titleLabel.font = Font_Yuan(15);
    _cableDetailBtn.tag = 10201;
    [_cableDetailBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [_cableDetailBtn setBackgroundColor: ColorR_G_B(254, 124, 124)];
    [_cableDetailBtn setCornerRadius:3 borderColor:UIColor.clearColor borderWidth:1];
    
    _cableLable = [UIView labelWithTitle:@"" isZheH:YES];
    _cableLable.frame = CGRectMake(10, 0, ScreenWidth - 65, _headAllView.height/2);
    _cableLable.font = Font_Yuan(15);
    _cableLable.textColor = UIColor.blackColor;
    
    _cableL = [UIView viewWithColor:UIColor.groupTableViewBackgroundColor];
    _cableL.frame = CGRectMake(_cableLable.width, 0, 1, _cableLable.height);
    
    UIView *headH1 = [UIView viewWithColor:UIColor.groupTableViewBackgroundColor];
    headH1.frame = CGRectMake(0, _cableLable.height-1, ScreenWidth, 1);

    
    _bearDetailBtn = [UIView buttonWithTitle:@"详情" responder:self SEL:@selector(headCBtnClick) frame:CGRectMake(ScreenWidth - 55, _cableLable.height + 1 +Vertical(10), 40, Vertical(20))];
    _bearDetailBtn.titleLabel.font = Font_Yuan(15);
    _bearDetailBtn.tag = 10202;
    [_bearDetailBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [_bearDetailBtn setBackgroundColor: ColorR_G_B(254, 124, 124)];
    [_bearDetailBtn setCornerRadius:3 borderColor:UIColor.clearColor borderWidth:1];
    
    _bearLable = [UIView labelWithTitle:@"" isZheH:YES];
    _bearLable.frame = CGRectMake(10, _cableLable.height, ScreenWidth - 65, _headAllView.height/2);
    _bearLable.font = Font_Yuan(15);
    _bearLable.textColor = UIColor.blackColor;
    
    _bearL = [UIView viewWithColor:UIColor.groupTableViewBackgroundColor];
    _bearL.frame = CGRectMake(_bearLable.width, _cableLable.height, 1, _bearLable.height);
    
    UIView *headH2 = [UIView viewWithColor:UIColor.groupTableViewBackgroundColor];
    headH2.frame = CGRectMake(0, _bearLable.height + _bearLable.origin.y -1, ScreenWidth, 1);

    
    [self.view addSubview:_headAllView];

    [_headAllView addSubviews:@[_cableLable,
                              _cableL,
                              _cableDetailBtn,
                              headH1,
                              _bearLable,
                              _bearL,
                              _bearDetailBtn,
                              headH2]];
    
    [self hideHeadAllView];
    

}

//光路使用
- (void)setUpHeadView {
    
    _headView = [UIView viewWithColor:UIColor.whiteColor];
    _headView.frame = CGRectMake(0, NaviBarHeight, ScreenWidth, 70);
    
    
    UIButton *detailBtn = [UIView buttonWithTitle:@"详情" responder:self SEL:@selector(headBtnClick:) frame:CGRectMake(ScreenWidth - 55, 15, 40, 20)];
    detailBtn.titleLabel.font = Font_Yuan(15);
    detailBtn.tag = 10010;
    [detailBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [detailBtn setBackgroundColor: ColorR_G_B(254, 124, 124)];
    [detailBtn setCornerRadius:3 borderColor:UIColor.clearColor borderWidth:1];
    
    UIButton *closeBtn = [UIView buttonWithTitle:@"关闭" responder:self SEL:@selector(headBtnClick:) frame:CGRectMake(detailBtn.x, detailBtn.y + detailBtn.height + 10, detailBtn.width, detailBtn.height)];
    closeBtn.titleLabel.font = Font_Yuan(15);
    closeBtn.tag = 10011;
    [closeBtn setTitleColor:UIColor.lightGrayColor forState:UIControlStateNormal];
    [closeBtn setBackgroundColor:ColorR_G_B(249, 249, 249)];
    [closeBtn setCornerRadius:3 borderColor:UIColor.clearColor borderWidth:1];

    _headTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth - 65, 30 + _headArray.count * 30 + 10) style:UITableViewStyleGrouped];
    _headTableView.backgroundColor = UIColor.whiteColor;
    _headTableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    _headTableView.rowHeight = 30;
    _headTableView.delegate = self;
    _headTableView.dataSource = self;
    
    _lineView = [UIView viewWithColor:UIColor.groupTableViewBackgroundColor];
    _lineView.frame = CGRectMake(_headTableView.width, 0, 1, _headView.height);
    
    _hlineView = [UIView viewWithColor:UIColor.groupTableViewBackgroundColor];
    _hlineView.frame = CGRectMake(0, self.headView.height-1 ,ScreenWidth ,1);
    
    [self.view addSubview:self.headView];
    [self.headView addSubviews:@[detailBtn,closeBtn,_headTableView,_lineView,_hlineView]];
    [self hideHeadView];
}

-(Inc_BusAllColumnView *)busAllColumnView {
    
    if (!_busAllColumnView) {
        WEAK_SELF;
        
        CGRect frame = CGRectMake(0, NaviBarHeight, ScreenWidth, ScreenHeight - 20);
        
        _busAllColumnView =
        [[Inc_BusAllColumnView alloc] initWithFrame:frame
                                             isPush:YES
                                  requestDataSource:_requestDataSource
                                     busDevice_Enum:Yuan_BusDeviceEnum_Normal
                                       busHttp_Enum:Yuan_BusHttpPortEnum_New
                                                 vc:self];
        

        _busAllColumnView.httpSuccessBlock = ^{
            [wself termLevel];
//            [wself termErgodic];
        };
        
    }
    return _busAllColumnView;
}

//黑色透明背景和异常table
-(void)setWindowBgView {
    _windowBgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    _windowBgView.backgroundColor = [UIColor colorWithRed:30/255.0 green:30/255.0 blue:30/255.0 alpha:0.4];
    _windowBgView.userInteractionEnabled = YES;
  

    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapEvent:)];
    [_windowBgView addGestureRecognizer:tap];
    
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    [window addSubview:_windowBgView];
    
    
    [_windowBgView addSubview:self.tableView];
    
    
    _examplesImage = [UIView imageViewWithImg:[UIImage Inc_imageNamed:@"zhang_examples_icon"] frame:CGRectMake(0, 0, ScreenWidth - Horizontal(80), ScreenWidth - Horizontal(80))];
    _examplesImage.center = self.view.center;
    UITapGestureRecognizer * imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapEvent:)];
    [_windowBgView addGestureRecognizer:imageTap];
    
    
    [_windowBgView addSubview:_examplesImage];

    
}


/// 导航栏右侧按钮
- (void) naviSet {
    
    // 导航栏右侧按钮
    
    UIBarButtonItem * rightBarBtn =
    [UIView getBarButtonItemWithImageName:@"icon_pplist_gongneng"
                                      Sel:@selector(rightBarBtnClick)
                                       VC:self];
    
    self.navigationItem.rightBarButtonItems = @[rightBarBtn];
}



// 导航栏右侧按钮 点击事件
- (void) rightBarBtnClick {
    
    [self.menu showMenuEnterAnimation:MLAnimationStyleTop];
}

//光路table
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectNull style:UITableViewStyleGrouped];
        _tableView.backgroundColor = UIColor.whiteColor;
        _tableView.rowHeight = 44;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        [_tableView setCornerRadius:10 borderColor:UIColor.clearColor borderWidth:1];
    }
    return _tableView;
}


// 添加titleView
- (void)setUpTitleView {
        
    _titleView = [[Inc_DeviceTitleView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 44)];
    WEAK_SELF;
    _titleView.btnClickBlock = ^(BOOL isJust) {
        
        [wself titleBntClick:isJust];
    };
    
    self.navigationItem.titleView = _titleView;
    
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
 
    if (tableView == _headTableView) {
        return self.headArray.count;
    }
    if (_menuIndex == 0) {
        return self.dataArray.count;

    }else if (_menuIndex == 1) {
        return self.cableArray.count;

    }else if (_menuIndex == 2) {
        return self.carryingArray.count;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView == _headTableView) {
        
        static NSString *cellIdentifier = @"Inc_headCell";
        
        Inc_headCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) {
            cell = [[Inc_headCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
  
        cell.dic = self.headArray[indexPath.row];
        cell.typeName = @"端子";
        return cell;
    }else{
        static NSString *cellIdentifier = @"Zhang_AbnormalCell";
        
        Inc_AlltermCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) {
            cell = [[Inc_AlltermCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        WEAK_SELF;
       
        if (_menuIndex == 0) {
            cell.labelBlock = ^(UILabel * _Nonnull label) {
                label.textColor = UIColor.redColor;
                _selectDic = wself.dataArray[indexPath.row];
                wself.headArray  = _selectDic[@"nodeList"];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [wself closeBtnClick];
                    [wself showHeadView];
                });
            };
            cell.dic = self.dataArray[indexPath.row];

        }else if (_menuIndex == 1) {
            [self hideHeadCView];

            cell.cableDic = self.cableArray[indexPath.row];
            cell.labelBlock = ^(UILabel * _Nonnull label) {
                label.textColor = UIColor.redColor;
                _selectDic = wself.cableArray[indexPath.row];
                _selectDicCable = wself.cableArray[indexPath.row];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [wself closeBtnClick];
                    if (self.carryingArray.count>0) {
                        [wself showHeadAllView];
                    }else{
                        [wself showHeadCView];
                    }
                });
            };

        }else if (_menuIndex == 2) {
            [self hideHeadCView];

            cell.carryingDic = self.carryingArray[indexPath.row];
            cell.labelBlock = ^(UILabel * _Nonnull label) {
                label.textColor = UIColor.redColor;
                _selectDic = wself.carryingArray[indexPath.row];
                _selectDicBear = wself.carryingArray[indexPath.row];

                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [wself closeBtnClick];
                    if (self.cableArray.count>0) {
                        [wself showHeadAllView];
                    }else{
                        [wself showHeadCView];
                    }
                });
            };

        }

        return cell;
    }
    
    return nil;
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return  UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView == _headTableView) {
        CGFloat height = [_selectDic[@"optRoadName"] boundingRectWithSize:CGSizeMake(ScreenWidth - 20 - 50-5, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:Font_Bold_Yuan(15)} context:nil].size.height;
        return MAX(height, 30);
    }
    return 44;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (tableView == _headTableView) {
        return 10;
    }
    return 0.0001;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableView == _headTableView) {
        CGFloat height = [_selectDic[@"optRoadName"] boundingRectWithSize:CGSizeMake(ScreenWidth - 20 - 50-5, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:Font_Bold_Yuan(15)} context:nil].size.height;
        UIView *sectionHeadView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _tableView.frame.size.width, MAX(height, 30))];
        sectionHeadView.backgroundColor = UIColor.whiteColor;
        
        UILabel *contentLabel = [UIView labelWithTitle:_selectDic[@"optRoadName"] frame:CGRectMake(10, 0, ScreenWidth - 20 - 50 , sectionHeadView.frame.size.height)];
        contentLabel.textColor = UIColor.blackColor;
        contentLabel.font = Font_Bold_Yuan(15);
        
        [sectionHeadView addSubview:contentLabel];
        
        return sectionHeadView;
    }else{
        UIView *sectionHeadView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _tableView.frame.size.width, 44)];
        sectionHeadView.backgroundColor = UIColor.whiteColor;
        
        UIView *lineLabel = [UIView viewWithColor:Color_V2Red];
        lineLabel.frame = CGRectMake(10, 14, 3, 16);
        
        [sectionHeadView addSubview:lineLabel];
        
        NSString *title;
        if (_menuIndex == 0) {
            title = @"光路列表";
        }else if(_menuIndex == 1){
            title = @"光缆段列表";
        }else if(_menuIndex == 2){
            title = @"承载业务列表";
        }
        
        UILabel *contentLabel = [UIView labelWithTitle:title frame:CGRectMake(20, 0, 200 , sectionHeadView.frame.size.height)];
        contentLabel.textColor = UIColor.blackColor;
        contentLabel.font = Font_Bold_Yuan(15);
        
        [sectionHeadView addSubview:contentLabel];
        
        UIButton *coloseBtn = [UIView buttonWithImage:@"icon_guanbi" responder:self SEL_Click:@selector(closeBtnClick) frame:CGRectMake(sectionHeadView.frame.size.width - 44, 0, 44, 44)];
        
        [sectionHeadView addSubview:coloseBtn];
        
        
        return sectionHeadView;
    }
   
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (tableView == _headTableView) {
        UIView *footer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.width, 10)];
        footer.backgroundColor = UIColor.whiteColor;
        return footer;
    }
    return nil;
}



#pragma mark ---  下拉列表代理  ---

- (void)menuView:(MLMenuView *)menu didselectItemIndex:(NSInteger)index {
    
    [self hideHeadView];
    [self hideLevelView];
    [self hideHeadAllView];
    [self clearHightLight];
    
    
    _menuIndex = index;
//    _menuIndexLast = NO;

    //当点击光缆段和承载业务时
    if (_menuIndex == 1 || _menuIndex == 2) {

    }else{
        [self hideHeadCView];
    }
    
    
    // 根据不同的index 跳转到不同的控制器
    switch (index) {
        case 0:
            if (_dataArray.count > 0) {
                _windowBgView.hidden = NO;
                _tableView.hidden = NO;
                [self Zhang_Layouts];

                [self.tableView reloadData];
                
            }else{
                //查看光路
                [self Http_SelectRoadInfoByEqpId:@{
                    @"id":self.deviceId,
                    @"type":[self getType:self.type]
                }];
            }
          
            break;
        
        case 1:
            if (_cableArray.count > 0) {
                _windowBgView.hidden = NO;
                _tableView.hidden = NO;
                [self Zhang_Layouts];

                [self.tableView reloadData];
                
            }else{
                //查看光缆段
                [self Http_GetOpeSectAndPort:@{
                    @"id":self.deviceId,
                    @"type":[self getType:self.type]
                }];
            }
            
            break;
            
            
        case 2:
            if (_carryingArray.count > 0) {
                _windowBgView.hidden = NO;
                _tableView.hidden = NO;
                [self Zhang_Layouts];

                [self.tableView reloadData];
            }else{
                //查看承载业务
                [self Http_GetCircuitAndPort:@{
                    @"id":self.deviceId,
                    @"type":[self getType:self.type]
                }];
            }
           
            break;
            
        case 3:
            //查看级别
            [self showLevelView];
            [self setBtnTitleCount:_levelCountArray];
            
            break;
        case 4:
            //查看图例
            _windowBgView.hidden = NO;
            _examplesImage.hidden = NO;
           
            break;
       
                       
                        
        default:
            break;
    }
    
    
    
}



// 下拉菜单
-(MLMenuView *)menu {
    
    if (_menu == nil) {
      
        NSArray * menuItems;
        NSArray * photoArryas;
        
        if (v_HLJ) {
            menuItems = @[
                @"查看光路"];


            photoArryas = @[
                @"zzc_guanglu"];
        }else{
            menuItems = @[
                                    @"查看光路",
                                    @"查看光缆段",
                                    @"查看承载业务",
                                    @"查看级别",
                                    @"端子图例"];


            photoArryas = @[
                                      @"zzc_guanglu",
                                      @"zzc_guanglan",
                                      @"zzc_yewu",
                                      @"zzc_jibie",
                                      @"zzc_tuli"];
        }
        
      
        
        
        float menuWidth = IphoneSize_Width(100);
        
        CGRect menuRect =  CGRectMake(ScreenWidth - menuWidth - 10,
                                      0,
                                      menuWidth,
                                      0);
        
        MLMenuView * menuView =
        [[MLMenuView alloc] initWithFrame:menuRect
                               WithTitles:menuItems
                           WithImageNames:photoArryas
                    WithMenuViewOffsetTop:NaviBarHeight
                   WithTriangleOffsetLeft:menuWidth - 10
                            triangleColor:UIColor.whiteColor];
        
        
        _menu = menuView;
        
        menuView.separatorOffSet = 0;
        menuView.separatorColor = HexColor(@"#eee");
        [menuView brightColor:UIColor.lightGrayColor radius:10 offset:CGSizeMake(2, 2) opacity:1.f];
        [menuView setMenuViewBackgroundColor:[UIColor whiteColor]];
        menuView.titleColor = [UIColor colorWithHexString:@"#333"];
        menuView.font = [UIFont systemFontOfSize:12];
        
        [menuView setCoverViewBackgroundColor:UIColor.clearColor];
        menuView.delegate = self;
    }
    
    return _menu;
    
}



#pragma mark -btnClick

- (void)titleBntClick:(BOOL )isShowJust {
    
    _busAllColumnView.isShowJust = isShowJust;

    if (isShowJust) {
        _isBack = NO;
        [self setBtnTitleCount:_levelCountArray];
        
    }else{
        _isBack = YES;
        [self setBtnTitleCount:_levelCountArrayB];
       
    }
    
}

//关闭异常table  清理数组
- (void)closeBtnClick{

    _windowBgView.hidden = YES;
    _tableView.hidden  = YES;
    _examplesImage.hidden  = YES;
}

//需要点击背景隐藏 打开
-(void)tapEvent:(UITapGestureRecognizer *)gesture {

    _windowBgView.hidden = YES;
    _tableView.hidden  = YES;
    _examplesImage.hidden  = YES;

}

//点击示例图片关闭
-(void)imageTapEvent:(UITapGestureRecognizer *)gesture {
    _windowBgView.hidden = YES;
    _examplesImage.hidden  = YES;
    _tableView.hidden  = YES;
}



//光路详情和关闭按钮点击
- (void)headBtnClick:(UIButton *)btn {
    if (btn.tag == 10011) {
        [self hideHeadView];
    }else{
        //push详情
        [self GetDetailWithGID:_selectDic[@"optRoadId"] block:^(NSDictionary *dict) {
            
            // TODO 智网通模板跳转
            // 跳转模板
            [Inc_Push_MB pushFrom:self
                      resLogicName:[NSString stringWithFormat:@"%@",_resLogicName]
                              dict:dict
                              type:TYKDeviceListUpdate];
             
        }];
        
    }
}

//光缆段和承载业务（电路）详情
- (void)headCBtnClick {
    
    NSDictionary *dict = @{
        
        @"resLogicName" : @"cable",
        @"GID" : _selectDic[@"gid"]
    };
    
    [[Http shareInstance] V2_POST:HTTP_TYK_Normal_Get
                             dict:dict
                          succeed:^(id data) {
        
        NSArray * arr = data;
        
        if (!arr || arr.count == 0) {
            return;
        }
        
        [Inc_Push_MB NewMB_PushDetailsFromId:_selectDic[@"gid"]
                                        Enum:Yuan_NewMB_ModelEnum_optSect
                                          vc:self];
    }];
}

-(void)levelBtnClick:(UIButton*)sender {
    
    static UIButton *lastBtn;
    
    UIButton *btn = (UIButton *)sender;
    if (lastBtn != btn) {
        
        [btn setTitleColor:HexColor(@"#ff4d4c") forState:UIControlStateNormal];
        [btn setCornerRadius:3 borderColor:HexColor(@"#ff4d4c") borderWidth:1];
        [btn setBackgroundColor:UIColor.whiteColor];


        [lastBtn setBackgroundColor:UIColor.groupTableViewBackgroundColor];
        [lastBtn setTitleColor:HexColor(@"#bbbbbb") forState:UIControlStateNormal];
        [lastBtn setCornerRadius:3 borderColor:HexColor(@"#bbbbbb") borderWidth:1];

        lastBtn = btn;
    }
    
    _levelIndex = btn.tag;
    
    [self ergodicLevel:_levelIndex];
    
}

- (void)ergodicLevel:(NSInteger)integer {
   
 
    [self clearHightLight];
    
    switch (integer) {
        case 100100:
            if (_isBack) {
                [self levelHight:_levelArray1B isHighLight:YES isBack:_isBack];
            }else{
                [self levelHight:_levelArray1 isHighLight:YES isBack:_isBack];
            }
          
            break;
        case 100101:
            if (_isBack) {
                [self levelHight:_levelArray2B isHighLight:YES isBack:_isBack];
            }else{
                [self levelHight:_levelArray2 isHighLight:YES isBack:_isBack];
            }
            
            break;
        case 100102:
            if (_isBack) {
                [self levelHight:_levelArray3B isHighLight:YES isBack:_isBack];
            }else{
                [self levelHight:_levelArray3 isHighLight:YES isBack:_isBack];
            }
            
            break;
        case 100103:
            if (_isBack) {
                [self levelHight:_levelArray4B isHighLight:YES isBack:_isBack];
            }else{
                [self levelHight:_levelArray4 isHighLight:YES isBack:_isBack];
            }
            
            break;
        default:
            break;
    }
    
}

//取消所有高亮状态
-(void)clearHightLight {
    
    for (Inc_BusDeviceView *deviceView in [_busAllColumnView getDeviceViewJustArray]) {
        NSMutableArray *array = [NSMutableArray array];
        for (Inc_BusScrollItem *itemAll in [deviceView getBtns]) {
            [array addObject:itemAll.terminalId];
        }
        [self levelHight:array isHighLight:NO isBack:NO];
    }
    for (Inc_BusDeviceView *deviceView in [_busAllColumnView getDeviceViewBackArray]) {
        NSMutableArray *array = [NSMutableArray array];
        for (Inc_BusScrollItem *itemAll in [deviceView getBtns]) {
            [array addObject:itemAll.terminalId];
        }
        [self levelHight:array isHighLight:NO isBack:YES];
    }
}

#pragma mark - 显示/隐藏
//光路
- (void)showHeadView {
    
    [self.headTableView reloadData];
    
    CGFloat height = [_selectDic[@"optRoadName"] boundingRectWithSize:CGSizeMake(ScreenWidth - 20 - 50-10, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:Font_Bold_Yuan(15)} context:nil].size.height;

    _headTableView.frame = CGRectMake(0, 0, ScreenWidth - 65, MAX(height, 30) + _headArray.count * 44);
    _headView.frame = CGRectMake(0, NaviBarHeight, ScreenWidth, _headTableView.height);
    _lineView.frame = CGRectMake(_headTableView.width, 0, 1, _headView.height);
    _hlineView.frame = CGRectMake(0, _headView.height-1 ,ScreenWidth ,1);

    _busAllColumnView.frame =  CGRectMake(0, _headView.height + _headView.y, ScreenWidth, ScreenHeight - 20);

    [self termHighlight:YES];

    
    _headView.hidden = NO;
    _headTableView.hidden = NO;
}

- (void)hideHeadView {

    [self termHighlight:NO];

    
    _busAllColumnView.frame =  CGRectMake(0, NaviBarHeight, ScreenWidth, ScreenHeight - 20);

    _headView.hidden = YES;
    _headTableView.hidden = YES;
}

//光缆段或承载
- (void)hideHeadCView  {
    
    [self termHighlightCable:NO];
    _busAllColumnView.frame =  CGRectMake(0, NaviBarHeight, ScreenWidth, ScreenHeight - 20);

    _headCView.hidden = YES;

}

//光缆段和承载
- (void)hideHeadAllView  {
    
    [self termHighlightCableAndBear:NO];
    _busAllColumnView.frame =  CGRectMake(0, NaviBarHeight, ScreenWidth, ScreenHeight - 20);

    _headAllView.hidden = YES;

}

//查看光缆段和承载业务
- (void)showHeadAllView {

    _cableLable.text = _selectDicCable[@"resName"];
    _bearLable.text = _selectDicBear[@"resName"];

    _busAllColumnView.frame =  CGRectMake(0, _headAllView.height + _headAllView.y, ScreenWidth, ScreenHeight - 20);

    [self termHighlightCableAndBear:YES];

    _headAllView.hidden = NO;
    

    _bearDetailBtn.hidden = YES;
    _bearL.hidden = YES;
    
    
}

//查看光缆段或承载业务
- (void)showHeadCView {

    _hLable.text = _selectDic[@"resName"];
    
    _busAllColumnView.frame =  CGRectMake(0, _headCView.height + _headCView.y, ScreenWidth, ScreenHeight - 20);

    [self termHighlightCable:YES];

    _headCView.hidden = NO;
    
    if (_menuIndex == 2) {
        _detailBtnC.hidden = YES;
        _headL.hidden = YES;
    }else{
        _detailBtnC.hidden = NO;
        _headL.hidden = NO;
    }
}


//查看级别
- (void)hideLevelView {
    _busAllColumnView.frame =  CGRectMake(0, NaviBarHeight, ScreenWidth, ScreenHeight - 20);

    _levelScrollView.hidden = YES;
}

- (void)showLevelView {
    
    _busAllColumnView.frame =  CGRectMake(0, _levelScrollView.height + _levelScrollView.y, ScreenWidth, ScreenHeight - 20);
   
    _levelScrollView.hidden = NO;
}

#pragma mark -转换

-(NSString *)getType:(NSString *)str {
    
    NSString *type;
    
    switch ([str integerValue]) {
        case 1:
            type = @"rackOdf";
            break;
        case 2:
            type = @"optConnectBox";

            break;
        case 3:
            type = @"optJntBox";

            break;
        case 4:
            type = @"complexBox";

            break;
            
        default:
            type = @"";
            
            break;
    }
    
    return type;
}

#pragma mark -http

//根据设备ID查询光缆段接口
- (void)Http_GetOpeSectAndPort:(NSDictionary *)param  {
    
    [Inc_NewFL_HttpModel1 Http_GetOpeSectAndPort:param success:^(id  _Nonnull result) {
        
        if (result) {
            NSArray *array = result;
            if (array.count == 0) {
                [[Yuan_HUD shareInstance] HUDFullText:@"没有光缆段信息"];
                
                if(_carryingArray.count > 0) {
                    _busAllColumnView.frame =  CGRectMake(0, _headCView.height + _headCView.y, ScreenWidth, ScreenHeight - 20);
                }

                return;
            }else{
                
                [self.cableArray removeAllObjects];
                [self.cableArray addObjectsFromArray:array];
                
                _windowBgView.hidden = NO;
                _tableView.hidden = NO;

         
                [self Zhang_Layouts];
                
                [self.tableView reloadData];

            }
        }
    }];
    
}

//根据设备ID查询承载业务接口
- (void)Http_GetCircuitAndPort:(NSDictionary *)param {
    [Inc_NewFL_HttpModel1 Http_GetCircuitAndPort:param success:^(id  _Nonnull result) {
        
        if (result) {
            NSArray *array = result;
            if (array.count == 0) {
                [[Yuan_HUD shareInstance] HUDFullText:@"没有承载业务信息"];
                if(_cableArray.count > 0) {
                    _busAllColumnView.frame =  CGRectMake(0, _headCView.height + _headCView.y, ScreenWidth, ScreenHeight - 20);
                }
                
                return;
            }else{
                
                [self.carryingArray removeAllObjects];
                [self.carryingArray addObjectsFromArray:array];
                
                _windowBgView.hidden = NO;
                _tableView.hidden = NO;

                [self Zhang_Layouts];
                
                [self.tableView reloadData];

            }
        }
    }];
}

//查询设备下端子成端、光路、跳纤状态
- (void)Http_GetTermSData:(NSDictionary *)param {
    
    [Inc_NewFL_HttpModel1 Http_GetTermSData:param success:^(id result) {
       
        if (result) {
            
            NSArray *arr  =result;
            if (arr.count > 0) {
    
                //列框
                for (NSDictionary *rowDic in arr) {
                    //3050001 正面       3050002 反面     3050005 无
                    if ([rowDic[@"faceInverse"] isEqualToString:@"3050002"]) {
                        //列框的一行
                        for (NSDictionary *dic in rowDic[@"rmeModuleList"]) {
                            
                            //行的一个端子
                            for (NSDictionary *termDic in dic[@"opticTerms"]) {
                            
                                NSArray *cdArr = termDic[@"opticTermList"];
                              
                                if (cdArr.count >0) {
                                    
                                    NSDictionary *dic = cdArr[0];
                                    //一干 7000112一干
                                    if ([dic[@"optLevel"] isEqualToString:@"7000112"]) {
                                        [_levelArray1B addObject:termDic[@"termId"]];
                                    }
                                    //二干 7000113二干
                                    else if ([dic[@"optLevel"] isEqualToString:@"7000113"] ){
                                        [_levelArray2B addObject:termDic[@"termId"]];
                                    }
                                    //本地网  7000124本地中继
                                    else if ([dic[@"optLevel"] isEqualToString:@"7000124"] ){
                                        [_levelArray3B addObject:termDic[@"termId"]];
                                    }
                                    //接入段 7000122本地主干（ODF-光交） 7000107本地联络（光交设备间） 7000123本地配线（光交以下光设备间） 7000125本地引入（光设备到用户）
                                    else{
                                        [_levelArray4B addObject:termDic[@"termId"]];
                                    }
                                }
                                
                             
//                                NSArray *cdArr = termDic[@"opticTermList"];
//                                NSArray *lightArr = termDic[@"optPairRouterList"];
//                                NSArray *jumpArr = termDic[@"optLineRelationList"];
//
//                                if (cdArr.count > 0) {
//                                    [_chengduanArrayB addObject:termDic[@"termId"]];
//                                }
//
//                                if (lightArr.count > 0) {
//                                    [_lightArrayB addObject:termDic[@"termId"]];
//                                }
//                                if (jumpArr.count > 0) {
//                                    [_jumpArrayB addObject:termDic[@"termId"]];
//                                }
                            }
                        }
                    }else{
                        //列框的一行
                        for (NSDictionary *dic in rowDic[@"rmeModuleList"]) {
                                                        
                            //行的一个端子
                            for (NSDictionary *termDic in dic[@"opticTerms"]) {
                            
                                NSArray *cdArr = termDic[@"opticTermList"];
                              
                                if (cdArr.count >0) {
                                    
                                    NSDictionary *dic = cdArr[0];
                                    //一干 7000112一干
                                    if ([dic[@"optLevel"] isEqualToString:@"7000112"]) {
                                        [_levelArray1 addObject:termDic[@"termId"]];
                                    }
                                    //二干 7000113二干
                                    else if ([dic[@"optLevel"] isEqualToString:@"7000113"] ){
                                        [_levelArray2 addObject:termDic[@"termId"]];
                                    }
                                    //本地网  7000124本地中继
                                    else if ([dic[@"optLevel"] isEqualToString:@"7000124"] ){
                                        [_levelArray3 addObject:termDic[@"termId"]];
                                    }
                                    //接入段 7000122本地主干（ODF-光交） 7000107本地联络（光交设备间） 7000123本地配线（光交以下光设备间） 7000125本地引入（光设备到用户）
                                    else{
                                        [_levelArray4 addObject:termDic[@"termId"]];
                                    }
                                }
                                
                                
//                                NSArray *cdArr = termDic[@"opticTermList"];
//                                NSArray *lightArr = termDic[@"optPairRouterList"];
//                                NSArray *jumpArr = termDic[@"optLineRelationList"];
//
//                                if (cdArr.count > 0) {
//                                    [_chengduanArray addObject:termDic[@"termId"]];
//                                }
//
//                                if (lightArr.count > 0) {
//                                    [_lightArray addObject:termDic[@"termId"]];
//                                }
//                                if (jumpArr.count > 0) {
//                                    [_jumpArray addObject:termDic[@"termId"]];
//                                }
                            }
                        }
                    }
                    
                }
                
            }
            
        }

        _levelCountArray = @[[NSString stringWithFormat:@"一干:%lu",(unsigned long)_levelArray1.count],
                             [NSString stringWithFormat:@"二干:%lu",(unsigned long)_levelArray2.count],
                             [NSString stringWithFormat:@"本地网:%lu",(unsigned long)_levelArray3.count],
                             [NSString stringWithFormat:@"接入段:%lu",(unsigned long)_levelArray4.count]];
        _levelCountArrayB = @[[NSString stringWithFormat:@"一干:%lu",(unsigned long)_levelArray1B.count],
                              [NSString stringWithFormat:@"二干:%lu",(unsigned long)_levelArray2B.count],
                              [NSString stringWithFormat:@"本地网:%lu",(unsigned long)_levelArray3B.count],
                              [NSString stringWithFormat:@"接入段:%lu",(unsigned long)_levelArray4B.count]];

    }];
   
}
//查看级别
- (void)termLevel {
    
    //使用端子
    for (Inc_BusDeviceView *deviceView in [_busAllColumnView getDeviceViewJustArray]) {
        
        for (Inc_BusScrollItem *itemAll in [deviceView getBtns]) {
           
            if (itemAll.opticTermList.count > 0) {

                    NSDictionary *dic = itemAll.opticTermList[0];
                    //一干 7000112一干
                    if ([dic[@"optLevel"] isEqualToString:@"7000112"]) {
                        [_levelArray1 addObject:itemAll.terminalId];
                    }
                    //二干 7000113二干
                    else if ([dic[@"optLevel"] isEqualToString:@"7000113"] ){
                        [_levelArray2 addObject:itemAll.terminalId];
                    }
                    //本地网  7000124本地中继
                    else if ([dic[@"optLevel"] isEqualToString:@"7000124"] ){
                        [_levelArray3 addObject:itemAll.terminalId];
                    }
                    //接入段 7000122本地主干（ODF-光交） 7000107本地联络（光交设备间） 7000123本地配线（光交以下光设备间） 7000125本地引入（光设备到用户）
                    else{
                        [_levelArray4 addObject:itemAll.terminalId];
                    }

            }
            
        }
                
    }
    
    
    for (Inc_BusDeviceView *deviceView in [_busAllColumnView getDeviceViewBackArray]) {
        
        for (Inc_BusScrollItem *itemAll in [deviceView getBtns]) {
            if (itemAll.opticTermList.count > 0) {

                NSDictionary *dic = itemAll.opticTermList[0];
                //一干 7000112一干
                if ([dic[@"optLevel"] isEqualToString:@"7000112"]) {
                    [_levelArray1B addObject:itemAll.terminalId];
                }
                //二干 7000113二干
                else if ([dic[@"optLevel"] isEqualToString:@"7000113"] ){
                    [_levelArray2B addObject:itemAll.terminalId];
                }
                //本地网  7000124本地中继
                else if ([dic[@"optLevel"] isEqualToString:@"7000124"] ){
                    [_levelArray3B addObject:itemAll.terminalId];
                }
                //接入段 7000122本地主干（ODF-光交） 7000107本地联络（光交设备间） 7000123本地配线（光交以下光设备间） 7000125本地引入（光设备到用户）
                else{
                    [_levelArray4B addObject:itemAll.terminalId];
                }
                
            }
            
        }
    }
    
    _levelCountArray = @[[NSString stringWithFormat:@"一干:%lu",(unsigned long)_levelArray1.count],
                         [NSString stringWithFormat:@"二干:%lu",(unsigned long)_levelArray2.count],
                         [NSString stringWithFormat:@"本地网:%lu",(unsigned long)_levelArray3.count],
                         [NSString stringWithFormat:@"接入段:%lu",(unsigned long)_levelArray4.count]];
    _levelCountArrayB = @[[NSString stringWithFormat:@"一干:%lu",(unsigned long)_levelArray1B.count],
                          [NSString stringWithFormat:@"二干:%lu",(unsigned long)_levelArray2B.count],
                          [NSString stringWithFormat:@"本地网:%lu",(unsigned long)_levelArray3B.count],
                          [NSString stringWithFormat:@"接入段:%lu",(unsigned long)_levelArray4B.count]];
    
}

//成端、光路、跳接遍历

-(void)termErgodic {
    
    
    //使用端子
    for (Inc_BusDeviceView *deviceView in [_busAllColumnView getDeviceViewJustArray]) {
        
        for (Inc_BusScrollItem *itemAll in [deviceView getBtns]) {
           
            if (itemAll.opticTermList.count > 0) {
                [itemAll Terminal_ChengD_Sympol_IsShow:YES];
            }
            
            if (itemAll.optLineRelationList.count > 0) {
                [itemAll Terminal_JumpFiber_Sympol_IsShow:YES];
            }
            
            if (itemAll.optPairRouterList.count > 0) {
                [itemAll Terminal_InFiberLink_Sympol_IsShow:YES];
            }
            
        }
                
    }
    
    for (Inc_BusDeviceView *deviceView in [_busAllColumnView getDeviceViewBackArray]) {
        
        for (Inc_BusScrollItem *itemAll in [deviceView getBtns]) {
            if (itemAll.opticTermList.count > 0) {
                [itemAll Terminal_ChengD_Sympol_IsShow:YES];
            }
            
            if (itemAll.optLineRelationList.count > 0) {
                [itemAll Terminal_JumpFiber_Sympol_IsShow:YES];
            }
            
            if (itemAll.optPairRouterList.count > 0) {
                [itemAll Terminal_InFiberLink_Sympol_IsShow:YES];
            }
        }
    }
    
    
//    return;
//
//    //根据接口请求返回数据
//    for (Inc_BusDeviceView *deviceView in _deviceViewJustArray) {
//
//        for (Inc_BusScrollItem *itemAll in [deviceView getBtns]) {
//            for (NSString *termId in _jumpArray) {
//                if ([itemAll.terminalId isEqualToString:termId]) {
//                    [itemAll Terminal_JumpFiber_Sympol_IsShow:YES];
//                }
//            }
//
//            for (NSString *termId in _chengduanArray) {
//                if ([itemAll.terminalId isEqualToString:termId]) {
//                    [itemAll Terminal_ChengD_Sympol_IsShow:YES];
//                }
//            }
//
//            for (NSString *termId in _lightArray) {
//                if ([itemAll.terminalId isEqualToString:termId]) {
//                    [itemAll Terminal_InFiberLink_Sympol_IsShow:YES];
//                }
//            }
//        }
//
//    }
//
//    for (Inc_BusDeviceView *deviceView in _deviceViewBackArray) {
//
//        for (Inc_BusScrollItem *itemAll in [deviceView getBtns]) {
//            for (NSString *termId in _jumpArrayB) {
//                if ([itemAll.terminalId isEqualToString:termId]) {
//                    [itemAll Terminal_JumpFiber_Sympol_IsShow:YES];
//                }
//            }
//
//            for (NSString *termId in _chengduanArrayB) {
//                if ([itemAll.terminalId isEqualToString:termId]) {
//                    [itemAll Terminal_ChengD_Sympol_IsShow:YES];
//                }
//            }
//
//            for (NSString *termId in _lightArrayB) {
//                if ([itemAll.terminalId isEqualToString:termId]) {
//                    [itemAll Terminal_InFiberLink_Sympol_IsShow:YES];
//                }
//            }
//
//        }
//
//
//    }

    
}

//级别高亮
-(void)levelHight:(NSArray *)array isHighLight:(BOOL)isHighLight isBack:(BOOL)isBack{
    
    if (isBack) {
        for (Inc_BusDeviceView *deviceView in [_busAllColumnView getDeviceViewBackArray]) {
            [deviceView letTerminal_Ids:array isHighLight:isHighLight];
        }
        
    }else{
        for (Inc_BusDeviceView *deviceView in [_busAllColumnView getDeviceViewJustArray]) {
            [deviceView letTerminal_Ids:array isHighLight:isHighLight];
        }
        
    }
   
}


//查询光路
- (void)Http_SelectRoadInfoByEqpId:(NSDictionary *)param {
    
    [Inc_NewFL_HttpModel1 Http_SelectRoadInfoByEqpId:param success:^(id  _Nonnull result) {
        
        if (result) {
            NSArray *array = result;
            if (array.count == 0) {
                [[Yuan_HUD shareInstance] HUDFullText:@"没有关联的光路"];
                return;
            }else{
                
                [self.dataArray removeAllObjects];
                [self.dataArray addObjectsFromArray:array];
                
                _windowBgView.hidden = NO;
                _tableView.hidden = NO;

         
                [self Zhang_Layouts];
                
                [self.tableView reloadData];

            }
        }
    }];
    
    
}

// 根据 Gid 和 reslogicName 获取 详细信息
- (void) GetDetailWithGID:(NSString *)GID
                    block:(void(^)(NSDictionary * dict))block{
    
    NSDictionary * dict = @{
        @"resLogicName" : _resLogicName,
        @"GID":GID
    };
    
    [Http.shareInstance V2_POST:HTTP_TYK_Normal_Get
                           dict:dict
                        succeed:^(id data) {
            
        NSArray * arr = data;
        
        if (arr.count > 0) {
            block(arr.firstObject);
        }
        
    }];
    
}

//光路遍历高亮
- (void)termHighlight:(BOOL)isHighLight {
    
    
    NSMutableArray *arr = [NSMutableArray array];
    
    for (NSDictionary *dic in self.headArray) {
        [arr addObject:dic[@"gid"]];
    }
    
    for (Inc_BusDeviceView *deviceView in [_busAllColumnView getDeviceViewJustArray]) {
        
        [deviceView letTerminal_Ids:arr isHighLight:isHighLight];

    }
    
    for (Inc_BusDeviceView *deviceView in [_busAllColumnView getDeviceViewBackArray]) {
        
        [deviceView letTerminal_Ids:arr isHighLight:isHighLight];

        
    }

    
}

//光缆段或承载遍历高亮
- (void)termHighlightCable:(BOOL)isHighLight {
    
    
    for (Inc_BusDeviceView *deviceView in [_busAllColumnView getDeviceViewJustArray]) {
        
        [deviceView letTerminal_Ids:_selectDic[@"ids"] isHighLight:isHighLight];

    }
    
    for (Inc_BusDeviceView *deviceView in [_busAllColumnView getDeviceViewBackArray]) {
        
        [deviceView letTerminal_Ids:_selectDic[@"ids"] isHighLight:isHighLight];

    }
    
}

//光缆段和承载遍历高亮
- (void)termHighlightCableAndBear:(BOOL)isHighLight {
    
    
    for (Inc_BusDeviceView *deviceView in [_busAllColumnView getDeviceViewJustArray]) {
        
        [deviceView letTerminal_Ids:_selectDicCable[@"ids"] isHighLight:isHighLight];
        [deviceView letTerminal_Ids:_selectDicBear[@"ids"] isHighLight:isHighLight];

    }
    
    for (Inc_BusDeviceView *deviceView in [_busAllColumnView getDeviceViewBackArray]) {
        
        [deviceView letTerminal_Ids:_selectDicCable[@"ids"] isHighLight:isHighLight];
        [deviceView letTerminal_Ids:_selectDicBear[@"ids"] isHighLight:isHighLight];

    }
 
    
  
    NSPredicate * filterPredicate_same = [NSPredicate predicateWithFormat:@"SELF IN %@",_selectDicCable[@"ids"]];
    NSArray * filter_no = [_selectDicBear[@"ids"] filteredArrayUsingPredicate:filterPredicate_same];

    //重复数据  两个都包涵的高亮处理
    NSLog(@"%@",filter_no);
    
    
    for (Inc_BusDeviceView *deviceView in [_busAllColumnView getDeviceViewJustArray]) {
        
        [deviceView letTerminal_IdsCableAndBear:filter_no isHighLight:isHighLight];

    }
    
    for (Inc_BusDeviceView *deviceView in [_busAllColumnView getDeviceViewBackArray]) {
        
        [deviceView letTerminal_IdsCableAndBear:filter_no isHighLight:isHighLight];

    }
 
    
}

//级别按钮赋值
- (void)setBtnTitleCount:(NSArray *)array {
    
    for (UIButton *btn  in _levelBtn) {
        [btn setTitle:array[btn.tag - 100100] forState:UIControlStateNormal];
    }
    
    [self ergodicLevel:_levelIndex];
    
}



- (void)initArray {
    
    _cableArray = [NSMutableArray array];
    _carryingArray = [NSMutableArray array];
    
    //查看级别
    _levelArray1 = [NSMutableArray array];
    _levelArray2 = [NSMutableArray array];
    _levelArray3 = [NSMutableArray array];
    _levelArray4 = [NSMutableArray array];
    _levelArray1B = [NSMutableArray array];
    _levelArray2B = [NSMutableArray array];
    _levelArray3B = [NSMutableArray array];
    _levelArray4B = [NSMutableArray array];
        
    _levelBtn  = [NSMutableArray array];
    
    _levelCountArray = @[@"一干:0",@"二干:0",@"本地网:0",@"接入段:0"];
}




#pragma mark - 适配

- (void)Zhang_Layouts {
        
    CGFloat height;
    
    if (_menuIndex == 0) {
        height = MIN(44 * _dataArray.count + 44 + 20, ScreenHeight - NaviBarHeight);

    }else if (_menuIndex == 1) {
        height = MIN(44 * _cableArray.count + 44 + 20, ScreenHeight - NaviBarHeight);

    }else if (_menuIndex == 2) {
        height = MIN(44 * _carryingArray.count + 44 + 20, ScreenHeight - NaviBarHeight);

    }else{
        height = MIN(44 * _dataArray.count + 44 + 20, ScreenHeight - NaviBarHeight);

    }
    _tableView.frame = CGRectMake(0, ScreenHeight - height, ScreenWidth, height);

}



@end
