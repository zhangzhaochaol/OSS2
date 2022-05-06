//
//  Inc_BusAllColumnView.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/8/17.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_BusAllColumnView.h"

#import "Yuan_ODF_HttpModel.h"          /// 专门用于网络请求的类


@interface Inc_BusAllColumnView ()<UIScrollViewDelegate,Yuan_BusDevice_ItemDelegate>

{
    
    //端子盘数组
    NSArray *_requestDataSource;
    
    CGFloat _justHeight;//正面高度
    CGFloat _backHeight;//反面高度
    
    
    //正面用于存储框label
    NSMutableArray  *_labelJustArray;
    //正面用于存储框的y值
    NSMutableArray <UILabel*>  *_tempJustArray;
    
    //反面
    NSMutableArray  *_labelBackArray;
    NSMutableArray <UILabel*>  *_tempBackArray;
    
    
    //点击端子是否跳转
    BOOL _isPush;
    
    UIViewController *_VC;
    
    Yuan_BusDeviceEnum_ _busDevice_Enum;
    Yuan_BusHttpPortEnum_ _busHttp_Enum;
}

//整体滑动view 正
@property (nonatomic, strong) UIScrollView *justScrollView;
//整体滑动view  反
@property (nonatomic, strong) UIScrollView *backScrollView;

@property (nonatomic, strong) Inc_BusDeviceView *deviceView;

//正面和其他端子盘数组
@property (nonatomic, strong) NSMutableArray *justArray;

//反面端子盘
@property (nonatomic, strong) NSMutableArray *backArray;

//反面端子盘
@property (nonatomic, strong) NSMutableArray<Inc_BusDeviceView*> *deviceViewBackArray;
//正面端子盘
@property (nonatomic, strong) NSMutableArray<Inc_BusDeviceView*> *deviceViewJustArray;

@end

@implementation Inc_BusAllColumnView


/**
    根据设备Id  和 设备类型 请求全部端子信息
 */
- (instancetype)initWithFrame:(CGRect)frame
                       isPush:(BOOL)isPush
                     deviceId:(NSString *)deviceId
                      busType:(BusAllColumnType_ )busType
               busDevice_Enum:(Yuan_BusDeviceEnum_)busDevice_Enum
                 busHttp_Enum:(Yuan_BusHttpPortEnum_)busHttp_Enum
                           vc:(UIViewController*)vc {
    
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = UIColor.whiteColor;
        _isPush = isPush;
        _VC = vc;
        _busDevice_Enum = busDevice_Enum;
        _busHttp_Enum = busHttp_Enum;
        
        _tempJustArray = NSMutableArray.array;
        _tempBackArray = NSMutableArray.array;
        _justArray = NSMutableArray.array;
        _backArray = NSMutableArray.array;
        _deviceViewBackArray = NSMutableArray.array;
        _deviceViewJustArray = NSMutableArray.array;
        _labelJustArray = NSMutableArray.array;
        _tempJustArray = NSMutableArray.array;
        _labelBackArray = NSMutableArray.array;
        _tempBackArray = NSMutableArray.array;
        
        NSString *postType;
        if (busType == BusAllColumnType_ODF) {
            postType = @"1";
        }else if(busType == BusAllColumnType_OCC){
            postType = @"2";
        }else if (busType == BusAllColumnType_ODB) {
            postType = @"3";
        }
        else if (busType == BusAllColumnType_ODB) {
            postType = @"4";
        }
        
        
        if (!deviceId) {
            [YuanHUD HUDFullText:@"未检测到设备ID"];
            return self;
        }
        
        [self http_post:deviceId postType:postType];
        
        
    }
    return self;
    
}



/**
    根据端子盘数据 请求 全部端子信息
 */
