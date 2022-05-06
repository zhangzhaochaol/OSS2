//
//  IWPButton.m
//  OSS2.0-ios-v2
//
//  Created by 王旭焜 on 2016/6/6.
//  Copyright © 2016年 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "IWPButton.h"
//#import "INCControlBarButtonAngleView.h"

@interface IWPButton ()
@property (nonatomic, copy) NSString * colorName;
@property (nonatomic, weak) UIImageView * cornerImage;

@end

@implementation IWPButton


-(UIImageView *)cornerImage{
    
    if (_cornerImage == nil) {
        
        UIImageView * cornerImage = [UIImageView.alloc init];
        _cornerImage = cornerImage;
        
        [self addSubview:cornerImage];
        [cornerImage mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.top.equalTo(self);
            make.width.offset(IphoneSize_Width(18));
            make.height.offset(IphoneSize_Height(18));
            
        }];
        
    }else{
        [_cornerImage removeFromSuperview];
        _cornerImage = nil;
        return self.cornerImage;
    }
    
    return _cornerImage;
    
}

- (void)configCorderAngle:(NSString *)colorName{
    
    self.colorName = colorName;
    self.cornerImage.alpha = 1;
    
    
}

-(void)setCornerStatus:(IWPPECCornerStatus)cornerStatus{
    _cornerStatus = cornerStatus;
    
    if (cornerStatus == IWPPECCornerStatusHave) {
        self.cornerImage.image = [UIImage Inc_imageNamed:@"icon_corner_green"];
    }else{
        self.cornerImage.image = [UIImage Inc_imageNamed:@"icon_corner_grey"];
    }
    
}

-(void)setHighlighted:(BOOL)highlighted{
    
    if (!(self.buttontype == IWPButtonTypeSpecial)) {
        
        
        
        return;
        // 袁全注释 有这段代码 会导致 点击后变颜色 , 我不需要高亮效果
//        self.backgroundColor = ;
        
        [UIView animateWithDuration:.5f animations:^{
            self.backgroundColor = highlighted ? [self.backgroundColor setAlpha:.7f] : [UIColor mainColor];
        }];
    }
    
    
}


//-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    [super touchesBegan:touches withEvent:event];
//
//
//}
@end
