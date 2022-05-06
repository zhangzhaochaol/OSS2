//
//  Inc_BusCableFiberItem.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/2/20.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_BusCableFiberItem.h"
#import "Yuan_CFConfigVM.h"

@interface Inc_BusCableFiberItem ()


/** 我的编号 */
@property (nonatomic,strong) UILabel *myNum;

/** 绑定的编号 */
@property (nonatomic,strong) UILabel *bindingNum;


@end

@implementation Inc_BusCableFiberItem

{
    
    UIImageView * _upImg;
    UIImageView * _downImg;
    
    Yuan_CFConfigVM * _viewModel;

}



#pragma mark - 初始化构造方法

- (instancetype) initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        

        
        self.contentView.backgroundColor = ColorValue_RGB(0xf2f2f2);
        
        _myNum = [UIView labelWithTitle:@"01" frame:CGRectNull];
        _myNum.textColor = UIColor.blackColor;
        _myNum.font = Font_Bold_Yuan(14);
        
        _bindingNum = [UIView labelWithTitle:@"   " frame:CGRectNull];
        _bindingNum.font = Font_Bold_Yuan(12);
        _bindingNum.textColor = ColorR_G_B(0, 225, 109);
        
        _upImg = [UIView imageViewWithImg:[UIImage Inc_imageNamed:@"cf_lan_shang"]
                                    frame:CGRectNull];
        
        _downImg = [UIView imageViewWithImg:[UIImage Inc_imageNamed:@"cf_lan_xia"]
                                      frame:CGRectNull];
        
        [self.contentView addSubviews:@[_myNum,_bindingNum,_upImg,_downImg]];
        [self layoutAllSubViews];
        
        _viewModel = Yuan_CFConfigVM.shareInstance;
        
 
        
    }
    return self;
}





#pragma mark -  setget / dict  ---

- (void) configBuliding_Color {
    
    
    self.contentView.backgroundColor = ColorValue_RGB(0xf2f2f2);

}

/// 左上角图片 是成端还是熔接
- (void) imgConfigUpImage:(CF_HeaderCellType_)upType {
    
    _upImg.hidden = NO;
    
    if (upType == CF_HeaderCellType_ChengDuan) {
        _upImg.image = [UIImage Inc_imageNamed:@"cf_lan_shang"];
    }else if(upType == CF_HeaderCellType_RongJie){
        _upImg.image = [UIImage Inc_imageNamed:@"cf_hong_shang"];
    }else {
        
        _upImg.hidden = YES;
    }
    
}


/// 右下角图片 是成端还是熔接
- (void) imgConfigDownImg:(CF_HeaderCellType_)downType {
    
    _downImg.hidden = NO;
    
    if (downType == CF_HeaderCellType_ChengDuan) {
        _downImg.image = [UIImage Inc_imageNamed:@"cf_lan_xia"];
    }else if(downType == CF_HeaderCellType_RongJie){
        _downImg.image = [UIImage Inc_imageNamed:@"cf_hong_xia"];
    }else {
        _downImg.hidden = YES;
    }
    
}



- (void) configNum:(NSString *)index {
    
    _myNum.text = index;
}


- (void) configBindNum : (NSString *)pairNo from:(configBindingNumFrom_)type{
    
    _bindingNum.text = pairNo;
    
    if (type == configBindingNumFrom_HTTP) {
        _bindingNum.textColor = UIColor.orangeColor;
    }else {
        _bindingNum.textColor = ColorR_G_B(0, 225, 109);
    }
}









#pragma mark - 屏幕适配

- (void)layoutAllSubViews {
    
    float limit = Horizontal(3);
    
    [_myNum autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:limit];
    [_myNum autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:limit];
    
    [_bindingNum autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:limit];
    [_bindingNum autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:limit];
    
    [_upImg autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [_upImg autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0];
    
    [_downImg autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    [_downImg autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
    
}
@end