- (instancetype)initWithFrame:(CGRect)frame
                       isPush:(BOOL)isPush
            requestDataSource:(NSArray *)requestDataSource
               busDevice_Enum:(Yuan_BusDeviceEnum_)busDevice_Enum
                 busHttp_Enum:(Yuan_BusHttpPortEnum_)busHttp_Enum
                           vc:(UIViewController*)vc{
    
    if (self = [super initWithFrame:frame]) {
      
        self.backgroundColor = UIColor.whiteColor;
        _isPush = isPush;
        _requestDataSource = requestDataSource;
        _VC = vc;
        _busDevice_Enum = busDevice_Enum;
        _busHttp_Enum = busHttp_Enum;
        _tempJustArray = NSMutableArray.array;
        _tempBackArray = NSMutableArray.array;
        _justArray = NSMutableArray.array;
        _backArray = NSMutableArray.array;
        _deviceViewBackArray = NSMutableArray.array;
        _deviceViewJustArray = NSMutableArray.array;
        _labelJustArray = NSMutableArray.array;
        _tempJustArray = NSMutableArray.array;
        _labelBackArray = NSMutableArray.array;
        _tempBackArray = NSMutableArray.array;

        
        if (!_requestDataSource || _requestDataSource.count == 0) {
            
            [YuanHUD HUDFullText:@"未检测到设备ID"];
            return self;
        }
        
        [self createUI];
    }
    return self;
}

- (void)createUI {
    
    //正反面板
    [self addSubview:self.justScrollView];
    [self addSubview:self.backScrollView];
    
    for (NSDictionary *dic in _requestDataSource) {
        
        NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:dic];
        
        //要多算一个  否则会出现最后一个得划动查看
        //行优使用行数计算
        dict[@"height"] = [NSString stringWithFormat:@"%.2f",[dic[@"moduleRowQuantity"] integerValue] * Horizontal(40) + Horizontal(40)];
        
        //列优使用固定值  默认6个
        if ([dict[@"noRule"] isEqualToString:@"2"]) {
            //要多算一个  否则会出现最后一个得划动查看
            dict[@"height"] = [NSString stringWithFormat:@"%.2f",6 * Horizontal(40) + Horizontal(40)];
        }
        
        if ([dic[@"faceInverse"] integerValue] == 2) {
            [self.backArray addObject:dict];
        }else{
            [self.justArray addObject:dict];
        }
    }
    
    [self arraySort];
    
    
    //正反面板
    [self setUpTeimJust];
    [self setUpTeimback];
    
    self.backScrollView.hidden = YES;
    self.justScrollView.hidden = YES;
}




