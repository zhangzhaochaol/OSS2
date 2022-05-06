//
//  Inc_jumpSelectCell.m
//  OSS2.0-ios-v2
//
//  Created by zzc on 2021/6/25.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_jumpSelectCell.h"

@interface Inc_jumpSelectCell ()

//名称
@property (nonatomic, strong) UILabel *nameLabel;

@end

@implementation Inc_jumpSelectCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = UIColor.whiteColor;
        [self setupUI];
        
        
    }
    return self;
}

- (void)setupUI {
    
    _nameLabel = [UIView labelWithTitle:@"" isZheH:YES];

    [self.contentView addSubview:_nameLabel];
}


- (void)setDic:(NSDictionary *)dic {
    _dic = dic;
        
    _nameLabel.text = dic[@"name"];
    
    [self ZhangLayouts];
}

- (void)ZhangLayouts {
    
    CGFloat height = [_nameLabel.text boundingRectWithSize:CGSizeMake(ScreenWidth  -22, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_nameLabel.font} context:nil].size.height;
        
    [_nameLabel YuanToSuper_Top:0];
    [_nameLabel YuanToSuper_Right:10];
    [_nameLabel YuanToSuper_Left:10];
    [_nameLabel autoSetDimension:ALDimensionHeight toSize:MAX(height + 1, self.height)];
    [_nameLabel YuanToSuper_Bottom:0];

    
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
