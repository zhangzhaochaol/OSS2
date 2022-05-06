//
//  YKLListViewCell.m
//  YKLListViewDemo
//
//  Created by 擎杉 on 2017/1/17.
//  Copyright © 2017年 艾玩世纪互动娱乐. All rights reserved.
//

#import "YKLListViewCell.h"

@implementation YKLListViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        // 创建开关
        UISwitch * switcher = [[UISwitch alloc] init];
        self.switcher = switcher;
        
        // 放在 accessoryView 中
        self.accessoryView = switcher;
        
        [switcher addTarget:self action:@selector(switcherHandler:) forControlEvents:UIControlEventValueChanged];
        
        self.textLabel.lineBreakMode = NSLineBreakByTruncatingHead;
        
        self.textLabel.font = [UIFont systemFontOfSize:15.f];
        
        
        self.imageView.layer.cornerRadius = 22.f;
        self.imageView.layer.masksToBounds = YES;
        
    }
    
    return self;
}

-(void)switcherHandler:(UISwitch *)switcher{
 
    if ([self.delegate respondsToSelector:@selector(didSwitchSwitcher:indexPath:isPlus:)]) {
        
        [self.delegate didSwitchSwitcher:switcher.isOn indexPath:self.indexPath isPlus:self.isPlus];
        
    }
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

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
