//
//  Inc_CFConfigCableCollectionView.m
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/7/21.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_CFConfigCableCollectionView.h"

#import "Yuan_ConfigCableCollectionItem.h"
#import "Yuan_CFConfigVM.h"                 // viewModel


#import "Yuan_CFConfigModel.h"   //model 获取 postDict

@interface Inc_CFConfigCableCollectionView ()

<
    UICollectionViewDelegate ,
    UICollectionViewDataSource ,
    UICollectionViewDelegateFlowLayout
>


/** collection */
@property (nonatomic,strong) UICollectionView *collection;



@end

@implementation Inc_CFConfigCableCollectionView

{
    NSMutableArray * _dataSource;
    
    __weak  Yuan_CFConfigVM * _viewModel;
}




#pragma mark - 初始化构造方法

- (instancetype) init {
    
    if (self = [super init]) {
        
        _dataSource = [NSMutableArray array];
        
        _viewModel = Yuan_CFConfigVM.shareInstance;
        
        
/// MARK: 长按 自动配置 --
        // 执行长按循环的事件
        _viewModel.viewModel_for_Circle_Block = ^(NSInteger tapIndex,
                                                  NSInteger position) {
            
            
              for (int i = 0; i < _viewModel.for_Circle_Count; i++) {
                    
                    // 防止越界
                    if (tapIndex + i > _viewModel.connectionItemArray.count - 1) {
                        break;
                    }
                    
                    Yuan_ConfigCableCollectionItem * item = [_viewModel.connectionItemArray objectAtIndex:tapIndex + i];
                    
                    [self collectionSelect_Click:item];
                }
        };
        
        
        
/// MARK: 长按 手动配置  --
        
        __block Yuan_ConfigCableCollectionItem * item;
        
        __block NSInteger startTapIndex;
        
        // 执行长按 手动配置事件 -- 开始按钮!!!!
        _viewModel.viewModel_for_HandleConfig_Block = ^(NSInteger tapIndex) {
          
            startTapIndex = tapIndex;
            
            item = [_viewModel.connectionItemArray objectAtIndex:tapIndex];
            
            item.layer.borderWidth = 2;
            item.layer.borderColor = UIColor.blueColor.CGColor;
            
            [[Yuan_HUD shareInstance] HUDFullText:@"请再选中一个纤芯,作为此次关联的终点." delay:3];
            
        };
        
        
        
        // 执行长按 手动配置事件 -- 结束按钮!!!!
        _viewModel.viewModel_for_HandleConfig_END_Block = ^(NSInteger endIndex) {
            
            
            
            if (endIndex < startTapIndex) {
                
                [[Yuan_HUD shareInstance] HUDFullText:@"终点不能小于起点 , 请重新选择"];
                return ;
            }
            
            
            
            // 把刚才长按的开始按钮颜色变回去
            item.layer.borderWidth = 0;
            item.layer.borderColor = UIColor.clearColor.CGColor;
            
            [[Yuan_HUD shareInstance] HUDFullText:@"手动配置完成" delay:1];
            
            NSInteger allCircelCount = endIndex - startTapIndex + 1;
            
            if (allCircelCount > _viewModel.for_Circle_Count) {
                // 避免越界
                allCircelCount = _viewModel.for_Circle_Count;
            }
            
            
            for (int i = 0; i < allCircelCount; i++) {
                
                // 防止越界  -- 一定是通过 startTapIndex 起始位置来计算的
                if (startTapIndex + i > _viewModel.connectionItemArray.count - 1) {
                    break;
                }
                
                Yuan_ConfigCableCollectionItem * item = [_viewModel.connectionItemArray objectAtIndex:startTapIndex + i];
                
                [self collectionSelect_Click:item];
            }
            
            // 操作完毕 None
            _viewModel.handleConfig_State = CF_ConfigHandle_None;
            
        };
        
        
        
        
        
        [self addSubview:self.collection];
        
        [_collection autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    return self;
}








- (void)dataSource:(NSMutableArray *)dataSource {
    
    if (!dataSource) return;
    
    _dataSource = dataSource;
    [_collection reloadData];
//    [[Yuan_HUD shareInstance] HUDFullText:@"已改变光缆段"];
}


#pragma mark -  UICollectionViewDataSource  ---



- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    
    return _dataSource.count ;
}




- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    __weak Yuan_ConfigCableCollectionItem * item =
    [collectionView dequeueReusableCellWithReuseIdentifier:@"Yuan_ConfigCableCollectionItem"
                                              forIndexPath:indexPath];
    
    if (!item) {
        item = Yuan_ConfigCableCollectionItem.alloc.init;
    }
    
    NSDictionary * dict = _dataSource[indexPath.row];
    
    item.myDict = dict;
    
    NSString * pairId = dict[@"pairId"];
    
    [item configNum:dict[@"pairNo"] ?: @""];
    
    // 默认是两端都不显示图片的 在下面的代码中再次配置图片
    [item imgConfigUpImage:CF_HeaderCellType_None];
    [item imgConfigDownImg:CF_HeaderCellType_None];
    
    
    // 获取到 判断纤芯的小map , 用来判断成端还是熔接 , 显示在左上角还是右下角
    NSArray * connectList = dict[@"connectList"];
    
    if (connectList.count > 0 && connectList) {
        // *** *** ***  判断成端 熔接 左上 右下
        
        NSString * type;
        NSString * location;
        
        // 循环遍历 connectList
        
        for (NSDictionary * fiberDict in connectList) {
            
            NSDictionary * vm_Dict =
            [_viewModel viewModelFiberTypeAndLocationFromDict:fiberDict
                                                       pairId:pairId];
            
            // 成端还是熔接
            type = vm_Dict[@"type"];
            // 左上还是右下
            location = vm_Dict[@"location"];
            
            // 如果 location == 1 左上角
            if ([location isEqualToString:@"1"]) {
                
                // type == 1 成端
                if ([type isEqualToString:@"2"]) {
                    [item imgConfigUpImage:CF_HeaderCellType_ChengDuan];
                }
                // type == 2 熔接
                else {
                    [item imgConfigUpImage:CF_HeaderCellType_RongJie];
                }
            }
            // 如果 location == 2 右下角
            else if([location isEqualToString:@"2"]){
                
                // type == 1 成端
                if ([type isEqualToString:@"2"]) {
                    [item imgConfigDownImg:CF_HeaderCellType_ChengDuan];
                }
                // type == 2 熔接
                else {
                    [item imgConfigDownImg:CF_HeaderCellType_RongJie];
                }
                
            }else {
                // 什么都不做 , 因为之前已经清空了  unKnow
            }
        }
        
    }
    
    
    
    // MARK: 根据HTTP 请求 为右上角的文字 赋值
    // 根据pairId 为一进来的collectionView 赋值右上角的文字
    NSString * pairNo =  [self getBindingNumFromViewModelWithGID:pairId];
    [item configBindNum:pairNo from:configBindingNumFrom_HTTP];
    
    [_viewModel.connectionItemArray addObject:item];
    
    return item;
    
}



- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    
    Yuan_ConfigCableCollectionItem * item = (Yuan_ConfigCableCollectionItem*)[collectionView cellForItemAtIndexPath:indexPath];
    
    
    
    if (_viewModel.handleConfig_State == CF_ConfigHandle_Setting) {
        // 如果当前是手动配置工单中 , 要走手动配置流程
        
        NSInteger index = [_viewModel.connectionItemArray indexOfObject:item];
        
        [_viewModel Notification_HandleConfigEndIndexFromResArray:index];
        
        return;
    }
    
    
    
    [self collectionSelect_Click:item];
}


#pragma mark -  抽离的点击事件方法  ---

- (void) collectionSelect_Click:(Yuan_ConfigCableCollectionItem *)item {
    
    NSDictionary * dict = item.myDict;
        
    
    /// 正常点击时的逻辑
    
    
    Yuan_CFConfigModel * postModel = [[Yuan_CFConfigModel alloc] init];
    
    // 把所有的起始终止的id 拼接map 再加入数组当中
    BOOL isSuccessJoinHttpSaveArray = [postModel joinSingleDictToLinkSaveHttpArray:dict type:CF_HeaderCellType_RongJie];
    
    // 如果加入 待储存数组 成功后
    if (isSuccessJoinHttpSaveArray) {
        
        // 循环 所有item
        for (Yuan_ConfigCableCollectionItem * item_anyOne in _viewModel.connectionItemArray) {
            
            // 先让所有item 清空
            [item_anyOne configBindNum:@"" from:configBindingNumFrom_HTTP];
            
            NSDictionary * item_anyOne_dict = item_anyOne.myDict;
            NSString * pairId = item_anyOne_dict[@"pairId"];
            NSString * pairNo =  [self getBindingNumFromViewModelWithGID:pairId];
            [item_anyOne configBindNum:pairNo from:configBindingNumFrom_HTTP];
            
  /*
//            //MARK: 步骤1  首先去看 网络请求中的数据源 , 如果刚才被覆盖 , 现在取消覆盖 , 要给他复原的
            NSString * pairNo = @"";

            if (_viewModel.startOrEnd == CF_VC_StartOrEndType_Start) {

                // 遍历起始设备数组
                pairNo = [self circleArray:_viewModel.allStartDeviceArray
                                      myId:dict[@"pairId"]];

            }else {
                // 遍历终止设备数组
                pairNo = [self circleArray:_viewModel.allEndDeviceArray
                                      myId:dict[@"pairId"]];
            }


            [item configBindNum:pairNo from:configBindingNumFrom_HTTP];
*/

            //MARK: 步骤2  再去看 操作数组当中
            
            // 在根据 linkSaveHttpArray 里现有的dict 给对应ID的 item赋值
            for (NSDictionary * singleDict in _viewModel.linkSaveHttpArray) {
                NSArray * optConjunctions = singleDict[@"optConjunctions"];
                NSDictionary * postMap = optConjunctions.firstObject;
                
                if ([postMap[@"resB_Id"] isEqualToString:item_anyOne.myDict[@"pairId"]]) {
                    [item_anyOne configBindNum:singleDict[@"pairNo"]
                                          from:configBindingNumFrom_Connect];
                    break;
                }
            }
        }
    }
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
                                     registerClass:[Yuan_ConfigCableCollectionItem class]
                               CellReuseIdentifier:@"Yuan_ConfigCableCollectionItem"
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



@end
