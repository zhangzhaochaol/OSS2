//
//  Inc_PairNoChangeTipView.h
//  OSS2.0-ios-v2
//
//  Created by zzc on 2021/9/9.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface Inc_PairNoChangeTipView : UIView


//纤芯编号变更输入框
@property (nonatomic, strong) UITextField *pairNoTextField;

//复选框按钮
@property (nonatomic, strong) UIButton *checkBtn;

//按钮回调
@property (nonatomic, copy) void (^btnBlock)(UIButton *btn,NSArray *postArr);


//高度回调
@property (nonatomic, copy) void (^heightBlock)(CGFloat height);




//数据
-(void)setDataSource:(NSArray *)array index:(int)index;

-(void)cleareData ;

@end



