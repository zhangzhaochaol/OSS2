//
//  Yuan_MoreLevelDeleteTipsView.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/1/25.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_MoreLevelDeleteTipsView.h"

@implementation Yuan_MoreLevelDeleteTipsView

{
    
    UILabel * _title;
    
    UILabel * _msg;
}



#pragma mark - 初始化构造方法

- (instancetype)init {
    
    if (self = [super init]) {
        _title = [UIView labelWithTitle:@"什么是级联删除" frame:CGRectNull];
        _title.font = Font_Bold_Yuan(14);
        
        _msg = [UIView labelWithTitle:@"级联删除功能不仅会删除当前资源，还会删除下属资源和下属资源与其他资源的关联关系。由于涉及多资源删除，系统会自动形成张级联删除工单，由管理员进行确认删除" frame:CGRectNull];
        
        _msg.numberOfLines = 0;//根据最大行数需求来设置
        _msg.lineBreakMode = NSLineBreakByTruncatingTail;
        
        _msg.textColor = UIColor.lightGrayColor;
        
        
        [self addSubviews:@[_title,_msg]];
        [self yuan_LayoutSubViews];
    }
    return self;
}


- (void) yuan_LayoutSubViews {
    
    float limit = 5;
    
    [_title autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:limit];
    [_title autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:limit];
    
    [_msg autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_title withOffset:limit];
    [_msg autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:limit];
    [_msg autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:limit];
    [_msg autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:limit];
    
}

@end
