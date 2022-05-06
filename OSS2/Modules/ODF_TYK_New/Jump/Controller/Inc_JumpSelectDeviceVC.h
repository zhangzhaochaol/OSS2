//
//  Inc_JumpSelectDeviceVC.h
//  OSS2.0-ios-v2
//
//  Created by zzc on 2021/6/29.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_BaseVC.h"


@interface Inc_JumpSelectDeviceVC : Inc_BaseVC

/**  block */
@property (nonatomic , copy) void (^getODFDicBlock) (NSDictionary *dic);

@property (nonatomic, strong) NSString *roomId;

@end


