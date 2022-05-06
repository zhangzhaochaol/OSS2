//
//  InstrumentsMainViewController.m
//  OSS2.0-ios-v2
//
//  Created by 孟诗萌 on 2017/10/12.
//  Copyright © 2017年 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "InstrumentsMainViewController.h"

#import "Inc_Push_MB.h"
//#import "IWPDeviceListViewController.h"


//#import "InstrumentViewController.h"



/*以iPhone6为标准进行横向缩放*/
#define Zoomx [UIScreen mainScreen].bounds.size.width/375
/*以iPhone6为标准进行纵向缩放*/
#define Zoomy [UIScreen mainScreen].bounds.size.height/667


@interface InstrumentsMainViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) UICollectionView *collectionView;
@end

@implementation InstrumentsMainViewController
{
    NSArray *imageArr;
    NSArray *titleArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"仪器仪表";
    
    imageArr = @[@[@"cableSurveyInstrument",@"cableDeviceInstrument",@""]];
    titleArr = @[@[@"现场测试",@"光缆普查仪",@""]];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    UICollectionView * collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) collectionViewLayout:flowLayout];
    _collectionView = collectionView;
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.backgroundColor = [UIColor whiteColor];
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    [_collectionView setScrollEnabled:NO];
    [self.view addSubview:_collectionView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 3;
}
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    if (imageArr.count == 1) {
        [_collectionView setFrame:CGRectMake(0, ScreenHeight/3, ScreenWidth, ScreenHeight)];
    }else if (imageArr.count == 2){
        [_collectionView setFrame:CGRectMake(0, ScreenHeight/4, ScreenWidth, ScreenHeight)];
    }else if (imageArr.count == 3){
        [_collectionView setFrame:CGRectMake(0, ScreenHeight/7, ScreenWidth, ScreenHeight)];
    }
    return imageArr.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"cell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0 ,0 ,cell.frame.size.width ,cell.frame.size.height - 35)];
    UIImage *image = [UIImage Inc_imageNamed:imageArr[indexPath.section][indexPath.row]];
    imageView.image = image;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [cell.contentView addSubview:imageView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, cell.frame.size.height - 30, cell.frame.size.width, 35)];
    label.text = titleArr[indexPath.section][indexPath.row];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = [UIColor blackColor];
    [cell.contentView addSubview:label];
    
    return cell;
}


#pragma mark UICollectionViewDelegateFlowLayout

-(CGSize)collectionView:(UICollectionView *)collectionView
                 layout:(UICollectionViewLayout *)collectionViewLayout
 sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake(80*Zoomx, 115*Zoomy);
}


-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                       layout:(UICollectionViewLayout *)collectionViewLayout
       insetForSectionAtIndex:(NSInteger)section{
    NSInteger posX = 80;
    
    if (imageArr.count>2) {
        posX = 30;
    }else if (imageArr.count == 1){
        posX = 150;
    }
    
    return UIEdgeInsetsMake(10, posX*Zoomx, 10, posX*Zoomx);
}
#pragma mark UIColletionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([titleArr[indexPath.section][indexPath.row] isEqualToString:@""]) {
        return;
    }
    
    if (indexPath.section == 0) {
        [YuanHUD HUDFullText:@"到这了InstrumentViewController"];
//        // 现场测试
//        if (indexPath.row == 0) {
//            InstrumentViewController * instrumentVC = [[InstrumentViewController alloc] init];
//            [self.navigationController pushViewController:instrumentVC animated:YES];
//        }
        
        // 光缆普查仪
        if (indexPath.row == 1) {
            [YuanHUD HUDFullText:@"到这了IWPDeviceListViewController"];
//
//            IWPDeviceListViewController * list = [[IWPDeviceListViewController alloc] initWithFileName:@"meterConfig" isShowEditButton:YES withReadType:IWPDeviceListControlTypeRead offlineSwitch:NO];
//
//            Push(self, list);
        }
        
    }
    
    
}
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

@end
