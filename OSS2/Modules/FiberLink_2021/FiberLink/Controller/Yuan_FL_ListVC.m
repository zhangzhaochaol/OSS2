//
//  Yuan_FL_ListVC.m
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/12/1.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_FL_ListVC.h"

#import "Yuan_FL_HeaderView.h"          //头视图
#import "Yuan_FL_LinkChooseView.h"      //光链路切换
#import "Yuan_FL_IntervalView.h"        //分割线


#import "Yuan_FL_ListCell.h"


#import "Yuan_FL_HttpModel.h"
#import "Inc_Push_MB.h"

@interface Yuan_FL_ListVC ()

<
    UITableViewDelegate ,
    UITableViewDataSource
>

/** 头视图 */
@property (nonatomic,strong) Yuan_FL_HeaderView *headerView;

/** 光链路切换 */
@property (nonatomic,strong) Yuan_FL_LinkChooseView *linkChooseView;

/** 分割线 */
@property (nonatomic,strong) Yuan_FL_IntervalView *intervalView;

/** tableView */
@property (nonatomic,strong) UITableView *tableView;

@end

@implementation Yuan_FL_ListVC
{
    
    
    // 是光纤 还是光链路
    FL_InitType_ _type;
    
    NSString * _myTitle;
    
    // 返回结果
    NSDictionary * _resultDict;
    
    // 路由数据 -- 光纤
    NSArray * _fiberRouteSource;
    
    // 路由总数据 -- 光路
    NSArray * _linkRouteSource;
    
    // 切换光路数据
    NSMutableArray * _nowLinkSource;
}



#pragma mark - 初始化构造方法

- (instancetype) initWithEnum:(FL_InitType_)type {
    
    if (self = [super init]) {
        _type = type;
        
        if (type == FL_InitType_OpticalLink) {
            _myTitle = @"光纤光路";
            _nowLinkSource = NSMutableArray.array;
        }
        else {
            _myTitle = @"局向光纤";
        }
    }
    return self;
}




- (void)viewDidLoad {
    
    [super viewDidLoad];

//    if (!_opticTermId) {
//        [[Yuan_HUD shareInstance] HUDFullText:@"缺少必要的GID字段"];
//        return;
//    }
    
    [self UI_Init];
    [self block_Init];
    
    
    self.view.backgroundColor = ColorValue_RGB(0xf2f2f2);
    
    self.title = _myTitle;
    
    
    // 局向纤芯
    if (_type == FL_InitType_OpticalFiber) {
        [_headerView reloadHeaderName:@"局向光纤"];
        [self http_fiberPort];
    }
    // 光链路
    else {
        [_headerView reloadHeaderName:@"光纤光路"];
        [self http_linkPort];
    }
}



#pragma mark -  http  ---


// 局向纤芯
- (void) http_fiberPort {
    
    NSMutableDictionary * postDict = NSMutableDictionary.dictionary;
    
    postDict[@"nodeId"] = _opticTermId;
    
    [Yuan_FL_HttpModel HTTP_FL_GetOpticalFiber:postDict
                                       success:^(id  _Nonnull result) {
        
        _resultDict = result;
        
        _fiberRouteSource = result[@"routers"];
        
        NSString * pairName = result[@"optLogicPairName"];
        
        [_headerView reloadResName:pairName ?: @""];
        
        if (_fiberRouteSource.count == 0) {
            [[Yuan_HUD shareInstance] HUDFullText:@"未查询到路由信息"];
        }
        
        else {
            [_tableView reloadData];
        }
        
    }];
    
    
}


// 光链路
- (void) http_linkPort {
    
    NSMutableDictionary * postDict = NSMutableDictionary.dictionary;
    // 090007020000000119031571 双芯
    // 090003170000000035817886 单芯
    postDict[@"currentEptId"] = _opticTermId;
    
    [Yuan_FL_HttpModel HTTP_FL_GetOpticalLink:postDict
                                      success:^(id  _Nonnull result) {
        
        _resultDict = result;
        
        // 光链路切换 , 判断是单芯还是双芯
        NSArray * optPairLinkList = result[@"optPairLinkList"];
        
        // 资源名
        [_headerView reloadResName:result[@"optRoadName"]];

        // 路由 , 如果是双芯的话 , 会区分
        _linkRouteSource = result[@"optPariRouterList"];
        
        
        if (!_linkRouteSource) {
            [[Yuan_HUD shareInstance] HUDFullText:@"暂无数据"];
        }
        
        
        // 当前资源所在光路的ID  也就是在一芯 还是 二芯  与 optPairLinkList里的linkId做比较
        NSString * currentOptPairLinkId = result[@"currentOptPairLinkId"];
        
        // 当前资源所在的数据库索引 , 与 optPariRouterList 里的 sequence 比较
//        NSString * currentOptPairRouterSequence = result[@"currentOptPairRouterSequence"];
        
        for (NSDictionary * singleDict in _linkRouteSource) {
            if ([singleDict[@"linkId"] isEqualToString:currentOptPairLinkId]) {
                [_nowLinkSource addObject:singleDict];
            }
        }
        
        // 重置光链路选项
        [_linkChooseView reloadLink:optPairLinkList
               currentOptPairLinkId:currentOptPairLinkId];
        
        [_tableView reloadData];
    }];
    
}



