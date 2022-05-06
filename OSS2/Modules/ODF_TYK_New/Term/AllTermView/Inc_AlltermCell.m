//
//  Inc_AlltermCell.m
//  OSS2.0-ios-v2
//
//  Created by zzc on 2021/6/17.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_AlltermCell.h"


@interface Inc_AlltermCell ()

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation Inc_AlltermCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
//        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = UIColor.whiteColor;
        self.contentView.userInteractionEnabled = YES;
        [self setupUI];
        
        
    }
    return self;
}

- (void)setupUI {
    
    _titleLabel = [UIView labelWithTitle:@"" isZheH:YES];
    _titleLabel.textColor = UIColor.lightGrayColor;
    _titleLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapEvent:)];
    [_titleLabel addGestureRecognizer:tap];
    
    [self.contentView addSubview:_titleLabel];
    
}


- (void)setDic:(NSDictionary *)dic {
    _dic = dic;
        
    _titleLabel.text = dic[@"optRoadName"];
    _titleLabel.textColor = UIColor.lightGrayColor;

    [self ZhangLayouts];
}

- (void)setCableDic:(NSDictionary *)cableDic {
    _cableDic = cableDic;
        
    _titleLabel.text = cableDic[@"resName"];
    _titleLabel.textColor = UIColor.lightGrayColor;

    [self ZhangLayouts];
}


- (void)setCarryingDic:(NSDictionary *)carryingDic {
    _carryingDic = carryingDic;
        
    _titleLabel.text = carryingDic[@"resName"];
    _titleLabel.textColor = UIColor.lightGrayColor;

    [self ZhangLayouts];
}


- (void)ZhangLayouts {
    
    CGFloat height = [_titleLabel.text boundingRectWithSize:CGSizeMake(ScreenWidth  -22, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_titleLabel.font} context:nil].size.height;
    
    [_titleLabel YuanToSuper_Top:0];
    [_titleLabel YuanToSuper_Left:10];
    [_titleLabel YuanToSuper_Right:10];
    [_titleLabel autoSetDimension:ALDimensionHeight toSize:MAX(height + 1, self.height)];
    [_titleLabel YuanToSuper_Bottom:0];

    
}


//title 点击
-(void)tapEvent:(UITapGestureRecognizer *)gesture {
  
    if (self.labelBlock) {
        self.labelBlock(_titleLabel);
    }
}


- (void)awakeFromNib {
    [super awakeFromNib];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];


}

@end
