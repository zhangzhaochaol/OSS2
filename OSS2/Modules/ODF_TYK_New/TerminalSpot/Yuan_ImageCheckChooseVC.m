//
//  Yuan_ImageCheckChooseVC.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/2/2.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_ImageCheckChooseVC.h"
#import "Yuan_ImageTerminalBtn.h"
@interface Yuan_ImageCheckChooseVC ()


@property (nonatomic , strong) UIImageView * imgView;

@property (nonatomic , strong) UIView * enterBackView;

@property (nonatomic , strong) UILabel * msg;

@property (nonatomic , strong) UIButton * enterBtn;

@end

@implementation Yuan_ImageCheckChooseVC

{
    
    UIImage * _myImage;
    
    NSArray * _dataSource;
    
    NSMutableArray * _btnsArr;
    
    NSMutableArray * _chooseArr;
}

#pragma mark - 初始化构造方法

- (instancetype)initWithImage:(UIImage * )image
                   dataSource:(NSArray *)dataSource{
    
    if (self = [super init]) {
        _myImage = image;
        _dataSource = dataSource;
        _chooseArr = NSMutableArray.array;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.blackColor;
    
    if (!_myImage) {
        [self dismissViewControllerAnimated:YES completion:nil];
        [YuanHUD HUDFullText:@"未检测到图片"];
        return;
    }
    
    [self UI_init];
    
    
    // 生成图片上的button
    [self buttons_Init];
    
    [YuanHUD HUDFullText:@"请在图片中先点击左上角端子,后点击右下角端子,按确认键结束" delay:3];
}


- (void) UI_init {
    
    _imgView = [UIView imageViewWithImg:_myImage frame:CGRectNull];
    [self.view addSubview:_imgView];
    _imgView.contentMode =UIViewContentModeScaleAspectFit;
    _imgView.userInteractionEnabled = YES;
    
    _enterBackView = [UIView viewWithColor:UIColor.whiteColor];
    _msg = [UIView labelWithTitle:@"⚠️请记住图片中端子1和端子2的实际位置,确认后在平面图界面选择正确的端子"
                            frame:CGRectNull];
    
    _msg.numberOfLines = 0;//根据最大行数需求来设置
    _msg.lineBreakMode = NSLineBreakByTruncatingTail;
    
    _enterBtn = [UIView buttonWithTitle:@"确认"
                              responder:self
                                    SEL:@selector(enterClick)
                                  frame:CGRectNull];
    
    
    [_enterBtn cornerRadius:3 borderWidth:0 borderColor:nil];
    [_enterBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    _enterBtn.backgroundColor = UIColor.mainColor;
    
    [self.view addSubview:_enterBackView];
    [_enterBackView addSubviews:@[_msg,_enterBtn]];
    
    [self yuan_LayoutSubViews];
}



- (void) buttons_Init {
    
    _btnsArr = NSMutableArray.array;
    
    float small_LT = 0;
    float big_RB = 0;
    
    
    NSInteger smallIndex = 0;
    NSInteger bigIndex = 0;
    
    for (NSDictionary * dict in _dataSource) {
        
        NSNumber * left = dict[@"left"];
        NSNumber * top = dict[@"top"];
        
        NSNumber * right = dict[@"right"];
        NSNumber * bottom = dict[@"bottom"];
        
        if (small_LT == 0) {
            small_LT = left.floatValue + top.floatValue;
        }
        else {
            if (small_LT > left.floatValue + top.floatValue) {
                small_LT = left.floatValue + top.floatValue;
                smallIndex = [_dataSource indexOfObject:dict];
            }
        }
        
        
        if (big_RB == 0) {
            big_RB = right.floatValue + bottom.floatValue;
        }
        
        else {
            if (big_RB < right.floatValue + bottom.floatValue) {
                big_RB = right.floatValue + bottom.floatValue;
                bigIndex = [_dataSource indexOfObject:dict];
            }
        }
        
        
        
        float width = right.floatValue - left.floatValue;
        float height = bottom.floatValue - top.floatValue;
        
        float x = left.floatValue;
        float y = top.floatValue;
        
        NSString * class = dict[@"class"];
        
        Yuan_ImageTerminalBtn * btn = [[Yuan_ImageTerminalBtn alloc] initWithFrame:CGRectMake(x/2, y/2, width/2, height/2)];
        [btn setTitle:class forState:UIControlStateNormal];
        
        UIColor * color = UIColor.mainColor;
        if ([class isEqualToString:@"u"]) {
            color = UIColor.greenColor;
        }
        
        btn.myDict = dict;
        btn.backgroundColor = color;
        [btn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [_imgView addSubview:btn];
        [_btnsArr addObject:btn];

    }
    
    Yuan_ImageTerminalBtn * smallBtn = [_btnsArr objectAtIndex:smallIndex];
    Yuan_ImageTerminalBtn * bigBtn = [_btnsArr objectAtIndex:bigIndex];
    
    
    
    
    
    UILabel * circle = [UIView labelWithTitle:[Yuan_Foundation fromInteger:1]
                                     frame:CGRectMake(0, 0, 10, 10)];
    circle.textAlignment = NSTextAlignmentCenter;

    circle.textColor = UIColor.whiteColor;
    circle.backgroundColor = UIColor.mainColor;
    [smallBtn addSubview:circle];
    [circle cornerRadius:5 borderWidth:0 borderColor:nil];
     
    
    UILabel * circle_2 = [UIView labelWithTitle:[Yuan_Foundation fromInteger:2]
                                        frame:CGRectMake(0, 0, 10, 10)];
    circle_2.textAlignment = NSTextAlignmentCenter;
    
    circle_2.textColor = UIColor.whiteColor;
    circle_2.backgroundColor = UIColor.mainColor;
    [bigBtn addSubview:circle_2];
    [circle_2 cornerRadius:5 borderWidth:0 borderColor:nil];
    
    
    
    
}


- (void) btnClick:(Yuan_ImageTerminalBtn *)btn {
    
    
    // 不要后面的业务了
    return;
    
    if (_chooseArr.count >= 2 ) {
        [YuanHUD HUDFullText:@"已选择完毕 , 请点击确认按钮完成操作"];
        return;
    }
    
    
    [_chooseArr addObject:btn.myDict];
    
    
    
}




- (void) yuan_LayoutSubViews {
    
    [_imgView YuanAttributeHorizontalToView:self.view];
    [_imgView YuanAttributeVerticalToView:self.view];

//    [_imgView autoSetDimension:ALDimensionWidth toSize:ScreenWidth];
    
    float img_Width = _myImage.size.width;
    float img_Height = _myImage.size.height;
    [_imgView autoSetDimensionsToSize:CGSizeMake(img_Width/2, img_Height/2)];
    
    
    
    [_enterBackView YuanToSuper_Bottom:BottomZero];
    [_enterBackView YuanToSuper_Left:0];
    [_enterBackView YuanToSuper_Right:0];
    [_enterBackView autoSetDimension:ALDimensionHeight toSize:Vertical(80)];
    
    [_msg YuanAttributeHorizontalToView:_enterBackView];
    [_msg YuanToSuper_Left:10];
    [_msg autoSetDimension:ALDimensionWidth toSize:ScreenWidth/3 * 2];
    
    [_enterBtn YuanToSuper_Right:10];
    [_enterBtn YuanAttributeHorizontalToView:_msg];
    [_enterBtn autoSetDimensionsToSize:CGSizeMake(Horizontal(60), Vertical(30))];
    
}



- (void) enterClick {
        
    [UIAlert alertSmallTitle:@"是否已经确认端子位置" vc:self agreeBtnBlock:^(UIAlertAction *action) {
    
        [self dismissViewControllerAnimated:YES completion:^{
            if (_finishBlock) {
                _finishBlock();
            }
        }];
    }];
    
    
}




// 根据选中的起点终点 重新配置
- (NSMutableArray *) resetArr {
    
    NSMutableArray * reSetArr = NSMutableArray.array;
    
    
    NSDictionary * firstDict = _chooseArr.firstObject;
    NSDictionary * secondDict = _chooseArr.lastObject;
    
    
    NSNumber * left = firstDict[@"left"];
    NSNumber * top = firstDict[@"top"];
    
    NSNumber * right = secondDict[@"right"];
    NSNumber * bottom = secondDict[@"bottom"];
    
    for (NSDictionary * dict in _dataSource) {
        
        NSNumber * myLeft = dict[@"left"];
        NSNumber * myTop = dict[@"top"];
        
        NSNumber * myRight = dict[@"right"];
        NSNumber * myBottom = dict[@"bottom"];
        
        
        if (myLeft.floatValue >= left.floatValue &&
            myTop.floatValue >= top.floatValue &&
            
            myRight.floatValue <= right.floatValue &&
            myBottom.floatValue <= bottom.floatValue) {
            
            // 选出符合 起点终点之间的矩形范围内的map
            [reSetArr addObject:dict];
        }
        
    }
    
    return reSetArr;
    
}



- (void) reSetImage {
    
    
    NSMutableArray * mt_Arr = NSMutableArray.array;
    
    NSDictionary * firstDict = _chooseArr.firstObject;
    NSDictionary * secondDict = _chooseArr.lastObject;
    
    
    NSNumber * left = firstDict[@"left"];
    NSNumber * top = firstDict[@"top"];
    
    NSNumber * right = secondDict[@"right"];
    NSNumber * bottom = secondDict[@"bottom"];
    
    // 新图片的长和宽
    float newWidth = right.floatValue - left.floatValue;
    float newHeight = bottom.floatValue - top.floatValue;
    
    // 新图片的x和y
    float newX = left.floatValue;
    float newY = top.floatValue;
    
    // 单个模块的 宽和高
    float single_Width = newWidth / _inlineNums;
    float single_Height = newHeight / _lineCount;
    
    
    // 圈出 新范围内的map
    for (NSDictionary * dict in _dataSource) {
        
        NSNumber * myLeft = dict[@"left"];
        NSNumber * myTop = dict[@"top"];
        
        NSNumber * myRight = dict[@"right"];
        NSNumber * myBottom = dict[@"bottom"];
        
        
        // 只要你button 图形内任意一个点 在新图片内 , 都把他圈选进来
        if (myRight.floatValue >= left.floatValue &&
            myBottom.floatValue >= top.floatValue &&
            myLeft.floatValue <= right.floatValue &&
            myTop.floatValue <= bottom.floatValue) {
            
            [mt_Arr addObject:dict];
        }
    }
    
    
    // 对新范围内的map 重新切割图片
    for (NSDictionary * dict in mt_Arr) {
        
        NSNumber * top = dict[@"top"];
        NSNumber * left = dict[@"left"];
        
        NSNumber * right = dict[@"right"];
        NSNumber * bottom = dict[@"bottom"];
        
        if ([top obj_IsNull] ||
            [left obj_IsNull] ||
            [right obj_IsNull] ||
            [bottom obj_IsNull]) {
            
            continue;
        }
        
        float center_X = (right.floatValue - left.floatValue) / 2 + left.floatValue;
        float center_Y = (bottom.floatValue - top.floatValue) / 2 + top.floatValue;
        
        // 行
        int row = center_Y / single_Height;
        // 列
        int line = center_X / single_Width;
    }
    
}


@end