- (void) http_GetResWithDict:(NSDictionary *)dict {
    
    
    
    
    [Yuan_FL_HttpModel HTTP_FL_GetResWithDict:dict
                                      success:^(id  _Nonnull result) {
            
        
        NSDictionary * resDict = result[0];
        
        if (!resDict || [resDict obj_IsNull]) {
            [[Yuan_HUD shareInstance] HUDFullText:@"数据源错误"];
            return ;
        }
        
        NSString * resLogicName = resDict[@"resLogicName"];
        
        //TODO 智网通跳转
        [Inc_Push_MB pushFrom:self
                  resLogicName:resLogicName
                          dict:resDict
                          type:TYKDeviceListUpdate];
        
    }];
    
}





#pragma mark -  delegate  ---

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    
    if (_type == FL_InitType_OpticalFiber) {
        
        return _fiberRouteSource.count;
    }
    else {
        return _nowLinkSource.count;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Yuan_FL_ListCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Yuan_FL_ListCell"];
    
    if (!cell) {
        cell = [[Yuan_FL_ListCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:@"Yuan_FL_ListCell"];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSDictionary * dict ;
    
    // 局向光纤
    if (_type == FL_InitType_OpticalFiber) {
        
        //currentRouterSequence
        
        NSString * currentRouterSequence = _resultDict[@"currentRouterSequence"];
        dict = _fiberRouteSource[indexPath.row];
        
        NSString * sequence = dict[@"sequence"];
        
        if ([currentRouterSequence isEqualToString:sequence]) {
            [cell isCurrentDevice:YES];
        }
        else {
            [cell isCurrentDevice:NO];
        }
        
        
        [cell reload_FiberDict:dict];
    }
    // 光链路
    else {
        
        
        NSString * currentEptId = _resultDict[@"currentEptId"];
        dict = _nowLinkSource[indexPath.row];
        
        NSString * cellEptId = dict[@"eptId"];
        
        if ([currentEptId isEqualToString:cellEptId]) {
            [cell isCurrentDevice:YES];
        }
        else {
            [cell isCurrentDevice:NO];
        }
        
        [cell reload_LinkDict:dict];
    }
    
    return cell;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return Vertical(120);
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return;
    
    Yuan_FL_ListCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (!cell.deviceId || [cell.deviceId isEqualToString:@""]) {
        [[Yuan_HUD shareInstance] HUDFullText:@"缺少必要的Id字段"];
        return;
    }
    
    
    NSDictionary * dict;
    
    if (_type == FL_InitType_OpticalFiber) {
        dict = _fiberRouteSource[indexPath.row];
    }
    else {
        dict = _nowLinkSource[indexPath.row];
    }
    
    NSLog(@"-- %@",dict);
    
    //http_GetResWithDict
    
    
    NSDictionary * myPostDict = @{@"resLogicName" : cell.resLogicName,
                                  @"GID" : cell.deviceId
    };
    
    // 点击 发送网络请求
    [self http_GetResWithDict:myPostDict];
}





#pragma mark -  block_Init  ---

- (void) block_Init {
    
    __typeof(self)wself = self;
    _linkChooseView.chooseId_Block = ^(NSString * _Nonnull linkId, int now_LinkNum) {
        [wself->_nowLinkSource removeAllObjects];
        
        for (NSDictionary * singleDict in wself->_linkRouteSource) {
            if ([singleDict[@"linkId"] isEqualToString:linkId]) {
                [wself->_nowLinkSource addObject:singleDict];
            }
        }
        [wself->_tableView reloadData];
    };
}



#pragma mark -  UI  ---

- (void) UI_Init {
    
    _tableView = [UIView tableViewDelegate:self
                             registerClass:[Yuan_FL_ListCell class]
                       CellReuseIdentifier:@"Yuan_FL_ListCell"];
    
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _headerView = Yuan_FL_HeaderView.alloc.init;
    
    _linkChooseView = Yuan_FL_LinkChooseView.alloc.init;
    
    NSString * interTitle ;
    
    if (_type == FL_InitType_OpticalLink) {
        interTitle = @"光链路路由";
    }
    else {
        interTitle = @"局向光纤路由";
    }
    
    _intervalView = [[Yuan_FL_IntervalView alloc] initWithTitle:interTitle];
    
    [self.view addSubviews:@[_tableView,_headerView,_linkChooseView,_intervalView]];
    
    [self yuan_layoutAllSubViews];
}


#pragma mark - 屏幕适配

- (void) yuan_layoutAllSubViews {
    
    float limit = Horizontal(15);
    
    [_headerView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:NaviBarHeight];
    [_headerView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    [_headerView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [_headerView autoSetDimension:ALDimensionHeight toSize:Vertical(100)];
    
    
    [_linkChooseView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [_linkChooseView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    
    if (_type == FL_InitType_OpticalLink) {
        [_linkChooseView autoSetDimension:ALDimensionHeight toSize:50];
        [_linkChooseView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_headerView withOffset:limit];
    }
    else {
        [_linkChooseView autoSetDimension:ALDimensionHeight toSize:0];
        [_linkChooseView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_headerView withOffset:0];
        _linkChooseView.hidden = YES;
    }
    
    [_intervalView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_linkChooseView withOffset:0];
    [_intervalView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [_intervalView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    [_intervalView autoSetDimension:ALDimensionHeight toSize:Vertical(50)];
    
    [_tableView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_intervalView withOffset:0];
    [_tableView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [_tableView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    [_tableView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:BottomZero];


}



@end
