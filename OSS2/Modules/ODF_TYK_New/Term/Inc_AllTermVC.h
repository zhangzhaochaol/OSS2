//
//  Inc_AllTermVC.h
//  OSS2.0-ios-v2
//
//  Created by zzc on 2021/6/16.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_BaseVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface Inc_AllTermVC : Inc_BaseVC

//资源类型rackOdf机架(odf) 1    optJntBox光分接箱 3     optConnectBox光交接箱(occ) 2

/**if (enterType == InitType_ODF) {
_postType = @"1";
}else if(enterType == InitType_OCC){
_postType = @"2";
}else if (enterType == InitType_ODB) {
_postType = @"3";
}
else if (enterType == InitType_OBD) {
_postType = @"4";
}
 */
@property (nonatomic, strong) NSString *type;

//设备id
@property (nonatomic, strong) NSString *deviceId;


//端子盘个数
@property (nonatomic, strong) NSArray *requestDataSource;



@end

NS_ASSUME_NONNULL_END
