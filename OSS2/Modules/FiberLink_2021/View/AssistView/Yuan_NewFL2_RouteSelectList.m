//
//  Yuan_NewFL2_RouteSelectList.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/10/29.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_NewFL2_RouteSelectList.h"
#import "Yuan_NewFL_LinkVC.h"

#import "Yuan_NewFL2_AlertWindow.h"

#import "Yuan_NewFL_HttpModel.h"
#import "Yuan_NewFL_VM.h"

@interface Yuan_NewFL2_RouteSelectList () <UITableViewDelegate , UITableViewDataSource>

/** tableView */
@property (nonatomic , strong) UITableView * tableView;
@end

@implementation Yuan_NewFL2_RouteSelectList

{
    
    NSArray * _datas;
    
    NSDictionary * _postDict;
    
    Yuan_NewFL2_AlertWindow * _alertWindow;
    
    NSDictionary * _cellDict;
    
    Yuan_NewFL_VM * _VM;
}


#pragma mark - 初始化构造方法

/// 单设备进行查询
- (instancetype)initWithEqpId:(NSString *) eqpId
                    eqpTypeId:(NSString *)eqpTypeId {
    
    if (self = [super init]) {
        
        _postDict = @{@"eqpId" : eqpId,
                      @"eqpTypeId" : eqpTypeId};
    }
    return self;
}


/// 双设备进行查询
- (instancetype)initWithEqpIdA:(NSString *)eqpIdA
                    eqpTypeIdA:(NSString *)eqpTypeIdA
                        eqpIdZ:(NSString *)eqpIdZ
                    eqpTypeIdZ:(NSString *)eqpTypeIdZ  {
    
    if (self = [super init]) {
        

        
        _postDict = @{@"aeqpId" : eqpIdA,
                      @"aeqpTypeId" : eqpTypeIdA,
                      @"zeqpId" : eqpIdZ,
                      @"zeqpTypeId" : eqpTypeIdZ,
        };
        
    }
    return self;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    _VM = Yuan_NewFL_VM.shareInstance;

    _tableView = [UIView tableViewDelegate:self registerClass:[UITableViewCell class] CellReuseIdentifier:@"UITableViewCell"];
    
    [self.view addSubview:_tableView];
    [_tableView Yuan_Edges:UIEdgeInsetsMake(NaviBarHeight, 0, 0, 0)];
    
    [self http_SelectRoutes];
    
}


#pragma mark - http port ---

// 查询局向光纤列表
- (void) http_SelectRoutes {
    
    if (!_postDict) {
        return;
    }
    
    
    
    [Yuan_NewFL_HttpModel Http2_SelectRoutesList:_postDict
                                         success:^(id  _Nonnull result) {
        _datas = result;
        
        if (_datas.count == 0) {
            [YuanHUD HUDFullText:@"暂无数据"];
            return;
        }
        
        
        NSMutableArray * mt_Arr = NSMutableArray.array;
        // 过滤掉 不显示的id
        for (NSDictionary * routeDict in _datas) {
            
            NSString * pairId = routeDict[@"pairId"];
            
            if ([_filterIdsArr containsObject:pairId]) {
                continue;
            }
            [mt_Arr addObject:routeDict];
        }
        
        _datas = mt_Arr;
        
        [_tableView reloadData];
        
    }];
    
}


