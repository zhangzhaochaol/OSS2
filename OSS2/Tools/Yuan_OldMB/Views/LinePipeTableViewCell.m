//
//  LinePipeTableViewCell.m
//  OSS2.0-ios-v2
//
//  Created by 孟诗萌 on 2017/1/9.
//  Copyright © 2017年 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "LinePipeTableViewCell.h"
#import "IWPPropertiesReader.h"


#define WIDTH [UIScreen mainScreen].bounds.size.width-20
#define HEIGHT self.contentView.frame.size.height
@implementation LinePipeTableViewCell
{
    UILabel *name;//资源名称
    UILabel *station;//资源所属局站
    IWPPropertiesReader * reader;
    IWPPropertiesSourceModel * model;
}
@synthesize backView;
@synthesize type;
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        [self createUI];
    }
    return self;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (void)createUI
{
    backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 45)];
    [self.contentView addSubview:backView];
    
    name = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, WIDTH-20, 20)];
    [name setTextColor:[UIColor colorWithHexString:@"#000000"]];
    name.numberOfLines = 0;
    [name setFont:[UIFont systemFontOfSize:16.0]];
    name.lineBreakMode = NSLineBreakByTruncatingHead;
    [self.contentView addSubview:name];
    
    station = [[UILabel alloc] initWithFrame:CGRectMake(10, 25, WIDTH-20, 20)];
    [station setTextColor:[UIColor colorWithHexString:@"#888888"]];
    [station setFont:[UIFont systemFontOfSize:14.0]];
    station.numberOfLines = 0;
    station.lineBreakMode = NSLineBreakByTruncatingHead;
    [self.contentView addSubview:station];
}


- (void)setDict:(NSDictionary *)dict{
    if([type isEqualToString:@"0"]){
        //光缆
        name.text = dict[@"routename"];
        station.text = dict[@"areaname"];
    }else if([type isEqualToString:@"1"]){
        //光缆段
        name.text = dict[@"cableName"];
        station.text = dict[@"areaname"];
    }else if([type isEqualToString:@"2"]){
        //端子
        name.text = dict[@"PCODE"];
        station.text = dict[@"PSERV"];
    }else if([type isEqualToString:@"3"]){
        //管孔承载缆段/备用承载缆段
        name.text = dict[@"cableName"];
        if ([dict[@"isGreen"] isEqualToString:@"YES"]) {
            name.textColor = [UIColor greenColor];
        }else{
            name.textColor = [UIColor blackColor];
        }
        [name setFrame:CGRectMake(10, 5, WIDTH-40, 20)];
        
        UIImageView *accessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(WIDTH-30, 5, 30, 30)];
        [accessoryView setImage:[UIImage Inc_imageNamed:@"infoIcon"]];
        [self.contentView addSubview:accessoryView];
    }else if([type isEqualToString:@"4"]){
        //occ
        name.text = dict[@"occName"];
        station.text = dict[@"addr"];
    }else {
        //动态

        reader = [IWPPropertiesReader propertiesReaderWithFileName:dict[@"resLogicName"] withFileDirectoryType:IWPPropertiesReadDirectoryDocuments];
        model = [IWPPropertiesSourceModel modelWithDict:reader.result];
        
        name.text = dict[model.list_item_title_name];
        station.text = dict[model.list_item_note_name];
    }
    
    CGSize nameTextSize = [name.text boundingRectWithSize:CGSizeMake(name.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16.0]} context:nil].size;
    CGRect nameFrame = name.frame;
    if (nameTextSize.height>20) {
        nameFrame.size.height = nameTextSize.height;
        name.frame = nameFrame;
    }
    
    CGRect stationFrame = station.frame;
    stationFrame.origin.y = nameFrame.origin.y+nameFrame.size.height;
    CGSize stationTextSize = [station.text boundingRectWithSize:CGSizeMake(station.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14.0]} context:nil].size;
    if (stationTextSize.height>20) {
        stationFrame.size.height = stationTextSize.height;
    }
    station.frame = stationFrame;
    
    if ((nameFrame.size.height + stationFrame.size.height)>45) {
        CGRect backViewFrame = backView.frame;
        backViewFrame.size.height = nameFrame.size.height + stationFrame.size.height;
        backView.frame = backViewFrame;
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}
-(float)getBackGroundHeignt{
    return backView.frame.size.height;
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
