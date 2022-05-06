//
//  Yuan_NewFL_ChooseCableView.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/2/19.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_NewFL_ChooseCableView.h"
#import "Yuan_BlockLabelView.h"
#import "Yuan_NewFL_ChooseCableCell.h"
@interface Yuan_NewFL_ChooseCableView () <UITableViewDelegate,UITableViewDataSource>

@end

@implementation Yuan_NewFL_ChooseCableView

{
    Yuan_BlockLabelView * _blockView;
    
    UIButton * _cancelBtn;
    
    UITableView * _tableView;
    
    NSArray * _cellData;
    
    NSArray * _dataSource;
}


#pragma mark - 初始化构造方法

- (instancetype)init {
    
    if (self = [super init]) {
        _cellData = @[@"ODF",@"光交接箱",@"光分纤箱"];
        [self UI_Init];
        self.backgroundColor = UIColor.whiteColor;
    }
    return self;
}



- (void) cancelClick {
    
    if (_chooseCableBlock) {
        _chooseCableBlock(nil);
    }
    
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary * dict = _dataSource[indexPath.row];
    _chooseCableBlock(dict);
}



#pragma mark - delegate ---


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _dataSource.count;
}

- (Yuan_NewFL_ChooseCableCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath; {
    
    Yuan_NewFL_ChooseCableCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Yuan_NewFL_ChooseCableCell"];
    
    if (!cell) {
        cell = [[Yuan_NewFL_ChooseCableCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"Yuan_NewFL_ChooseCableCell"];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    NSDictionary * dict = _dataSource[indexPath.row];
    
    [cell reloadCell:dict];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return Vertical(120);
}




#pragma mark - UI Init ---

- (void) UI_Init {
    
    _blockView = [[Yuan_BlockLabelView alloc] initWithBlockColor:UIColor.mainColor title:@"请选择光缆段"];
    
    _cancelBtn = [UIView buttonWithImage:@"icon_guanbi"
                               responder:self
                               SEL_Click:@selector(cancelClick)
                                   frame:CGRectNull];
    
    _tableView = [UIView tableViewDelegate:self
                             registerClass:[Yuan_NewFL_ChooseCableCell class]
                       CellReuseIdentifier:@"Yuan_NewFL_ChooseCableCell"];
    
    [self addSubviews:@[_blockView,_cancelBtn,_tableView]];
    [self yuan_LayoutSubViews];
}


- (void) yuan_LayoutSubViews {
    
    // 120
    
    float limit = Horizontal(15) /2;
    
    [_blockView YuanToSuper_Left:limit];
    [_blockView YuanToSuper_Top:limit];
    [_blockView autoSetDimension:ALDimensionHeight toSize:Vertical(30)];
    
    [_cancelBtn YuanToSuper_Right:limit];
    [_cancelBtn YuanAttributeHorizontalToView:_blockView];
    
    [_tableView YuanMyEdge:Top ToViewEdge:Bottom ToView:_blockView inset:0];
    [_tableView YuanToSuper_Left:limit];
    [_tableView YuanToSuper_Right:limit];
    [_tableView YuanToSuper_Bottom:0];
    
}


// 数据源
- (void) reloadData:(NSArray *) dataSource {
    
    _dataSource = dataSource;
    [_tableView reloadData];
}

@end
