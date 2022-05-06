//
//  Inc_CableListCell.m
//  OSS2.0-ios-v2
//
//  Created by zzc on 2021/9/14.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_CableListCell.h"

@interface Inc_CableListCell ()

{
    //灰色背景
    UIView *_bgView;
    
    
    //所属光缆的提示
    UILabel *_belongCable;
    //所属光缆
    UILabel *_belongLabel;
    
    //光缆段名称
    UILabel *_cableName;
    
   
    

    
    //起始设施
    UILabel *_startF;
    //终止设施
    UILabel *_endF;
    //起始设施名称
    UILabel *_startFName;
    //终止设施名称
    UILabel *_endFName;

    //横线
    UIView *_hLine;
    
    
}


@end

@implementation Inc_CableListCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = UIColor.whiteColor;
    
        
        [self setupUI];
        
    }
    
    return self;
}


-(void)setupUI {
    
    _bgView = [UIView viewWithColor:HexColor(@"#F3F3F3")];
    
    
    _belongCable = [UIView labelWithTitle:@"所属光缆:" frame:CGRectNull];
    
    _belongLabel = [UIView labelWithTitle:@"" isZheH:YES];
    _belongLabel.textColor = HexColor(@"#939393");

    
    _cableName = [UIView labelWithTitle:@"" isZheH:YES];
    _cableName.font = Font_Yuan(16);
    _cableName.textColor = UIColor.blackColor;
    
    _startF = [UILabel labelWithTitle:@"起" frame:CGRectNull];
    _startF.textAlignment = NSTextAlignmentCenter;
    _startF.font = Font(13);
    _startF.textColor = UIColor.whiteColor;
    _startF.backgroundColor = HexColor(@"#AFAFAF");
    [_startF setCornerRadius:3 borderColor:UIColor.clearColor borderWidth:1];
    
    
    _startFName = [UIView labelWithTitle:@"" isZheH:YES];
    _startFName.font = Font(13);
    _startFName.textColor = _belongLabel.textColor;
    
    _endF = [UILabel labelWithTitle:@"终" frame:CGRectNull];
    _endF.textAlignment = NSTextAlignmentCenter;
    _endF.font = Font(13);
    _endF.textColor = _startF.textColor;
    _endF.backgroundColor = _startF.backgroundColor;
    [_endF setCornerRadius:3 borderColor:UIColor.clearColor borderWidth:1];
    
    
    _endFName = [UIView labelWithTitle:@"" isZheH:YES];
    _endFName.font = Font(13);
    _endFName.textColor = _belongLabel.textColor;

    _hLine = [UIView viewWithColor:HexColor(@"#EFEFEF")];

    
    [self.contentView addSubview:_bgView];

    
    [_bgView addSubviews:@[_belongCable,
                           _belongLabel,
                           _cableName,
                           _startF,
                           _startFName,
                           _endF,
                           _endFName,
                           _hLine
    ]];
    
}



- (void)setDic:(NSDictionary *)dic {
    _dic = dic;
    
    _belongLabel.text = dic[@"optName"];
    _cableName.text = dic[@"resName"];
    _startFName.text = dic[@"sname"];
    _endFName.text = dic[@"ename"];


    [self autolayoutFrame];
}


-(void)autolayoutFrame {
    
    CGFloat limit = Horizontal(10);

    CGRect frame = [self frame];

    CGFloat belongWidth = [_belongCable.text boundingRectWithSize:CGSizeMake(ScreenWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_belongCable.font} context:nil].size.width + 5;

    //所属光缆
    CGFloat belongHeight = [_belongLabel.text boundingRectWithSize:CGSizeMake(ScreenWidth - 2*limit - belongWidth - 20 - 10, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_belongLabel.font} context:nil].size.height + 5;

    //起始设施名称
    CGFloat sFnameHeight = [_startFName.text boundingRectWithSize:CGSizeMake(ScreenWidth - 3*limit - 20 - 20, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_startFName.font} context:nil].size.height +10;
    
    //终止设施名称
    CGFloat eFNameHeight = [_endFName.text boundingRectWithSize:CGSizeMake(ScreenWidth - 3*limit - 20 -20, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_endFName.font} context:nil].size.height +5;
    
    //光缆段名称
    CGFloat cableHeight = [_cableName.text boundingRectWithSize:CGSizeMake(ScreenWidth - 2*limit - 20, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_cableName.font} context:nil].size.height + 10;

    _bgView.frame = CGRectMake(10, 10, ScreenWidth - 20, 100);
    
    _belongCable.frame = CGRectMake(limit, 0, belongWidth, 40);
    
    _belongLabel.frame = CGRectMake(_belongCable.x + _belongCable.width + 5, 0, _bgView.width - 10 - (_belongCable.x + _belongCable.width + 5), MAX(40, belongHeight));
    
    _cableName.frame = CGRectMake(limit, _belongLabel.y+_belongLabel.height + 5, _bgView.width -2*limit, MAX(cableHeight, 30));
   
    _hLine.frame = CGRectMake(0, _cableName.y+_cableName.height+limit/2-1, _bgView.width, 1);
   
    _startF.frame = CGRectMake(limit, 0, 20, 20);
    
    _startFName.frame = CGRectMake(_startF.x+_startF.width + limit, _hLine.y+_hLine.height, _bgView.width - limit - (_startF.x+_startF.width + limit), MAX(30, sFnameHeight));
    _startF.centerY = _startFName.centerY;
    
    _endF.frame = CGRectMake(_startF.x, 0, _startF.width, _startF.height);
   
    _endFName.frame = CGRectMake(_startFName.x, _startFName.y+_startFName.height, _startFName.width, MAX(30, eFNameHeight));
    _endF.centerY = _endFName.centerY;

    _bgView.frame = CGRectMake(10, 10, ScreenWidth - 20,  _endFName.y + _endFName.height + 5);

    frame.size.height = _bgView.height + _bgView.y;
    
    self.frame = frame;
}

