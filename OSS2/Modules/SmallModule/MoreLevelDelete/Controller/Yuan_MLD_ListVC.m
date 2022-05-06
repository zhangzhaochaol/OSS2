//
//  Yuan_MLD_ListVC.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/1/27.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_MLD_ListVC.h"
// 详细信息
#import "Yuan_MLD_DetailVC.h"

#import "Yuan_MLD_ListCell.h"
#import "Yuan_DOList_HeaderView.h"
#import "Yuan_ML_HttpModel.h"



@interface Yuan_MLD_ListVC () <UITableViewDelegate , UITableViewDataSource>
/** tableview */
@property (nonatomic , strong) UITableView * tableView;

/** header */
@property (nonatomic , strong) Yuan_DOList_HeaderView * headerView;

@end

@implementation Yuan_MLD_ListVC

{
    
    NSArray * _dataSource;
    
    NSArray * _reloadDataSource;
    
    Yuan_DOHeaderType_ _chooseType;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"级联删除列表";
    
    // 待审核
    _chooseType = Yuan_DOHeaderType_MyOrder;
    
    _tableView = [UIView tableViewDelegate:self
                             registerClass:[Yuan_MLD_ListCell class]
                       CellReuseIdentifier:@"Yuan_MLD_ListCell"];
    
    _headerView = [[Yuan_DOList_HeaderView alloc] init_MLD];
    
    [self.view addSubviews:@[_tableView,_headerView]];
    
    [self yuan_LayoutSubViews];
    
    [self block_Init];
    
}


- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self http_Select];
}


- (void) http_Select {
    
    NSDictionary * myDict = @{
        
        @"pageSize" : @"-1",
        @"pageNum" : @"-1",
        @"reqDb" : Yuan_WebService.webServiceGetDomainCode
    };
    
    [Yuan_ML_HttpModel HTTP_MLD_Select:myDict success:^(id  _Nonnull result) {
        _dataSource = result[@"content"];
        if (_dataSource.count == 0 || !_dataSource) {
            
            [[Yuan_HUD shareInstance] HUDFullText:@"数据错误"];
            return;
        }
        [self chooseDataSource];
        
    }];
    
}


- (void) block_Init {
    
    
    __typeof(self)weakSelf = self;
    _headerView.doHeaderChooseBlock = ^(Yuan_DOHeaderType_ type) {
        
        _chooseType = type;
        [weakSelf chooseDataSource];
    };
}


- (void) chooseDataSource {
    
    NSMutableArray * authorized_0 = NSMutableArray.array;
    NSMutableArray * authorized_1 = NSMutableArray.array;
    
    
    for (NSDictionary * dict in _dataSource) {
        
        
        NSNumber * authorized = dict[@"authorized"];
        NSNumber * reject = dict[@"reject"];
    
        if (authorized.intValue == 0 && reject.intValue == 0) {
            [authorized_0 addObject:dict];
        }
        else {
            [authorized_1 addObject:dict];
        }
        
    }

    _reloadDataSource = nil;
    
    // 未审批
    if (_chooseType == Yuan_DOHeaderType_MyOrder) {
        _reloadDataSource = authorized_0;
    }
    else {
        _reloadDataSource = authorized_1;
    }
    
    
    [_tableView reloadData];
}






- (void) yuan_LayoutSubViews {
    
    
    [_headerView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:NaviBarHeight];
    [_headerView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [_headerView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    [_headerView autoSetDimension:ALDimensionHeight toSize:Vertical(50)];
    
    [_tableView YuanToSuper_Left:0];
    [_tableView YuanToSuper_Right:0];
    [_tableView YuanToSuper_Bottom:BottomZero];
    [_tableView YuanMyEdge:Top ToViewEdge:Bottom ToView:_headerView inset:10];
}





#pragma mark - delegate ---

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _reloadDataSource.count;
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    Yuan_MLD_ListCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Yuan_MLD_ListCell"];
    
    if (!cell) {
        cell = [[Yuan_MLD_ListCell alloc] initWithStyle:UITableViewCellStyleDefault
                                        reuseIdentifier:@"Yuan_MLD_ListCell"];
    }
    
    NSDictionary * dict = _reloadDataSource[indexPath.row];
    
    [cell reloadDict:dict];
    
    __typeof(self)weakSelf = self;
    cell.reloadSelectBlock = ^{
        // 重新请求列表
        [weakSelf http_Select];
    };
    
    if (_chooseType == Yuan_DOHeaderType_MyOrder) {
        [cell btnHidden:NO];
    }
    else {
        [cell btnHidden:YES];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    
    
    
    return cell;
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary * dict = _reloadDataSource[indexPath.row];
    
    Yuan_MLD_DetailVC * detailVc = [[Yuan_MLD_DetailVC alloc] initWithDict:dict];
    
    if (_chooseType == Yuan_DOHeaderType_MyOrder) {
        detailVc.isHiddenTopBtns = NO;
    }
    else {
        detailVc.isHiddenTopBtns = YES;
    }
    
    Push(self, detailVc);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary * dict = _reloadDataSource[indexPath.row];
    
    NSString * resName = dict[@"resName"];
    
    if (resName.length > 20) {
        return Vertical(150);
    }
    
    
    return Vertical(130);
}


@end
