//
//  PointTYKTableViewCell.m
//  OSS2.0-ios-v2
//
//  Created by 孟诗萌 on 2017/9/26.
//  Copyright © 2017年 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "PointTYKTableViewCell.h"
#import "PointViewCell.h"
#define WIDTH [UIScreen mainScreen].bounds.size.width
#define HEIGHT self.contentView.frame.size.height
@implementation PointTYKTableViewCell
{
    UILabel *text1;//左面的绿框
    UILabel *text2;//右面的绿框
//    NSIndexPath *lastClickPointIndex;
}
@synthesize fjListDic;
@synthesize modelGIDArr;
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        [self createUI];
    }
    return self;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (void)createUI
{
    text1 = [[UILabel alloc] initWithFrame:CGRectMake(9.5, 0, 50, HEIGHT)];
    text1.textAlignment = NSTextAlignmentCenter;
    text1.numberOfLines = 0;
    text1.font = [UIFont systemFontOfSize:10];
    text1.textColor = [UIColor whiteColor];
    UIColor *color = [UIColor colorWithPatternImage:[UIImage Inc_imageNamed:@"lvkuangk"]];
    [text1 setBackgroundColor:color];
    [self.contentView addSubview:text1];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    UICollectionView *panCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(51, 0, WIDTH-111.5, HEIGHT)collectionViewLayout:flowLayout];
    _panCollectionView = panCollectionView;
    panCollectionView.showsHorizontalScrollIndicator = YES;
    panCollectionView.dataSource = self;
    panCollectionView.delegate = self;
    panCollectionView.backgroundColor = [UIColor whiteColor];
    [panCollectionView registerClass:[PointViewCell class] forCellWithReuseIdentifier:@"cell"];
    [panCollectionView setScrollEnabled:YES];
    panCollectionView.showsVerticalScrollIndicator = false;
    panCollectionView.showsHorizontalScrollIndicator = false;
    [self.contentView addSubview:panCollectionView];

    text2 = [[UILabel alloc] initWithFrame:CGRectMake(WIDTH-59.5, 0, HEIGHT, HEIGHT)];
    text2.textAlignment = NSTextAlignmentCenter;
    text2.numberOfLines = 0;
    text2.font = [UIFont systemFontOfSize:10];
    text2.textColor = [UIColor whiteColor];
    [text2 setBackgroundColor:color];
    [self.contentView addSubview:text2];
}
- (void)setDict:(NSDictionary *)dict{
    text1.text = dict[@"position"];
    text2.text = dict[@"position"];
    
    [_panCollectionView reloadData];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}
#pragma mark UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSLog(@"modelGIDArr:%@",modelGIDArr);
    NSLog(@"self.tableViewIndex:%ld",self.tableViewIndex);
    NSArray *fjList = [fjListDic objectForKey:modelGIDArr[self.tableViewIndex]];
    NSLog(@"----fjList:%@",fjList);
    return fjList.count;
}
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
    
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{

    static NSString *identifier = @"cell";
    PointViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];

    UIImage *image;
    cell.backgroundColor = [UIColor whiteColor];
//    //还原上一个点击的端子
//    if (lastClickPointIndex!=nil) {
//        UICollectionViewCell * lastCell = (UICollectionViewCell *)[collectionView cellForItemAtIndexPath:lastClickPointIndex];
//        lastCell.backgroundColor = [UIColor blackColor];
//    }
    int pstate = [[[fjListDic objectForKey:modelGIDArr[self.tableViewIndex]][indexPath.row] objectForKey:@"oprStateId"] intValue];
    if (pstate == 1) {
        //空闲
        image = [UIImage Inc_imageNamed:@"duanzi_1"];
    }else if (pstate == 10) {
        //故障
        image = [UIImage Inc_imageNamed:@"duanzi_2"];
    }else if (pstate == 3) {
        //占用
        image = [UIImage Inc_imageNamed:@"duanzi_4"];
    }else if (pstate == 2) {
        //预占
        image = [UIImage Inc_imageNamed:@"duanzi_6"];
    }else{
        image = [UIImage Inc_imageNamed:@"duanzi_1"];
    }
    cell.textLabel.text = [fjListDic objectForKey:modelGIDArr[self.tableViewIndex]][indexPath.row][@"position"];
 
    cell.imageView.image = image;
    [cell sizeToFit];
    return cell;
}
#pragma mark UICollectionViewDelegateFlowLayout
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(HEIGHT, HEIGHT);
}
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    
    return UIEdgeInsetsMake(0, 0, 0, 0);
}
#pragma mark UIColletionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
//    UICollectionViewCell * cell = (UICollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    //端子点击事件
    //还原上一个点击的端子
//    if (lastClickPointIndex!=nil) {
//        UICollectionViewCell * lastCell = (UICollectionViewCell *)[collectionView cellForItemAtIndexPath:lastClickPointIndex];
//        lastCell.backgroundColor = [UIColor whiteColor];
//    }else{
//        lastClickPointIndex = [NSIndexPath new];
//
//    }
//    lastClickPointIndex = indexPath;
//    //添加点击效果
//    cell.backgroundColor = [UIColor blackColor];
    if ([self.delegate respondsToSelector:@selector(doSomeThingo:)] == YES) {
        NSDictionary *dic = @{@"type":@"showPoint",@"pointInfo":[fjListDic objectForKey:modelGIDArr[self.tableViewIndex]][indexPath.row],@"name":@"opticTerm",@"cellIndexPath":indexPath};
        [self.delegate doSomeThingo:dic];
    }
}
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
/// 重写指示视图setter
/// 适配iOS13
/// @param accessoryType 指示视图类型
-(void)setAccessoryType:(UITableViewCellAccessoryType)accessoryType{
    
    if (accessoryType == UITableViewCellAccessoryDisclosureIndicator){
        // 该类型存在显示错误的问题，采用指定图片的方式适配
        
        UIImageView * accessoryView = [UIImageView.alloc initWithImage:[UIImage Inc_imageNamed:@"icon_defaultAccessoryView"]];
        accessoryView.frame = CGRectMake(0, 0, 15, 15);
        
        self.accessoryView = accessoryView;
        
        
    }else{
        [super setAccessoryType:accessoryType];
    }
    
    
}
@end
