//
//  Yuan_NewFL_ChooseDeviceView.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/2/19.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_NewFL_ChooseDeviceView.h"
#import "Yuan_BlockLabelView.h"


@interface Yuan_NewFL_ChooseDeviceView () <UITableViewDelegate,UITableViewDataSource>

@end

@implementation Yuan_NewFL_ChooseDeviceView
{
    Yuan_BlockLabelView * _blockView;
    
    UIButton * _cancelBtn;
    
    UITableView * _tableView;
    
    NSArray * _cellData;
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
    
    if (_ChooseDeviceCancelBlock) {
        _ChooseDeviceCancelBlock(ChooseDeviceType_Cancel);
    }
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ChooseDeviceType_ type;
    
    switch (indexPath.row) {
        case 0:
            type = ChooseDeviceType_ODF;
            break;
        
        case 1:
            type = ChooseDeviceType_OCC;
            break;
        
        case 2:
            type = ChooseDeviceType_ODB;
            break;
            
        default:
            type = ChooseDeviceType_ODF;
            break;
    }
    
    if (_ChooseDeviceCancelBlock) {
        _ChooseDeviceCancelBlock(type);
    }
}

#pragma mark - delegate ---


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath; {
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"UITableViewCell"];
    }
    
    NSString * title = _cellData[indexPath.row];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = title;
    cell.textLabel.font = Font_Yuan(13);
    cell.textLabel.textColor = ColorValue_RGB(0x666666);
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return Vertical(40);
}


#pragma mark - UI Init ---

- (void) UI_Init {
    
    _blockView = [[Yuan_BlockLabelView alloc] initWithBlockColor:UIColor.mainColor title:@"请选择设备类型"];
    
    _cancelBtn = [UIView buttonWithImage:@"icon_guanbi"
                               responder:self
                               SEL_Click:@selector(cancelClick)
                                   frame:CGRectNull];
    
    _tableView = [UIView tableViewDelegate:self
                             registerClass:[UITableViewCell class]
                       CellReuseIdentifier:@"UITableViewCell"];
    _tableView.scrollEnabled = NO;
    
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
    [_tableView YuanToSuper_Left:0];
    [_tableView YuanToSuper_Right:0];
    [_tableView YuanToSuper_Bottom:0];
    
}



@end
