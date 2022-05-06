//
//  Inc_CFConfigSwitchController.m
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/7/22.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//  他虽然是个controller 但没啥实际的业务 , 就有一个tableView 可供选择回调的

#import "Inc_CFConfigSwitchController.h"
#import "Inc_CFSwitchCell.h"

#import "Yuan_CFConfigVM.h"

#import "Yuan_CF_HttpModel.h"


@interface Inc_CFConfigSwitchController ()

<
    UITableViewDelegate ,
    UITableViewDataSource
>

/** 背景色 */
@property (nonatomic,strong) UIView *backGroundView;

/** blockView */
@property (nonatomic,strong) UIView *blockView;

/** 请选择 xxx */
@property (nonatomic,strong) UILabel *deviceName;

/** 返回按钮 */
@property (nonatomic,strong) UIButton * back;

/** tableView */
@property (nonatomic,strong) UITableView *tableView;


/** 声明 点击回调的block 的block */
@property (nonatomic ,copy) void(^selectBlock)(id cableArray);

@end

@implementation Inc_CFConfigSwitchController
{
    
    NSMutableArray * _dataSource;
    
    Yuan_CFConfigVM * _viewModel;
    
}




#pragma mark - 初始化构造方法


- (instancetype)initWithDataSource:(NSMutableArray *)dataSource
                             block:(void (^)(id _Nonnull))cableDict {
    
    
    
    if (self = [super init]) {
        _dataSource = dataSource;
        _selectBlock = cableDict;   //block 赋值
        
        _viewModel = [Yuan_CFConfigVM shareInstance];
        
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self UI_Config];
}


