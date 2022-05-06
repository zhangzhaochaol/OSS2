//
//  Inc_BusCableFiberView.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/2/20.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_BusCableFiberView.h"


#import "Inc_BusCableFiberItem.h"
#import "Yuan_CFConfigVM.h"                 // viewModel
#import "Yuan_CF_HttpModel.h"

#import "Yuan_CFConfigModel.h"   //model 获取 postDict

@interface Inc_BusCableFiberView ()
<
    UICollectionViewDelegate ,
    UICollectionViewDataSource ,
    UICollectionViewDelegateFlowLayout
>

/** collection */
@property (nonatomic,strong) UICollectionView *collection;




@end

@implementation Inc_BusCableFiberView

{
    NSArray * _dataSource;
    __weak  Yuan_CFConfigVM * _viewModel;
    
    NSString * _cableId;
    NSDictionary * _cableDict;
    
    // 2021.6.18 控制哪个为高亮
    NSArray * _highLight_IdsArr;
}


#pragma mark - 初始化构造方法

- (instancetype) initWithCableData:(NSDictionary *)cableDict{
    
    if (self = [super init]) {
        
        _cableDict = cableDict;
        _cableId = cableDict[@"GID"];
        
        _dataSource = [NSMutableArray array];
        
        _viewModel = Yuan_CFConfigVM.shareInstance;

        [self addSubview:self.collection];
        
        [_collection YuanToSuper_Left:0];
        [_collection YuanToSuper_Right:0];
        [_collection YuanToSuper_Top:0];
        [_collection YuanToSuper_Bottom:0];
        
        
        // 根据光缆段Id 请求纤芯
        [self httpPort];
        
    }
    return self;
}


- (void) httpPort {
    
    // 当没有在 数据源数组中 找到已经请求过的 光缆段Id的资源时  , 进行网络请求
    [Yuan_CF_HttpModel Http_CableFilberListRequestWithCableId:_cableId
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
                                   
//                // 从该光缆段中拿出资源数据 初始化该光缆段下的纤芯
//
//                initDict[@"cableSeg_Id"] = _cableId;
//                initDict[@"cableSeg"] = [_cableDict objectForKey:@"cableName"];
//                initDict[@"capacity"] = [_cableDict objectForKey:@"capacity"];
//                initDict[@"resLogicName"] = @"optPair";
        
                    
                //新的重新初始化接口入参
                        
                initDict[@"capacity"] = _cableDict[@"capacity"];
                initDict[@"resId"] = _cableId;
                initDict[@"reqDb"] = Yuan_WebService.webServiceGetDomainCode;
                
                
                // 进行初始化操作
                [Yuan_CF_HttpModel HttpFiberWithDict:initDict success:^(NSArray * _Nonnull data) {
                    
                    if (data) {
                        
                        [self http_ListWithCableId:_cableId];
                    }
                    
                }];
                
            }];
        }
        
        // 不需要初始化  , 直接返回数据时 ...
        else {
            [self dataSource:data];
        }
        
    }];
    
}



- (void) http_ListWithCableId:(NSString *)cableId {
    
    [Yuan_CF_HttpModel Http_CableFilberListRequestWithCableId:cableId
                                                      Success:^(NSArray * _Nonnull data) {
        
        NSArray * dataArr = data;
        
        
        if (dataArr.count > 0) {
            
            [self dataSource:data];
        }
        
    }];
    
}



- (void)dataSource:(NSArray *)dataSource {
    
    if (!dataSource) return;
    
    _dataSource = dataSource;
    [_collection reloadData];
}


- (void) reloadData {
    
    [_collection reloadData];
}


#pragma mark -  UICollectionViewDataSource  ---



- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    
    return _dataSource.count ;
}




- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    __weak Inc_BusCableFiberItem * item =
    [collectionView dequeueReusableCellWithReuseIdentifier:@"Yuan_BusCableFiberItem"
                                              forIndexPath:indexPath];
    
    if (!item) {
        item = Inc_BusCableFiberItem.alloc.init;
    }
    
    NSDictionary * dict = _dataSource[indexPath.row];
    
    item.myDict = dict;
    
    // 配置已绑定 未绑定颜色
    [item configBuliding_Color];
    
    
    
    NSString * pairId = dict[@"pairId"];
    
    [item configNum:dict[@"pairNo"] ?: @""];
    
    // 默认是两端都不显示图片的 在下面的代码中再次配置图片
    [item imgConfigUpImage:CF_HeaderCellType_None];
    [item imgConfigDownImg:CF_HeaderCellType_None];
    
    
    
    
    
    // MARK: 根据HTTP 请求 为右上角的文字 赋值
    // 根据pairId 为一进来的collectionView 赋值右上角的文字
    NSString * pairNo =  [self getBindingNumFromViewModelWithGID:pairId];
    [item configBindNum:pairNo from:configBindingNumFrom_HTTP];
    
    [_viewModel.connectionItemArray addObject:item];
    
    if (_busCableEnum == Yuan_BusCableEnum_NewFL) {
        
        NSArray * connectList = dict[@"connectList"];
        
        if (connectList.count == 2) {
            item.contentView.backgroundColor = UIColor.greenColor;
        }
        
    }
    
    // 2021.6.18 新增 , 仅控制纤芯边框颜色
    if (_isControlFibers_HighLight) {
        
        [item cornerRadius:0 borderWidth:1 borderColor:UIColor.whiteColor];
        
        if (_highLight_IdsArr) {
            
            for (NSString * ids in _highLight_IdsArr) {
             
                if ([ids isEqualToString:pairId]) {
                    [item cornerRadius:0 borderWidth:1 borderColor:UIColor.mainColor];
                }
            }
        }
    }
    
    return item;
    
}



- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    
    Inc_BusCableFiberItem * item = (Inc_BusCableFiberItem*)[collectionView cellForItemAtIndexPath:indexPath];
    
    
    // 没有任何点击事件
    if (_viewModel.handleConfig_State == CF_ConfigHandle_NOSelectClick) {
        return;
    }
    
    
    // 楼宇中无效
    if (_viewModel.handleConfig_State == CF_ConfigHandle_Setting) {
        // 如果当前是手动配置工单中 , 要走手动配置流程
        
        NSInteger index = [_viewModel.connectionItemArray indexOfObject:item];
        
        [_viewModel Notification_HandleConfigEndIndexFromResArray:index];
        
        return;
    }
    
    
    
    [self collectionSelect_Click:item];
}


#pragma mark -  抽离的点击事件方法  ---

- (void) collectionSelect_Click:(Inc_BusCableFiberItem *)item {
    
    NSDictionary * dict = item.myDict;
        

    NSNotification * noti =
    [[NSNotification alloc] initWithName:BusCableSubFiberClickNotification
                                  object:nil
                                userInfo:dict];
    
    [[NSNotificationCenter defaultCenter] postNotification:noti];
    
}



#pragma mark -  初始化 右上角数据源   ---

- (NSString *) getBindingNumFromViewModelWithGID:(NSString *)itemGID {
    
    
    // 首先判断需要拿起始设备数组 还是 终止设备数组
    NSArray * myDataSource;
    
    if (_viewModel.startOrEnd == CF_VC_StartOrEndType_Start) {
        // 证明是从 起始设备 点击进来的熔接
        myDataSource = [_viewModel.allStartDeviceArray copy];
    } else {
        // 证明是从 终止设备 点击进来的熔接
        myDataSource = [_viewModel.allEndDeviceArray copy];
    }
    
    
    // 再遍历数组解析map  与 当前item的GID 比较 相同的话 就返回显示的数字
    
    NSString * pairNo = @"";
    
    for (NSDictionary * dict in myDataSource) {
        
        NSString * resId = dict[@"resId"];
        
        if ([resId isEqualToString:itemGID]) {
            pairNo = dict[@"pairNo"];
            break;
        }
        
    }
    
    
    
    
    return pairNo ?: @"";
}










#pragma mark -  UI  ---


- (UICollectionView *)collection {
    
    if (!_collection) {
        
        float limit = Horizontal(13);        // 间距
        float sideLength = Horizontal(40);   // 边距
        
        UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc]init];
        //设置布局方向为垂直流布局
        layout.scrollDirection =UICollectionViewScrollDirectionVertical;
        //设置每个item的大小为100*100
        layout.itemSize =CGSizeMake(sideLength,sideLength);
        layout.minimumLineSpacing = limit;
        layout.minimumInteritemSpacing = limit;
        
        _collection = [UIView collectionDatasource:self
                                     registerClass:[Inc_BusCableFiberItem class]
                               CellReuseIdentifier:@"Yuan_BusCableFiberItem"
                                        flowLayout:layout];
        
    }
    return _collection;
}




/// 传入起始或终止数组 返回右上角显示的数组
/// @param array 起始或终止数组
/// @param myId 我的 端子Id
- (NSString *) circleArray:(NSMutableArray *)array
                      myId:(NSString *)myId{
    
    
    NSString * pairNo = @"";
    
    
    for (NSDictionary * singleDeviceMap in array) {
        
        NSString * resId = singleDeviceMap[@"resId"];
        
        if ([resId isEqualToString:myId]) {
            pairNo = singleDeviceMap[@"pairNo"];
            break;
        }
        
    }
    
    
    return pairNo ?: @"";
    
}




#pragma mark - 2021.6.18 新增 ---

/// 控制传入的端子 高亮或取消高亮
- (void) letFiber_Ids:(NSArray *) FiberIdsArr isHighLight:(BOOL)isHighLight {
    
    if (isHighLight) {
        _highLight_IdsArr = FiberIdsArr;
    }
    else {
        _highLight_IdsArr = nil;
    }
    
}


@end