//正面
- (void)setUpTeimJust {

    int i = 0;

    //接口成功回调+1
   __block int countJustHttp = 0;
    
    Inc_BusDeviceView * deviceView;
    
    for (NSDictionary *dic  in self.justArray) {
        
        UILabel *columnLabel = [UIView labelWithTitle:[NSString stringWithFormat:@"%@框",dic[@"position"]] frame:CGRectMake(0, i * 4 + _justHeight, 50, 20)];
        columnLabel.backgroundColor = ColorR_G_B(254, 124, 124);
        columnLabel.textAlignment = NSTextAlignmentCenter;
        columnLabel.textColor = UIColor.whiteColor;
        columnLabel.tag = 100+ i;
        if (@available(iOS 11.0, *)) {
            columnLabel.layer.maskedCorners = kCALayerMaxXMaxYCorner;
        } else {
             // Fallback on earlier versions
        }
        columnLabel.layer.cornerRadius = 10.0;
        columnLabel.layer.masksToBounds = YES;
        CGFloat y = columnLabel.y;
        [_labelJustArray addObject:[NSString stringWithFormat:@"%f",y]];
        [_tempJustArray addObject:columnLabel];
        
        deviceView = [[Inc_BusDeviceView alloc] initWithPieDict:dic VC:_VC];
        deviceView.delegate = self;
        deviceView.busHttp_Enum = _busHttp_Enum;
        deviceView.terminalBtnClickBlock = ^(NSDictionary * _Nonnull terminalDict) {
            
            if (_isPush) {
                /*
                [Inc_Push_MB pushFrom:_VC
                         resLogicName:@"opticTerm"
                                 dict:terminalDict
                                 type:TYKDeviceListUpdateRfid];
                 */
            }
            
        };
        
        deviceView.httpSuccessBlock = ^{
            countJustHttp ++;
            NSLog(@"正面接口成功回调次数%d",countJustHttp);
            if (countJustHttp == self.justArray.count) {
                self.justScrollView.hidden = NO;
                
                //所有盘请求成功后 才可以使用对应端子盘的数据
                if (self.httpSuccessBlock) {
                    self.httpSuccessBlock();
                }

                if (_busHttp_Enum == Yuan_BusHttpPortEnum_New) {
                    [self termErgodic];
                }

            }
        };
       
        
        deviceView.busDevice_Enum = _busDevice_Enum;
        
        deviceView.frame = CGRectMake(0, columnLabel.y + 14, self.justScrollView.width, [dic[@"height"] floatValue]);
        _justHeight += [dic[@"height"] floatValue];

        if (i != 0) {
            UIView *view = [UIView viewWithColor:UIColor.groupTableViewBackgroundColor];
            view.frame = CGRectMake(0, columnLabel.y - 4, self.justScrollView.width, 4);
            [_justScrollView addSubview:view];
        }
        
        i ++;
        
        [_deviceViewJustArray addObject:deviceView];
        
        [self.justScrollView addSubview:deviceView];
        [self.justScrollView addSubview:columnLabel];
    }
    
    _justScrollView.contentSize = CGSizeMake(self.width, _justHeight + 100);
}
//反面
- (void)setUpTeimback {

    int i = 0;

    //接口成功回调+1
   __block int countJustHttp = 0;
    Inc_BusDeviceView * deviceView;
    
    for (NSDictionary *dic  in self.backArray) {
        
        UILabel *columnLabel = [UIView labelWithTitle:[NSString stringWithFormat:@"%@框",dic[@"position"]] frame:CGRectMake(0, i * 4 + _backHeight, 50, 20)];
        columnLabel.backgroundColor = ColorR_G_B(254, 124, 124);
        columnLabel.textAlignment = NSTextAlignmentCenter;
        columnLabel.textColor = UIColor.whiteColor;
        if (@available(iOS 11.0, *)) {
            columnLabel.layer.maskedCorners = kCALayerMaxXMaxYCorner;
        } else {
             // Fallback on earlier versions
        }
        columnLabel.layer.cornerRadius = 10.0;
        columnLabel.layer.masksToBounds = YES;

        CGFloat y = columnLabel.y;
        [_labelBackArray addObject:[NSString stringWithFormat:@"%f",y]];
        [_tempBackArray addObject:columnLabel];

        deviceView = [[Inc_BusDeviceView alloc] initWithPieDict:dic VC:_VC];
        deviceView.delegate = self;
        deviceView.busHttp_Enum = _busHttp_Enum;
        deviceView.terminalBtnClickBlock = ^(NSDictionary * _Nonnull terminalDict) {
            
            if (_isPush) {
                /*
                [Inc_Push_MB pushFrom:_VC
                         resLogicName:@"opticTerm"
                                 dict:terminalDict
                                 type:TYKDeviceListUpdateRfid];
                 */
            }
            
        };
        
        
        deviceView.httpSuccessBlock = ^{
            countJustHttp ++;
            NSLog(@"反面接口成功回调次数%d",countJustHttp);
            if (countJustHttp == self.justArray.count) {
//                self.backScrollView.hidden = NO;
                if (_busHttp_Enum == Yuan_BusHttpPortEnum_New) {
                    [self termErgodic];
                }
            }
        };
       
        deviceView.busDevice_Enum = _busDevice_Enum;

        deviceView.frame = CGRectMake(0, columnLabel.y + 14, self.backScrollView.width, [dic[@"height"] floatValue]);
        _backHeight += [dic[@"height"] floatValue];

        if (i != 0) {
            UIView *view = [UIView viewWithColor:UIColor.groupTableViewBackgroundColor];
            view.frame = CGRectMake(0, columnLabel.y - 4, self.backScrollView.width, 4);
            [_backScrollView addSubview:view];
        }
        
        i ++;
        
        [_deviceViewBackArray addObject:deviceView];

        [self.backScrollView addSubview:deviceView];
        [self.backScrollView addSubview:columnLabel];
    }
    _backScrollView.contentSize = CGSizeMake(self.width, _backHeight + 100);

}


