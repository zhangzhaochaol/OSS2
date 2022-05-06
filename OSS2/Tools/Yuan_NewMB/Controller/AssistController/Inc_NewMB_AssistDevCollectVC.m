//
//  Inc_NewMB_AssistDevCollectVC.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/4/14.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

// TODO : 智网通
#import "Inc_NewMB_AssistDevCollectVC.h"
#import "Inc_AssDev_Item.h"


//#import "GeneratorSSSBTYKListViewController.h"   //设备
#import "Inc_NewMB_ListVC.h"   // 新模板

@interface Inc_NewMB_AssistDevCollectVC ()

<
    UICollectionViewDelegate ,
    UICollectionViewDataSource ,
    UICollectionViewDelegateFlowLayout
>

/** 九宫格 */
@property (nonatomic , strong) UICollectionView * collection;
@end

@implementation Inc_NewMB_AssistDevCollectVC

{
    NSArray * _imgArr;
    NSArray * _titleArr;
}

#pragma mark - 初始化构造方法

- (instancetype)init {
    
    if (self = [super init]) {
        
        _imgArr = @[@"instruments",@"instruments"];
        _titleArr = @[@"设备",@"分光器"];
        
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self UI_Init];
}


- (void) UI_Init {
    
    UICollectionViewFlowLayout * flowLayout = UICollectionViewFlowLayout.alloc.init;
    
    flowLayout.minimumLineSpacing = 2;
    flowLayout.minimumInteritemSpacing = 2;
    flowLayout.itemSize = CGSizeMake(Horizontal(80), Horizontal(100));
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    _collection = [UIView collectionDatasource:self registerClass:[Inc_AssDev_Item class] CellReuseIdentifier:@"Yuan_AssDev_Item" flowLayout:flowLayout];
    
    [self.view addSubviews:@[_collection]];
    
    [_collection autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(NaviBarHeight, 0, BottomZero, 0)];
}



- (void)    collectionView:(UICollectionView *)collectionView
  didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
        
    NSString * title = _titleArr[indexPath.row];
    
    if ([title isEqualToString:@"设备"]) {
        
        if (!_requestDict) {
            return;
        }
        /*
         // TODO 智网通模板跳转
        GeneratorSSSBTYKListViewController *generatorSSSBTYKListVC = [[GeneratorSSSBTYKListViewController alloc] init];
        generatorSSSBTYKListVC.dic = [NSMutableDictionary dictionaryWithDictionary:_requestDict];
        [self.navigationController pushViewController:generatorSSSBTYKListVC animated:YES];
        
        // 设备放置点 比较特殊
        if ([_requestDict[@"resLogicName"] isEqualToString:@"EquipmentPoint"]) {
            generatorSSSBTYKListVC.generator_Type = GeneratorSSSBTYK_Type_EquipmentPoint;
        }
        */
    }
    
    else if([title isEqualToString:@"分光器"]) {
        
        Inc_NewMB_ListVC * list = [[Inc_NewMB_ListVC alloc] initWithModelEnum:Yuan_NewMB_ModelEnum_obd];
        
        
        NSString * resTypeId = @"";
        NSString * resLogicName = _requestDict[@"resLogicName"];
        NSString * searchName = [NSString stringWithFormat:@"%@Name",resLogicName];

        if ([resLogicName isEqualToString:@"OCC_Equt"]) {
            resTypeId = @"703";      // 703
        }

        else if ([resLogicName isEqualToString:@"ODB_Equt"]) {
            resTypeId = @"704";      //704
        }

        else if ([resLogicName isEqualToString:@"ODF_Equt"]) {
            resTypeId = @"302";      //302
        }

        else if ([resLogicName isEqualToString:@"generator"]) {
            resTypeId = @"205";      //205
        }

        
        else {
            return;
        }

        NSDictionary * insertDict = @{

            @"positId" : _requestDict[@"GID"],
            @"positTypeId" : resTypeId,
            @"positName" : _requestDict[searchName]
        };

        list.insertDict = insertDict;
        list.selectDict = insertDict;
        
        Push(self, list);
    }
    
    else return;
    
}



- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return _titleArr.count;
}


- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    Inc_AssDev_Item * item = [collectionView dequeueReusableCellWithReuseIdentifier:@"Yuan_AssDev_Item" forIndexPath:indexPath];
    
    
    if (!item) {
        item = [[Inc_AssDev_Item alloc] init];
    }
    
    NSString * title = _titleArr[indexPath.row];
    NSString * img = _imgArr[indexPath.row];
    
    [item reloadImg:img title:title];
    
    return item;
}

@end
