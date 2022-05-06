//
//  Yuan_FL_ListCell.m
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/12/1.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_FL_ListCell.h"

@implementation Yuan_FL_ListCell
{
    UIView * _backView;
    
    UIImageView * _leftTopIcon;
    
    UILabel * _rank;
    
    UILabel * _belongDevice;
    
    UILabel * _myDevice;
    
    UIView * _line;
    
}



#pragma mark - 初始化构造方法

- (instancetype) initWithStyle:(UITableViewCellStyle)style
               reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self UI_Init];
    }
    
    return self;
}



- (void) reload_FiberDict:(NSDictionary *)dict {
    
       
    
    _belongDevice.text = dict[@"root_NAME"];

    
    // 当前设备在路由中的顺序
    _sequence = dict[@"sequence"];
    _rank.text = _sequence;
    
    _deviceId = dict[@"nodeId"] ?: @"";
    
    NSString * nodeTypeId = dict[@"nodeTypeId"];
    
    if ([nodeTypeId isEqualToString:@"317"]) {
        // 端子
        _resLogicName = @"opticTerm";
        _myDevice.text = dict[@"node_NAME"];
    }
    else if ([nodeTypeId isEqualToString:@"702"]) {
        // 光缆纤芯
        _resLogicName = @"optPair";
        NSString * node_NAME = dict[@"node_NAME"];
        NSArray * fenge = [node_NAME componentsSeparatedByString:@"/"];
        if (fenge.count > 0) {
            _myDevice.text = [NSString stringWithFormat:@"纤芯编号 : %@",fenge.lastObject];
        }
        
    }
    else {
        _resLogicName = @"";
    }
    
}


- (void) reload_LinkDict:(NSDictionary *)dict {
    
    _belongDevice.text = dict[@"relateResName"];
    _myDevice.text = dict[@"eptName"];

    _deviceId = dict[@"eptId"] ?: @"";
    
    // 当前设备在路由中的顺序
    _sequence = dict[@"sequence"];
    _rank.text = _sequence;
    
    NSString * eptTypeId = dict[@"eptTypeId"];
    
    // 光端口
    if ([eptTypeId isEqualToString:@"310"]) {
        _resLogicName = @"port";
    }
    
    // 端子
    else if ([eptTypeId isEqualToString:@"317"]) {
        _resLogicName = @"opticTerm";
    }
    
    // 纤芯
    else if ([eptTypeId isEqualToString:@"702"]) {
        _resLogicName = @"optPair";
        
        NSString * eptName = dict[@"eptName"];
        NSArray * fenge = [eptName componentsSeparatedByString:@"/"];
        if (fenge.count > 0) {
            _myDevice.text = [NSString stringWithFormat:@"纤芯编号 : %@",fenge.lastObject];
        } 
    }
    
    // 局向光纤
    else if ([eptTypeId isEqualToString:@"713"]) {
        _resLogicName = @"optLogicPair";
    }
    
    // 文本路由
    else if ([eptTypeId isEqualToString:@"1032"]) {
        _resLogicName = @"trsTextRoute";
    }
    
    else {
        _resLogicName = @"";
    }
}



- (void) isCurrentDevice:(BOOL) isCurrent {
    
    if (isCurrent) {
        _backView.backgroundColor = ColorValue_RGB(0xd2d2d2);
    }
    else {
        _backView.backgroundColor = UIColor.whiteColor;
    }
    
}




#pragma mark -  UI_Init  ---

- (void) UI_Init {
    
    
    _backView = [UIView viewWithColor:UIColor.whiteColor];
    [_backView cornerRadius:5 borderWidth:1 borderColor:ColorValue_RGB(0xc2c2c2)];
    
    [self.contentView addSubview:_backView];
    
    _leftTopIcon = [UIView imageViewWithImg:[UIImage Inc_imageNamed:@"FL_CellRank"] frame:CGRectNull];
    
    
    _rank = [UIView labelWithTitle:@"1" frame:CGRectNull];
    _rank.font = Font_Yuan(12);
    _rank.textColor = UIColor.whiteColor;
    
    
    _belongDevice = [UIView labelWithTitle:@"所属设备" frame:CGRectNull];
    
    _myDevice = [UIView labelWithTitle:@"我当前的设备" frame:CGRectNull];
    
    _belongDevice.numberOfLines = 0;//根据最大行数需求来设置
    _belongDevice.lineBreakMode = NSLineBreakByTruncatingTail;


    _myDevice.numberOfLines = 0;//根据最大行数需求来设置
    _myDevice.lineBreakMode = NSLineBreakByTruncatingTail;
    _myDevice.font = Font_Yuan(13);
    
    _line = [UIView viewWithColor:ColorValue_RGB(0xc2c2c2)];
    
    [_backView addSubviews:@[_leftTopIcon,_rank,_belongDevice,_myDevice,_line]];
    
    [self.contentView bringSubviewToFront:_rank];
    
    [self yuan_layoutAllSubViews];
}






#pragma mark - 屏幕适配

- (void) yuan_layoutAllSubViews {
    
    float limit = Horizontal(15);
    
    [_backView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(limit/2, limit, limit/2, limit)];
    
    [_leftTopIcon autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [_leftTopIcon autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0];
    
    [_rank autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:2];
    [_rank autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:2];
    
    [_belongDevice autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:limit];
    [_belongDevice autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:limit];
    [_belongDevice autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:limit];
    
    [_line autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_belongDevice withOffset:5];
    [_line autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:limit];
    [_line autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:limit];
    [_line autoSetDimension:ALDimensionHeight toSize:1];
    
    [_myDevice autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:limit];
    [_myDevice autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:limit];
    [_myDevice autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:limit];
    
    
}


@end