//正面scroll
- (UIScrollView *)justScrollView {
    if (!_justScrollView) {
        
        _justScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
//        _justScrollView.backgroundColor = [UIColor greenColor];
        //设置显示内容的大小，这里表示可以下滑十倍原高度
        _justScrollView.contentSize = CGSizeMake(self.width, self.height*2);
        //设置当滚动到边缘继续滚时是否像橡皮经一样弹回
        _justScrollView.bounces = YES;
        //设置滚动条指示器的类型，默认是白边界上的黑色滚动条
        _justScrollView.indicatorStyle = UIScrollViewIndicatorStyleDefault;//还有UIScrollViewIndicatorStyleBlack、UIScrollViewIndicatorStyleWhite
        //设置是否只允许横向或纵向（YES）滚动，默认允许双向
        //    _justScrollView.directionalLockEnabled = YES;
        //设置是否允许缩放超出倍数限制，超出后弹回
        _justScrollView.bouncesZoom = YES;
        //设置委托
        _justScrollView.delegate = self;

    }
    return _justScrollView;
}


//反面scroll
- (UIScrollView *)backScrollView {
    if (!_backScrollView) {
        
        _backScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
//        _backScrollView.backgroundColor = [UIColor yellowColor];
        //设置显示内容的大小，这里表示可以下滑十倍原高度
        _backScrollView.contentSize = CGSizeMake(self.width, self.height*2);
        //设置当滚动到边缘继续滚时是否像橡皮经一样弹回
        _backScrollView.bounces = YES;
        //设置滚动条指示器的类型，默认是白边界上的黑色滚动条
        _backScrollView.indicatorStyle = UIScrollViewIndicatorStyleDefault;//还有UIScrollViewIndicatorStyleBlack、UIScrollViewIndicatorStyleWhite
        //设置是否允许缩放超出倍数限制，超出后弹回
        _backScrollView.bouncesZoom = YES;
        //设置委托
        _backScrollView.delegate = self;

    }
    return _backScrollView;
}


#pragma mark devieViewDelegate

- (void) Yuan_BusDeviceSelectItems:(NSArray <Inc_BusScrollItem *> * )btnsArr
                     nowSelectItem:(Inc_BusScrollItem *) item
                  BusODFScrollView:(Inc_BusDeviceView *)busView {

    if (self.yuan_BusDeviceSelectItemBlock) {
        self.yuan_BusDeviceSelectItemBlock(btnsArr, item, busView);
    }
    
}



//处理列框悬浮问题
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
        
    CGPoint point = scrollView.contentOffset;
    NSLog(@"point:%f",point.y);
    
    if (scrollView == _justScrollView) {
        for (int i=0 ; i<_justArray.count; i++) {
            UILabel *label = _tempJustArray[i];
            
            if ([_labelJustArray[i] floatValue] < point.y) {
                label.frame = CGRectMake(0, point.y, 50, 20);
            }else{
                label.frame = CGRectMake(0, [_labelJustArray[i] floatValue], 50, 20);
            }
        }
    }else {
        for (int i=0 ; i<_backArray.count; i++) {
            UILabel *label = _tempBackArray[i];
            
            if ([_labelBackArray[i] floatValue] < point.y) {
                label.frame = CGRectMake(0, point.y, 50, 20);
            }else{
                label.frame = CGRectMake(0, [_labelBackArray[i] floatValue], 50, 20);
            }
        }
    }
    
}


//切换显示正反面
- (void)setIsShowJust:(BOOL)isShowJust {
    
    if (isShowJust) {
        self.backScrollView.hidden = YES;
        self.justScrollView.hidden = NO;
    }else{
        self.backScrollView.hidden = NO;
        self.justScrollView.hidden = YES;
    }
    
}

