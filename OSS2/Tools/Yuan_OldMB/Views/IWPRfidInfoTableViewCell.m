//
//  IWPRfidInfoTableViewCell.m
//  OSS2.0-ios-v2
//
//  Created by 王旭焜 on 2017/4/13.
//  Copyright © 2017年 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "IWPRfidInfoTableViewCell.h"



@implementation IWPRfidInfoModel

-(instancetype)initWithDict:(NSDictionary *)dict{
    
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
    }
    
    
    return self;
}


+(instancetype)modelWithDict:(NSDictionary *)dict{
    return [[self alloc] initWithDict:dict];
}

@end


@implementation IWPRfidInfoFrameModel

-(void)setModel:(IWPRfidInfoModel *)model{
    _model = model;
    
    CGSize maxSize = CGSizeMake(ScreenWidth - 60.f, MAXFLOAT);
    
    CGSize titleLabelSize = [model.cableName boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17.f]} context:nil].size;
    
    
    if (titleLabelSize.height < 30.f) {
        titleLabelSize.height = 30.f;
    }
    
    CGRect frame = CGRectMake(15, 5, 0, 0);
    frame.size = titleLabelSize;
    
    _titleLabelFrame = frame;
    
    _rowHeight = CGRectGetMaxY(frame) + 5.f;
    
    

    
}

@end



@interface IWPRfidInfoTableViewCell ()
@property (nonatomic, weak) UILabel * titleLabel;
@end

@implementation IWPRfidInfoTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        UILabel * titleLabel = [[UILabel alloc] init];
        self.titleLabel = titleLabel;
        
        titleLabel.numberOfLines = 0;
        
        [self.contentView addSubview:titleLabel];
    }
    
    return self;
    
}

-(void)setModel:(IWPRfidInfoFrameModel *)model{
    
    _model = model;
    [self configSubViews];
    
}

-(void)configSubViews{

    self.titleLabel.frame = _model.titleLabelFrame;
    
    self.titleLabel.text = _model.model.cableName;

 
    if (_model.model.cableRfid.length > 1) {
        self.titleLabel.textColor = [UIColor greenColor];
    }else{
        self.titleLabel.textColor = [UIColor blackColor];
    }
    
    
    
    
    
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    
    [UIView animateWithDuration:animated ? .7f : 0.f animations:^{
        if (highlighted) {
            self.backgroundColor = [UIColor colorWithHexString:@"#f3f3f3"];
        }else{
            self.backgroundColor = [UIColor colorWithHexString:@"#fff"];
        }
    }];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    
    [UIView animateWithDuration:animated ? .7f : 0.f animations:^{
        if (selected) {
            self.backgroundColor = [UIColor colorWithHexString:@"#f3f3f3"];
        }else{
            self.backgroundColor = [UIColor colorWithHexString:@"#fff"];
        }
    }];
    
    // Configure the view for the selected state
}

/// 重写指示视图setter
/// 适配iOS13
/// @param accessoryType 指示视图类型
-(void)setAccessoryType:(UITableViewCellAccessoryType)accessoryType{
    
    if (accessoryType == UITableViewCellAccessoryDisclosureIndicator){
        // 该类型存在显示错误的问题，采用指定图片的方式适配
        
        UIImageView * accessoryView = [UIImageView.alloc initWithImage:[UIImage Inc_imageNamed:@"icon_defaultAccessoryView"]];
        accessoryView.frame = CGRectMake(0, 0, 15, 15);
        
        self.accessoryView = accessoryView;
        
        
    }else{
        [super setAccessoryType:accessoryType];
    }
    
    
}
@end
