//
//  Yuan_MLD_DetailTopView.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/6/28.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_MLD_DetailTopView.h"
#import "Yuan_ML_HttpModel.h"
@implementation Yuan_MLD_DetailTopView
{
    
    NSDictionary * _dict;
    
    // 资源名称
    UILabel * _resName;
    UIView * _line;
    
    
    // 资源类型
    UILabel * _resType;
    UILabel * _resType_Detail;
    
    // 申请时间
    UILabel * _applyTime;
    UILabel * _applyTime_Detail;
    
    // 申请人
    UILabel * _applyPerson;
    UILabel * _applyPerson_Detail;
    
    // 按钮
    UIButton * _agreeBtn;
    UIButton * _noPassBtn;
    
    UILabel * _isAlreadyState;
    
    
    // 警告 !
    UILabel * _warning;
    
}
#pragma mark - 初始化构造方法

- (instancetype)init {
    
    if (self = [super init]) {
        [self UI_Init];
    }
    return self;
}

- (void) reloadDict:(NSDictionary *) dict {
    
    _dict = dict;
    
    _resName.text = dict[@"resName"] ?: @"";
    _applyTime_Detail.text = dict[@"createTime"] ?: @"";
    _applyPerson_Detail.text = dict[@"createBy"] ?: @"";
    _resType_Detail.text = dict[@"resChName"] ?: @"";
}

- (void) hideAllBtn {
    
    _agreeBtn.hidden = YES;
    _noPassBtn.hidden = YES;
    _isAlreadyState.hidden = YES;
    _warning.hidden = NO;
    
}
- (void) btnHidden:(BOOL) needHidden {
    
    _agreeBtn.hidden = needHidden;
    _noPassBtn.hidden = needHidden;
    _isAlreadyState.hidden = YES;
    _isAlreadyState.textColor = UIColor.greenColor;
    
    if (needHidden) {
        NSNumber * authorized = _dict[@"authorized"];
        NSNumber * reject = _dict[@"reject"];
        
        _isAlreadyState.hidden = NO;
        
        if (authorized.intValue == 1) {
            
            _isAlreadyState.textColor = ColorValue_RGB(0x16c046);
            _isAlreadyState.text = @"已通过";
        }
        
        if (reject.intValue == 1) {
            
            _isAlreadyState.textColor = UIColor.mainColor;
            _isAlreadyState.text = @"已不通过";
        }
        
        _isAlreadyState.textAlignment = NSTextAlignmentRight;
        

    }
    
}


#pragma mark - btnClick ---


- (void) agreeClick {
    
    
    [UIAlert alertSmallTitle:@"是否同意级联删除?" agreeBtnBlock:^(UIAlertAction *action) {
            
        [self isAgree:YES];
    }];
    
    
}

- (void) noPassClick {
    
    
    [UIAlert alertSmallTitle:@"是否拒绝级联删除?" agreeBtnBlock:^(UIAlertAction *action) {
        [self isAgree:NO];
    }];
    
}


- (void) isAgree:(BOOL) isAgree {
    
    
    if (isAgree) {
        
        
        NSDictionary * deleteDict = @{
            @"reqDb":Yuan_WebService.webServiceGetDomainCode,
            @"resType": _dict[@"resType"],
            @"gid" : _dict[@"gid"]
        };
        
        
        [Yuan_ML_HttpModel HTTP_MLD_AgreeApply:@{@"id":_dict[@"id"]}
                                       success:^(id  _Nonnull result) {
           
            
            [Yuan_ML_HttpModel HTTP_MLD_Delete:deleteDict
                                       success:^(id  _Nonnull result) {
                        
                if (_reloadSelectBlock) {
                    _reloadSelectBlock();
                }
            }];

            
        }];
    }
    
    else {
        
        [Yuan_ML_HttpModel HTTP_MLD_NoPassApply:@{@"id":_dict[@"id"]}
                                        success:^(id  _Nonnull result) {
                
            [[Yuan_HUD shareInstance] HUDFullText:@"已拒绝删除"];
            
            if (_reloadSelectBlock) {
                _reloadSelectBlock();
            }
        }];
    }
    
}


