//
//  Inc_CFListLightVC.m
//  OSS2.0-ios-v2
//
//  Created by zzc on 2021/6/17.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_CFListLightVC.h"
#import "Inc_headCell.h"

#import "Inc_BusCableFiberView.h"  //纤芯




#import "Yuan_CFConfigVM.h"

//#import "Yuan_NewFL_VM.h"

// 新模板跳转
#import "Inc_NewMB_Presenter.h"
#import "Inc_NewMB_DetailVC.h"
#import "Inc_Push_MB.h"


@interface Inc_CFListLightVC ()<UITableViewDelegate,UITableViewDataSource>{
    
    //详情按钮前view
    UIView *_lineView;
    //head底部横线
    UIView *_hlineView;

    //名称
    NSString * _resLogicName;
        
    Yuan_CFConfigVM *_VM;
    
}

//光路
@property (nonatomic, strong) UIView *headView;
@property (nonatomic, strong) UITableView *headTableView;
//关联该光路的端子列表
@property (nonatomic, strong) NSMutableArray *headArray;

/** 光缆段纤芯 */
@property (nonatomic , strong) Inc_BusCableFiberView * busCable;


@end

@implementation Inc_CFListLightVC

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    _VM.handleConfig_State =  CF_ConfigHandle_None;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    _VM = Yuan_CFConfigVM.shareInstance;

    
    self.title = @"光路展示";
    _resLogicName = @"opticalPath";
    self.headArray = [NSMutableArray array];
    self.headArray = self.selectDic[@"nodeList"];
    //head
    [self setUpHeadView];
    

    _busCable = [[Inc_BusCableFiberView alloc] initWithCableData:_moban_Dict];
    _busCable.vc = self;
    _busCable.busCableEnum = Yuan_BusCableEnum_NewFL;
//    _VM.handleConfig_State =  CF_ConfigHandle_NOSelectClick;
    
    _busCable.isControlFibers_HighLight = YES;
    
    
    [self.view addSubview:_busCable];
    
    [self pariHighlight:YES];
    
    [self Zhang_layoutSubviews];
    
    
    // 纤芯的点击事件 通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fiberClick:)
                                                 name:BusCableSubFiberClickNotification
                                               object:nil];
    
 
}


//初始化header
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
    _hlineView.frame = CGRectMake(0, _headView.height-1 ,ScreenWidth ,1);

    
    [self.view addSubview:self.headView];
    [self.headView addSubviews:@[detailBtn,closeBtn,_headTableView,_lineView,_hlineView]];
    [self showHeadView];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.headArray.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    static NSString *cellIdentifier = @"Inc_headCell";
    
    Inc_headCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[Inc_headCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.dic = self.headArray[indexPath.row];
    cell.typeName = @"纤芯";
    return cell;
    
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return  UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {

    CGFloat height = [_selectDic[@"optRoadName"] boundingRectWithSize:CGSizeMake(ScreenWidth - 20 - 50-5, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:Font_Bold_Yuan(15)} context:nil].size.height;

    return MAX(height, 30);
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
 
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGFloat height = [_selectDic[@"optRoadName"] boundingRectWithSize:CGSizeMake(ScreenWidth - 20 - 50-5, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:Font_Bold_Yuan(15)} context:nil].size.height;
    
    UIView *sectionHeadView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, MAX(height, 30))];
    sectionHeadView.backgroundColor = UIColor.whiteColor;
    
    UILabel *contentLabel = [UIView labelWithTitle:_selectDic[@"optRoadName"] frame:CGRectMake(10, 0, ScreenWidth - 10 - 50 , sectionHeadView.frame.size.height)];
    contentLabel.textColor = UIColor.blackColor;
    contentLabel.font = Font_Bold_Yuan(15);
    
    [sectionHeadView addSubview:contentLabel];
    
    return sectionHeadView;
    
    
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    UIView *footer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.width, 10)];
    footer.backgroundColor = UIColor.whiteColor;
    return footer;
    
}



- (void)headBtnClick:(UIButton *)btn {
    if (btn.tag == 10011) {
        [self hideHeadView];
    }else{
        //push详情
        [self GetDetailWithGID:_selectDic[@"optRoadId"] block:^(NSDictionary *dict) {
            
            /*
            // 跳转模板
            [Inc_Push_MB pushFrom:self
                      resLogicName:[NSString stringWithFormat:@"%@",_resLogicName]
                              dict:dict
                              type:TYKDeviceListUpdate];
             */
        }];
        
    }
}


- (void)showHeadView {
    
    [self.headTableView reloadData];
    CGFloat height = [_selectDic[@"optRoadName"] boundingRectWithSize:CGSizeMake(ScreenWidth - 20 - 50-10, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:Font_Bold_Yuan(15)} context:nil].size.height;

    _headTableView.frame = CGRectMake(0, 0, ScreenWidth - 65, MAX(height, 30) + _headArray.count * 44);
    _headView.frame = CGRectMake(0, NaviBarHeight + 1, ScreenWidth, _headTableView.height);
    _lineView.frame = CGRectMake(_headTableView.width, 0, 1, _headView.height);
    _hlineView.frame = CGRectMake(0, _headView.height-1 ,ScreenWidth ,1);
    
}

- (void)hideHeadView {
    
    [self.navigationController popViewControllerAnimated:YES];
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



// 纤芯点击事件
- (void) fiberClick:(NSNotification *) noti {
    
    NSDictionary * dict = noti.userInfo;

    [self push_NewMB:dict];
}

/// 新增 走大为新模板的接口 2021.6.23
- (void) push_NewMB:(NSDictionary *) dict {
    
    if (dict.allKeys.count == 0) {
        
        Inc_NewMB_Presenter * presenter = Inc_NewMB_Presenter.presenter;
        presenter.cableLength = _moban_Dict[@"cableSectionLength"];
        
        Inc_NewMB_DetailVC * vc = [[Inc_NewMB_DetailVC alloc] initWithDict:@{} Yuan_NewMB_ModelEnum:Yuan_NewMB_ModelEnum_optPair];
        
        Push(self, vc);
        
        return;
    }
    
    // 根据id 请求详细信息
    [Inc_Push_MB NewMB_GetDetailDictFromGid:dict[@"pairId"]
                                        Enum:Yuan_NewMB_ModelEnum_optPair
                                     success:^(NSDictionary * _Nonnull dict) {
       
        Inc_NewMB_Presenter * presenter = Inc_NewMB_Presenter.presenter;
        presenter.cableLength = _moban_Dict[@"cableSectionLength"];
        
        Inc_NewMB_DetailVC * vc = [[Inc_NewMB_DetailVC alloc] initWithDict:dict Yuan_NewMB_ModelEnum:Yuan_NewMB_ModelEnum_optPair];
        
        Push(self, vc);
    }];
}




//遍历高亮
- (void)pariHighlight:(BOOL)isHighLight  {
    
    NSMutableArray *arr = [NSMutableArray array];
    
    for (NSDictionary *dic in self.headArray) {
        [arr addObject:dic[@"gid"]];
    }
    [_busCable letFiber_Ids:arr isHighLight:isHighLight];
    
}


//适配
- (void)Zhang_layoutSubviews {
    
    [_busCable YuanToSuper_Left:0];
    [_busCable YuanToSuper_Right:0];
    [_busCable YuanToSuper_Bottom:20];
    
    [_busCable YuanMyEdge:Top ToViewEdge:Bottom ToView:_headView inset:1];
    
}

@end