/// 验证局向光纤是否在光链路中
- (void) http_VerifyRouteIsInLinks:(NSDictionary *) cellDict {
    
    
    [Yuan_NewFL_HttpModel Http2_CheckChooseTerminalOrFiberShip:@{@"id" : cellDict[@"pairId"],
                                                                 @"type" : @"731"}
                                                       success:^(id  _Nonnull result) {
            
        
        NSLog(@"-- %@" , result);
        
        NSString * linkType = result[@"linkType"];
        
        if ([linkType isEqualToString:@"optLink"]) {
            
            __typeof(self)weakSelf = self;
            _alertWindow = [[Yuan_NewFL2_AlertWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
            _alertWindow.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
            
            [_alertWindow reloadWithEnum:AlertWindow_Link];
            
            
            weakSelf->_alertWindow.AlertGoBlock = ^(AlertChooseType_ Enum) {
                
                switch (Enum) {
                        
                        // 取消
                    case AlertChooseType_Cancel:
                        
                        [_alertWindow removeFromSuperview];
                        _alertWindow = nil;
                        break;
                        
                        // 查看
                    case AlertChooseType_Look:
                        [self Look:linkType result:result];
                        
                        [_alertWindow removeFromSuperview];
                        _alertWindow = nil;
                        
                        break;
                        
                    default:
                        break;
                }
                
            };
            
            [[UIApplication sharedApplication].keyWindow addSubview:_alertWindow];
            
        }
        
        else if ([linkType isEqualToString:@"noOptLink"]) {
            
            // 如果是局向光纤替换
            if (_isExchangeMode) {
                [self http_Exchange:cellDict];
            }
            
            // 局向光纤向下插入
            else {
                [self http_InsertRouteInLinks:cellDict];
            }
            
        }
            
        else {
            [YuanHUD HUDFullText:[NSString stringWithFormat:@"无法选取该光缆段 %@",linkType]];
            return;
        }

    }];
 
}


/// 查看局向光纤所在的光链路
- (void) Look:(NSString *) linkType result:(NSDictionary *) result {
    
    // 光链路 / 局向光纤的id
    NSString * linkId = result[@"linkId"];
    
    // 光链路 -- 需要再返回一个所属光路id的字段
    if ([linkType isEqualToString:@"optLink"]) {
        
        [Yuan_NewFL_HttpModel Http2_GetLinkFromLinkId:linkId
                                              success:^(id  _Nonnull result) {
            NSDictionary * linkRouter = result;
            if (linkRouter.count == 0) {
                [YuanHUD HUDFullText:@"所在光链路无下属路由"];
                return;
            }
            
            NSDictionary * dict = @{@"optPairLinkList" : @[linkRouter]};
            Yuan_NewFL_LinkVC * linkVC = [[Yuan_NewFL_LinkVC alloc] initFromLinkDatas:dict];
            
            Push(self, linkVC);
            
        }];
    }
}

/// 向上/向下插入
- (void) http_InsertRouteInLinks:(NSDictionary *) routeDict {
    
    NSMutableDictionary * mt_Dict = [NSMutableDictionary dictionaryWithDictionary:routeDict];
    mt_Dict[@"eptTypeId"] = @"731";
    
    // 向上插入的时候 , index不需要考虑
    [Yuan_NewFL_HttpModel Http2_InsertInLinks:mt_Dict
                                  insertIndex:_insertIndex.row
                                        links:_insertBaseArray
                                      success:^(id  _Nonnull result) {
            
        if (_selectRouteBlock) {
            _selectRouteBlock(_cellDict);
        }
        
        Pop(self);
        
    }];
    
}


/// 替换
- (void) http_Exchange:(NSDictionary *) routeDict {
    
    if (!_needExchangeDict) {
        [YuanHUD HUDFullText:@"局向光纤替换失败, 未找到数据"];
        return;
    }
    
    NSString * pairId = routeDict[@"pairId"];
    
    NSDictionary * postDict = @{
        
        @"optPairRouterList" : _VM.nowLinkRouters,
        @"changeRouterList" : @[_needExchangeDict],
        @"optPairRouter" : @{
            @"sequence" : _needExchangeDict[@"sequence"],
            @"eptId" : pairId,
            @"eptTypeId" : @"731",
            @"relateResId" : pairId,
            @"relateResTypeId" : @"731"
        }
        
    };
    
    
    [Yuan_NewFL_HttpModel Http2_ExchangeRouterPointInLinks:postDict
                                                   success:^(id  _Nonnull result) {
            
        
        if (_selectRouteBlock) {
            _selectRouteBlock(_cellDict);
        }
        
        Pop(self);
        
    }];
    
}



#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier = @"UITableViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSDictionary * cellDict = _datas[indexPath.row];
    
    cell.textLabel.text = cellDict[@"pairNoDesc"] ?: @"";
    
    
    cell.textLabel.numberOfLines = 0;//根据最大行数需求来设置
    cell.textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary * cellDict = _datas[indexPath.row];
    
    [UIAlert alertSmallTitle:@"是否选择该局向光纤?"
               agreeBtnBlock:^(UIAlertAction *action) {
            
        _cellDict = cellDict;
        [self http_VerifyRouteIsInLinks:cellDict];
        
        
    }];
    
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return Vertical(60);
}

@end
