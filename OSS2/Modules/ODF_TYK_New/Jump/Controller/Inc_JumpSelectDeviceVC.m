//
//  Inc_JumpSelectDeviceVC.m
//  OSS2.0-ios-v2
//
//  Created by zzc on 2021/6/29.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_JumpSelectDeviceVC.h"
#import "Inc_jumpSelectCell.h"
#import "Inc_ODF_JumpFiber_HttpModel.h"
#import "MJRefresh.h"
@interface Inc_JumpSelectDeviceVC ()<UITableViewDelegate,UITableViewDataSource> {
    NSMutableArray * _search_Arr;
    NSInteger _pageNum;

}

@property (nonatomic, strong) UITableView *tableView;

/** 搜索框 */
@property (nonatomic , strong) UITextField * textField;

@end

@implementation Inc_JumpSelectDeviceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"选择设备";
    
        
    _search_Arr = [NSMutableArray array];
    _pageNum = 1;

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
    
    return _search_Arr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    Inc_jumpSelectCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Zhang_jumpSelectCell"];
    
    if (!cell) {
        cell = [[Inc_jumpSelectCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"Zhang_jumpSelectCell"];
    }
    
    NSDictionary * dict = _search_Arr[indexPath.row];
    
    cell.dic = dict;
    
    return cell;
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary * dict = _search_Arr[indexPath.row];
    
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
    
    [self SearchUnionTermJump:@{@"id":self.roomId,
                                @"pageSize":@"15",
                                @"pageNum":[NSString stringWithFormat:@"%ld",(long)_pageNum],
                                @"type":@"rackOdf",
                                @"name":_textField.text
    } isNeedClear:isNeedClear];
    
}





#pragma mark -http

//通过机房id查所属设备
- (void)SearchUnionTermJump:(NSDictionary *)dict isNeedClear:(BOOL)isNeedClear{
    [Inc_ODF_JumpFiber_HttpModel SearchUnionTermJump:dict successBlock:^(id result) {
        if (result) {
            if (isNeedClear) {
                [_search_Arr removeAllObjects];
            }
            [_search_Arr addObjectsFromArray:result[@"content"]];
            
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
