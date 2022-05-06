//
//  Inc_PoryraitSplitCell.h
//  OSS2.0-ios-v2
//
//  Created by zzc on 2021/9/16.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Inc_PoryraitSplitCell : UITableViewCell


//纤芯数回调
@property (nonatomic, copy) void (^textFeildBlock)(NSString *text);

//名称回调
@property (nonatomic, copy) void (^textViewBlock)(NSString *text);



//赋值
-(void)setDataSource:(NSDictionary *)dic indexPath:(NSInteger)indexPath;

@end

NS_ASSUME_NONNULL_END
