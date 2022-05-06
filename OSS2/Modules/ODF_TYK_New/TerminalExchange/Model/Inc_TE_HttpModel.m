//
//  Inc_TE_HttpModel.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/8/17.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_TE_HttpModel.h"


// 根据 端子Id , 查询对应的光链路数据
static NSString * _selectTerminal_BelongLinksPort = @"lineRes/findSwapTermState";

// 将修改后的数据 , 返还给后台
static NSString * _upDate_ExchangePort = @"lineApi/swapTerm";


@implementation Inc_TE_HttpModel


/// 根据端子Id 获取所在链路信息
+ (void) Http_TE_GetDatasFromTerminalIds:(NSDictionary *) terminalIds
                                 success:(void(^)(id result)) success {
    
    [Http.shareInstance DavidJsonPostURL:David_SelectUrl(_selectTerminal_BelongLinksPort)
                                   Parma:terminalIds
                                 success:^(id result) {
            
        if (success) {
            success(result);
        }
    }];
    
}


/// 返回对调后的数据
+ (void) Http_TE_ExchangeTerminal:(NSDictionary *) param
                          success:(void(^)(id result)) success {
    
    
    [Http.shareInstance DavidJsonPostURL:David_ModifiUrl(_upDate_ExchangePort)
                                   Parma:param
                                 success:^(id result) {
            
        if (success) {
            success(result);
        }
    }];
    
}









@end
