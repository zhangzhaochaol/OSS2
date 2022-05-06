//
//  Yuan_OBD_PointsVM.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/4/21.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_OBD_PointsVM.h"
#import "Yuan_OBD_PointsHttpModel.h"
@implementation Yuan_OBD_PointsVM


#pragma mark - 输入端 ---

- (void) handleModel_InputConfig:(void(^)(void))handleSuccess_Block {
    

    NSDictionary * postDict = @{
        
        @"reqDb" : Yuan_WebService.webServiceGetDomainCode,
        @"aid" : _obd_Point_Dict[@"resId"] ?: @"",
        @"atypeId" : @"310",
        @"ano" : _obd_Point_Dict[@"resNo"] ?: @"",
        @"aeqpId" : _obd_Point_Dict[@"superResId"] ?: @"",
        @"aeqpTypeId" : @"2530",
        
        
        @"zid" : _terminal_Dict[@"GID"] ?: @"",
        @"ztypeId" : @"317",
        @"zeqpId" : _terminal_Dict[@"eqpId_Id"] ?: @"",
        
        
        @"linkType" : @"0"
    };
    
    [Yuan_OBD_PointsHttpModel Http_Input_OBDPoint_Terminals_Connect:postDict
                                                            success:^(id  _Nonnull result) {
       
        // 完成绑定的回调
        if (handleSuccess_Block) {
        
            _obd_Point_Dict = nil;
            _terminal_Dict = nil;
            handleSuccess_Block();
        }
        
    }];
    
    
}


#pragma mark - 输出端 ---
// 手动配对
- (void) handleModel_Config:(void(^)(void))handleSuccess_Block {

    NSDictionary * postDict = @{
        
        @"reqDb" : Yuan_WebService.webServiceGetDomainCode,
        @"resId" : _obd_Point_Dict[@"resId"] ?: _obd_Point_Dict[@"gid"],
        @"resName" : _obd_Point_Dict[@"resName"] ?: _obd_Point_Dict[@"name"],
        @"resNo" : _obd_Point_Dict[@"resNo"] ?: _obd_Point_Dict[@"no"],
        @"superResId" : _obd_Point_Dict[@"superResId"] ?: @"",
        @"oprStateId" : _obd_Point_Dict[@"oprStateId"] ?: @"",
        @"mntStateId" : _obd_Point_Dict[@"mntStateId"] ?: @"",
        @"zid" : _terminal_Dict[@"GID"],
        @"linkType" : @"0",
        @"lineDesc" : @"0",
        @"lineLength" : @"0"
        
    };
    
    
    [Yuan_OBD_PointsHttpModel Http_OBDPoint_Terminals_Connect:@[postDict]
                                                      success:^(id  _Nonnull result) {
            
        // 完成绑定的回调
        if (handleSuccess_Block) {
        
            _obd_Point_Dict = nil;
            _terminal_Dict = nil;
            handleSuccess_Block();
        }

    }];
    
}



// 自动配对
- (void) autoModel_Config:(void(^)(void))handleSuccess_Block {
    
    if (_obd_PointsArr.count == 0 || _terminalsArr.count == 0) {
        [YuanHUD HUDFullText:@"自动关联失败 , 数据为空"];
        return;
    }
    
    // 取他们俩当中小的那个 , 作为循环索引
    NSInteger count = 0;
    
    if (_obd_PointsArr.count < _terminalsArr.count) {
        count = _obd_PointsArr.count;
    }
    
    if (_obd_PointsArr.count > _terminalsArr.count) {
        count = _terminalsArr.count;
    }
    
    if (_obd_PointsArr.count == _terminalsArr.count) {
        count = _obd_PointsArr.count;
    }
    
    
    NSMutableArray * autoPostArr = NSMutableArray.array;
    
    for (int i = 0 ; i < count; i++) {
        
        
        NSDictionary * obd_Point_Dict = _obd_PointsArr[i];
        NSDictionary * terminal_Dict = _terminalsArr[i];
        
        
        NSDictionary * postDict = @{
            
            @"reqDb" : Yuan_WebService.webServiceGetDomainCode,
            @"resId" : obd_Point_Dict[@"resId"] ?: obd_Point_Dict[@"gid"],
            @"resName" : obd_Point_Dict[@"resName"] ?: obd_Point_Dict[@"name"],
            @"resNo" : obd_Point_Dict[@"resNo"] ?: obd_Point_Dict[@"no"],
            @"superResId" : obd_Point_Dict[@"superResId"] ?: @"",
            @"oprStateId" : obd_Point_Dict[@"oprStateId"] ?: @"",
            @"mntStateId" : obd_Point_Dict[@"mntStateId"] ?: @"",
            @"zid" : terminal_Dict[@"GID"],
            @"linkType" : @"0",
            @"lineDesc" : @"0",
            @"lineLength" : @"0"
        };
        
        [autoPostArr addObject:postDict];
    }
    
    
    
    [Yuan_OBD_PointsHttpModel Http_OBDPoint_Terminals_Connect:autoPostArr
                                                      success:^(id  _Nonnull result) {
            
        // 完成绑定的回调
        if (handleSuccess_Block) {
            handleSuccess_Block();
        }

    }];
    
    
    
}

@end