- (void) UI_Config {
    
    _backGroundView = [UIView viewWithColor:UIColor.whiteColor];
    
    _blockView = [UIView viewWithColor:Color_V2Red];
    
    
    NSString * title = @"";
    if (_viewModel.configVC_type == CF_HeaderCellType_ChengDuan) {
        title = @"请选择设备";
    }else if (_viewModel.configVC_type == CF_HeaderCellType_RongJie) {
        title = @"请选择光缆段";
    }
    
    _deviceName = [UIView labelWithTitle:title frame:CGRectNull];
    _deviceName.font = Font_Yuan(13);
    
    _back = [UIView buttonWithTitle:@"返回"
                          responder:self
                                SEL:@selector(backClick)
                              frame:CGRectNull];
    
    _back.backgroundColor = Color_V2Red;
    [_back setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    _back.layer.cornerRadius = 3;
    _back.layer.masksToBounds = YES;
    
    _back.titleLabel.font = Font_Yuan(13);
    
    
    _tableView = [UIView tableViewDelegate:self registerClass:[Inc_CFSwitchCell class] CellReuseIdentifier:@"Yuan_CFSwitchCell"];
    
    [self.view addSubview:_backGroundView];
    
    [_backGroundView addSubviews:@[_blockView ,
                                   _deviceName ,
                                   _back ,
                                   _tableView]];
    [self layoutAllSubViews];
    
}



- (void) backClick {
    
    [self dismissViewControllerAnimated:YES completion:^{
        // 当返回空字符串时  直接返回到列表界面
        _selectBlock(@"");
    }];
}





- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _dataSource.count;
    
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Inc_CFSwitchCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Yuan_CFSwitchCell"];
    
    if (!cell) {
        cell = [[Inc_CFSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault
                                        reuseIdentifier:@"Yuan_CFSwitchCell"];
    }
    
    NSDictionary * dict = _dataSource[indexPath.row];
    
    NSString * fiberCount = dict[@"capacity"];
    
    NSString * cableName = dict[@"cableName"];
    
    [cell setCellNum:fiberCount DeviceName:cableName];

    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    NSDictionary * dict = _dataSource[indexPath.row];
    
    NSString * cableId = dict[@"GID"] ?: @"";
    
    // 回调名称
    if (_cableName_Block) {
        _cableName_Block(dict[@"cableName"] ?: @"未知名称的光缆段");
    }
    
    // 回调数据
    if (_selectBlock) {
    
        // 首先 遍历 _viewModel.connect_LazyLoad_DataSource 数组
        
        BOOL alreadySource = NO;
        
        NSArray * rongjie_Collection_DataSource ;
        
        for (NSDictionary * dict in _viewModel.connect_LazyLoad_DataSource) {
            if ([dict.allKeys.firstObject isEqualToString:cableId]) {
                // 如果 遍历懒加载数组 , 他的key如果和deviceId 重名 , 证明请求过了
                alreadySource = YES;
                // 把对应的数据的值 给数组
                rongjie_Collection_DataSource = [dict.allValues.firstObject copy];
                break;
            }
        }
        
        if (alreadySource) {
            // 不在向下执行 , 直接取出对应的数组 作为给UI刷新的数据源
            [self rebackWithArray:@{cableId : rongjie_Collection_DataSource}];
            return;
        }
        

        
        // 当没有在 数据源数组中 找到已经请求过的 光缆段Id的资源时  , 进行网络请求
        [Yuan_CF_HttpModel Http_CableFilberListRequestWithCableId:cableId
                                                          Success:^(NSArray * _Nonnull data) {
            
            
            //MARK: 当请求回来的数组为空时 需要进行初始化操作 --
            if (data.count == 0 || !data) {
                
                [UIAlert alertSmallTitle:@"是否初始化?" agreeBtnBlock:^(UIAlertAction *action) {
                    
                    NSMutableDictionary * initDict = [NSMutableDictionary dictionary];
                    
                    /*
                     
                     cableSeg_Id 所属光缆段ID
                     cableSeg 所属光缆段名称
                     capacity 纤芯总数
                     */
                                       
                    // 从该光缆段中拿出资源数据 初始化该光缆段下的纤芯
//
//                    initDict[@"cableSeg_Id"] = cableId;
//                    initDict[@"cableSeg"] = [dict objectForKey:@"cableName"];
//                    initDict[@"capacity"] = [dict objectForKey:@"capacity"];
//                    initDict[@"resLogicName"] = @"optPair";
                    
                    //新的重新初始化接口入参
                            
                    initDict[@"capacity"] = dict[@"capacity"];
                    initDict[@"resId"] = cableId;
                    initDict[@"reqDb"] = Yuan_WebService.webServiceGetDomainCode;
                    
                    // 进行初始化操作
                    [Yuan_CF_HttpModel HttpFiberWithDict:initDict success:^(NSArray * _Nonnull data) {
                        
                        if (data) {
                            
                            [self http_ListWithCableId:cableId];
                        }
                        
                    }];
                    
                }];
            }
            
            // 不需要初始化  , 直接返回数据时 ...
            else {
                
                
                NSDictionary * newDict = @{cableId: data};
                
                // 把请求下来的数据 和光缆段id 打包起来 , 给懒加载数据源
                [_viewModel.connect_LazyLoad_DataSource addObject:newDict];
                // 直接把请求成功的值 给回调回去
                [self rebackWithArray:newDict];
                
            }
            
        }];
    }
}



- (void) http_ListWithCableId:(NSString *)cableId {
    
    [Yuan_CF_HttpModel Http_CableFilberListRequestWithCableId:cableId
                                                      Success:^(NSArray * _Nonnull data) {
        
        NSArray * dataArr = data;
        
        
        if (dataArr.count > 0) {
            
            NSDictionary * newDict = @{cableId: data};
            
            // 把新请求下来的数据 和光缆段id 打包起来 , 给懒加载数据源
            [_viewModel.connect_LazyLoad_DataSource addObject:newDict];
            
            // 并且回调 给前台刷新
            [self rebackWithArray:newDict];
            
        }
        
    }];
    
}





- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 55;
    
}


#pragma mark -  back  ---

- (void) rebackWithArray:(NSDictionary *)dict {
    
    if (!dict) {
        return;
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        // 回调 cableId 光缆段Id
        _selectBlock(dict);
    }];
    
}




#pragma mark - 屏幕适配

- (void)layoutAllSubViews {
    
    float limit = Horizontal(15);
    
    // 背景色
    [_backGroundView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
    [_backGroundView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [_backGroundView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    [_backGroundView autoSetDimension:ALDimensionHeight toSize:Vertical(300)];
    
    
    // 方块
    [_blockView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:5];
    [_blockView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:limit];
    [_blockView autoSetDimensionsToSize:CGSizeMake(Horizontal(5), limit)];
    
    // 请选择
    [_deviceName autoConstrainAttribute:ALAttributeHorizontal
                            toAttribute:ALAttributeHorizontal
                                 ofView:_blockView
                         withMultiplier:1.0];
    
    [_deviceName autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:_blockView withOffset:5];
    
    
    [_back autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:limit];
    [_back autoConstrainAttribute:ALAttributeHorizontal
                      toAttribute:ALAttributeHorizontal
                           ofView:_blockView
                   withMultiplier:1.0];
    
    [_back autoSetDimensionsToSize:CGSizeMake(Horizontal(70), Vertical(20))];
    
    
    // tableview
    [_tableView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_blockView withOffset:limit];
    
    [_tableView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
    [_tableView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [_tableView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    
    
}

@end
