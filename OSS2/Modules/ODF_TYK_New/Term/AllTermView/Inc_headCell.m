//
//  Inc_headCell.m
//  OSS2.0-ios-v2
//
//  Created by zzc on 2021/6/17.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_headCell.h"


@interface Inc_headCell ()
//名称
@property (nonatomic, strong) UILabel *titleLabel;
//端子
@property (nonatomic, strong) UILabel *termLabel;

@end

@implementation Inc_headCell



- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = UIColor.whiteColor;
        [self setupUI];
        
        
    }
    return self;
}

- (void)setupUI {
    
    _termLabel = [UIView labelWithTitle:@"" frame:CGRectMake(10, 10, 30, 16)];
    _termLabel.centerY = self.centerY;
    _termLabel.font = Font_Yuan(13);

    _titleLabel = [UIView labelWithTitle:@"" isZheH:YES];
    _titleLabel.textColor = UIColor.lightGrayColor;
    
    [self.contentView addSubview:_termLabel];
    [self.contentView addSubview:_titleLabel];
    
}


- (void)setDic:(NSDictionary *)dic {
    _dic = dic;
        
    _titleLabel.text = dic[@"resName"];
    
    [self ZhangLayouts];
}

- (void)setTypeName:(NSString *)typeName {
    
    if ([typeName isEqualToString:@"端子"]) {
        [_termLabel setCornerRadius:4 borderColor:ColorR_G_B(181, 220, 253) borderWidth:1];
        _termLabel.backgroundColor = ColorR_G_B(217, 237, 254);
        _termLabel.textColor = ColorR_G_B(62, 163, 252);
        _termLabel.text = @"端子";
    }else{
        [_termLabel setCornerRadius:4 borderColor:UIColor.lightGrayColor borderWidth:1];
        _termLabel.backgroundColor = ColorR_G_B(234, 235, 236);
        _termLabel.textColor = UIColor.lightGrayColor;
        _termLabel.text = @"纤芯";
    }
    [self ZhangLayouts];
}


- (void)ZhangLayouts {
    
    CGFloat height = [_titleLabel.text boundingRectWithSize:CGSizeMake(ScreenWidth  -22, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_titleLabel.font} context:nil].size.height;
    
//    _titleLabel.frame = CGRectMake(_termLabel.x + _termLabel.width + 10, 0, self.width -(_termLabel.x + _termLabel.width + 10) , MAX(height + 1, self.height));
    
    [_titleLabel YuanToSuper_Top:0];
    [_titleLabel autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:_termLabel withOffset:10];
    [_titleLabel YuanToSuper_Right:10];
    [_titleLabel autoSetDimension:ALDimensionHeight toSize:MAX(height + 1, self.height)];
    [_titleLabel YuanToSuper_Bottom:0];

    
}







- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
