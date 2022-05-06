//
//  Inc_ImageCheckNewVC.m
//  OSS2.0-ios-v2
//
//  Created by zzc on 2021/8/10.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_ImageCheckNewVC.h"
#import "Yuan_ODF_HttpModel.h"
#import "Inc_ImageCheckBtn.h"

@interface Inc_ImageCheckNewVC ()

/** 提示 */
@property (nonatomic , strong) UILabel * msg;


/** image */
@property (nonatomic , strong) UIImageView * img;

/** image */
@property (nonatomic , strong) UIImageView * imgBottom;


/** image */
@property (nonatomic , strong) UIImageView * imgBg;

/** image */
@property (nonatomic , strong) UIImageView * imgBottomBg;

/** image */
@property (nonatomic , strong) UIImageView * imgBgAlpha;

/** image */
@property (nonatomic , strong) UIImageView * imgBottomBgAlpha;



/** btn */
@property (nonatomic , strong) UIButton * saveBtn;

/** btn  增强识别*/
@property (nonatomic , strong) UIButton * enhanceBtn;


/** 识别前 */
@property (nonatomic , strong) UILabel * frontLabel;

/** 识别后*/
@property (nonatomic , strong) UILabel * afterLabel;

@end

@implementation Inc_ImageCheckNewVC
{
    
    NSMutableArray * _btnsArr;
    
    
    NSArray * _terminalImageCheck_Arr;
    UIImage * _rebackImage;
    
    
    
    // 横向份数
    NSInteger _horPart;
    
    // 纵向份数
    NSInteger _verPart;
    
    
    
    NSString * _base64Img;
    NSArray * _matrix;
    
    //图片宽高缩放系数
    CGFloat _imgCoefficient;
    
    //数组排序
    NSMutableArray *_terminalImageArr;
    
    //按钮存放
    NSMutableArray *_imageCheckBtnArr;
    
    //是否首次点击增强识别按钮
    BOOL _isFirst;
}


#pragma mark - 初始化构造方法

- (instancetype)initWithImage:(UIImage *) image
                        Array:(NSArray *) arr {
    
    if (self = [super init]) {
        
        _terminalImageCheck_Arr = arr;
        _rebackImage = image;
        
        //返回数据处理
        [self handleArray];
    }
    return self;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _isFirst = YES;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    _imageCheckBtnArr  = [NSMutableArray array];
 
    
    _imgCoefficient = (ScreenWidth - Horizontal(30))/_rebackImage.size.width;
    
    [self UI_Init];
    
//    [self setupBtnWithImgBottom];
    [self setupBtnWithImgBottomNew];
//    [YuanHUD HUDFullText:@"加载中..."];
    
    
}

