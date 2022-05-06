//
//  Yuan_bearingCablesList.m
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/9/1.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//  承载缆段列表



#import "Yuan_bearingCablesList.h"
#import "Yuan_bearingCablesCell.h"

#import "ResourceTYKListViewController.h"

@interface Yuan_bearingCablesList ()

<
    UITableViewDelegate ,
    UITableViewDataSource
>


/** tableView */
@property (nonatomic,strong) UITableView *tableView;

/** 穿缆按钮 */
@property (nonatomic,strong) UIButton *chuanLan_Btn;

@end

@implementation Yuan_bearingCablesList

{
    
    NSMutableArray * _dataSource;
    
}




- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.whiteColor;
    self.title = @"承载缆段列表";

    // 初始化
    _dataSource = NSMutableArray.array;
    
    [self UI_Init];
    
    [self http_Port];
    
}


- (void) UI_Init {
    
    // tableView
    _tableView = [UIView tableViewDelegate:self
                             registerClass:[Yuan_bearingCablesCell class]
                       CellReuseIdentifier:@"Yuan_bearingCablesCell"];
    
    [self.view addSubview:_tableView];
    
    float limit = Horizontal(10);
    
    
    UIEdgeInsets insets = UIEdgeInsetsMake(limit, limit, 40 + limit * 2, limit);
    
    [_tableView autoPinEdgesToSuperviewEdgesWithInsets:insets];
    
    
    
    // 穿缆按钮
    _chuanLan_Btn = [UIView buttonWithTitle:@"穿缆"
                                  responder:self
                                        SEL:@selector(chuanLan_Click)
                                      frame:CGRectNull];
    
    _chuanLan_Btn.layer.cornerRadius = 5;
    _chuanLan_Btn.layer.masksToBounds = YES;
    [_chuanLan_Btn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    _chuanLan_Btn.backgroundColor = Color_V2Red;
    
    [self.view addSubview:_chuanLan_Btn];
    
    [_chuanLan_Btn autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:limit];
    [_chuanLan_Btn autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:limit];
    [_chuanLan_Btn autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:BottomZero + limit];
    [_chuanLan_Btn autoSetDimension:ALDimensionHeight toSize:40];
    
}

#pragma mark -  网络请求  ---

// 列表的请求
- (void) http_Port {
    
    NSString * url = @"rm!queryPipOccupyByRes.interface";
    NSMutableDictionary * mt_Dict = NSMutableDictionary.dictionary;
    
    mt_Dict[@"resLogicName"] = @"cableRouteSubmit";
    mt_Dict[@"resType"] = _requestDict[@"resLogicName"];
    mt_Dict[@"resGid"] = _requestDict[@"GID"];
    
    // 如果是管孔 并且 是子孔的情况下 , 发 isFather = 2
    if ([mt_Dict[@"resType"] isEqualToString:@"tube"] && _isNeed_isFather) {
        mt_Dict[@"isFather"] = @"2";
    }
    
    
    [[Http shareInstance] V2_POST:url
                             dict:mt_Dict
                          succeed:^(id data) {
        
        _dataSource = [NSMutableArray arrayWithArray:data];
        
        if (_dataSource.count == 0) {
            [[Yuan_HUD shareInstance] HUDFullText:@"暂无数据"];
            return;
        }
        
        
        
        [_tableView reloadData];
    }];
    
}

// 穿缆的请求
- (void) http_chuanLanWithCableDict:(NSDictionary *) cableMsg {
    
    // 回调回来的 光缆段的map
    
    NSString * url = @"rm!insertOptoccupy.interface";
    
    NSMutableDictionary * mt_Dict = NSMutableDictionary.dictionary;
    
    mt_Dict[@"resLogicName"] = @"cableRouteSubmit";
    mt_Dict[@"resType"] = _requestDict[@"resLogicName"];
    mt_Dict[@"resGid"] = _requestDict[@"GID"] ?: @"";
    mt_Dict[@"resName"] = _requestDict[@"tubeName"] ?: @"";
    
    mt_Dict[@"cableGid"] = cableMsg[@"GID"] ?: @"";
    mt_Dict[@"cableName"] = cableMsg[@"cableName"] ?: @"";
    
    
    // 如果是管孔 并且 是子孔的情况下 , 发 isFather = 2
    if ([mt_Dict[@"resType"] isEqualToString:@"tube"] && _isNeed_isFather) {
        mt_Dict[@"isFather"] = @"2";
    }
    
    
    [[Http shareInstance] V2_POST:url
                             dict:mt_Dict
                          succeed:^(id data) {
       
        // 成功 重新请求当前列表
        [[Yuan_HUD shareInstance] HUDFullText:@"穿缆成功"];
        [self http_Port];
    }];
    
}


// 撤缆的请求
- (void) http_cheLan:(NSInteger)row {
    
    NSDictionary * cellDict = _dataSource[row];
    
    NSString * url = @"rm!deleteOptoccupy.interface";
    NSMutableDictionary * mt_Dict = NSMutableDictionary.dictionary;
    
    mt_Dict[@"resLogicName"] = @"cableRouteSubmit";
    mt_Dict[@"resType"] = _requestDict[@"resLogicName"];
    mt_Dict[@"resGid"] = _requestDict[@"GID"] ?: @"";
    mt_Dict[@"resName"] = _requestDict[@"tubeName"] ?: @"";
    
    mt_Dict[@"cableGid"] = cellDict[@"GID"];
    mt_Dict[@"cableName"] = cellDict[@"cableName"];
    
    
    
    // 如果是管孔 并且 是子孔的情况下 , 发 isFather = 2
    if ([mt_Dict[@"resType"] isEqualToString:@"tube"] && _isNeed_isFather) {
        mt_Dict[@"isFather"] = @"2";
    }
    
    [[Http shareInstance] V2_POST:url
                             dict:mt_Dict
                          succeed:^(id data) {
        // 撤缆成功后 ,
        [[Yuan_HUD shareInstance] HUDFullText:@"撤缆成功"];
        
        [_dataSource removeObjectAtIndex:row];
       
        NSIndexPath * deleteIndex = [NSIndexPath indexPathForRow:row inSection:0];
        [_tableView deleteRowsAtIndexPaths:@[deleteIndex]
                          withRowAnimation:UITableViewRowAnimationNone];
        
    }];
    
}




#pragma mark -  btnClick  ---

- (void) chuanLan_Click {
    
    // 发起穿缆 , 跳转光缆段
    
    // 跳转到光缆段 带回对应的光缆段的数据 , 完成穿缆操作
     // TODO 智网通跳转
    ResourceTYKListViewController * list =
    [[ResourceTYKListViewController alloc] initWithSearchTitle:@""
                                                      blockMsg:^(NSDictionary *cableMsg) {
        
        [self http_chuanLanWithCableDict:cableMsg];
        
    }];
    
    list.fileName = @"cable";
    list.showName = @"光缆段";
    Push(self, list);

}





#pragma mark -  delegate  ---


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
        
    return _dataSource.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Yuan_bearingCablesCell * cell =
    [tableView dequeueReusableCellWithIdentifier:@"Yuan_bearingCablesCell"];
    
    if (!cell) {
        cell = [[Yuan_bearingCablesCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"Yuan_bearingCablesCell"];
    }
    
    NSDictionary * dict = _dataSource[indexPath.row];
    
    cell.bearingCables_Name.text = dict[@"cableName"];
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return Vertical(60);
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



- (UITableViewCellEditingStyle)tableView:(UITableView*)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath*)indexPath {

   return UITableViewCellEditingStyleDelete;

}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath*)indexPath {

    
   UITableViewRowAction *rowAction =
    [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive
                                       title:@"撤缆"
                                     handler:^(UITableViewRowAction *_Nonnullaction,
                                               NSIndexPath *_NonnullindexPath) {
        
        // 执行 撤缆
        [self http_cheLan:indexPath.row];
    }];

   rowAction.backgroundColor = Color_V2Red;
   return @[rowAction];
}
@end
