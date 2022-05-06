//
//  Yuan_ImageCheck_NewConfigVC.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/7/8.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_ImageCheck_NewConfigVC.h"
#import "Yuan_ODF_HttpModel.h"



@interface Yuan_ImageCheck_NewConfigVC () <Yuan_BusDevice_ItemDelegate>

/** 提示 */
@property (nonatomic , strong) UILabel * msg;

/** 滑动 */
@property (nonatomic , strong) Inc_BusDeviceView * scroll;

/** image */
@property (nonatomic , strong) UIImageView * img;


/** btn */
@property (nonatomic , strong) UIButton * saveBtn;

/** btn */
@property (nonatomic , strong) UIButton * cancelBtn;

@end

@implementation Yuan_ImageCheck_NewConfigVC
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
    
}



#pragma mark - 初始化构造方法

- (instancetype)initWithImage:(UIImage *) image
                        Array:(NSArray *) arr {
    
    if (self = [super init]) {
        
        _terminalImageCheck_Arr = arr;
        _rebackImage = image;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
        
    [self UI_Init];
    
    [YuanHUD HUDFullText:@"加载中..."];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                 (int64_t)(2 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(),  ^{
        
        [self terminalConfig];
        
    });
    
    
}


#pragma mark - delegate ---

- (void)Yuan_BusDeviceSelectItems:(NSArray<Inc_BusScrollItem *> *)btnsArr
                    nowSelectItem:(Inc_BusScrollItem *)item
                 BusODFScrollView:(Inc_BusDeviceView *)busView {
    
    
    
    if ([item.note isEqualToString:@"1"]) {
        item.note = @"0";
        [item configTerminalText:@"占" color:UIColor.mainColor];
    }
    
    else if ([item.note isEqualToString:@"0"]) {
        item.note = @"1";
        [item configTerminalText:@"闲" color:UIColor.systemGreenColor];
    }
    
    else if (!item.note) {
        item.note = @"0";
        [item configTerminalText:@"占" color:UIColor.mainColor];
    }
    
    
    NSInteger index = [btnsArr indexOfObject:item];
    
    [_btnsArr replaceObjectAtIndex:index withObject:item];
    
    
}



#pragma mark - btnClick ---

- (void) saveClick {
    
    // 端子批量修改状态接口
    
    NSMutableArray * postArr = NSMutableArray.array;
    
    for (Inc_BusScrollItem * item in _btnsArr) {
        
        if (!item.note) {
            continue;
        }
        
        NSMutableDictionary * mt_Dict = [NSMutableDictionary dictionaryWithDictionary:item.dict];
        
        // 空闲
        if ([item.note isEqualToString:@"1"]) {
            mt_Dict[@"oprStateId"] = @"1";
        }
        
        // 占用
        if ([item.note isEqualToString:@"0"]) {
            mt_Dict[@"oprStateId"] = @"3";
        }
        
        [postArr addObject:mt_Dict];
        
    }
    
    if (postArr.count == 0) {
        [YuanHUD HUDFullText:@"没有识别到需要修改状态的端子"];
        return;
    }
    
    [UIAlert alertSmallTitle:@"是否修改端子状态?"
               agreeBtnBlock:^(UIAlertAction *action) {
    
        [Http.shareInstance V2_POST_SendMore:HTTP_TYK_Normal_UpData
                                       array:postArr
                                     succeed:^(id data) {
            
            [YuanHUD HUDFullText:@"端子状态修改成功"];
            [self http_Reback];
            
            if (_reloadWithPie) {
                _reloadWithPie();
                Pop(self);
            }
        }];
    }];
    
    
    
}



- (void) backClick {
    
    [UIAlert alertSmallTitle:@"是否退出端子识别?"
               agreeBtnBlock:^(UIAlertAction *action) {
            
        Pop(self);
    }];
    
}



// 将回调的结果返回去
- (void) http_Reback {
    
    
    [Yuan_ODF_HttpModel ODF_HttpImageToUnionBatchHold_TxtCoordinated:_terminalImageCheck_Arr
                                                             base64Img:_base64Img
                                                                matrix:_matrix
                                                        matrixModified:@[]
                                                          successBlock:^(id  _Nonnull requestData) {
        NSLog(@"已完成回调");
    }];
}



#pragma mark - UI ---

- (void) UI_Init {
    
    _msg = [UIView labelWithTitle:@" ⚠️ 点击端子 , 切换状态" frame:CGRectNull];
    _msg.backgroundColor = [UIColor yellowColor];
    
    _img = [UIView imageViewWithImg:_rebackImage frame:CGRectNull];
    _img.contentMode =UIViewContentModeScaleAspectFit;

    _saveBtn = [UIView buttonWithTitle:@"保存"
                             responder:self
                                   SEL:@selector(saveClick)
                                 frame:CGRectNull];
    
    _cancelBtn = [UIView buttonWithTitle:@"返回" responder:self SEL:@selector(backClick) frame:CGRectNull];
    
    
    [_saveBtn cornerRadius:5 borderWidth:0 borderColor:nil];
    [_cancelBtn cornerRadius:5 borderWidth:0 borderColor:nil];
    
    _saveBtn.backgroundColor = UIColor.mainColor;
    [_saveBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    
    _cancelBtn.backgroundColor = UIColor.f2_Color;
    [_cancelBtn setTitleColor:UIColor.darkGrayColor forState:UIControlStateNormal];
    
    
    /*
        需要根据正确端子面板图中 , 行优列优选择出正确的端子绑卡数
     列优时 : 选取出 当只有一行的绑卡数量
     行优时 : 选取出 当只有一列的绑卡数量
     */
    NSArray * data = _datas;
    
    if (_lieNum > 1) {
        
        NSInteger index = 0 ;
        
        // 列优  就取多少列为一组
        if (_importRuler == Important_row) {
            index = _lieNum;
        }
        
        // 行优 就取多少行为一组
        else {
            index = _hangNum;
        }
        
        
        // 根据绑卡的key 取出对应的绑卡数
        // 取出前index 个 , 作为本次端子盘显示的数据
        NSMutableArray * mt_arr = NSMutableArray.array;
        
        for (int i = 1 ; i <= index ; i++) {
            
            for (NSDictionary * dict in _datas) {
                if ([dict.allKeys.firstObject isEqualToString:[Yuan_Foundation fromInt:i]]) {
                    [mt_arr addObject:dict];
                    break;
                }
            }
        }
        
        data = mt_arr;
    }
    
    
    /*
     切割出对应行优列优时 , 横向和纵向的份数
     份数的取值 :
     当列优时 横向为列的个数 , 纵向为行内端子数
     当行优时 横向为行内端子个数 , 纵向为行数
     
     */
    
    // 列优
    if (_importRuler == Important_row) {
        _hangNum = 1;
        
        // 设置宽高份数
        _horPart = _lieNum;
        _verPart = _inLineNums;
    }
    // 行优
    else {
        _lieNum = 1;
        
        // 设置宽高份数
        _verPart = _hangNum;
        _horPart = _inLineNums;
    }
    
    
    
    // 根据筛选完成的数据 初始化端子面板图
    _scroll =
    [[Inc_BusDeviceView alloc] initWithLineCount:(int)_hangNum
                                         rowCount:(int)_lieNum
                                        Important:_importRuler
                                        Direction:_dire
                                       dataSource:data
                                          PieDict:_pieDict
                                               VC:self];
    _scroll.hidden = YES;
    _scroll.delegate = self;
    [self.view addSubviews:@[_scroll,
                             _img ,
                             _cancelBtn ,
                             _saveBtn ,
                             _msg]];
    
    
    [_msg YuanToSuper_Top:NaviBarHeight];
    [_msg YuanToSuper_Left:0];
    [_msg YuanToSuper_Right:0];
    [_msg Yuan_EdgeHeight:Vertical(30)];
    
    [_img YuanMyEdge:Top ToViewEdge:Bottom ToView:_msg inset:0];
    [_img YuanAttributeVerticalToView:self.view];
    [_img YuanToSuper_Left:Horizontal(15)];
    [_img YuanToSuper_Right:Horizontal(15)];
    [_img Yuan_EdgeHeight:Vertical(250)];
    
    [_scroll YuanToSuper_Left:Horizontal(15)];
    [_scroll YuanToSuper_Right:Horizontal(15)];
    [_scroll YuanToSuper_Bottom:Vertical(100)];
    [_scroll YuanMyEdge:Top ToViewEdge:Bottom ToView:_img inset:Vertical(30)];
    

    [_cancelBtn YuanToSuper_Left:Horizontal(15)];
    [_cancelBtn YuanToSuper_Bottom:Vertical(35)];
    [_cancelBtn Yuan_EdgeSize:CGSizeMake(Horizontal(100), Vertical(40))];
    
    
    
    [_saveBtn YuanAttributeHorizontalToView:_cancelBtn];
    [_saveBtn YuanToSuper_Right:Horizontal(15)];
    [_saveBtn YuanMyEdge:Left ToViewEdge:Right ToView:_cancelBtn inset:Horizontal(15)];
    [_saveBtn Yuan_EdgeHeight:Vertical(40)];

}


- (void) terminalConfig {
            
    _scroll.hidden = NO;
    
    
    // 获取本次生成的端子面板图中 , 端子的数据 (views)
    _btnsArr = [NSMutableArray arrayWithArray:_scroll.getBtns];
    
    
    // 宽度因子和高度因子 , 由图片/行列份数 得出结果
    float widthUnit = _rebackImage.size.width / _horPart;
    float heightUnit = _rebackImage.size.height / _verPart;
    
    
    NSMutableArray * checkArr = NSMutableArray.array;
    
    /*
     遍历取left 和 top , 看识别出来的端子在图片中的位置 , 会落在哪个行列因子下
     类比插秧 !
    */
    
    for (NSDictionary * dict in _terminalImageCheck_Arr) {
        
        NSNumber * myLeft = dict[@"left"];
        NSNumber * myTop = dict[@"top"];
        
        float left = myLeft.floatValue;
        float top = myTop.floatValue;
        
        NSInteger hor_Int = 0;
        NSInteger ver_Int = 0;
        
        for (int i = 1; i < 10000; i++) {
            
            float left_Sympol = widthUnit * i;
            if (left < left_Sympol) {
                hor_Int = i;
                break;
            }
        }
        
        for (int i = 1; i < 10000; i++) {
            
            float topSympol = heightUnit * i;
            if (top < topSympol) {
                ver_Int = i;
                break;
            }
        }
        
        
        
        // 如果出现重复的 , 选第一个植入的数据 (避免出现脏数据)
        BOOL isAdd = YES;
        for (NSDictionary * alreadyDict in checkArr) {
            
            NSNumber * hor = alreadyDict[@"hor"];
            NSNumber * ver = alreadyDict[@"ver"];
            
            if (hor.integerValue == hor_Int && ver.integerValue == ver_Int) {
                isAdd = NO;
                break;
            }
        }
        
        
        NSString * class = @"0";
        // u 是空闲
        if ([dict[@"class"] isEqualToString:@"u"]) {
            class = @"1";
        }
        
        
        if (isAdd) {
            
            // state 0 占用 1 空闲
            [checkArr addObject:@{@"hor":@(hor_Int) ,
                                  @"ver" : @(ver_Int),
                                  @"state" : class}];
        }
        
    }
    
    
    
    
    /*
        遍历所有的端子 , 找出他对应的  -- 绑卡索引 position , 端子位置 index
     与之前识别的 横纵因子 做匹配. 判断当前属于空闲还是占用状态
     */
    
    for (Inc_BusScrollItem * item in _btnsArr) {

        [item configTerminalText:@"" color:UIColor.mainColor];
        
        for (NSDictionary * checkDict in checkArr) {
            
            NSNumber * hor_Int = checkDict[@"hor"];
            
            NSNumber * ver_Int = checkDict[@"ver"];
            
            // state 0 占用 1 空闲
            NSString * state = checkDict[@"state"];
            
            
            // 列优
            if (_importRuler == Important_row) {
                
                // 加强识别的算法
                if (hor_Int.integerValue == item.position &&
                    ver_Int.integerValue == item.index) {
                    
                    item.note = state;
                    
                    if ([state isEqualToString:@"1"]) {
                        [item configTerminalText:@"闲" color:UIColor.systemGreenColor];
                    }
                    
                    else if ([state isEqualToString:@"0"]) {
                        [item configTerminalText:@"占" color:UIColor.mainColor];
                    }
                    else {
                        continue;
                    }
                }
            }
            
            // 行优
            else {
                
                
                // 加强识别的算法
                if (ver_Int.integerValue == item.position &&
                    hor_Int.integerValue == item.index) {
                    
                    
                    item.note = state;
                    
                    if ([state isEqualToString:@"1"]) {
                        [item configTerminalText:@"闲" color:UIColor.systemGreenColor];
                    }
                    
                    else if ([state isEqualToString:@"0"]) {
                        [item configTerminalText:@"占" color:UIColor.mainColor];
                    }
                    else {
                        continue;
                    }
                }
            }
        }
    }
}




#pragma mark - method ---

// 赋值
- (void) configDatasArray:(NSArray *) txtCoordinated
                imgBase64:(NSString *) img
                   matrix:(NSArray *) matrix {
    
    
    
    _matrix = matrix;
    _base64Img = img;
    
}


- (void) configDatas {
    
    
    int s_top = 100;
    int s_left = 100;
    
    int b_bottom = 100;
    int b_right = 100;
    
    
    for (NSDictionary * dict in _terminalImageCheck_Arr) {
        
        NSNumber * left = dict[@"left"];
        NSNumber * top = dict[@"top"];
        
        NSNumber * right = dict[@"right"];
        NSNumber * bottom = dict[@"bottom"];
        
        
        // 上左 取最小
        if (left.intValue < s_left) {
            s_left = left.intValue;
        }
        
        if (top.intValue < s_top) {
            s_top = top.intValue;
        }
        
        // 右下 取最大
        if (right.intValue > b_right) {
            s_left = left.intValue;
        }
        
        if (bottom.intValue > b_bottom) {
            b_bottom = bottom.intValue;
        }
        
    }
    
    
    NSMutableArray * leftArr = NSMutableArray.array;
    
    for (NSDictionary * dict in _terminalImageCheck_Arr) {
        
        NSNumber * left = dict[@"left"];
        
        if (left.intValue < s_left + 20) {
            [leftArr addObject:dict];
        }
    }
    
    
    // 对数组中的left map  , 以top值进行排序
    NSArray * newLeft_Arr  = [leftArr sortedArrayUsingFunction:compare context:NULL];
    
    NSMutableArray * juZhenArr = NSMutableArray.array;
    
    for (NSDictionary * leftDic in newLeft_Arr) {
        
        NSNumber * top = leftDic[@"top"];
        
        NSMutableArray * single_Pan_Arr = NSMutableArray.array;
        
        for (NSDictionary * singleDict in _terminalImageCheck_Arr) {
            
            NSNumber * singleTop = singleDict[@"top"];
  
        }
        
    }
    
    
    
    
    
    
    
    
    
    // 一共有多少行  -- 6
    NSInteger linesCount = _matrix.count;
    
    // 每行多少个端子 ?
    NSInteger inLineTerminals = 12;
    
    
    float single_Width = (b_right - s_left) / inLineTerminals;
    float single_Height = (b_bottom - s_top) / linesCount;
    
    
    NSMutableArray * my_MtArr = NSMutableArray.array;
    
    for (NSArray * subArr in _matrix) {
        
        for (NSString * value in subArr) {
            
            
            
        }
        
    }
    
    
    
    
}




// 数组中字典的排序算法  根据 segmId 排序
NSComparisonResult compare(NSDictionary *firstDict, NSDictionary *secondDict, void *context) {

    if ([[firstDict objectForKey:@"top"] integerValue] < [[secondDict objectForKey:@"top"] integerValue])

        return NSOrderedAscending;

    else if ([[firstDict objectForKey:@"top"] integerValue] > [[secondDict objectForKey:@"top"] integerValue])

        return NSOrderedDescending;

    else

        return NSOrderedSame;

}


@end

