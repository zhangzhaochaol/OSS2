//
//  Yuan_NewFL_RouteVC.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/2/19.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_NewFL_RouteVC.h"

#import "Inc_NewFL_GisVC.h"
#import "Yuan_NewFL3_AlertDecayVC.h"    // 纤芯衰耗分解

#import "Yuan_FL_HeaderView.h"          //头视图
#import "Yuan_FL_IntervalView.h"        //分割线
#import "Yuan_NewFL_LinkCell.h"         //端子纤芯cell

// 业务
#import "Yuan_NewFL_HttpModel.h"
#import "Yuan_NewFL_VM.h"



@interface Yuan_NewFL_RouteVC ()<UITableViewDelegate , UITableViewDataSource>

/** 头视图 */
@property (nonatomic,strong) Yuan_FL_HeaderView *headerView;

/** 分割线 */
@property (nonatomic,strong) Yuan_FL_IntervalView *intervalView;

/** tableView */
@property (nonatomic , strong) UITableView * tableView;

/** 衰耗分解按钮 */
@property (nonatomic , strong) UIButton * decayBtn;

@end

@implementation Yuan_NewFL_RouteVC

{
    Yuan_NewFL_VM * _VM;
    NSArray * _dataSource;
}


#pragma mark - 初始化构造方法

- (instancetype)init {
    
    if (self = [super init]) {
        _VM = Yuan_NewFL_VM.shareInstance;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"局向光纤";
    
    if (!_routeId) {
        [YuanHUD HUDFullText:@"缺少局向光纤Id"];
        return;
    }
    
    [self naviBarSet];
    [self UI_Init];
    [self http_SelectRoute];
    
}




/// 根据局向光纤Id 查询下属局向光纤路由
- (void) http_SelectRoute {
    
    [Yuan_NewFL_HttpModel Http_SelectRouteFromId:_routeId
                                         success:^(id  _Nonnull result) {
    
        NSArray * arr = result;
        
        if (arr.count == 0 || !arr) {
            [YuanHUD HUDFullText:@"暂无数据"];
        }
        
        [self configData:arr.firstObject];
    }];
}



- (void) configData:(NSDictionary *) data {
    
    
    [_headerView reloadResName:data[@"pairNoDesc"] ?: @""];
    NSArray * optSectLogicRouteList = data[@"optSectLogicRouteList"];
    
    
    if (!optSectLogicRouteList || optSectLogicRouteList.count == 0) {
        [YuanHUD HUDFullText:@"暂无路由数据"];
    }
    
    _dataSource = optSectLogicRouteList;
    [_tableView reloadData];
    
}


- (void) reSelectDatas {
    [self http_SelectRoute];
}


- (void) http_routeDeletePort: (NSDictionary *) cellDict {
    
    NSMutableDictionary * swapTerm = NSMutableDictionary.dictionary;
    
    swapTerm[@"termId"] = cellDict[@"nodeId"] ?: @"";
    swapTerm[@"linkId"] = cellDict[@"pairId"] ?: @"";
    
    NSMutableArray * mt_Arr = NSMutableArray.array;
    for (NSDictionary * dict in _dataSource) {
        
        NSMutableDictionary * mt_CellDict = [NSMutableDictionary dictionaryWithDictionary:dict];
        
        mt_CellDict[@"routeId"] = _routeId;
        mt_CellDict[@"sequence"] = dict[@"sequence"];
        mt_CellDict[@"eptTypeId"] = dict[@"nodeTypeId"];
        mt_CellDict[@"eptId"] = dict[@"nodeId"];
        mt_CellDict[@"eptName"] = dict[@"nodeName"];
        mt_CellDict[@"relateResTypeId"] = dict[@"rootTypeId"];
        mt_CellDict[@"relateResId"] = dict[@"rootId"];
        mt_CellDict[@"relateResName"] = dict[@"rootName"];
        
        [mt_Arr addObject:mt_CellDict];
    }
    
    swapTerm[@"route"] = mt_Arr;
    
    
    
    [Yuan_NewFL_HttpModel Http2_DeleteRouterPoint:swapTerm
                                           isLink:NO
                                          success:^(id  _Nonnull result) {
        [self reSelectDatas];
    }];
}



#pragma mark - delegate ---

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataSource.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    
    NSDictionary * cellDict = _dataSource[indexPath.row];
    
    Yuan_NewFL_LinkCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Yuan_NewFL_LinkCell"];
    
    
    if (!cell) {
        cell = [[Yuan_NewFL_LinkCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:@"Yuan_NewFL_LinkCell"];
    }
    
    cell.selectionStyle = 0;
    
    [cell reloadRouteData:cellDict];
    
    return cell;
    
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary * cellDict = _dataSource[indexPath.row];
    NSString * eptName = cellDict[@"nodeName"];
    NSString * relateResName = cellDict[@"rootName"];
    
    
    NSInteger length = eptName.length + relateResName.length;
    
    if (length <= 50) {
        return Vertical(90);
    }
    
    else if (length > 50 && length <= 80) {
        return Vertical(150);
    }
    else {
        return Vertical(200);
    }
    
    
    return Vertical(90);
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}




- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSDictionary * cellDict = _dataSource[indexPath.row];
    
    UITableViewRowAction * deleteRouter =
    [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal
                                       title:@"移除"
                                     handler:^(UITableViewRowAction * _Nonnull action,
                                               NSIndexPath * _Nonnull indexPath) {

        
        [UIAlert alertSmallTitle:@"是否移除路由节点"
                   agreeBtnBlock:^(UIAlertAction *action) {
            
            [self http_routeDeletePort:cellDict];
        }];
    }];
    
    deleteRouter.backgroundColor = ColorValue_RGB(0xE46262);
    
    return @[deleteRouter];
}


