//
//  Yuan_TYKPhotoVC.m
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/8/24.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_TYKPhotoVC.h"
#import "Yuan_BigImgVC.h"       //图片放大

#import "Yuan_PhotoItem.h"


#import <Photos/Photos.h>
#import "INCPrivacyManager.h"   //判断权限
#import "Yuan_PhotoService.h"   //获取定位

#import "Yuan_PhotoHttpModel.h"


//#import "UIImageView+WebCache.h"
#import <SDWebImage/SDImageCache.h>


@interface Yuan_TYKPhotoVC ()
<
    UICollectionViewDelegate ,
    UICollectionViewDataSource ,
    UICollectionViewDelegateFlowLayout,
    UIGestureRecognizerDelegate, //长按删除
    UINavigationControllerDelegate,
    UIImagePickerControllerDelegate
>


/** 视图 */
@property (nonatomic,strong) UICollectionView *collection;

@end

@implementation Yuan_TYKPhotoVC

{
    UIImageView * _newImg;
    
    Yuan_PhotoService * _photoService;
    
    // 网络请求回来的数据 , 用于请求图片
    NSMutableArray * _imgHttpDataSource;
    
    NSString * _resLogicName;
    NSString * _Gid;
    NSString * _userName;
    
    Yuan_BigImgVC *_carema;
}


#pragma mark - 初始化构造方法

- (instancetype) init {
    
    if (self = [super init]) {
        
        _photoService = Yuan_PhotoService.alloc.init;
        [_photoService startLocation];   //开始定位
        
        _imgHttpDataSource = NSMutableArray.array;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = UIColor.whiteColor;
    
    self.title = @"照片";
    
    [self.view addSubview:self.collection];
    
    [_collection autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    
    [self naviSet];

    _resLogicName = _moban_Dict[@"resLogicName"] ?: @"";
    _Gid = _moban_Dict[@"GID"] ?: @"";
    
    
    _userName = UserModel.userName ?: @"";
        
    // 获取图片关系表
    [self http_GetList];
}




#pragma mark -  Http  ---

/// 图片上传
- (void) http_UpLoadWithImg:(UIImage *)image {
    
    
    
    NSDictionary * param = @{
        @"userName" : _userName,
        @"sysName" : @"OSS2.0",
        @"serviceId" : _Gid
    };
    
    
    [Yuan_PhotoHttpModel http_upLoadImg:image
                                imgName:ImgName(_resLogicName, _Gid)
                                  param:param
                                success:^(id  _Nonnull result) {
        
        [[Yuan_HUD shareInstance] HUDFullText:@"图片上传成功"];
        
        // 重新请求列表
        [self http_GetList];
        
    }];
    
}

// 获取图片列表 -- url列表 不是真实的图片
- (void) http_GetList {
    
    NSDictionary * dict = @{
        @"pageSize" : @"-1",
        @"pageNum" : @"-1",
        @"sysName" : @"OSS2.0",
        @"serviceId" : _Gid
    };
    
    [Yuan_PhotoHttpModel http_GetList_PhotoURL:dict
                                       success:^(NSArray * _Nonnull result) {
          
        _imgHttpDataSource = [NSMutableArray arrayWithArray:result];
        [_collection reloadData];
    }];
    
    
}


- (void) http_deleteImgWithDict:(NSDictionary *)dict
                      indexPath:(NSIndexPath *)indexPath{
    
    
    
    
    
    [Yuan_PhotoHttpModel http_deletePhoto:dict
                                  success:^(NSArray * _Nonnull result) {
        
        // 因为拍照按钮的存在 所以要 -1
        [_imgHttpDataSource removeObjectAtIndex:indexPath.row - 1];
        [_collection deleteItemsAtIndexPaths:@[indexPath]];
        [_collection reloadData];
    }];
    
}


#pragma mark -  delegate  ---

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    // 最少一个  , 上传图片的按钮
    return _imgHttpDataSource.count + 1;
}




- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    
    
    Yuan_PhotoItem * item =
    [collectionView dequeueReusableCellWithReuseIdentifier:@"Yuan_PhotoItem"
                                              forIndexPath:indexPath];
    
    
    if (!item) {
        item = Yuan_PhotoItem.alloc.init;
    }else {
        [item hideBtn];
    }
    
    
    // 当 0 的时候 , 是拍照
    if (indexPath.row == 0) {
        [item showBtn];
        [item.takePhotoBtn addTarget:self
                              action:@selector(openCarema)
                    forControlEvents:UIControlEventTouchUpInside];
        
        return item;
        
    }
    
    
    
    // 以为有上传按钮的存在 , 所以有 -1 一位
    NSDictionary * dict = _imgHttpDataSource[indexPath.row - 1];
    
    item.filePath = dict[@"filePath"];
    [item downLoadImg];
    item.index = indexPath;
    
    item.itemLongPressBlock = ^(NSIndexPath * _Nonnull index) {
        [self itemLongPress:index];
    };
    
    return item;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (indexPath.row == 0) {
        return;
    }
    
    
    Yuan_PhotoItem * item  =
    (Yuan_PhotoItem*)[collectionView cellForItemAtIndexPath:indexPath];
    
    UIImage * img = item.photoImg.image;
    
    
    if (!img) {
        [[Yuan_HUD shareInstance] HUDFullText:@"未检测到图片 , 请下载完成后重试" delay:1];
        return;
    }
    
    
    _carema = [[Yuan_BigImgVC alloc] initWithImg:img];
     
    self.definesPresentationContext = YES;
    _carema.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    _carema.modalPresentationStyle = UIModalPresentationOverFullScreen;//关键语句，必须有 ios8 later
 
    [self presentViewController:_carema animated:NO completion:nil];
    
//    [[SDImageCache sharedImageCache] setValue:nil forKey:@"memCache"];
}