#pragma mark - UI ---
- (void) UI_Init {
    
    
    _resName = [UIView labelWithTitle:@"资源名称" frame:CGRectNull];
    _line = [UIView viewWithColor:UIColor.clearColor];
    
    _resType =  [UIView labelWithTitle:@"资源类型" frame:CGRectNull];
    _resType_Detail =  [UIView labelWithTitle:@"xxx" frame:CGRectNull];
    _applyTime =  [UIView labelWithTitle:@"申请时间" frame:CGRectNull];
    _applyTime_Detail =  [UIView labelWithTitle:@"2020-05-23 10:45" frame:CGRectNull];
    _applyPerson =  [UIView labelWithTitle:@"申请人" frame:CGRectNull];
    _applyPerson_Detail =  [UIView labelWithTitle:@"无情哈拉少" frame:CGRectNull];
    
    _agreeBtn = [UIView buttonWithTitle:@"通过"
                              responder:self
                                    SEL:@selector(agreeClick)
                                  frame:CGRectNull];
    
    _noPassBtn = [UIView buttonWithTitle:@"不通过"
                               responder:self
                                     SEL:@selector(noPassClick)
                                   frame:CGRectNull];
    
    _isAlreadyState = [UIView labelWithTitle:@"已通过" frame:CGRectNull];
    _isAlreadyState.hidden = YES;
    
    
    _resName.font = Font_Bold_Yuan(16);
    
    _resName.numberOfLines = 0;//根据最大行数需求来设置
    _resName.lineBreakMode = NSLineBreakByTruncatingTail;
    
    _resType.textColor = _applyTime.textColor = _applyPerson.textColor = ColorValue_RGB(0x666666);
    
    
    
    _resType_Detail.backgroundColor = ColorValue_RGB(0xffeed6);
    _resType_Detail.textColor = UIColor.orangeColor;
    _applyTime_Detail.textColor = UIColor.mainColor;
    
    _agreeBtn.backgroundColor = ColorValue_RGB(0x16c046);
    [_agreeBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    
    _noPassBtn.backgroundColor = ColorValue_RGB(0xf0f0f0);
    [_noPassBtn setTitleColor:UIColor.darkGrayColor forState:UIControlStateNormal];
    
    _warning = [UIView labelWithTitle:@"⚠️ 部分资源没有权限，无法审核。"
                                frame:CGRectNull];
    _warning.backgroundColor = UIColor.yellowColor;
    _warning.hidden = YES;
    
    
    
    [self addSubviews:@[_resName,
                        _line,
                        _resType,
                        _resType_Detail,
                        _applyTime,
                        _applyTime_Detail,
                        _applyPerson,
                        _applyPerson_Detail,
                        _agreeBtn,
                        _noPassBtn,
                        _isAlreadyState,
                        _warning]];
    
    [self yuan_LayoutSubViews];
}


- (void) yuan_LayoutSubViews {
    
    float limit = Horizontal(10);
    
    [_warning YuanToSuper_Top:0];
    [_warning YuanToSuper_Right:0];
    [_warning YuanToSuper_Left:0];
    [_warning Yuan_EdgeHeight:Vertical(25)];
    
    [_resName YuanMyEdge:Top ToViewEdge:Bottom ToView:_warning inset:limit/2];
    [_resName autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:limit];
    [_resName autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:limit];
    
    [_line autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:limit];
    [_line autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:limit];
    [_line autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_resName withOffset:limit];
    [_line autoSetDimension:ALDimensionHeight toSize:1];
    
    // 资源类型
    [_resType autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_line withOffset:limit];
    [_resType autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:limit];
    [_resType autoSetDimension:ALDimensionWidth toSize:Horizontal(60)];
    
    [_resType_Detail YuanAttributeHorizontalToView:_resType];
    [_resType_Detail autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:_resType withOffset:limit];
    
    
    // 申请时间
    [_applyTime autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_resType withOffset:limit];
    [_applyTime autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:limit];
    [_applyTime autoSetDimension:ALDimensionWidth toSize:Horizontal(60)];
    
    [_applyTime_Detail YuanAttributeHorizontalToView:_applyTime];
    [_applyTime_Detail autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:_applyTime withOffset:limit];
    
    
    
    
    // 申请人
    
    [_applyPerson autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_applyTime withOffset:limit];
    [_applyPerson autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:limit];
    [_applyPerson autoSetDimension:ALDimensionWidth toSize:Horizontal(60)];
    
    [_applyPerson_Detail YuanAttributeHorizontalToView:_applyPerson];
    [_applyPerson_Detail autoPinEdge:ALEdgeLeft
                              toEdge:ALEdgeRight
                              ofView:_applyPerson
                          withOffset:limit];
    
    
    // 批准 不同意
    [_agreeBtn autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:limit];
    [_agreeBtn autoConstrainAttribute:ALAttributeHorizontal toAttribute:ALAttributeHorizontal ofView:self withMultiplier:0.65];
    [_agreeBtn autoSetDimensionsToSize:CGSizeMake(Horizontal(60), Vertical(30))];
    
    [_noPassBtn autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:limit];
    [_noPassBtn autoConstrainAttribute:ALAttributeHorizontal toAttribute:ALAttributeHorizontal ofView:self withMultiplier:1.35];
    [_noPassBtn autoSetDimensionsToSize:CGSizeMake(Horizontal(60), Vertical(30))];
    
    
    [_isAlreadyState YuanToSuper_Right:Horizontal(15)];
    [_isAlreadyState YuanAttributeHorizontalToView:self];
    [_isAlreadyState autoSetDimensionsToSize:CGSizeMake(Horizontal(60), Vertical(30))];

}
@end
