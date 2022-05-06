//
//  Inc_CableHeadView.m
//  OSS2.0-ios-v2
//
//  Created by zzc on 2021/9/14.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_CableHeadView.h"

@interface Inc_CableHeadView ()
{
    
    //所属光缆的提示
    UILabel *_belongCable;
    //所属光缆
    UILabel *_belongLabel;
    
    //光缆段名称
    UILabel *_cableName;
    
    //纤芯背景view
    UIView *_pairBgView;
    //纤芯数量提示
    UILabel *_pairNumTip;
    //纤芯数量
    UILabel *_pairNum;

    
    //设施 背景
    UIView *_facilityView;
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
    //竖线
    UIView *_vLine;
}

@end

@implementation Inc_CableHeadView

-(instancetype)initWithFrame:(CGRect)frame {
    if (self == [super initWithFrame:frame]) {
        
        self.backgroundColor = UIColor.whiteColor;

        [self createUI];
    }
    
    return self;
}

-(void)createUI {
    
    
    _belongCable = [UIView labelWithTitle:@"所属光缆:" frame:CGRectNull];
    
    _belongLabel = [UIView labelWithTitle:@"" isZheH:YES];
    _belongLabel.textColor = HexColor(@"#FF8080");
    
    _cableName = [UIView labelWithTitle:@"" isZheH:YES];
    _cableName.font = Font_Yuan(16);
    _cableName.textColor = UIColor.blackColor;
    
    
    _pairBgView = [UIView viewWithColor:UIColor.whiteColor];
    
    _pairNumTip = [UIView labelWithTitle:@"纤芯数" frame:CGRectNull];
    _pairNumTip.textAlignment = NSTextAlignmentCenter;
    _pairNumTip.textColor = HexColor(@"#939393");
    
    _pairNum = [UIView labelWithTitle:@"" frame:CGRectNull];
    _pairNum.textAlignment = NSTextAlignmentCenter;
    _pairNum.textColor = _belongLabel.textColor;
    _pairNum.font = Font_Yuan(30);
    
 
    
    _facilityView = [UIView viewWithColor:UIColor.whiteColor];

    _startF = [UILabel labelWithTitle:@"起始设施" frame:CGRectNull];
    _startF.textAlignment = NSTextAlignmentCenter;
    _startF.font = Font(13);
    _startF.textColor = ColorR_G_B(173, 213, 174);
    _startF.backgroundColor = ColorR_G_B(226, 245, 226);
    [_startF setCornerRadius:4 borderColor:_startF.textColor borderWidth:1];
    
    
    _startFName = [UIView labelWithTitle:@"" isZheH:YES];
    _startFName.font = Font(13);
    _startFName.textColor = _pairNumTip.textColor;
    
    
    _endF = [UILabel labelWithTitle:@"终止设施" frame:CGRectNull];
    _endF.textAlignment = NSTextAlignmentCenter;
    _endF.font = Font(13);
    _endF.textColor = HexColor(@"#FF8080");
    _endF.backgroundColor = ColorR_G_B(246, 215, 208);
    [_endF setCornerRadius:4 borderColor:_endF.textColor borderWidth:1];
    
    
    _endFName = [UIView labelWithTitle:@"" isZheH:YES];
    _endFName.font = Font(13);
    _endFName.textColor = _pairNumTip.textColor;

    
    _hLine = [UIView viewWithColor:HexColor(@"#EFEFEF")];
    
    _vLine = [UIView viewWithColor:HexColor(@"#EFEFEF")];

    [self addSubviews:@[_belongCable,
                        _belongLabel,
                        _cableName,
                        _pairBgView,
                        _facilityView,
                        _hLine,
                        _vLine]];
    
    
    [_pairBgView addSubviews:@[_pairNumTip,_pairNum]];
    
    [_facilityView addSubviews:@[_startF,_endF,_startFName,_endFName]];

}

- (void)setMb_Dict:(NSDictionary *)mb_Dict {
    _mb_Dict = mb_Dict;
    
    _belongLabel.text = mb_Dict[@"route"];
    _cableName.text = mb_Dict[@"cableName"];
    _pairNum.text = mb_Dict[@"capacity"];
    _startFName.text = mb_Dict[@"cableStart"];
    _endFName.text = mb_Dict[@"cableEnd"];

    
    
    
    [self autoLayout];
}

