//
//  IWPGISSiftCollectionViewCell.m
//  OSS2.0-ios-v2
//
//  Created by 王旭焜 on 2018/11/27.
//  Copyright © 2018 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "IWPGISSiftCollectionViewCell.h"

@interface IWPGISSiftCollectionViewCell ()
@property (nonatomic, weak) UIButton * checkBox;
@property (nonatomic, weak) UILabel * titleLabel;
@end

@implementation IWPGISSiftCollectionViewCell
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        UIButton * checkBox = [UIButton buttonWithType:UIButtonTypeCustom];
        _checkBox = checkBox;
        checkBox.userInteractionEnabled = false;
        [checkBox setImage:[UIImage Inc_imageNamed:@"login_password_selected"] forState:UIControlStateSelected];
        [checkBox setImage:[UIImage Inc_imageNamed:@"login_password_normal"] forState:UIControlStateNormal];
        
        checkBox.titleLabel.font = [UIFont systemFontOfSize:Horizontal(12)];
        [checkBox setTitleColor:[UIColor colorWithHexString:@"#5e6977"] forState:UIControlStateNormal];
        
        [self.contentView addSubview:checkBox];
        
        [checkBox mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.left.equalTo(self.contentView).offset(IphoneSize_Width(5));
            make.centerY.equalTo(self.contentView);
            make.width.offset(IphoneSize_Width(17));
            make.height.offset(IphoneSize_Height(17));
            
        }];
        
        UILabel * titleLabel = UILabel.new;
        _titleLabel = titleLabel;
        titleLabel.font = [UIFont systemFontOfSize:Horizontal(14)];
        
        [self.contentView addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.left.equalTo(checkBox.mas_right).offset(IphoneSize_Width(5));
            make.right.equalTo(self.contentView).offset(IphoneSize_Width(-5));
            make.centerY.equalTo(self.contentView);
            make.height.offset(IphoneSize_Height(17));
            
        }];
        
    }
    return self;
}

-(void)setTitle:(NSString *)title{
    self.titleLabel.text = title;
    if ([title isEqualToString:@"全部"]) {
        self.titleLabel.textColor = [UIColor colorWithHexString:@"#3577ff"];
    }else{
        self.titleLabel.textColor = [UIColor colorWithHexString:@"#333"];
    }
//    [_checkBox setTitle:title forState:UIControlStateNormal];
}

-(void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    
    self.checkBox.selected = selected;
}



@end
