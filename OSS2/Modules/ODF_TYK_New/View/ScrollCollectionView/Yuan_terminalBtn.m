//
//  Yuan_terminalBtn.m
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/6/4.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_terminalBtn.h"

@implementation Yuan_terminalBtn

{
    
    NSDictionary * _myDict;
    
    
    UILabel * _myUnionStateLabel;
    
    BOOL _isNeedChangeState;
}
   



- (void)setDict:(NSDictionary *)dict {
    
    _myDict = dict;
    
    self.layer.borderWidth = 0.5;
    self.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    NSInteger oprStateId = [dict[@"oprStateId"] integerValue];

    
    /*
        TODO:  1. 询问 为何保存后 oprStateId 还是 1 没有成功修改
        TODO:  2. 修改后 应该如何变化 按钮颜色 ??
    */
    
    switch (oprStateId) {
        case 2:     //预占
        case 4:     //预释放
        case 5:     //预留
        case 6:     //预选
        case 7:     //备用
        case 11:    //测试
        case 12:    //临时占用
            
            self.backgroundColor = ColorR_G_B(252, 160, 0);
            [self setTitleColor:[UIColor whiteColor]
                       forState:UIControlStateNormal];
            break;
        
        case 3:     //占用
        
            
            self.backgroundColor = ColorR_G_B(147, 222, 113);
            [self setTitleColor:[UIColor whiteColor]
                       forState:UIControlStateNormal];
            break;
        
        case 8:     //停用
        case 10:    //损坏
            
            self.backgroundColor = ColorR_G_B(255, 0, 44);
            [self setTitleColor:[UIColor whiteColor]
                       forState:UIControlStateNormal];
            break;
            
        default:    //1.空闲 9.闲置
            
            self.backgroundColor = ColorR_G_B(232, 232, 232);
            [self setTitleColor:ColorValue_RGB(0x929292)
                       forState:UIControlStateNormal];
            break;
    }
    
    
    
}


- (NSDictionary *)dict {
    
    return _myDict;
}





/// 修改业务状态 ID 让按钮改变颜色
/// @param oprStateId oprStateId
- (void) change_OprStateId:(NSString *)oprStateId {
    
    
    
    NSInteger oprStateId_Switch = [oprStateId integerValue];

    
    /*
        TODO:  1. 询问 为何保存后 oprStateId 还是 1 没有成功修改
        TODO:  2. 修改后 应该如何变化 按钮颜色 ??
    */
    
    switch (oprStateId_Switch) {
        case 2:     //预占
        case 4:     //预释放
        case 5:     //预留
        case 6:     //预选
        case 7:     //备用
        case 11:    //测试
        case 12:    //临时占用
            
            self.backgroundColor = ColorR_G_B(252, 160, 0);
            [self setTitleColor:[UIColor whiteColor]
                       forState:UIControlStateNormal];
            break;
        
        case 3:     //占用
        
            
            self.backgroundColor = ColorR_G_B(147, 222, 113);
            [self setTitleColor:[UIColor whiteColor]
                       forState:UIControlStateNormal];
            break;
        
        case 8:     //停用
        case 10:    //损坏
            
            self.backgroundColor = ColorR_G_B(255, 0, 44);
            [self setTitleColor:[UIColor whiteColor]
                       forState:UIControlStateNormal];
            break;
            
        default:    //1.空闲 9.闲置
            
            self.backgroundColor = ColorR_G_B(232, 232, 232);
            [self setTitleColor:ColorValue_RGB(0x929292)
                       forState:UIControlStateNormal];
            break;
    }
    
    
    // 需要把端子的 dict 状态也一并重置 不然 再次点进去 端子状态显示不变 

    NSMutableDictionary * newDict = [NSMutableDictionary dictionaryWithDictionary:_myDict];
    
    newDict[@"oprStateId"] = oprStateId;
    
    _myDict = newDict;
    
}



- (void) showMyUnionPhotoState:(NSDictionary *)unionDict {
    
    NSString * class = unionDict[@"class"];
    
    if (!class || [class obj_IsNull]) {
        return;
    }
    
//    [4]    (null)    @"oprStateId" : @"1"
    
    // 1空闲 3 占用
    // u空闲 p 占用
    
    NSString * oprStateId = _myDict[@"oprStateId"] ?: @"";
    
    NSString * classOprStateId ;
    
    if ([oprStateId isEqualToString:@"1"]) {
        classOprStateId = @"u";
    }
    else if ([oprStateId isEqualToString:@"p"]) {
        
        classOprStateId = @"p";
    }
    else {
        classOprStateId = @"";
    }
    
    
    // 不等 变红色
    if (![class isEqualToString:classOprStateId]) {
        [self cornerRadius:0 borderWidth:1 borderColor:UIColor.mainColor];
        _isNeedChangeState = YES;
    }
    else {
        _isNeedChangeState = NO;
    }
    
    
    
    if (!_myUnionStateLabel) {
        _myUnionStateLabel = [UIView labelWithTitle:class
                                              frame:CGRectMake(0, 0, 15, 15)];
    }
    
    _myUnionStateLabel.text = class;
    
    
    if ([class isEqualToString:@"u"]) {
        _myUnionStateLabel.backgroundColor = UIColor.greenColor;
    }
    else {
        _myUnionStateLabel.backgroundColor = UIColor.mainColor;
    }
    
    _myUnionStateLabel.textColor = UIColor.whiteColor;
    _myUnionStateLabel.textAlignment = NSTextAlignmentCenter;
    
    [self addSubview:_myUnionStateLabel];
}



- (void) hideMyUnionPhotoState:(BOOL) isNeedClearUnionLabel {
    
    [self cornerRadius:0 borderWidth:0 borderColor:UIColor.clearColor];
    
    if (isNeedClearUnionLabel) {
        [_myUnionStateLabel removeFromSuperview];
        _myUnionStateLabel = nil;
    }
    
    
}



/// 2021年1月新增

- (BOOL) isNeedChangeState {
    
    
    return _isNeedChangeState;
}


- (void) redBorder:(BOOL)isNeedRedBorder {
    
    UIColor * borderColor ;
    float limit = 1;
    if (isNeedRedBorder) {
        borderColor = UIColor.mainColor;
    }
    else {
        borderColor = UIColor.whiteColor;
    }
    
    [self cornerRadius:0 borderWidth:limit borderColor:borderColor];
    
}


@end
