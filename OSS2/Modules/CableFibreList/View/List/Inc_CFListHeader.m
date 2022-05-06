//
//  Inc_CFListHeader.m
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/7/20.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_CFListHeader.h"

#import "Inc_CFListHeaderBtn.h"

#import "Inc_CFConfigController.h"

#import "Yuan_CFConfigVM.h"

@implementation Inc_CFListHeader

{
    Inc_CFListHeaderCell * _headerCell_Fir;    //cell1
    Inc_CFListHeaderCell * _headerCell_Sec;    //cell2
    
      
    Inc_CFListHeaderBtn * _fibreCount;     //纤芯数量
    Inc_CFListHeaderBtn * _occupyCount;    //占用数量
    Inc_CFListHeaderBtn * _leisureCount;   //空闲数量
    Inc_CFListHeaderBtn * _faultCount;     //故障数量
    Inc_CFListHeaderBtn * _formedCount;    //成端数量
    
    
    UIView * _line_A;       //分割线1
    UIView * _line_B;       //分割线2
    UIView * _line_C;       //分割线3
    UIView * _line_D_Blod;  //分割线4 加粗
 
    
    UIViewController * _pushVC;
    NSMutableArray * _httpDataSource;
    Yuan_CFConfigVM * _viewModel;
    
}



#pragma mark - 初始化构造方法

- (instancetype) initWithVC:(UIViewController *)vc {
    
    if (self = [super init]) {
        
        _viewModel = [Yuan_CFConfigVM shareInstance];
        
        [self UI_Config];
        [self layoutAllSubViews];
        
        [_fibreCount btnType:@"纤芯数量" count:@"0"];
        [_occupyCount btnType:@"占用数量" count:@"0"];
        [_leisureCount btnType:@"空闲数量" count:@"0"];
        [_faultCount btnType:@"故障数量" count:@"0"];
        [_formedCount btnType:@"成端数量" count:@"0"];
        
        self.layer.borderWidth = 1;
        self.layer.borderColor = [ColorValue_RGB(0xf2f2f2) CGColor];
        
        _pushVC = vc;
        
        
        [_headerCell_Fir.btn addTarget:self
                                action:@selector(ConfigClick_ChengD:)
                      forControlEvents:UIControlEventTouchUpInside];
        
        
        [_headerCell_Sec.btn addTarget:self
                                action:@selector(ConfigClick_ChengD:)
                      forControlEvents:UIControlEventTouchUpInside];
        
        
        [_headerCell_Fir.btn_2 addTarget:self
                                  action:@selector(ConfigClick_RJ:)
                        forControlEvents:UIControlEventTouchUpInside];
        
        
        [_headerCell_Sec.btn_2 addTarget:self
                                  action:@selector(ConfigClick_RJ:)
                        forControlEvents:UIControlEventTouchUpInside];
        
        
        [_headerCell_Fir.deleteBtn addTarget:self
                                      action:@selector(batchDelete:)
                            forControlEvents:UIControlEventTouchUpInside];
        
        
        [_headerCell_Sec.deleteBtn addTarget:self
                                      action:@selector(batchDelete:)
                            forControlEvents:UIControlEventTouchUpInside];
        
        
        _httpDataSource = [NSMutableArray array];
        
        
    }
    return self;
}


#pragma mark -  Method 跳转到详情界面 ---