- (void)setupBtnWithImgBottom {
    
    
    for (NSDictionary *dic in _terminalImageCheck_Arr) {
        
        CGFloat x = [dic[@"left"] floatValue] * _imgCoefficient;
        CGFloat y = [dic[@"top"] floatValue] * _imgCoefficient;
        CGFloat w = ([dic[@"right"] floatValue] - [dic[@"left"] floatValue]) * _imgCoefficient;
        CGFloat h = ([dic[@"bottom"] floatValue] - [dic[@"top"] floatValue]) * _imgCoefficient;

        
        Inc_ImageCheckBtn *button = [[Inc_ImageCheckBtn alloc]initWithFrame:CGRectMake(x, y, w, h)];
        button.dic = dic;
        button.isNomal = YES;
        button.title = [self getBtnTitile:dic[@"class"]];
        button.titleColor = [self getBtnColor:dic[@"class"]];

        [button addTarget:self action:@selector(imgBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_imgBottom addSubview:button];
        
        [_imageCheckBtnArr addObject:button];
    }
    
}

//正常显示
- (void)setupBtnWithImgBottomNew {
    
    for (NSArray *array in _terminalImageArr) {
        
        for (NSDictionary *dic in array) {
            
            //先画正常btn
            if (![dic[@"class"] isEqualToString:@"X"]) {
                
                CGFloat x = [dic[@"left"] floatValue] * _imgCoefficient;
                CGFloat y = [dic[@"top"] floatValue] * _imgCoefficient;
                CGFloat w = ([dic[@"right"] floatValue] - [dic[@"left"] floatValue]) * _imgCoefficient;
                CGFloat h = ([dic[@"bottom"] floatValue] - [dic[@"top"] floatValue]) * _imgCoefficient;
                
                Inc_ImageCheckBtn *button = [[Inc_ImageCheckBtn alloc]initWithFrame:CGRectMake(x, y, w, h)];
                button.dic = dic;
                button.isNomal = YES;
                button.title = [self getBtnTitile:dic[@"class"]];
                button.titleColor = [self getBtnColor:dic[@"class"]];

                [button addTarget:self action:@selector(imgBtnClick:) forControlEvents:UIControlEventTouchUpInside];
                [_imgBottom addSubview:button];
                
                [_imageCheckBtnArr addObject:button];
            }
            
        }
    }
    
}

//增强识别显示
- (void)setupBtnWithImgBottomNew1 {
    
    for (NSArray *array in _terminalImageArr) {
        
        for (NSDictionary *dic in array) {
            
            //画增强识别btn
            if ([dic[@"class"] isEqualToString:@"X"]) {
                CGFloat x = [dic[@"left"] floatValue] * _imgCoefficient;
                CGFloat y = [dic[@"top"] floatValue] * _imgCoefficient;
                CGFloat w = ([dic[@"right"] floatValue] - [dic[@"left"] floatValue]) * _imgCoefficient;
                CGFloat h = ([dic[@"bottom"] floatValue] - [dic[@"top"] floatValue]) * _imgCoefficient;
                Inc_ImageCheckBtn *button = [[Inc_ImageCheckBtn alloc]initWithFrame:CGRectMake(x, y, w, h)];
                button.dic = dic;
                button.isNomal = NO;
                button.title = [self getBtnTitile:dic[@"class"]];
                button.titleColor = HexColor(@"#ffc809");

                [button addTarget:self action:@selector(imgBtnClick:) forControlEvents:UIControlEventTouchUpInside];
                [_imgBottom addSubview:button];
                
                [_imageCheckBtnArr addObject:button];
            }
            
        }
    }

}


- (NSString *)getBtnTitile:(NSString *)note {
    
    if ([note isEqualToString:@"u"]) {
        return @"闲";
    }else{
        return @"占";
    }
}


- (UIColor *)getBtnColor:(NSString *)note {
    
    if ([note isEqualToString:@"u"]) {
        return UIColor.groupTableViewBackgroundColor;
    }else{
        return UIColor.greenColor;
    }
}

- (NSString *)getState:(NSString *)stateStr {
    
    if ([stateStr isEqualToString:@"占"]) {
        return @"3";
    }else{
        return @"1";
    }
}

#pragma mark - btnClick ---
- (void)imgBtnClick:(Inc_ImageCheckBtn *)btn {
    
    if (btn.isNomal) {
        if ([btn.title isEqualToString:@"闲"]) {
            btn.title = @"占";
            btn.titleColor = UIColor.greenColor;

        }else if ([btn.title isEqualToString:@"占"]) {
            btn.title = @"闲";
            btn.titleColor = UIColor.groupTableViewBackgroundColor;

        }else{
            btn.title = @"占";
            btn.titleColor = UIColor.greenColor;

        }
        
    }else{
        
        if ([btn.title isEqualToString:@"闲"]) {
            btn.title = @"占";
            btn.titleColor = HexColor(@"#ffc809");

        }else if ([btn.title isEqualToString:@"占"]) {
            btn.title = @"闲";
            btn.titleColor = HexColor(@"#ffc809");

        }else{
            btn.title = @"占";
            btn.titleColor = HexColor(@"#ffc809");

        }
    }
    
   
    
}

- (void) saveClick {
    NSLog(@"保存");
    
    NSMutableArray * postArr = NSMutableArray.array;
    
    for (Inc_ImageCheckBtn *btnNew  in _imageCheckBtnArr) {
        
        NSDictionary *dic =  btnNew.dic;
        
        // 不是X或者是增强识别的按钮 满足二者之一进行变更  增强识别按钮把btnNew.title变成“占“了
        if (![dic[@"class"] isEqualToString:@"X"] || !btnNew.isNomal) {
            
            for (Yuan_terminalBtn *btn in _btnsArray) {
                
                NSDictionary *dict = btn.dict;
                //btnNew和btn  坐标相同
                if ([dic[@"position"] integerValue] == btn.position && [dic[@"index"] integerValue] == btn.index) {
                    
                    NSString *optStateId = [self getState:btnNew.title];
                    
                    NSMutableDictionary * mt_Dict = [NSMutableDictionary dictionaryWithDictionary:dict];
                    mt_Dict[@"oprStateId"] = optStateId;
                    [postArr addObject:mt_Dict];

                    
                }
            }
        }
        
    }
    
  
    // 批量修改端子状态
    Http.shareInstance.statisticEnum = HttpStatistic_ResourceBatchUpdateTerm;
    
    [Yuan_ODF_HttpModel ODF_HttpChangeBatchHoldArray:postArr
                                        successBlock:^(id  _Nonnull requestData) {
            
        [self http_Reback];

        
    }];
    
    
    
}



- (void) enhanceBtnClick{
    NSLog(@"增强识别");
  
    //除首次点击外直接返回
    if (!_isFirst) {
        return;
    }
    
    [_enhanceBtn setImage:[UIImage Inc_imageNamed:@"zzc_new_enhanceS"] forState:UIControlStateNormal];
    
    [self setupBtnWithImgBottomNew1];
    
    _isFirst = NO;
    
}



// 将回调的结果返回去
- (void) http_Reback {
    
    
    [Yuan_ODF_HttpModel ODF_HttpImageToUnionImageCheck_TxtCoordinated:_terminalImageCheck_Arr
                                                            base64Img:_base64Img
                                                               matrix:_matrix
                                                       matrixModified:@[]
                                                         successBlock:^(id  _Nonnull requestData) {
        
        if (self.reloadWithPie) {
            self.reloadWithPie();
            Pop(self);
        }
        
    }];
}



#pragma mark - UI ---

- (void) UI_Init {
    
    CGFloat coefficint = _rebackImage.size.height/_rebackImage.size.width;
        
    CGFloat imgW = ScreenWidth - Horizontal(30);
    CGFloat imgH = imgW *coefficint;

    
    
    _msg = [UIView labelWithTitle:@" ⚠️ 点击端子 , 切换状态" frame:CGRectNull];
    _msg.backgroundColor = [UIColor yellowColor];
    
    _frontLabel = [UIView labelWithTitle:@"识别前" frame:CGRectNull];
    _frontLabel.textColor = UIColor.whiteColor;
    _frontLabel.textAlignment = NSTextAlignmentCenter;
    _frontLabel.backgroundColor = ColorR_G_B(255, 94, 94);
    
    _afterLabel = [UIView labelWithTitle:@"识别后" frame:CGRectNull];
    _afterLabel.textColor = UIColor.whiteColor;
    _afterLabel.textAlignment = NSTextAlignmentCenter;
    _afterLabel.backgroundColor = ColorR_G_B(35, 155, 41);
    
    
    _img = [UIView imageViewWithImg:_rebackImage frame:CGRectNull];
    _img.contentMode =UIViewContentModeScaleAspectFit;
    
    _imgBg = [UIView imageViewWithImg:_rebackImage frame:CGRectNull];
//    _imgBg.contentMode =UIViewContentModeScaleAspectFit;

    
    _imgBgAlpha = [UIView imageViewWithImg:[UIImage Inc_imageNamed:@""] frame:CGRectNull];
    _imgBgAlpha.backgroundColor = UIColor.whiteColor;
    _imgBgAlpha.alpha = 0.7;
    
    
    _imgBottom = [UIView imageViewWithImg:_rebackImage frame:CGRectNull];
    _imgBottom.userInteractionEnabled = YES;
    _imgBottom.contentMode =UIViewContentModeScaleAspectFit;

    _imgBottomBg = [UIView imageViewWithImg:_rebackImage frame:CGRectNull];
//    _imgBottomBg.contentMode =UIViewContentModeScaleAspectFit;
    _imgBottomBg.userInteractionEnabled = YES;

    _imgBottomBgAlpha = [UIView imageViewWithImg:[UIImage Inc_imageNamed:@""] frame:CGRectNull];
    _imgBottomBgAlpha.backgroundColor = UIColor.whiteColor;
    _imgBottomBgAlpha.alpha = 0.7;
    
    
    _saveBtn = [UIView buttonWithTitle:@"保存"
                             responder:self
                                   SEL:@selector(saveClick)
                                 frame:CGRectNull];
    
//    _enhanceBtn = [UIView buttonWithTitle:@"增强识别" responder:self SEL:@selector(enhanceBtnClick) frame:CGRectNull];
    _enhanceBtn = [UIView buttonWithImage:@"zzc_new_enhance" responder:self SEL_Click:@selector(enhanceBtnClick) frame:CGRectNull];
    _enhanceBtn.adjustsImageWhenHighlighted = NO;
    
    [_saveBtn cornerRadius:5 borderWidth:0 borderColor:nil];
    [_enhanceBtn cornerRadius:5 borderWidth:0 borderColor:nil];
    
    _saveBtn.backgroundColor = UIColor.mainColor;
    [_saveBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    
    _enhanceBtn.backgroundColor = UIColor.f2_Color;
    [_enhanceBtn setTitleColor:UIColor.darkGrayColor forState:UIControlStateNormal];

    
    [_imgBg addSubviews:@[_imgBgAlpha,_frontLabel,_img]];
    [_imgBottomBg addSubviews:@[_imgBottomBgAlpha,_afterLabel,_imgBottom]];

    [self.view addSubviews:@[_imgBg,
                             _imgBottomBg ,
                             _enhanceBtn ,
                             _saveBtn ,
                             _msg]];

    [_msg YuanToSuper_Top:NaviBarHeight];
    [_msg YuanToSuper_Left:0];
    [_msg YuanToSuper_Right:0];
    [_msg Yuan_EdgeHeight:Vertical(0)];
    
    
    [_imgBg YuanMyEdge:Top ToViewEdge:Bottom ToView:_msg inset:0];
    [_imgBg YuanToSuper_Left:0];
    [_imgBg YuanToSuper_Right:0];
    [_imgBg Yuan_EdgeSize:CGSizeMake(ScreenWidth, imgH + Vertical(50))];
    
    [_imgBgAlpha YuanToSuper_Top:0];
    [_imgBgAlpha YuanToSuper_Left:0];
    [_imgBgAlpha YuanToSuper_Bottom:0];
    [_imgBgAlpha YuanToSuper_Right:0];

    
    [_frontLabel YuanToSuper_Top:0];
    [_frontLabel YuanToSuper_Left:0];
    [_frontLabel Yuan_EdgeSize:CGSizeMake(Horizontal(50), Vertical(20))];
    
    [_img YuanMyEdge:Top ToViewEdge:Bottom ToView:_frontLabel inset:10];
    [_img YuanAttributeVerticalToView:_imgBg];
    [_img Yuan_EdgeSize:CGSizeMake(imgW, imgH)];
    
    [_imgBottomBg YuanMyEdge:Top ToViewEdge:Bottom ToView:_imgBg inset:10];
    [_imgBottomBg YuanToSuper_Left:0];
    [_imgBottomBg YuanToSuper_Right:0];
    [_imgBottomBg Yuan_EdgeSize:CGSizeMake(ScreenWidth, imgH + Vertical(50))];
    
    [_imgBottomBgAlpha YuanToSuper_Top:0];
    [_imgBottomBgAlpha YuanToSuper_Left:0];
    [_imgBottomBgAlpha YuanToSuper_Bottom:0];
    [_imgBottomBgAlpha YuanToSuper_Right:0];

    
    [_afterLabel YuanToSuper_Top:0];
    [_afterLabel YuanToSuper_Left:0];
    [_afterLabel Yuan_EdgeSize:CGSizeMake(Horizontal(50), Vertical(20))];
    
    [_imgBottom YuanMyEdge:Top ToViewEdge:Bottom ToView:_afterLabel inset:10];
    [_imgBottom YuanAttributeVerticalToView:_imgBottomBg];
    [_imgBottom Yuan_EdgeSize:CGSizeMake(imgW, imgH)];

    [_enhanceBtn YuanToSuper_Left:Horizontal(15)];
    [_enhanceBtn YuanToSuper_Bottom:Vertical(35)];
    [_enhanceBtn Yuan_EdgeSize:CGSizeMake(Horizontal(100), Vertical(40))];
    
        
    
    [_saveBtn YuanAttributeHorizontalToView:_enhanceBtn];
    [_saveBtn YuanToSuper_Right:Horizontal(15)];
    [_saveBtn YuanMyEdge:Left ToViewEdge:Right ToView:_enhanceBtn inset:Horizontal(15)];
    [_saveBtn Yuan_EdgeHeight:Vertical(40)];

}



#pragma mark - method ---

// 赋值
- (void) configDatasArray:(NSArray *) txtCoordinated
                imgBase64:(NSString *) img
                   matrix:(NSArray *) matrix {
    
    _matrix = matrix;
    _base64Img = img;
    

}

- (void)handleArray {
        
    _terminalImageArr = NSMutableArray.array;

    [_terminalImageArr addObjectsFromArray:_terminalImageCheck_Arr];
    
    for (int i = 0; i<_terminalImageArr.count; i++) {

        NSMutableArray *array = [NSMutableArray arrayWithArray:_terminalImageArr[i]];
        
//        NSMutableArray *intervalArr  = NSMutableArray.array;
//
//        for (int k = 0; k < array.count -1; k++) {
//
//            NSDictionary *dic0 = array[k];
//            NSDictionary *dic1 = array[k + 1];
//
//            if ([dic0[@"right"] floatValue] >0 && [dic1[@"left"] floatValue] >0) {
//                CGFloat interval = [dic1[@"left"] floatValue] - [dic0[@"right"] floatValue];
//                [intervalArr addObject:[NSString stringWithFormat:@"%.2f",interval]];
//            }
//        }
//
//        CGFloat intervalNum = 0;
        CGFloat gap = 0;
//
//        if (intervalArr.count > 0) {
//            for (NSString *interval in intervalArr) {
//                intervalNum += [interval floatValue];
//            }
//            gap = intervalNum/intervalArr.count;
//        }
                
        
        for (int j = 0; j<array.count; j++) {
            
            NSMutableDictionary *dic = NSMutableDictionary.dictionary;
            [dic addEntriesFromDictionary:array[j]];
            [dic setObject:[NSString stringWithFormat:@"%d",i+1] forKey:@"position"];
            [dic setObject:[NSString stringWithFormat:@"%d",j+1] forKey:@"index"];

            if ([dic[@"class"]isEqualToString:@"X"]) {
                
                CGFloat x = 0 ,y = 0 ,w = 0 ,h = 0;
                
                if (j == 0) {
                    int temp = 0;
                    for (int m = j+1; m<array.count; m++) {
                        NSDictionary *temDic = array[m];
                        if (![temDic[@"class"]isEqualToString:@"X"]) {
                            temp = m;
                            break;
                        }
                    }
                    NSDictionary *dict = array[temp];

                    CGFloat left = 0.0;//查找最近的下一个不是X的
                    
                    //判断最后一个是否也是X  如果是使用图片宽
                    if ([dict[@"left"] floatValue] < 1 || [dict[@"left"] floatValue] == 0) {
                        left = _rebackImage.size.width;//图片宽
                    }else {
                        left = [dict[@"left"] floatValue];
                    }
                    
                    CGFloat tempW = left/temp;
                    
                    x = gap;
                    w = tempW - gap *2;
                    y = [dict[@"top"] floatValue];
                    h = [dict[@"bottom"] floatValue] -  [dict[@"top"] floatValue];
                }
                else{
                    
                    int temoP = 0;//X上一个
                    int tempN = 0;//X下一个
                    
                    for (int m = j+1; m<array.count; m++) {
                        NSDictionary *temDic = array[m];
                        if (![temDic[@"class"]isEqualToString:@"X"]) {
                            tempN = m;
                            break;
                        }
                    }
                    
                    for (int n = j-1; n > 0; n--) {
                        NSDictionary *temDic = array[n];
                        if (![temDic[@"class"]isEqualToString:@"X"]) {
                            temoP = n;
                            break;
                        }
                    }
                    
                    CGFloat right = 0.0;//查找最近的上一个不是X的
                    CGFloat left = 0.0;//查找最近的下一个不是X的
                    
                    NSDictionary *dic = array[temoP];
                    NSDictionary *dict = array[tempN];
                    
                    
                    //判断最后一个是否也是X  如果是使用图片宽
                    if ([dict[@"left"] floatValue] < 1 || [dict[@"left"] floatValue] == 0) {
                        left = _rebackImage.size.width;//图片宽
                    }else {
                        left = [dict[@"left"] floatValue];
                    }
                    
                    if ([dic[@"right"] floatValue] < 1 || [dic[@"right"] floatValue] == 0) {
                        right = 0;//图片宽
                    }else {
                        right = [dic[@"right"] floatValue];
                    }
                    
                    
                    
                    CGFloat tempW = (left - right)/(tempN - temoP - 1);
                    
                    //下一个y值
                    CGFloat top = [dict[@"top"] floatValue];
                    CGFloat bottom = [dict[@"bottom"] floatValue];

                    //tempN=0 证明为最后一个
                    if (tempN == 0) {
                        tempW = _rebackImage.size.width - right;
                        //最后一个没有下一个，等同前一个的y值
                        top = [dic[@"top"] floatValue];
                        bottom = [dic[@"bottom"] floatValue];
                    }
                    

                    x = [dic[@"right"] floatValue] + tempW * (j - temoP - 1) + gap;
                    y = ([dic[@"top"] floatValue] + top)/2;
                    w = tempW - 2*gap;
                    h = ([dic[@"bottom"] floatValue] -  [dic[@"top"] floatValue] + bottom -  top)/2;
                }
                
                [dic setValue:[NSString stringWithFormat:@"%.f",x] forKey:@"left"];
                [dic setValue:[NSString stringWithFormat:@"%.f",x+w] forKey:@"right"];
                [dic setValue:[NSString stringWithFormat:@"%.f",y] forKey:@"top"];
                [dic setValue:[NSString stringWithFormat:@"%.f",y+h] forKey:@"bottom"];

            }
            
            [array replaceObjectAtIndex:j withObject:dic];
            
        }
        [_terminalImageArr replaceObjectAtIndex:i withObject:array];
        
    }
        
    

}


@end
