//
//  Inc_CFListTableView.m
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/7/20.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_CFListTableView.h"
#import "Inc_CFListTableCell.h"

#import "Yuan_CFConfigVM.h"

#import "Yuan_CF_HttpModel.h"


typedef NS_ENUM(NSUInteger, CF_Delete_) {
    CF_Delete_Start,
    CF_Delete_End,
};



@interface Inc_CFListTableView () <UITableViewDelegate , UITableViewDataSource>

/** tableView */
@property (nonatomic,strong) UITableView *tableView;

@end

@implementation Inc_CFListTableView

{
    NSMutableArray * _dataSource;
    
    NSArray * _noSuperResIdArray;
    
    Yuan_CFConfigVM * _viewModel;
}


#pragma mark - 初始化构造方法

- (instancetype) init {
    
    if (self = [super init]) {
        
        _dataSource = [NSMutableArray array];
        
        _viewModel = [Yuan_CFConfigVM shareInstance];
        
        _tableView = [UIView tableViewDelegate:self
                                 registerClass:[Inc_CFListTableCell class]
                           CellReuseIdentifier:@"Yuan_CFListTableCell"];
        
        [self addSubview:_tableView];
        
        [_tableView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
        
    }
    return self;
}




#pragma mark -  method  ---


- (void) dataSource:(NSMutableArray *) dataSource {
    
    _dataSource = dataSource;
    
    [_tableView reloadData];
    
}


// 哪些纤芯成端的端子 缺少superResId , 就把它变黄色
- (void) noSuperResIdSource:(NSArray *) noSuperResIdArray {
    
    _noSuperResIdArray = noSuperResIdArray;
    
    [_tableView reloadData];
}



#pragma mark -  UITableViewDataSource  ---


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _dataSource.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Inc_CFListTableCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Yuan_CFListTableCell"];
    
    if (!cell) {
        
        cell = [[Inc_CFListTableCell alloc] initWithStyle:UITableViewCellStyleDefault
                                           reuseIdentifier:@"Yuan_CFListTableCell"];
    }
    
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSDictionary * dict = _dataSource[indexPath.row];
    
    NSString * pairId = dict[@"pairId"];
    
    // 如果数组中存在 这个Id 证明 -- 该纤芯关联的端子 缺少superResId
    // 变黄色 border
    if ([_noSuperResIdArray containsObject:pairId]) {
        cell.titleBusiness.layer.borderColor = UIColor.yellowColor.CGColor;
        cell.titleBusiness.layer.borderWidth = 1;
    }
    
    
    // 显示的名称
    [cell configMsg:dict[@"pairName"] ?: @""];
    // 显示 数值
    cell.headerLab.text = dict[@"pairNo"] ?: @"";
   
    cell.headerLab.userInteractionEnabled = YES;
    cell.headerLab.tag = indexPath.row;
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
    //属性设置
    //最小长按时间
    longPress.minimumPressDuration = 0.5;
    [cell.headerLab addGestureRecognizer:longPress];
    
    
   [cell fiberPerformance:dict[@"opticalFiberPerformance"] num:dict[@"lightAttenuationCoefficient"]];


    
    // 默认是两端都不显示图片的 在下面的代码中再次配置图片
    [cell imgConfigUpImage:CF_HeaderCellType_None];
    [cell imgConfigDownImg:CF_HeaderCellType_None];
    
    // 配置颜色
    [cell configColor:dict[@"oprStateId"]];
    
    
    // 获取到 判断纤芯的小map , 用来判断成端还是熔接 , 显示在左上角还是右下角
    NSArray * connectList = dict[@"connectList"];
    
    if (!connectList ||
        connectList.count == 0 ||
        [connectList isEqual:[NSNull null]]) {
        
        
        
        return cell;
    }
    
    // *** *** ***  判断成端 熔接 左上 右下
    
    NSString * type;
    NSString * location;
    
    // 循环遍历 connectList
    
    for (NSDictionary * fiberDict in connectList) {
        
        NSDictionary * vm_Dict = [_viewModel viewModelFiberTypeAndLocationFromDict:fiberDict
                                                                            pairId:pairId];
        
        
        
        // 成端还是熔接
        type = vm_Dict[@"type"];
        // 左上还是右下
        location = vm_Dict[@"location"];
        
        // 如果 location == 1 左上角
        if ([location isEqualToString:@"1"]) {
            
            // type == 2 成端
            if ([type isEqualToString:@"2"]) {
                [cell imgConfigUpImage:CF_HeaderCellType_ChengDuan];
            }
            // type == 1 熔接
            else {
                [cell imgConfigUpImage:CF_HeaderCellType_RongJie];
            }
        }
        // 如果 location == 2 右下角
        else if([location isEqualToString:@"2"]){
            
            // type == 1 成端
            if ([type isEqualToString:@"2"]) {
                [cell imgConfigDownImg:CF_HeaderCellType_ChengDuan];
            }
            // type == 2 熔接
            else {
                [cell imgConfigDownImg:CF_HeaderCellType_RongJie];
            }
            
        }else {
            // 什么都不做 , 因为之前已经清空了  unKnow
        }
        
        
    }

    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return Vertical(50);
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary * dict = _dataSource[indexPath.row];
    
    // 回调 block 
    if (_tableView_SelectCellBlock) {
        _tableView_SelectCellBlock(dict ?: @{});
    }
    
    
}



- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView
                  editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    __typeof(self)wself = self;
    
    UITableViewRowAction *delete_Start =
    [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal
                                       title:@"撤销起始设备"
                                     handler:^(UITableViewRowAction * _Nonnull action,
                                               NSIndexPath * _Nonnull indexPath) {
        
        [wself delete:CF_Delete_Start
                 Dict:_dataSource[indexPath.row]];
    }];


    UITableViewRowAction *delete_End =
    [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal
                                       title:@"撤销终止设备"
                                     handler:^(UITableViewRowAction * _Nonnull action,
                                               NSIndexPath * _Nonnull indexPath) {
        
        [wself delete:CF_Delete_End
                 Dict:_dataSource[indexPath.row]];
    }];

    delete_End.backgroundColor = Color_V2Red;
    delete_Start.backgroundColor = Color_V2Blue;
    
    return @[delete_End,delete_Start];
}




- (void) delete:(CF_Delete_)type Dict:(NSDictionary *)WDW_Dict {
    
    
    if (type == CF_Delete_Start) {
        
        [Yuan_CF_HttpModel HttpCableFiberDelete_StartDeviceWithDict:WDW_Dict
                                                            Success:^{
            // 刷新列表
            if (_tableView_DeleteSuccessBlock) {
                _tableView_DeleteSuccessBlock();
            }
        }];
        
    }
    
    else {
        
        [Yuan_CF_HttpModel HttpCableFiberDelete_EndDeviceWithDict:WDW_Dict
                                                          Success:^{
            // 刷新列表
            if (_tableView_DeleteSuccessBlock) {
                _tableView_DeleteSuccessBlock();
            }
        }];
        
    }
    
    
    
}



#pragma mark langPress 长按手势事件
-(void)longPress:(UILongPressGestureRecognizer *)sender{
    //进行判断,在什么时候触发事件
    UILabel *label = (UILabel *)sender.view;
    if (sender.state == UIGestureRecognizerStateBegan) {
        NSLog(@"长按状态");
        if (self.PressGestureBlock) {
            self.PressGestureBlock(label.tag);
        }
    }
}
@end