/// 成端
- (void) ConfigClick_ChengD:(UIButton *)sender {
    
    // 根据枚举类型 跳转不同类型的控制器
    
    CF_HeaderCellType_ type;
    
    NSString * deviceId = @""; // 设备Id 用来请求端子盘信息和光缆段列表
    NSString * device_Name = @"";
    if (sender.superview == _headerCell_Fir) {
        type = [_headerCell_Fir getCellType];
        deviceId = [_viewModel viewModel_GetStartDeviceId];
        device_Name = [_viewModel viewModel_GetStartDeviceName];
        
        // 我是从起始设备进入
        _viewModel.startOrEnd = CF_VC_StartOrEndType_Start;
        
    }else {
        type = [_headerCell_Sec getCellType];
        deviceId = [_viewModel viewModel_GetEndDeviceId];
        device_Name = [_viewModel viewModel_GetEndDeviceName];
        
        // 我是从终止设备进入
        _viewModel.startOrEnd = CF_VC_StartOrEndType_End;
    }
    

    Inc_CFConfigController * configVC =
    [[Inc_CFConfigController alloc] initWithType:type
                                       dataSource:_httpDataSource];
    
    configVC.deviceId = deviceId;
    configVC.deviceName_txt = device_Name;
    
    Push(_pushVC, configVC);
    
}

/// 熔接
- (void) ConfigClick_RJ : (UIButton * )btn {
    
    // 根据枚举类型 跳转不同类型的控制器
    
    // 一定是熔接
    CF_HeaderCellType_ type = CF_HeaderCellType_RongJie;
    
    NSString * deviceId = @""; // 设备Id 用来请求端子盘信息和光缆段列表
    NSString * device_Name = @"";
    
    if (btn.superview == _headerCell_Fir) {
        deviceId = [_viewModel viewModel_GetStartDeviceId];
        device_Name = [_viewModel viewModel_GetStartDeviceName];
        
        // 我是从起始设备进入
        _viewModel.startOrEnd = CF_VC_StartOrEndType_Start;
        
    }else {
        
        deviceId = [_viewModel viewModel_GetEndDeviceId];
        device_Name = [_viewModel viewModel_GetEndDeviceName];
        
        // 我是从终止设备进入
        _viewModel.startOrEnd = CF_VC_StartOrEndType_End;
    }
    

    Inc_CFConfigController * configVC =
    [[Inc_CFConfigController alloc] initWithType:type
                                       dataSource:_httpDataSource];
    
    configVC.deviceId = deviceId;
    configVC.deviceName_txt = device_Name;
    
    Push(_pushVC, configVC);
    
}

/// 批量删除成端熔接关系
- (void) batchDelete: (UIButton * )btn {
    
    if (!_headerResetBlock) {
        return;
    }
    
    if (btn.superview == _headerCell_Fir) {
        _headerResetBlock(CFHeaderReset_Start);
    }
    else {
        _headerResetBlock(CFHeaderReset_End);
    }
    
}

- (void) dataSource:(NSMutableArray *) dataSource {
    
    if (dataSource) {
        _httpDataSource = dataSource;
    }else {
        _httpDataSource = [NSMutableArray array];
    }
    
    
    int zhanyong_Count = 0;     //占用状态
    int guzhang_Count = 0;      //故障状态
    int kongxian_Count = 0;     //空闲状态
    
    int chengDuan_Count = 0;
    
    // 除了占用 和 故障 , 其余的都是空闲
    
    for (NSDictionary * dict in _httpDataSource) {
        
        // 业务状态
        NSString * oprStateId = dict[@"oprStateId"];
    
        if (oprStateId && ![oprStateId isEqual:[NSNull null]]) {
            
            
            
            switch ([oprStateId intValue]) {
                case 170003:  //占用
                    zhanyong_Count++;
                    break;
                    
                case 170147:  //损坏
                    guzhang_Count++;
                    break;
                    
                default:  //其余的都是空闲
                    kongxian_Count++;
                    break;
            }
        }
        
        NSArray * connectList = dict[@"connectList"];
        
        if (!connectList) {
            continue;
        }
        
        if (connectList && connectList.count == 2) {
            chengDuan_Count++;
        }
        
    }
    
    
    // 纤芯数量
    [_fibreCount text:[Yuan_Foundation fromInteger:_httpDataSource.count]];
    // 占用数量
    [_occupyCount text:[Yuan_Foundation fromInt:zhanyong_Count]];
    // 空闲数量
    [_leisureCount text:[Yuan_Foundation fromInt:kongxian_Count]];
    //故障数量
    [_faultCount text:[Yuan_Foundation fromInt:guzhang_Count]];
    
    //成端数量
    // ...
    [_formedCount text:[Yuan_Foundation fromInt:chengDuan_Count]];
}