//数组排序
- (void)arraySort {
   
    NSMutableArray * justArr = NSMutableArray.array;
    //转换为number类型后排序，否则按字符串首字母排序  大于10的排序错误
    for (NSDictionary *dic in self.justArray) {
        
        NSMutableDictionary * dict = [[NSMutableDictionary alloc]initWithDictionary:dic];
        [dict setValue:[NSNumber numberWithInt: [dic[@"position"] intValue]] forKey:@"position"];

        [justArr addObject:dict];
    }
    
    NSSortDescriptor *justSort = [NSSortDescriptor sortDescriptorWithKey:@"position" ascending:YES];
    [justArr sortUsingDescriptors:[NSArray arrayWithObject:justSort]];
    
    [self.justArray removeAllObjects];
    [self.justArray addObjectsFromArray:justArr];
    
    NSMutableArray * backArr = NSMutableArray.array;
    for (NSDictionary *dic in self.backArray) {
        
        NSMutableDictionary * dict = [[NSMutableDictionary alloc]initWithDictionary:dic];
        [dict setValue:[NSNumber numberWithInt: [dic[@"position"] intValue]] forKey:@"position"];

        [backArr addObject:dict];
    }
    NSSortDescriptor *backSort = [NSSortDescriptor sortDescriptorWithKey:@"position" ascending:YES];
    [backArr sortUsingDescriptors:[NSArray arrayWithObject:backSort]];
   
    [self.backArray removeAllObjects];
    [self.backArray addObjectsFromArray:backArr];
    
    NSLog(@"%@,%@",justArr,backArr);
}


//正面存放deviceView数组
-(NSArray *)getDeviceViewJustArray {
    
    return _deviceViewJustArray;
}
//反面存放deviceView数组
-(NSArray *)getDeviceViewBackArray {
    return _deviceViewBackArray;
}


#pragma mark -http

/// MARK: 列表的请求 --- --- --- --- ---
- (void) http_post:(NSString *)device postType:(NSString *)postType{
    
    [Yuan_ODF_HttpModel ODF_HttpGetLimitDataWithID:device
                                          InitType:postType
                                      successBlock:^(id  _Nonnull requestData) {
        
        NSArray * resultArray = requestData;
        
        _requestDataSource = resultArray;
        
        [self createUI];
        
    }];
    
}



#pragma mark - 重新刷新全部模块的数据 ---

/// 根据模块Id 去重新请求对应的模块数据
- (void) reloadAllDatas {

    
    /// 正面反面全部清空数据
    for (UIView * view in _justScrollView.subviews) {
        [view removeFromSuperview];
    }
    
    for (UIView * view in _backScrollView.subviews) {
        [view removeFromSuperview];
    }
    
    [_justArray removeAllObjects];
    [_backArray removeAllObjects];
    
    [_labelJustArray removeAllObjects];
    [_tempJustArray removeAllObjects];
    
    [_labelBackArray removeAllObjects];
    [_tempBackArray removeAllObjects];
    
    [_deviceViewJustArray removeAllObjects];
    [_deviceViewBackArray removeAllObjects];
    
    
    [_justScrollView removeFromSuperview];
    _justScrollView = nil;
    
    [_backScrollView removeFromSuperview];
    _justScrollView = nil;
    
    
    _justHeight = 0;
    _backHeight = 0;
    
    // 重新去请求
    [self createUI];
    
}



-(void)termErgodic {
    
    
    //使用端子
    for (Inc_BusDeviceView *deviceView in _deviceViewJustArray) {
        
        for (Inc_BusScrollItem *itemAll in [deviceView getBtns]) {
           
            if (itemAll.opticTermList.count > 0) {
                [itemAll Terminal_ChengD_Sympol_IsShow:YES];
            }
            
            if (itemAll.optLineRelationList.count > 0) {
                [itemAll Terminal_JumpFiber_Sympol_IsShow:YES];
            }
            
            if (itemAll.optPairRouterList.count > 0) {
                [itemAll Terminal_InFiberLink_Sympol_IsShow:YES];
            }
            
        }
                
    }
    
    for (Inc_BusDeviceView *deviceView in _deviceViewBackArray) {
        
        for (Inc_BusScrollItem *itemAll in [deviceView getBtns]) {
            if (itemAll.opticTermList.count > 0) {
                [itemAll Terminal_ChengD_Sympol_IsShow:YES];
            }
            
            if (itemAll.optLineRelationList.count > 0) {
                [itemAll Terminal_JumpFiber_Sympol_IsShow:YES];
            }
            
            if (itemAll.optPairRouterList.count > 0) {
                [itemAll Terminal_InFiberLink_Sympol_IsShow:YES];
            }
        }
    }

}
    
@end
