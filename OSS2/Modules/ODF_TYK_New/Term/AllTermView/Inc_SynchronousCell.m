//
//  Inc_SynchronousCell.m
//  OSS2.0-ios-v2
//
//  Created by zzc on 2021/6/15.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_SynchronousCell.h"
@interface Inc_SynchronousCell ()

//cell 边框背景
@property (nonatomic, strong) UIView *bgView;
//端子/纤芯
@property (nonatomic, strong) UILabel *nameLabel;
//竖线
@property (nonatomic, strong) UIView *vLine;
//横线
@property (nonatomic, strong) UIView *hLine;

// title  光缆段/机架名称
@property (nonatomic, strong) UILabel *contentLabel1;

// title  端子/纤芯名称
@property (nonatomic, strong) UILabel *contentLabel2;



@end

@implementation Inc_SynchronousCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self setupUI];

    }
    return self;
}


- (void)setupUI {
    
    _bgView = [UIView viewWithColor:UIColor.whiteColor];
    [_bgView setCornerRadius:1 borderColor:UIColor.groupTableViewBackgroundColor borderWidth:1];
    
    
    _nameLabel  = [UIView labelWithTitle:@"" frame:CGRectNull];
    _nameLabel.textAlignment = NSTextAlignmentCenter;
    _nameLabel.font = Font_Yuan(11);
    
   
    _vLine = [UIView viewWithColor:UIColor.groupTableViewBackgroundColor];

    _contentLabel1 = [UIView labelWithTitle:@"" isZheH:YES];
    _contentLabel1.font = Font_Yuan(15);
    _contentLabel1.textColor = UIColor.blackColor;

    
    _contentLabel2 = [UIView labelWithTitle:@"" isZheH:YES];
    _contentLabel2.font = Font_Yuan(15);
    _contentLabel2.textColor = UIColor.lightGrayColor;

    _hLine = [UIView viewWithColor:UIColor.groupTableViewBackgroundColor];
    
    [self.contentView addSubview:_bgView];
    
    [_bgView addSubviews:@[_nameLabel,_vLine,_contentLabel1,_hLine,_contentLabel2]];
    
    
}

//适配
- (void)Zhang_layoutViews {
        
    CGFloat title1Hight = [_contentLabel1.text boundingRectWithSize:CGSizeMake(ScreenWidth - 125, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_contentLabel1.font} context:nil].size.height;

    CGFloat title2Hight = [_contentLabel2.text boundingRectWithSize:CGSizeMake(ScreenWidth - 125, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_contentLabel2.font} context:nil].size.height;

    
    [_bgView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:10];
    [_bgView autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:10];
    [_bgView autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:10];
    [_bgView autoSetDimension:ALDimensionHeight toSize:MAX(30, title1Hight+1) + MAX(30, title2Hight+1)];
    [_bgView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];

    CGFloat nameWidth =  [_nameLabel.text boundingRectWithSize:CGSizeMake(120, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_nameLabel.font} context:nil].size.width;
    
    [_nameLabel autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:(50 - MAX(30, nameWidth+5))/2];
    [_nameLabel autoSetDimensionsToSize:CGSizeMake(MAX(30, nameWidth+5), 16)];
    [_nameLabel YuanAttributeHorizontalToView:_bgView];
    

    _vLine.frame = CGRectMake(50, 0, 1, MAX(30, title1Hight+1) + MAX(30, title2Hight+1) + 30);
    
    _contentLabel1.frame = CGRectMake(_vLine.x + 5, 0, ScreenWidth - 20*2 - 10 * 2 - 5*2 - 55, MAX(30, title1Hight+1));

    _hLine.frame = CGRectMake(_vLine.x, _contentLabel1.height, ScreenWidth - 110, 1);
    
    _contentLabel2.frame = CGRectMake(_contentLabel1.x, _hLine.y + _hLine.height, _contentLabel1.width, MAX(30, title2Hight+1));
        
}


- (void)setDic:(NSDictionary *)dic {
    _dic = dic;
   
    _nameLabel.text = [self getEtpSting:_dic[@"eptTypeId"]];
    _contentLabel1.text = _dic[@"relateResName"];
    _contentLabel2.text = _dic[@"eptName"];
    
    
    if ([_nameLabel.text isEqualToString:@"端子"]) {
        [_nameLabel setCornerRadius:4 borderColor:ColorR_G_B(181, 220, 253) borderWidth:1];
        _nameLabel.backgroundColor = ColorR_G_B(217, 237, 254);
        _nameLabel.textColor = ColorR_G_B(62, 163, 252);
    }else{
        [_nameLabel setCornerRadius:4 borderColor:UIColor.lightGrayColor borderWidth:1];
        _nameLabel.backgroundColor = ColorR_G_B(234, 235, 236);
        _nameLabel.textColor = UIColor.lightGrayColor;
    }
    [self Zhang_layoutViews];

}


- (NSString *)getEtpSting:(NSString *)eptTypeId {
    
    NSString *str = @"";
    
    switch ([eptTypeId integerValue]) {
        case 317:
            str = @"端子";
            break;
        case 702:
            str = @"纤芯";
            break;
        case 731:
            str = @"局向光纤";
            break;
            
        default:
            
            break;
    }
    
    return str;
    
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
