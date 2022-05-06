//
//  Yuan_MLD_DetailVC.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/6/28.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//  2021年6.28 新增 级联删除详情界面

#import "Yuan_MLD_DetailVC.h"
#import "Yuan_MLD_DetailTopView.h"
#import "Yuan_BlockLabelView.h"
#import "Yuan_TableViewCell.h"


#import "Yuan_ML_HttpModel.h"
@interface Yuan_MLD_DetailVC ()<UITableViewDelegate , UITableViewDataSource>

/** 顶部视图 */
@property (nonatomic , strong) Yuan_MLD_DetailTopView * topView;

/** table */
@property (nonatomic , strong) UITableView * tableView;

/** blockView */
@property (nonatomic , strong) Yuan_BlockLabelView * blockView;

@end

@implementation Yuan_MLD_DetailVC
{
    
    NSDictionary * _dict;
    
    NSArray * _datas;
    
    BOOL _isHiddenAllBtns;
}


#pragma mark - 初始化构造方法

- (instancetype)initWithDict:(NSDictionary *)dict {
    
    if (self = [super init]) {
        _dict = dict;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];

    [self UI_Init];
    [self http_CheckRegion];
}

#pragma mark - http ---

- (void) http_CheckRegion {
    
    NSString * regionId = Http.shareInstance.david_LoginDict[@"user"][@"regionId"];
    
    NSDictionary * postDict = @{
        @"regionId" : regionId,
        @"reqDb" : Yuan_WebService.webServiceGetDomainCode,
        @"resId" : _dict[@"gid"],
        @"resType" : _dict[@"resType"]
    };

    
    [Yuan_ML_HttpModel HTTP_MLD_CheckRegion:postDict
                                    success:^(id  _Nonnull result) {
        _datas = result;
        if (_datas.count == 0) {
            [YuanHUD HUDFullText:@"未查询到该资源的关联数据"];
            return;
        }
        
        for (NSDictionary * dict in _datas) {
            
            NSNumber * isInRange = dict[@"isInRange"];
            
            if (isInRange.intValue != 1) {
                _isHiddenAllBtns = YES;
            }
        }
        
        if (_isHiddenAllBtns) {        
            [_topView hideAllBtn];
        }
        
        [_tableView reloadData];
    }];
    
}


#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier = @"Yuan_TableViewCell";
    
    Yuan_TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[Yuan_TableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSDictionary * dict = _datas[indexPath.row];
    
    [cell reloadWithDict:dict];
    
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return Vertical(100);
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}




#pragma mark - ui ---

- (void) UI_Init {
    
    _topView = [[Yuan_MLD_DetailTopView alloc] init];
    
    [_topView reloadDict:_dict];
    [_topView btnHidden:_isHiddenTopBtns];
    
    __typeof(self)weakSelf = self;
    weakSelf->_topView.reloadSelectBlock = ^{
        Pop(self);
    };
    
    _topView.backgroundColor = UIColor.whiteColor;
    
    
    _blockView = [[Yuan_BlockLabelView alloc] initWithBlockColor:UIColor.mainColor
                                                           title:@"关联资源"];
    
    _tableView = [UIView tableViewDelegate:self
                             registerClass:[Yuan_TableViewCell class]
                       CellReuseIdentifier:@"Yuan_TableViewCell"];
    
    _tableView.separatorStyle = 0;
    
    [self.view addSubviews:@[_topView,_blockView,_tableView]];
    [self yuan_LayoutSubViews];
}

- (void) yuan_LayoutSubViews {
    
    float limit = Horizontal(10);
    [_topView YuanToSuper_Top:NaviBarHeight];
    [_topView YuanToSuper_Left:0];
    [_topView YuanToSuper_Right:0];
    [_topView Yuan_EdgeHeight:Vertical(160)];
    
    [_blockView YuanMyEdge:Top ToViewEdge:Bottom ToView:_topView inset:Vertical(20)];
    [_blockView YuanToSuper_Left:limit];
    [_blockView Yuan_EdgeHeight:Vertical(20)];
    
    [_tableView YuanMyEdge:Top ToViewEdge:Bottom ToView:_blockView inset:Vertical(10)];
    [_tableView YuanToSuper_Left:0];
    [_tableView YuanToSuper_Right:0];
    [_tableView YuanToSuper_Bottom:BottomZero];
    
}

@end