//多条数据滚动后可能出现内容显示不全
//-(void)autolayout {
//
//    CGFloat limit = Horizontal(10);
//
//
//
//    CGFloat belongWidth = [_belongCable.text boundingRectWithSize:CGSizeMake(ScreenWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_belongCable.font} context:nil].size.width + 5;
//
//
//    //所属光缆
//    CGFloat belongHeight = [_belongLabel.text boundingRectWithSize:CGSizeMake(ScreenWidth - 2*limit - belongWidth - 20 - 10, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_belongLabel.font} context:nil].size.height + 5;
//
//    //起始设施名称
//    CGFloat sFnameHeight = [_startFName.text boundingRectWithSize:CGSizeMake(ScreenWidth - 3*limit - 20 - 20, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_startFName.font} context:nil].size.height +10;
//
//    //终止设施名称
//    CGFloat eFNameHeight = [_endFName.text boundingRectWithSize:CGSizeMake(ScreenWidth - 3*limit - 20 -20, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_endFName.font} context:nil].size.height +5;
//
//    //光缆段名称
//    CGFloat cableHeight = [_cableName.text boundingRectWithSize:CGSizeMake(ScreenWidth - 2*limit - 20, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_cableName.font} context:nil].size.height + 10;
//
//
//
//    CGFloat bgHeight = MAX(40, belongHeight) + MAX(cableHeight, 30) + MAX(30, sFnameHeight) + MAX(30, eFNameHeight) + 5 + limit/2;
//
//    [_bgView YuanToSuper_Top:10];
//    [_bgView YuanToSuper_Left:10];
//    [_bgView YuanToSuper_Right:10];
//    [_bgView YuanToSuper_Bottom:0];
//    [_bgView autoSetDimension:ALDimensionHeight toSize:bgHeight];
//
//
//
//    [_belongCable YuanToSuper_Top:0];
//    [_belongCable YuanToSuper_Left:limit];
//    [_belongCable autoSetDimensionsToSize:CGSizeMake(belongWidth, 40)];
//
//
//
//    [_belongLabel YuanToSuper_Top:0];
//    [_belongLabel YuanToSuper_Right:limit];
//    [_belongLabel autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:_belongCable withOffset:5];
//    [_belongLabel autoSetDimension:ALDimensionHeight toSize:MAX(40, belongHeight)];
//
//
//    [_cableName autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_belongLabel withOffset:5];
//    [_cableName YuanToSuper_Left:limit];
//    [_cableName YuanToSuper_Right:limit];
//    [_cableName autoSetDimension:ALDimensionHeight toSize:MAX(cableHeight, 30)];
//
//
//    [_hLine autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_cableName withOffset:limit/2-1];
//    [_hLine YuanToSuper_Right:0];
//    [_hLine YuanToSuper_Left:0];
//    [_hLine autoSetDimension:ALDimensionHeight toSize:1];
//
//
//    [_startF autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_hLine withOffset:(MAX(30, sFnameHeight) - 20)/2];
//    [_startF YuanToSuper_Left:limit];
//    [_startF autoSetDimensionsToSize:CGSizeMake(20, 20)];
//
//    [_startFName autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_hLine];
//    [_startFName YuanToSuper_Right:limit];
//    [_startFName autoSetDimension:ALDimensionHeight toSize:MAX(30, sFnameHeight)];
//    [_startFName autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:_startF withOffset:limit];
//
//    [_endF autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_startF withOffset:(MAX(30, sFnameHeight) - 20)/2 + (MAX(30, eFNameHeight) - 20)/2];
//    [_endF YuanToSuper_Left:limit];
//    [_endF autoSetDimensionsToSize:CGSizeMake(20, 20)];
//
//    [_endFName autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_startFName];
//    [_endFName YuanToSuper_Right:limit];
//    [_endFName autoSetDimension:ALDimensionHeight toSize:MAX(30, eFNameHeight)];
//    [_endFName autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:_endF withOffset:limit];
//    [_endFName YuanToSuper_Bottom:0];
//
//
//
//}








- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
