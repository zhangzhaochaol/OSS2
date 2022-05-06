//
//  IWPRfidInfoTableViewCell.h
//  OSS2.0-ios-v2
//
//  Created by 王旭焜 on 2017/4/13.
//  Copyright © 2017年 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IWPRfidInfoModel : NSObject
@property (nonatomic, copy) NSString * cableName;
@property (nonatomic, copy) NSString * cableId;
@property (nonatomic, copy) NSString * cableRfid;


-(instancetype)initWithDict:(NSDictionary *)dict;
+(instancetype)modelWithDict:(NSDictionary *)dict;

@end

@interface IWPRfidInfoFrameModel : NSObject
@property (nonatomic, strong) IWPRfidInfoModel * model;
@property (nonatomic, assign, readonly) CGRect titleLabelFrame;
@property (nonatomic, assign, readonly) CGFloat rowHeight;
@end

@interface IWPRfidInfoTableViewCell : UITableViewCell

@property (nonatomic, strong) IWPRfidInfoFrameModel * model;

@end
