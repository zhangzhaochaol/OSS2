//
//  Yuan_SinglePieCell.m
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/5/29.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_SinglePieCell.h"





@implementation Yuan_SinglePieCell

#pragma mark - 初始化构造方法

- (instancetype) initWithStyle:(UITableViewCellStyle)style
               reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        
        self.userInteractionEnabled = YES;
        self.contentView.userInteractionEnabled = YES;
        
        [self.contentView addSubview:self.Pie_A];
        [self layoutAllSubViews];
        
    }
    return self;
}



#pragma mark - 信息配置

/*
    count  当前显示的数字
    state  当前的状态   0 未选中 1 选中
*/

- (void) A_Dict:(NSDictionary *)dict
  isFaceInverse:(BOOL)isFaceInverse{
    
    _Pie_A.dict = dict;
    
    NSString * position = dict[@"position"];
    
    [_Pie_A setCountNum:position];
    
    NSInteger count = [position integerValue] ;
    
    _Pie_A.index = count;
    
    
    
    if (dict.allKeys.count == 1) {
        // 证明是假数据的占位dict
        [_Pie_A changePieState:PieState_Normal_Gray];
        
        _Pie_A.hidden = YES;
        
        return;
    }
    
    // 其他情况 是彩色的状态
    [_Pie_A changePieState:PieState_Colorful];
    
    
    
    NSString * dict_faceInverse  =  dict[@"faceInverse"];
    // 1 - 正面, 2 - 反面
    
    if (isFaceInverse) {
        // 当前需要显示的是正面  正面 要让 dict_faceInverse = 1 才显示
        // 2020.08.28新增 无的状态 -- faceInverse = 3
        if ([dict_faceInverse isEqualToString:@"1"] ||
            [dict_faceInverse isEqualToString:@"3"]) {
            _Pie_A.hidden = NO;
        }else {
            _Pie_A.hidden = YES;
        }
        
        
    }else {
        // 当前需要显示的是反面  反面 要让 dict_faceInverse = 2 才显示
        
        if ([dict_faceInverse isEqualToString:@"2"]) {
            _Pie_A.hidden = NO;
        }else {
            _Pie_A.hidden = YES;
        }
    }
    
}





- (Yuan_Pie *)Pie_A {
    
    if (!_Pie_A) {
        _Pie_A = [[Yuan_Pie alloc] initWithState:PieState_Colorful];
    }
    return _Pie_A;
}

- (void)layoutAllSubViews {

    /// A

    float PieWidth = 101;
    float PieHeight = 50;

    [_Pie_A autoConstrainAttribute:ALAttributeHorizontal
                       toAttribute:ALAttributeHorizontal
                            ofView:self
                    withMultiplier:1.0];
    
    [_Pie_A autoConstrainAttribute:ALAttributeVertical
                       toAttribute:ALAttributeVertical
                            ofView:self
                    withMultiplier:1.0];

    [_Pie_A autoSetDimensionsToSize:CGSizeMake(Horizontal(PieWidth), Vertical(PieHeight))];

}

@end
