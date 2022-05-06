//
//  IWPPopverOperationTableViewCell.m
//  OSS2.0-ios-v2
//
//  Created by 王旭焜 on 2017/10/9.
//  Copyright © 2017年 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "IWPPopverOperationTableViewCell.h"
#import "IWPPopverViewItem.h"
#import "IWPTools.h"

@interface IWPPopverOperationTableViewCell()
@property (nonatomic, weak) UITableView * tableView;

@end

@implementation IWPPopverOperationTableViewCell

+ (instancetype)operationCellInTableView:(UITableView *)tableView item:(IWPPopverViewItem *)item indexPath:(NSIndexPath *)indexPath{
    static NSString * kCellId = @"kCellId";
    

    IWPPopverOperationTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:kCellId];
    
    if (cell == nil) {
        cell = [[IWPPopverOperationTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellId];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = [UIFont systemFontOfSize:15.f];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.textColor = [UIColor colorWithHexString:@"#e4e4e4"];
        NSInteger count = [tableView.dataSource tableView:tableView numberOfRowsInSection:indexPath.section];
        
        NSLog(@"%@ - %ld", indexPath, (long)count);
        if (indexPath.row < count - 1) {
            UIImageView *separatorImageView = [[UIImageView alloc] initWithFrame:CGRectMake(IphoneSize_Width(10), IphoneSize_Width(44) - IphoneSize_Width(6) , tableView.width - IphoneSize_Width(20), IphoneSize_Width(6))];
            [separatorImageView setImage:[UIImage Inc_imageNamed:@"DefaultLine"]];
            separatorImageView.opaque = YES;
            [cell.contentView addSubview:separatorImageView];
        }
        [cell setTableView:tableView];
    }
    
    
    
    cell.item = item;
    
    return cell;
}

- (void)setItem:(IWPPopverViewItem *)item{
    _item = item;
    
    
    NSLog(@"%@ -- %@ -- %d", item.title, item.selectedTitle, item.selected);
    
    if (item.selected) {
        self.textLabel.text = item.selectedTitle;
    }else{
        self.textLabel.text = item.title;
    }
    
    NSLog(@"%@",self.textLabel.text);
    
    self.imageView.image = [UIImage Inc_imageNamed:item.imageName];
    
//    if (!false) {
    
    
        
//    }else{
//
//        self.textLabel.textColor = [UIColor colorWithHexString:@"#ffffff"];
//
//    }
    
    
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted) {
        self.backgroundColor = [UIColor colorWithHexString:@"#424244"];
    }else{
        [UIView animateWithDuration:animated ? .3f : 0.f animations:^{
            self.backgroundColor = [UIColor clearColor];
        }];
    }    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    NSLog(@"%@",[_tableView indexPathForCell:self]);
    if (selected) {
        self.backgroundColor = [UIColor colorWithHexString:@"#424244"];
    }else{
        [UIView animateWithDuration:animated ? .3f : 0.f animations:^{
            self.backgroundColor = [UIColor clearColor];
        }];
    }
    
    
    
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