#pragma mark -  UI  ---

- (void) UI_Config {
    
    
    // 获取模板的 dict
    NSDictionary * moban_Dict = _viewModel.moBan_Dict;
    
    if (!moban_Dict) {
        return;
    }
    
    
    
    // cableEnd_Type  cableStart_Type
    
    NSString * cableStartType = moban_Dict[@"cableStart_Type"] ?:@"";
    NSString * cableEndType = moban_Dict[@"cableEnd_Type"] ?:@"" ;
    
    
    //TODO:  成端还是熔接 ?  要根据网络请求进行配置 CF_HeaderCellType_ChengDuan
    
    // 如果 type == 2 那么就是成端 否则是熔接
    
    CF_HeaderCellType_ startType = CF_HeaderCellType_None;
    CF_HeaderCellType_ endType = CF_HeaderCellType_None;
    
    // 熔接
    if ([cableStartType isEqualToString:@"2"]) {
        startType = CF_HeaderCellType_RongJie;
    }
    
    if ([cableEndType isEqualToString:@"2"]) {
        endType = CF_HeaderCellType_RongJie;
    }
    
    
    // 成端
    if ([cableStartType isEqualToAnyString:@"1",@"3",@"4", nil]) {
        startType = CF_HeaderCellType_ChengDuan;
    }
    
    if ([cableEndType isEqualToAnyString:@"1",@"3",@"4", nil]) {
        endType = CF_HeaderCellType_ChengDuan;
    }
    
    
    _headerCell_Fir = [[Inc_CFListHeaderCell alloc] initWithEnum:CF_HeaderCell_Start
                                                        typeEnum:startType];
    
    
    _headerCell_Sec = [[Inc_CFListHeaderCell alloc] initWithEnum:CF_HeaderCell_End
                                                        typeEnum:endType];
    

    
    // 详细信息
    _fibreCount = [[Inc_CFListHeaderBtn alloc] init];
    _occupyCount = [[Inc_CFListHeaderBtn alloc] init];
    _leisureCount = [[Inc_CFListHeaderBtn alloc] init];
    _faultCount = [[Inc_CFListHeaderBtn alloc] init];
    _formedCount = [[Inc_CFListHeaderBtn alloc] init];
    
    // 分割线
    _line_A = [UIView viewWithColor:ColorValue_RGB(0xf2f2f2)];
    _line_B = [UIView viewWithColor:ColorValue_RGB(0xf2f2f2)];
    _line_C = [UIView viewWithColor:ColorValue_RGB(0xf2f2f2)];
    _line_D_Blod = [UIView viewWithColor:ColorValue_RGB(0xf2f2f2)];
    
    
    [self addSubviews:@[_headerCell_Fir,
                        _headerCell_Sec,
                        _fibreCount,
                        _occupyCount,
                        _leisureCount,
                        _faultCount,
                        _formedCount,
                        _line_A,
                        _line_B,
                        _line_C,
                        _line_D_Blod]];
    
    
    // 光缆
    _headerCell_Fir.deviceName.text = moban_Dict[@"cableStart"] ?: @"";
    _headerCell_Sec.deviceName.text = moban_Dict[@"cableEnd"] ?: @"";
    
    if (![moban_Dict.allKeys containsObject:@"cableStart"]) {
        _headerCell_Fir.btn.hidden = YES;
        _headerCell_Fir.btn_2.hidden = YES;
    }
    
    if (![moban_Dict.allKeys containsObject:@"cableEnd"]) {
        _headerCell_Sec.btn.hidden = YES;
        _headerCell_Sec.btn_2.hidden = YES;
    }
    
    NSString * cableStart_Type = moban_Dict[@"cableStart_Type"];
    NSString * cableEnd_Type = moban_Dict[@"cableEnd_Type"];
    
    // 只有 occ 同时显示 成端和熔接
    if (![cableStartType isEqualToString:@"3"]) {
        _headerCell_Fir.btn_2.hidden = YES;
    }
    
    if (![cableEnd_Type isEqualToString:@"3"]) {
        _headerCell_Sec.btn_2.hidden = YES;
    }
    
    
}


