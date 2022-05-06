//
//  Yuan_BusOBD_PointItem.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/4/15.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_BusOBD_PointItem.h"

@implementation Yuan_BusOBD_PointItem

{
    
    UILabel * _position;
    UIImageView * _img;
    
    UIImageView * _connectSympolImg;
}


#pragma mark - 初始化构造方法

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        [self.contentView cornerRadius:0 borderWidth:1 borderColor:ColorValue_RGB(0xe2e2e2)];
        [self UI_Init];
    }
    return self;
}


- (void) UI_Init {
    
    
    _position = [UIView labelWithTitle:@"1" frame:CGRectNull];
    _position.textAlignment = NSTextAlignmentCenter;
    
//    cf_OBD_Connect
    _connectSympolImg = [UIView imageViewWithImg:[UIImage Inc_imageNamed:@"cf_OBD_Connect"]
                                           frame:CGRectNull];
    _connectSympolImg.hidden = NO;
    
    
    [self.contentView addSubviews:@[_position,_connectSympolImg]];
    
    [_position autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [_connectSympolImg YuanToSuper_Top:0];
    [_connectSympolImg YuanToSuper_Right:0];
    
    UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc]init];
    [self addGestureRecognizer:gesture];
    [gesture setMinimumPressDuration:0.3];  //长按1秒后执行事件
    [gesture addTarget:self action:@selector(gestureEvent:)];
    
}


#pragma mark -  按钮的长按手势  ---

- (void) gestureEvent:(UILongPressGestureRecognizer *)gesture {
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
        if (_BusOBD_LongPressBlock) {
            _BusOBD_LongPressBlock(_myDict);
        }
    }
}




- (void) reloadWithDict:(NSDictionary *) dict {
    _myDict = dict;
    
    // 业务状态
    NSString * oprStateId = dict[@"oprStateId"];
    
    NSString * portName = dict[@"name"];
    NSString * OBDName = dict[@"superResName"];
    
    
    NSString * position = [portName stringByReplacingOccurrencesOfString:OBDName withString:@""];
    if ([position containsString:@"/"]) {
        position = [position stringByReplacingOccurrencesOfString:@"/" withString:@""];
    }
    
    position = [NSString stringWithFormat:@"%d",position.intValue];
    
    
    _position.text = position ?: @"";
    
    
    
    switch (oprStateId.intValue) {
        case 170002:     //预占
        case 170005:     //预释放
        case 170007:     //预留
        case 170014:     //预选
        case 170015:     //备用
        case 170046:    //测试
        case 170187:    //临时占用
            
            _position.backgroundColor = ColorR_G_B(252, 160, 0);
            _position.textColor = [UIColor whiteColor];
            break;
        
        case 170003:     //占用
        
            
            _position.backgroundColor = ColorR_G_B(147, 222, 113);
            _position.textColor = [UIColor whiteColor];
            break;
        
        case 160014:     //停用
        case 170147:    //损坏
            
            _position.backgroundColor = ColorR_G_B(255, 0, 44);
            _position.textColor = [UIColor whiteColor];

            break;
            
        default:    //1.空闲 9.闲置
            
            _position.backgroundColor = ColorR_G_B(232, 232, 232);
            _position.textColor = ColorValue_RGB(0x929292);
            break;
    }
    
    if ([_myDict.allKeys containsObject:@"zid"]) {
        [self connectSympol:YES];
    }
    else {
        [self connectSympol:NO];
    }
    
}

// 是否显示右上角角标
- (void) connectSympol:(BOOL) isShow {
    _connectSympolImg.hidden = !isShow;
    _isConnect = isShow;
}



@end
