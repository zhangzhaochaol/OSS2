//
//  Yuan_OBD_Points_DeviceListVC.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/4/20.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_OBD_Points_DeviceListVC.h"

#import "Yuan_BlockLabelView.h"
#import "Yuan_OBD_PointsListCell.h"

#import "Yuan_OBD_PointsHttpModel.h"        //OBD Http 请求
#import "Inc_NewMB_HttpModel.h"            //新模板Http请求

@interface Yuan_OBD_Points_DeviceListVC () <UITableViewDelegate , UITableViewDataSource>

/** tableView */
@property (nonatomic , strong) UITableView * tableView;

@end

@implementation Yuan_OBD_Points_DeviceListVC

{
    
    
    // block view
    Yuan_BlockLabelView * _blockView;
    
    // 取消按钮
    UIButton * _cancelBtn;
    
    // 背景
    UIView * _backView;
    
    // 网络请求返回值
    NSArray * _dataSource;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self UI_Init];
}


- (void) reloadData:(NSArray *) arr {
    
    _dataSource = arr;
    
    [_tableView reloadData];
}





#pragma mark - Click ---


- (void) cancelClick {
    
    [self dismissViewControllerAnimated:NO
                             completion:^{
        
        if (_choose_OBD) {
            _choose_OBD(@{});
        }
    }];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    NSDictionary * dict = _dataSource[indexPath.row];
    
    [UIAlert alertSmallTitle:@"是否编辑此分光器"
                          vc:self
               agreeBtnBlock:^(UIAlertAction *action) {
        
        
        [self dismissViewControllerAnimated:NO
                                 completion:^{
            
            if (_choose_OBD) {
                _choose_OBD(dict);
            }
           
        }];
    }];
}



#pragma mark - delegate ---


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    Yuan_OBD_PointsListCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Yuan_OBD_PointsListCell"];
    
    if (!cell ) {
        cell = [[Yuan_OBD_PointsListCell alloc] initWithStyle:UITableViewCellStyleDefault
                                              reuseIdentifier:@"Yuan_OBD_PointsListCell"];
    }
        
    
    NSDictionary * dict = _dataSource[indexPath.row];
    
    [cell reloadDict:dict];
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return Vertical(70);
}



#pragma mark - UI ---




- (void) UI_Init {
    
    _backView = [UIView viewWithColor:UIColor.whiteColor];
    [_backView cornerRadius:5 borderWidth:0 borderColor:nil];
    
    _blockView = [[Yuan_BlockLabelView alloc] initWithBlockColor:UIColor.mainColor title:@"分光器列表"];
    [_blockView font:18];
    
    _cancelBtn = [UIView buttonWithImage:@"DC_guanbi"
                               responder:self
                               SEL_Click:@selector(cancelClick)
                                   frame:CGRectNull];
    
    _tableView = [UIView tableViewDelegate:self
                             registerClass:[Yuan_OBD_PointsListCell class]
                       CellReuseIdentifier:@"Yuan_OBD_PointsListCell"];
    
    
    [self.view addSubview:_backView];
    [_backView addSubviews:@[_blockView , _cancelBtn , _tableView]];
    
    [self yuan_LayoutSubViews];
}


- (void) yuan_LayoutSubViews {
    
    float limit = Horizontal(10);
    
    [_backView YuanAttributeHorizontalToView:self.view];
    [_backView YuanAttributeVerticalToView:self.view];
    [_backView autoSetDimension:ALDimensionWidth toSize:ScreenWidth / 6 * 5];
    [_backView autoSetDimension:ALDimensionHeight toSize:ScreenHeight / 4 * 3];
    
    
    [_blockView YuanToSuper_Left:limit];
    [_blockView YuanToSuper_Top:limit];
    [_blockView autoSetDimension:ALDimensionHeight toSize:Vertical(40)];
    
    [_cancelBtn YuanAttributeHorizontalToView:_blockView];
    [_cancelBtn YuanToSuper_Right:limit];
    
    [_tableView YuanMyEdge:Top ToViewEdge:Bottom ToView:_blockView inset:0];
    [_tableView YuanToSuper_Left:0];
    [_tableView YuanToSuper_Right:0];
    [_tableView YuanToSuper_Bottom:0];
    
}


@end