/// 查看对应的Gis地图
- (void) GisClick {
    
    Inc_NewFL_GisVC * gis = [[Inc_NewFL_GisVC alloc] initWithEnum:NewFL_Gis_Route
                                                             dict:@{@"Id" : _routeId}];
    
    Push(self, gis);
}


/// 衰耗分解按钮
- (void) decayClick {
    
    Yuan_NewFL3_AlertDecayVC * vc = [[Yuan_NewFL3_AlertDecayVC alloc] initWithArray:_dataSource];
    self.definesPresentationContext = true;
    
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    
    // [UIApplication sharedApplication].keyWindow.rootViewController
    [self presentViewController:vc animated:NO completion:^{
        
        // 只让 view半透明 , 但其上方的其他view不受影响
        vc.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    }];
}


#pragma mark - UI ---

- (void) UI_Init {
    
    _tableView = [UIView tableViewDelegate:self
                             registerClass:[Yuan_NewFL_LinkCell class]
                       CellReuseIdentifier:@"Yuan_NewFL_LinkCell"];
    
    
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _headerView = Yuan_FL_HeaderView.alloc.init;
    
    NSString * interTitle = @"局向光纤";
    
    _intervalView = [[Yuan_FL_IntervalView alloc] initWithTitle:interTitle];
    
    _decayBtn = [UIView buttonWithImage:@"FL_Decsy"
                              responder:self
                              SEL_Click:@selector(decayClick)
                                  frame:CGRectNull];
    
    [self.view addSubviews:@[_tableView,_headerView,_intervalView,_decayBtn]];
    [self yuan_LayoutSubViews];
}

- (void) yuan_LayoutSubViews {
        
    float limit = Horizontal(15);
    
    [_headerView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:NaviBarHeight];
    [_headerView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    [_headerView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [_headerView autoSetDimension:ALDimensionHeight toSize:Vertical(70)];
    
    [_intervalView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_headerView withOffset:limit];
    [_intervalView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [_intervalView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    [_intervalView autoSetDimension:ALDimensionHeight toSize:Vertical(50)];
    
    [_tableView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_intervalView withOffset:limit];
    [_tableView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [_tableView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    [_tableView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:BottomZero + Vertical(80)];
    
    if (Yuan_NewFL_VM.isFiberDecay == true) {
        
        [_decayBtn YuanToSuper_Right:limit];
        [_decayBtn YuanToSuper_Bottom:BottomZero + 15];
        [_decayBtn Yuan_EdgeSize:CGSizeMake(Vertical(40), Vertical(40))];
        
    }
    
    
    
    
}

- (void) naviBarSet {
    

    
    UIBarButtonItem * Gis = [UIView getBarButtonItemWithTitleStr:@"Gis"
                                                             Sel:@selector(GisClick)
                                                              VC:self];
    
    self.navigationItem.rightBarButtonItems = @[Gis];

    
}

@end