#pragma mark - 屏幕适配

- (void)layoutAllSubViews {
    
    // header 1
    [_headerCell_Fir autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [_headerCell_Fir autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    [_headerCell_Fir autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0];
    
    
    // header 2
    [_headerCell_Sec autoPinEdge:ALEdgeTop
                          toEdge:ALEdgeBottom
                          ofView:_headerCell_Fir
                      withOffset:0];
    
    [_headerCell_Sec autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [_headerCell_Sec autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    
    [_headerCell_Fir autoSetDimension:ALDimensionHeight toSize:Vertical(40)];
    [_headerCell_Sec autoSetDimension:ALDimensionHeight toSize:Vertical(40)];
    
    
    // *** *** *** *** *** *** *** *** ***
    
    float limit = 2;
    
    [_fibreCount autoPinEdge:ALEdgeTop
                      toEdge:ALEdgeBottom
                      ofView:_headerCell_Sec
                  withOffset:10];
    
    [_fibreCount autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:limit];
    
    [_line_A autoPinEdge:ALEdgeLeft
                  toEdge:ALEdgeRight
                  ofView:_fibreCount
              withOffset:limit];
    
    
    [_occupyCount autoPinEdge:ALEdgeLeft
                       toEdge:ALEdgeRight
                       ofView:_line_A
                   withOffset:limit];
    
    [_line_B autoPinEdge:ALEdgeLeft
                  toEdge:ALEdgeRight
                  ofView:_occupyCount
              withOffset:limit];
    
    
    
    [_leisureCount autoPinEdge:ALEdgeLeft
                        toEdge:ALEdgeRight
                        ofView:_line_B
                    withOffset:limit];
    
    [_line_C autoPinEdge:ALEdgeLeft
                  toEdge:ALEdgeRight
                  ofView:_leisureCount
              withOffset:limit];
    
    [_faultCount autoPinEdge:ALEdgeLeft
                      toEdge:ALEdgeRight
                      ofView:_line_C
                  withOffset:limit];
    
    [_line_D_Blod autoPinEdge:ALEdgeLeft
                       toEdge:ALEdgeRight
                       ofView:_faultCount
                   withOffset:limit];
    
    
    
    
    [_formedCount autoPinEdge:ALEdgeLeft
                       toEdge:ALEdgeRight
                       ofView:_line_D_Blod
                   withOffset:limit];
    

    
    
    [self btnWidth:@[_fibreCount,_occupyCount,_leisureCount,_faultCount,_formedCount]];
    
    [self lineWidth:@[_line_A,_line_B,_line_C,_line_D_Blod]];
    
    [self HorizontalArray:@[_fibreCount,_occupyCount,_leisureCount,_faultCount,_formedCount,
                            _line_A,_line_B,_line_C,_line_D_Blod]];
    
}


- (void) btnWidth:(NSArray *)btnArray {
    
    for (UIView * btn in btnArray) {
        [btn autoSetDimension:ALDimensionWidth toSize:Horizontal(68)];
    }
    
    
}


- (void) lineWidth: (NSArray *)lineArray {
    
    for (UIView * line in lineArray) {
        [line autoSetDimensionsToSize:CGSizeMake(1, 15)];
    }
}



- (void) HorizontalArray:(NSArray *)viewArray {
    
    for (UIView * myView in viewArray) {
        
        [myView autoConstrainAttribute:ALAttributeHorizontal
                           toAttribute:ALAttributeHorizontal
                                ofView:_fibreCount
                        withMultiplier:1.0];
    }
    
    
    
    
    
    
}



@end
