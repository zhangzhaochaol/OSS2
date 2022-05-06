//
//  Yuan_TailorImageVC.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/1/22.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_TailorImageVC.h"
#import "TKImageView.h"
@interface Yuan_TailorImageVC ()
@property (nonatomic,strong)TKImageView *tkImageView;
@property (nonatomic,strong)UIImage *cropImg;
@end

@implementation Yuan_TailorImageVC


- (instancetype)initWithCropImage:(UIImage *)cropImage{
    
    if (self = [super init]) {
        self.cropImg = cropImage;
        [self viewConfig];
        self.view.backgroundColor = UIColor.blackColor;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}





- (void)viewConfig{
    
    
    self.tkImageView = [[TKImageView alloc] initWithFrame:CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height*0.8)];
    [self.view addSubview:_tkImageView];
    
    
    _tkImageView.toCropImage = self.cropImg;
    _tkImageView.showMidLines = YES;
    _tkImageView.needScaleCrop = YES;
    _tkImageView.showCrossLines = YES;
    _tkImageView.cornerBorderInImage = YES;
    _tkImageView.cropAreaCornerWidth = 3;
    _tkImageView.cropAreaCornerHeight = 3;
    _tkImageView.minSpace = 30;
    _tkImageView.cropAreaCornerLineColor = [UIColor lightGrayColor];
    _tkImageView.cropAreaBorderLineColor = [UIColor grayColor];
    _tkImageView.cropAreaCornerLineWidth = 6;
    _tkImageView.cropAreaBorderLineWidth = 6;
    _tkImageView.cropAreaMidLineWidth = 30;
    _tkImageView.cropAreaMidLineHeight = 8;
    _tkImageView.cropAreaMidLineColor = [UIColor grayColor];
    _tkImageView.cropAreaCrossLineColor = [UIColor whiteColor];
    _tkImageView.cropAreaCrossLineWidth = 1;
    
    UIButton *cancleBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    cancleBtn.frame = CGRectMake(0, 500, [UIScreen mainScreen].bounds.size.width/2, 50);
    [cancleBtn setTitle:@"取消" forState:(UIControlStateNormal)];
    [cancleBtn addTarget:self action:@selector(cancleBtnAction) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:cancleBtn];
    
    UIButton *okBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [okBtn addTarget:self action:@selector(okBtnAction) forControlEvents:(UIControlEventTouchUpInside)];
    okBtn.frame = CGRectMake(CGRectGetMaxX(cancleBtn.frame), CGRectGetMinY(cancleBtn.frame), CGRectGetWidth(cancleBtn.frame), CGRectGetHeight(cancleBtn.frame));
    [okBtn setTitle:@"确定" forState:(UIControlStateNormal)];
    [self.view addSubview:okBtn];
}

- (void)viewDidAppear:(BOOL)animated{
    _tkImageView.cropAspectRatio = 0;
}

#pragma mark buttonAction
- (void)cancleBtnAction{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)okBtnAction{
    
    [self dismissViewControllerAnimated:NO completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CropOK" object: [_tkImageView currentCroppedImage]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DISSMISSPICKER" object:nil];
    }];
    
}


@end