-(void)autoLayout {
    
    CGFloat limit = Horizontal(10);
    
    CGFloat belongWidth = [_belongCable.text boundingRectWithSize:CGSizeMake(ScreenWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_belongCable.font} context:nil].size.width + 5;
    
    [_belongCable YuanToSuper_Top:0];
    [_belongCable YuanToSuper_Left:limit];
    [_belongCable autoSetDimensionsToSize:CGSizeMake(belongWidth, 40)];

    CGFloat belongHeight = [_belongLabel.text boundingRectWithSize:CGSizeMake(ScreenWidth - 2*limit - belongWidth , MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_belongLabel.font} context:nil].size.height + 5;

    
    [_belongLabel YuanToSuper_Top:0];
    [_belongLabel YuanToSuper_Right:limit];
    [_belongLabel autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:_belongCable withOffset:5];
    [_belongLabel autoSetDimension:ALDimensionHeight toSize:MAX(40, belongHeight)];

    CGFloat cableHeight = [_cableName.text boundingRectWithSize:CGSizeMake(ScreenWidth - 2*limit, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_cableName.font} context:nil].size.height + 5;

    [_cableName autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_belongLabel withOffset:5];
    [_cableName YuanToSuper_Left:limit];
    [_cableName YuanToSuper_Right:limit];
    [_cableName autoSetDimension:ALDimensionHeight toSize:MAX(cableHeight, 30)];
    
    
    CGFloat facilityWidth = [_startF.text boundingRectWithSize:CGSizeMake(ScreenWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_startF.font} context:nil].size.width + 10;
    
    
    CGFloat sFnameHeight = [_startFName.text boundingRectWithSize:CGSizeMake(ScreenWidth - 3*limit - 62 - facilityWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_startFName.font} context:nil].size.height +5;
    
    
    CGFloat eFNameHeight = [_endFName.text boundingRectWithSize:CGSizeMake(ScreenWidth - 3*limit - 62 - facilityWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_endFName.font} context:nil].size.height +5;
    
    
    
    [_pairBgView  YuanToSuper_Left:0];
    [_pairBgView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_cableName withOffset:limit];
    [_pairBgView autoSetDimensionsToSize:CGSizeMake(60, MAX(30, sFnameHeight) + MAX(30, eFNameHeight))];
    
    
    [_pairNumTip YuanToSuper_Top:1];
    [_pairNumTip YuanToSuper_Left:1];
    [_pairNumTip YuanToSuper_Right:0];
    [_pairNumTip autoSetDimension:ALDimensionHeight toSize:20];
    
    [_pairNum autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_pairNumTip];
    [_pairNum YuanToSuper_Left:0];
    [_pairNum YuanToSuper_Right:1];
    [_pairNum YuanToSuper_Bottom:0];

    
    [_facilityView autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:_pairBgView];
    [_facilityView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_cableName withOffset:limit];
    [_facilityView autoSetDimension:ALDimensionHeight toSize:MAX(30, sFnameHeight) + MAX(30, eFNameHeight)];
    [_facilityView YuanToSuper_Right:0];
    
    [_hLine autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_cableName withOffset:limit-1];
    [_hLine YuanToSuper_Right:0];
    [_hLine YuanToSuper_Left:0];
    [_hLine autoSetDimension:ALDimensionHeight toSize:1];
    


    [_startF YuanToSuper_Top:(MAX(30, sFnameHeight) - 20)/2];
    [_startF YuanToSuper_Left:limit];
    [_startF autoSetDimensionsToSize:CGSizeMake(facilityWidth, 20)];
    
    [_startFName YuanToSuper_Top:0];
    [_startFName YuanToSuper_Right:limit];
    [_startFName autoSetDimension:ALDimensionHeight toSize:MAX(30, sFnameHeight)];
    [_startFName autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:_startF withOffset:limit];
    
    [_endF autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_startF withOffset:(MAX(30, sFnameHeight) - 20)/2 + (MAX(30, eFNameHeight) - 20)/2];
    [_endF YuanToSuper_Left:limit];
    [_endF autoSetDimensionsToSize:CGSizeMake(facilityWidth, 20)];
    
    [_endFName autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_startFName];
    [_endFName YuanToSuper_Right:limit];
    [_endFName autoSetDimension:ALDimensionHeight toSize:MAX(30, eFNameHeight)];
    [_endFName autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:_endF withOffset:limit];
    
    [_vLine autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_cableName withOffset:limit];
    [_vLine autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:_pairBgView];
    [_vLine autoSetDimensionsToSize:CGSizeMake(1, MAX(30, sFnameHeight) + MAX(30, eFNameHeight))];
    
    
    if (self.heightBlok) {
        self.heightBlok(MAX(cableHeight, 30) + MAX(40, belongHeight) + MAX(30, sFnameHeight) + MAX(30, eFNameHeight) +limit  + 5);
    }
}
@end
