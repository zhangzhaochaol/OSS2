//
//  Inc_CFListCollectionItem.m
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/7/20.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_CFListCollectionItem.h"


@interface Inc_CFListCollectionItem ()
/** item */
@property (nonatomic,strong) UILabel * item;
@end

@implementation Inc_CFListCollectionItem

{
    
    UIImageView * _upImg;
    UIImageView * _downImg;
    
}


#pragma mark - 初始化构造方法

- (instancetype) initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        _item = [UIView labelWithTitle:@"1" frame:CGRectNull];
        _item.backgroundColor = ColorValue_RGB(0xf2f2f2);
        _item.textAlignment = NSTextAlignmentCenter;
        
        _upImg = [UIView imageViewWithImg:[UIImage Inc_imageNamed:@"cf_lan_shang"]
                                    frame:CGRectNull];
        
        _downImg = [UIView imageViewWithImg:[UIImage Inc_imageNamed:@"cf_lan_xia"]
                                      frame:CGRectNull];
        
        [self.contentView addSubviews:@[_item,_upImg,_downImg]];
        [self layoutAllSubViews];
        
        
        // 默认有一个透明色的边框
        self.layer.borderColor = [[UIColor clearColor] CGColor];
        self.layer.borderWidth = 1;
        
        
    }
    return self;
}


#pragma mark -  method  ---



/// 左上角图片 是成端还是熔接
- (void) imgConfigUpImage:(CF_HeaderCellType_)upType {
    
    
    
    if (upType == CF_HeaderCellType_ChengDuan) {
        _upImg.hidden = NO;
        _upImg.image = [UIImage Inc_imageNamed:@"cf_lan_shang"];
    }else if(upType == CF_HeaderCellType_RongJie){
        _upImg.hidden = NO;
        _upImg.image = [UIImage Inc_imageNamed:@"cf_hong_shang"];
    }else {
        
        _upImg.hidden = YES;
    }
    
}


/// 右下角图片 是成端还是熔接
- (void) imgConfigDownImg:(CF_HeaderCellType_)downType {
    
    if (downType == CF_HeaderCellType_ChengDuan) {
        
        _downImg.hidden = NO;
        _downImg.image = [UIImage Inc_imageNamed:@"cf_lan_xia"];
    }else if(downType == CF_HeaderCellType_RongJie){
        
        _downImg.hidden = NO;
        _downImg.image = [UIImage Inc_imageNamed:@"cf_hong_xia"];
    }else {
        _downImg.hidden = YES;
    }
    
}



- (void) configNum:(NSString *)index {
    
    _item.text = index;
    
}

/// 根据 oprStateId 去判断颜色 占用:绿色 故障:红色
/// @param oprStateId id
- (void) configColor:(NSString *)oprStateId  {
    
    if (!oprStateId) {
        return;
    }
    
    NSInteger oprstate = [oprStateId integerValue];
    
    switch (oprstate) {
        case 170003:  // 占用
            
            _item.backgroundColor = ColorValue_RGB(0xbbffaa);
            _item.textColor = UIColor.whiteColor;
            break;
        case 170147: // 故障
            
            _item.backgroundColor = ColorR_G_B(246, 100, 109);
            _item.textColor = UIColor.whiteColor;
            break;
            
        default:
            _item.backgroundColor = ColorValue_RGB(0xf2f2f2);
            _item.textColor = UIColor.blackColor;
            break;
    }
    
}



/// 根据枚举值 , 更改他的边框颜色
/// @param colorState color_enum
- (void) configBorderColor:(CollectionListItemState_)colorState {
    
    switch (colorState) {
            
        case CollectionListItemState_None:  //无关联 无选中状态
            self.layer.borderColor = UIColor.clearColor.CGColor;
            break;
        
        case CollectionListItemState_Connect: // 已经与其他绑定了
            self.layer.borderColor = ColorR_G_B(0, 225, 109).CGColor;
            break;
        
        case CollectionListItemState_SelectingNow: // 正在选中的状态
            self.layer.borderColor = Color_V2Red.CGColor;
            break;
            
        default:
            break;
    }
    
    
}


#pragma mark - 屏幕适配

- (void)layoutAllSubViews {

    [_item autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    [_upImg autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [_upImg autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0];
    
    [_downImg autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    [_downImg autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
    
    
}



@end