#pragma mark -  长按  ---


- (void) itemLongPress:(NSIndexPath *)indexPath {
    
    [UIAlert alertSmallTitle:@"是否删除照片"
               agreeBtnBlock:^(UIAlertAction *action) {
        
        
        Yuan_PhotoItem * item = (Yuan_PhotoItem *)[_collection cellForItemAtIndexPath:indexPath];
        
        if (!item) {
            NSString * pointStr = [NSString stringWithFormat:@"%ld ",indexPath.row];
            [[Yuan_HUD shareInstance] HUDFullText:pointStr delay:0.5];
            return ;
        }
        
        NSDictionary * dict = @{
            @"userName" : _userName,
            @"filePath" : item.filePath
        };
        
        [self http_deleteImgWithDict:dict indexPath:indexPath];
        
    }];
    
}



- (void) longpress_delete:(UILongPressGestureRecognizer *)longPress {
    
    if (longPress.state == UIGestureRecognizerStateBegan) {
        
        [UIAlert alertSmallTitle:@"是否删除照片"
                   agreeBtnBlock:^(UIAlertAction *action) {
            
            
            
            
            CGPoint point = [longPress locationInView:_collection];
            
            NSIndexPath *currentIndexPath = [_collection indexPathForItemAtPoint:point];
            
            Yuan_PhotoItem * item = (Yuan_PhotoItem *)[_collection cellForItemAtIndexPath:currentIndexPath];
            
            if (!item) {
                NSString * pointStr = [NSString stringWithFormat:@"%f - %f",point.x , point.y];
                [[Yuan_HUD shareInstance] HUDFullText:pointStr delay:0.5];
                return ;
            }
            
    
        }];
        
    }
    
}




#pragma mark -  CaremaService  ---

- (void) openCarema {
    // 打开相机
    [_photoService openCaremaEnum:PhotoEnum_Carema delegate:self];
}

- (void) openLibrary {
    // 打开相册
    [_photoService openCaremaEnum:PhotoEnum_Library delegate:self];
}





#pragma mark - ImagePicker Delegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    
    NSString * mediaType = info[UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:@"public.image"]) {
    
        [picker dismissViewControllerAnimated:YES completion:nil];
        
        BOOL isNeedCancelLocation = false;
        
        
        
        // GCD做线程通信传值 , 长时间操作在子线程中操作 , 拿到值后回传给主线程使用.
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            
            UIImage * image = info[UIImagePickerControllerOriginalImage];
            
            // 修改照片旋转的角度
            if(image.imageOrientation != UIImageOrientationUp){
                // Adjust picture Angle
                UIGraphicsBeginImageContext(image.size);
                [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
            
            

            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self photoOver:image];
            });
            
        });
        
    }
            
}



- (void) photoOver:(UIImage *)newImg {
    
    [[Yuan_HUD shareInstance] HUDHide];
    // 去进行图片上传操作
    [self http_UpLoadWithImg:newImg];
}




#pragma mark -  UI  ---


- (UICollectionView *)collection {
    
    if (!_collection) {
        
        UICollectionViewFlowLayout * flowLayout = UICollectionViewFlowLayout.alloc.init;
        
        flowLayout.minimumLineSpacing = 2;
        flowLayout.minimumInteritemSpacing = 2;
        flowLayout.itemSize = CGSizeMake(Horizontal(88), Horizontal(117));
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        
        _collection = [UIView collectionDatasource:self
                                     registerClass:[Yuan_PhotoItem class]
                               CellReuseIdentifier:@"Yuan_PhotoItem"
                                        flowLayout:flowLayout];
        
        
        
    }
    return _collection;
}


#pragma mark -  naviSet  ---


- (void) naviSet {
    
    UIBarButtonItem * choosePhoto = [UIView getBarButtonItemWithTitleStr:@"选择照片" Sel:@selector(choosePhotoClick) VC:self];
    self.navigationItem.rightBarButtonItems = @[choosePhoto];
}



// 选择照片 图库
- (void) choosePhotoClick {
    
    [self openLibrary];

}


- (void)didReceiveMemoryWarning {
    
//    [[SDImageCache sharedImageCache] clearDisk];
    [[SDImageCache sharedImageCache] clearMemory];
    
    if (_carema) {
        [[Yuan_HUD shareInstance] HUDFullText:@"内存占用过高" delay:1];
        [_carema dismissViewControllerAnimated:YES completion:nil];
    }
    
}

@end
