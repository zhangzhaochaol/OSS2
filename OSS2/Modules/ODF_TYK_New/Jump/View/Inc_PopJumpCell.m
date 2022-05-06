//
//  Inc_PopJumpCell.m
//  OSS2.0-ios-v2
//
//  Created by zzc on 2021/6/24.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_PopJumpCell.h"


@interface Inc_PopJumpCell ()
//    A/Z端子
@property (nonatomic, strong) UILabel *tipLabel;
//端子名称
@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UIView *bgView;

@end


@implementation Inc_PopJumpCell



- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = UIColor.whiteColor;
        [self setupUI];
        
        
    }
    return self;
}

- (void)setupUI {
    
    _tipLabel = [UIView labelWithTitle:@"" frame:CGRectNull];
    _tipLabel.font = Font_Yuan(13);
    _tipLabel.textColor = UIColor.blackColor;
    
    _bgView = [UIView viewWithColor:UIColor.whiteColor];
    [_bgView cornerRadius:5 borderWidth:1 borderColor:UIColor.groupTableViewBackgroundColor];

    _nameLabel = [UIView labelWithTitle:@"" isZheH:YES];
    _nameLabel.textColor = UIColor.lightGrayColor;
    _nameLabel.font = Font_Yuan(13);
    

    [self.contentView addSubview:_tipLabel];
    [self.contentView addSubview:_bgView];
    [_bgView addSubview:_nameLabel];
}

- (void)setDic:(NSDictionary *)dic integer:(NSInteger)integer {
    _nameLabel.text = dic[@"resName"];
    
    if (integer == 0) {
        _tipLabel.text = @"A端子:";
    }else{
        _tipLabel.text = @"Z端子:";
    }
    
    [self ZhangLayouts];

}



- (void)ZhangLayouts {
    
    
    
    [_tipLabel YuanToSuper_Left:10];
    [_tipLabel YuanToSuper_Top:0];
    [_tipLabel YuanToSuper_Right:10];
    [_tipLabel autoSetDimension:ALDimensionHeight toSize:Horizontal(30)];
    
    
    
    CGFloat height = [_nameLabel.text boundingRectWithSize:CGSizeMake(ScreenWidth  -42, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_nameLabel.font} context:nil].size.height;
    
    [_bgView YuanToSuper_Left:10];
    [_bgView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_tipLabel withOffset:0];
    [_bgView YuanToSuper_Right:10];
    [_bgView autoSetDimension:ALDimensionHeight toSize:MAX(height + 1, Horizontal(30))];
    [_bgView YuanToSuper_Bottom:0];

    [_nameLabel YuanToSuper_Left:10];
    [_nameLabel YuanToSuper_Top:0];
    [_nameLabel YuanToSuper_Right:10];
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
