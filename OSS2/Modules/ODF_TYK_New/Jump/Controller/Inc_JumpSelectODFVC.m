//
//  Inc_JumpSelectODFVC.m
//  OSS2.0-ios-v2
//
//  Created by zzc on 2021/6/25.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_JumpSelectODFVC.h"
#import "Inc_ODF_JumpFiber_HttpModel.h"
#import "Inc_jumpSelectCell.h"
#import "MJRefresh.h"

@interface Inc_JumpSelectODFVC ()<UITableViewDelegate,UITableViewDataSource> {
    
    NSInteger _pageNum;
}


@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataArray;


/** 搜索框 */
@property (nonatomic , strong) UITextField * textField;

@end

@implementation Inc_JumpSelectODFVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"选择机房";
    
    _pageNum = 1;
    
    _dataArray = [NSMutableArray array];
    
    _tableView = [UIView tableViewDelegate:self
                             registerClass:[Inc_jumpSelectCell class]
                       CellReuseIdentifier:@"Zhang_jumpSelectCell"];
    _tableView.separatorInset = UIEdgeInsetsMake(0, 10, 0, 10);
    // 添加上拉下拉手势事件

    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [_tableView.mj_header endRefreshing];
        [self table_HeaderClick];
    }];

    _tableView.mj_footer = [MJRefreshBackStateFooter footerWithRefreshingBlock:^{
        [_tableView.mj_footer endRefreshingWithNoMoreData];
        [self table_FooterClick];
    }];

    
    
    
    _textField = [UIView textFieldFrame:CGRectNull];
    
    [_textField cornerRadius:5 borderWidth:1 borderColor:UIColor.lightGrayColor];
    _textField.placeholder = @"请输入名称查询";
    [self.view addSubviews:@[_tableView,_textField]];
    
    [self naviBarSet];

    [self zhang_layouts];
    
    [self reloadTbale:YES];

}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    Inc_jumpSelectCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Zhang_jumpSelectCell"];
    
    if (!cell) {
        cell = [[Inc_jumpSelectCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"Zhang_jumpSelectCell"];
    }
    
    NSDictionary * dict = _dataArray[indexPath.row];
    
    cell.dic = dict;
    
    return cell;
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary * dict = _dataArray[indexPath.row];
    
    if (self.getODFDicBlock) {
        self.getODFDicBlock(dict);
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}


/// 下拉刷新
- (void) table_HeaderClick {
    
    _pageNum = 1;
    [self reloadTbale:YES];

}


/// 上拉加载更多
- (void) table_FooterClick {
    
    _pageNum ++;

    [self reloadTbale:NO];
}

-(void)reloadTbale:(BOOL)isNeedClear{
    
    [self findRoomList:@{@"id":self.deviceId,
                         @"pageSize":@"15",
                         @"pageNum":[NSString stringWithFormat:@"%ld",(long)_pageNum],
                         @"name":_textField.text
    } isNeedClear:isNeedClear];

}

#pragma mark - http

-(void)findRoomList:(NSDictionary *)dict isNeedClear:(BOOL)isNeedClear{
    
    [Inc_ODF_JumpFiber_HttpModel FindRoomList:dict successBlock:^(id result) {
       
        if (result) {
            if (isNeedClear) {
                [_dataArray removeAllObjects];
            }
            [_dataArray addObjectsFromArray:result[@"content"]];
            
            [self.tableView reloadData];
            
        
        }
        
        [_tableView.mj_header endRefreshing];
        [_tableView.mj_footer endRefreshingWithNoMoreData];
    }];
    
}


#pragma mark - naviBar ---
- (void) naviBarSet {
    
    UIBarButtonItem * save = [UIView getBarButtonItemWithTitleStr:@"搜索" Sel:@selector(saveClick) VC:self];
    self.navigationItem.rightBarButtonItems = @[save];
}

- (void) saveClick {
    _pageNum = 1;
    [self reloadTbale:YES];
}


//适配
-(void)zhang_layouts {
    
    float limit = Horizontal(15);
    
    [_textField YuanToSuper_Left:limit];
    [_textField YuanToSuper_Right:limit];
    [_textField YuanToSuper_Top:NaviBarHeight + limit];
    [_textField Yuan_EdgeHeight:Vertical(35)];
    
    [_tableView YuanToSuper_Left:0];
    [_tableView YuanToSuper_Right:0];
    [_tableView YuanToSuper_Bottom:BottomZero];
    [_tableView YuanMyEdge:Top ToViewEdge:Bottom ToView:_textField inset:limit];
    
}

@end
