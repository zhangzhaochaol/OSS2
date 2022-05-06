//
//  Yuan_PhotoItem.m
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/8/24.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_PhotoItem.h"
#import "UIImageView+WebCache.h"
#import <SDWebImage/SDImageCache.h>

@implementation Yuan_PhotoItem



#pragma mark - 初始化构造方法

- (instancetype) initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        [self UI_Init];
        self.contentView.backgroundColor = UIColor.whiteColor;
        
        UILongPressGestureRecognizer * longpress_delete =
        [[UILongPressGestureRecognizer alloc]initWithTarget:self
                                                     action:@selector(longpress_delete:)];
        
        [self.contentView addGestureRecognizer:longpress_delete];
        [longpress_delete setMinimumPressDuration:0.3];  //长按0.3秒后执行事件
        
    }
    return self;
}


- (void) UI_Init {
    
    _photoImg = UIImageView.alloc.init;
    _photoImg.backgroundColor = Color_V2Blue;
    [self.contentView addSubview:_photoImg];
    [_photoImg autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    _photoImg.backgroundColor = ColorValue_RGB(0xf2f2f2);
    _photoImg.contentMode = UIViewContentModeScaleAspectFit;
    _photoImg.userInteractionEnabled = YES;
}


- (void)downLoadImg {
    
    
    if (!_filePath || _filePath.length == 0) {
        return;
    }
    
    [[SDImageCache sharedImageCache] clearMemory];
    
    NSString * imgUrl = [NSString stringWithFormat:@"http://120.52.12.12:8951/fastdfs/%@",_filePath];
    

    
    [_photoImg sd_setImageWithURL:[NSURL URLWithString:imgUrl]
                    placeholderImage:nil
                    completed:^(UIImage * _Nullable image,
                                NSError * _Nullable error,
                                SDImageCacheType cacheType,
                                NSURL * _Nullable imageURL) {
        
        
        
        _photoImg.image = image;
    }] ;
    
}



- (void) showBtn {
    
    _photoImg.hidden = YES;
    
    
    _takePhotoBtn = UIButton.alloc.init;
    [_takePhotoBtn setImage:[UIImage Inc_imageNamed:@"TYKPhoto_XiangJi"]
                   forState:UIControlStateNormal];
    _takePhotoBtn.backgroundColor = ColorValue_RGB(0xd2d2d2);
    [self.contentView addSubview:_takePhotoBtn];
    [_takePhotoBtn autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
}

- (void) hideBtn {
    
    _photoImg.hidden = NO;
    
    if (_takePhotoBtn) {
        [_takePhotoBtn removeFromSuperview];
        _takePhotoBtn = nil;
    }
    
}



#pragma mark -  长按  ---

- (void) longpress_delete:(UILongPressGestureRecognizer *)longPress {

    if (!_index) {
        return;
    }
    
    
    if (longPress.state == UIGestureRecognizerStateBegan) {
        
        if (_itemLongPressBlock) {
            _itemLongPressBlock(_index);
        }
    }
}


@end
