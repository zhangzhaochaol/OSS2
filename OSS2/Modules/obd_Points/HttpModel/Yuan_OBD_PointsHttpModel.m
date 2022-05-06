//
//  Yuan_OBD_PointsHttpModel.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/4/20.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_OBD_PointsHttpModel.h"





// 输入端端子绑定与解绑
static NSString * input_ConnectUrl = @"eqpApi/inBindResPort";
static NSString * input_DisConnectUrl = @"eqpApi/inUnBindResPort";



// 输出端端子绑定与解绑
static NSString * connectUrl = @"eqpApi/outBindResPort";
static NSString * disConnectUrl = @"eqpApi/outUnbindResPort";


static NSString * select_ShipUrl = @"optRes/findResBindPorts";
static NSString * init_OBDPoints = @"eqpApi/initResPort";

@implementation Yuan_OBD_PointsHttpModel

/// 输入端分光器端子和设备端子的绑定
+ (void) Http_Input_OBDPoint_Terminals_Connect:(NSDictionary *) datas
                                       success:(void(^)(id result)) succese {
    
    NSString * URL = [NSString stringWithFormat:@"%@%@",Http.David_ModifiUrl,input_ConnectUrl];
    
    [Http.shareInstance DavidJsonPostURL:URL
                                   Parma:datas
                                 success:^(id result) {
            
        if (succese) {
            succese(result);
        }
    }];
    
}


/// 输入端分光器端子和设备端子的解绑
+ (void) Http_Input_OBDPoint_Terminals_DisConnect:(NSDictionary *) disConnectDict
                                          success:(void(^)(id result)) succese {
    
    
    NSString * URL = [NSString stringWithFormat:@"%@%@",Http.David_ModifiUrl,input_DisConnectUrl];
    
    [Http.shareInstance DavidJsonPostURL:URL
                                   Parma:disConnectDict
                                 success:^(id result) {
            
        if (succese) {
            succese(result);
        }
        
    }];
    
}




/// 分光器端子和设备端子的绑定
+ (void) Http_OBDPoint_Terminals_Connect:(NSArray *) datas
                                 success:(void(^)(id result)) succese {
    
    
    
    NSString * URL = [NSString stringWithFormat:@"%@%@",Http.David_ModifiUrl,connectUrl];
    
    
    [Http.shareInstance DavidJsonPostURL:URL
                                ParmaArr:datas
                                 success:^(id result) {
            
        if (succese) {
            succese(result);
        }
    }];
    
}



/// 分光器端子和设备端子的解绑
+ (void) Http_OBDPoint_Terminals_DisConnect:(NSDictionary *) disConnectDict
                                    success:(void(^)(id result)) succese {
    
    
    NSString * URL = [NSString stringWithFormat:@"%@%@",Http.David_ModifiUrl,disConnectUrl];
    
    [Http.shareInstance DavidJsonPostURL:URL
                                   Parma:disConnectDict
                                 success:^(id result) {
            
        if (succese) {
            succese(result);
        }
        
    }];
    
    
}



/// 根据设备端子的Id 查询分光器端子的关联关系
+ (void) Http_OBDPoint_Terminals_ShipSelect:(NSDictionary *) terminalIdsArr
                                    success:(void(^)(id result)) succese {
    
    
    NSString * URL = [NSString stringWithFormat:@"%@%@",Http.David_SelectUrl,select_ShipUrl];
    
    // 如果是通过分光器端口查询 , 那么传 aids
    // 如果是通过设备端子查询 , 那么传 zids
    NSDictionary * param = @{@"aids" : terminalIdsArr};
    
    [Http.shareInstance DavidJsonPostURL:URL
                                   Parma:param
                                 success:^(id result) {
        
        if (succese) {
            succese(result);
        }
            
    }];
    
    
}



/// 根据设备端子的Id 查询分光器端子的关联关系  -- 通过设备端子Id 查询
+ (void) Http_OBDPoint_Terminals_ShipSelect_FromTerminals:(NSArray *) terminalIdsArr
                                                  success:(void(^)(id result)) succese {
    
    NSString * URL = [NSString stringWithFormat:@"%@%@",Http.David_SelectUrl,select_ShipUrl];
    
    // 如果是通过分光器端口查询 , 那么传 aids
    // 如果是通过设备端子查询 , 那么传 zids
    NSDictionary * param = @{@"zids" : terminalIdsArr};
    
    [Http.shareInstance DavidJsonPostURL:URL
                                   Parma:param
                                 success:^(id result) {
        
        if (succese) {
            succese(result);
        }
            
    }];
    
}




// 根据分光器Id 初始化 分光器端子
+ (void) Http_OBD_Point_Init:(NSString *) OBD_resId
                     success:(void(^)(id result)) succese {
    
    NSString * URL = [NSString stringWithFormat:@"%@%@",Http.David_ModifiUrl,init_OBDPoints];
    
    
    [Http.shareInstance DavidJsonPostURL:URL
                                   Parma:@{@"resId" : OBD_resId}
                                 success:^(id result) {
    
        if (succese) {
            succese(result);
        }
    }];
    
}


@end
