//
//  Yuan_DoublePieCell.m
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/5/29.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_DoublePieCell.h"



const float PieWidth = 101;
const float PieHeight = 50;


@implementation Yuan_DoublePieCell

#pragma mark - 初始化构造方法

- (instancetype) initWithStyle:(UITableViewCellStyle)style
               reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        
        [self.contentView addSubview:self.Pie_A];
        [self.contentView addSubview:self.Pie_B];
        
        [self layoutAllSubViews];
        
    }
    return self;
}


#pragma mark - 信息配置

/*
    根据 position 判断 ***
*/


- (void) A_Dict:(NSDictionary *)dict isFaceInverse:(BOOL) isFaceInverse{
    
    [self dictConfigPie:_Pie_A dict:dict
          isFaceInverse:isFaceInverse];
}



- (void) B_Dict:(NSDictionary *)dict isFaceInverse:(BOOL) isFaceInverse{
    
    [self dictConfigPie:_Pie_B dict:dict
          isFaceInverse:isFaceInverse];
}





- (void) dictConfigPie:(Yuan_Pie *)pie
                  dict:(NSDictionary *)dict
         isFaceInverse:(BOOL) isFaceInverse{
    
    
    pie.dict = dict;
    
    NSString * position = dict[@"position"];
    
    [pie setCountNum:position];
    
    NSInteger count = [position integerValue] ;
    
    pie.index = count;
    
    if (dict.allKeys.count == 1) {
        // 证明是假数据的占位dict
        [pie changePieState:PieState_Normal_Gray];
        
        pie.hidden = YES;
        
        return;
    }
    
    // 其他情况 是彩色的状态
    [pie changePieState:PieState_Colorful];
    
    
    NSString * dict_faceInverse  =  dict[@"faceInverse"];
    // 1 - 正面, 2 - 反面
    
    if (isFaceInverse) {
        // 当前需要显示的是正面  正面 要让 dict_faceInverse = 1 才显示
        // 2020.08.28新增 无的状态 -- faceInverse = 3
        if ([dict_faceInverse isEqualToString:@"1"] ||
            [dict_faceInverse isEqualToString:@"3"]) {
            pie.hidden = NO;
        }else {
            pie.hidden = YES;
        }
        
        
    }else {
        // 当前需要显示的是反面  反面 要让 dict_faceInverse = 2 才显示
        
        if ([dict_faceInverse isEqualToString:@"2"]) {
            pie.hidden = NO;
        }else {
            pie.hidden = YES;
        }
    }
}




#pragma mark - lazy load

- (Yuan_Pie *)Pie_A {
    
    if (!_Pie_A) {
        _Pie_A = [[Yuan_Pie alloc] initWithState:PieState_Colorful];
    }
    return _Pie_A;
}


- (Yuan_Pie *)Pie_B {
    
    if (!_Pie_B) {
        _Pie_B = [[Yuan_Pie alloc] initWithState:PieState_Normal_Gray];
    }
    return _Pie_B;
}


#pragma mark - 屏幕适配

- (void)layoutAllSubViews {
    
    
    /// A
    
    [_Pie_A autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:Horizontal(20)];
    
    [_Pie_A autoConstrainAttribute:ALAttributeHorizontal
                       toAttribute:ALAttributeHorizontal
                            ofView:self
                    withMultiplier:1.0];
    
    [_Pie_A autoSetDimensionsToSize:CGSizeMake(Horizontal(PieWidth), Vertical(PieHeight))];
    
    
    
    /// B
    
    [_Pie_B autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:Horizontal(20)];
    
    [_Pie_B autoConstrainAttribute:ALAttributeHorizontal
                       toAttribute:ALAttributeHorizontal
                            ofView:self
                    withMultiplier:1.0];
    
    [_Pie_B autoSetDimensionsToSize:CGSizeMake(Horizontal(PieWidth), Vertical(PieHeight))];
    
}



@end
