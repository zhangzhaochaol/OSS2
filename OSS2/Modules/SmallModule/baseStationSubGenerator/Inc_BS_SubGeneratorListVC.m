//
//  Inc_BS_SubGeneratorListVC.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/9/26.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_BS_SubGeneratorListVC.h"
#import "Inc_Push_MB.h"

@interface Inc_BS_SubGeneratorListVC () <UITableViewDelegate , UITableViewDataSource>

/** table */
@property (nonatomic , strong) UITableView * tableView;

@end

@implementation Inc_BS_SubGeneratorListVC

{
    NSArray * _datas;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];

    self.title = @"局站下属机房列表";
    
    _tableView = [UIView tableViewDelegate:self
                             registerClass:[UITableViewCell class]
                       CellReuseIdentifier:@"UITableViewCell"];
    
    [self.view addSubview:_tableView];
    [_tableView Yuan_Edges:UIEdgeInsetsMake(NaviBarHeight, 0, BottomZero, 0)];
    
    [self http_port];
}

#pragma mark - http ---


- (void) http_port {
    
    if (!_GID) {
        
        [[Yuan_HUD shareInstance] HUDFullText:@"缺少Gid"];
        Pop(self);
        return;;
    }
    
    
    //zzc 2021-10-18  入参添加limit  否则每次只返回默认的一条
    NSDictionary * dict = @{
        @"start":@"1",
        @"limit":@"1000",
        @"resLogicName" : @"generator",
        @"areaname_Id" : _GID       //所属局站ID
    };
    
    
    [[Http shareInstance] V2_POST:HTTP_TYK_Normal_Get
                             dict:dict
                          succeed:^(id data) {
                
        NSArray * arr = data;
        _datas = arr;
        [_tableView reloadData];
        
        if (_datas.count == 0) {
            [YuanHUD HUDFullText:@"当前局站无下属机房"];
            return;
        }
    }];
    
    
    
}


#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier = @"UITableViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSDictionary * cellDict = _datas[indexPath.row];
    cell.textLabel.text = cellDict[@"generatorName"] ?: @"";
    cell.textLabel.font = Font_Yuan(14);
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary * cellDict = _datas[indexPath.row];
    
    
    [Inc_Push_MB pushFrom:self resLogicName:@"generator" dict:cellDict type:TYKDeviceListUpdate];
}

@end
