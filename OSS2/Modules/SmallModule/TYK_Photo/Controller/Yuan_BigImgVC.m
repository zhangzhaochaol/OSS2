//
//  Yuan_BigImgVC.m
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/8/25.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_BigImgVC.h"
#import "UIImageView+WebCache.h"
#import <SDWebImage/SDImageCache.h>

@interface Yuan_BigImgVC ()

@end

@implementation Yuan_BigImgVC

{
    
    UIImageView * _photoImg;
    
    UIImage * _img;
    
    NSString * _url;
    
}

#pragma mark - 初始化构造方法

- (instancetype) initWithImg:(UIImage *)img {
    
    if (self = [super init]) {
        _img = img;
    }
    return self;
}

// 根据url查看图片
- (instancetype) initWithImgUrl:(NSString *)url {
    
    
    if (self = [super init]) {
        _url = url;
    }
    return self;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.whiteColor;
    
//    [[SDImageCache sharedImageCache] setValue:nil forKey:@"memCache"];
    
    _photoImg = UIImageView.alloc.init;
    [self.view addSubview:_photoImg];
    [_photoImg autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    _photoImg.backgroundColor = UIColor.blackColor;
    _photoImg.contentMode = UIViewContentModeScaleAspectFit;
    _photoImg.userInteractionEnabled = YES;
    _photoImg.userInteractionEnabled = YES;
    
    
    if (_img) {
        _photoImg.image = _img;
    }
    else if(_url){
        
        [[SDImageCache sharedImageCache] clearMemory];
        
        [_photoImg sd_setImageWithURL:[NSURL URLWithString:_url]
                        placeholderImage:nil
                        completed:^(UIImage * _Nullable image,
                                    NSError * _Nullable error,
                                    SDImageCacheType cacheType,
                                    NSURL * _Nullable imageURL) {
            
            _photoImg.image = image;
            _photoImg.contentMode =UIViewContentModeScaleAspectFit;
        }];
    }
    else {
        
        [YuanHUD HUDFullText:@"无可查看的图片"];
        return;
    }
    
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

@end
