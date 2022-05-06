//
//  Inc_JumpSelectODFVC.h
//  OSS2.0-ios-v2
//
//  Created by zzc on 2021/6/25.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_BaseVC.h"



@interface Inc_JumpSelectODFVC : Inc_BaseVC

/**  block */
@property (nonatomic , copy) void (^getODFDicBlock) (NSDictionary *dic);

//设备id
@property (nonatomic, strong) NSString *deviceId;
@end


