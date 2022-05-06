//
//  Inc_TE_ViewModel.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/8/17.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_TE_ViewModel.h"

@implementation Inc_TE_ViewModel



// 根据端子业务状态 返回颜色
- (UIColor *) colorFromState:(NSInteger) oprStateId
                   needAlpha:(BOOL) needAlpha{
    
    UIColor * color ;
        
    switch (oprStateId) {
            
        case 2:     //预占
        case 4:     //预释放
        case 5:     //预留
        case 6:     //预选
        case 7:     //备用
        case 11:    //测试
        case 12:    //临时占用
            
            color = [self colorFromR:252 G:160 B:0 needAlpha:needAlpha];
            break;
        
        case 3:     //占用
        
            color = [self colorFromR:147 G:222 B:113 needAlpha:needAlpha];
            break;
            
        case 8:     //停用
        case 10:    //损坏
            
            color = [self colorFromR:255 G:0 B:44 needAlpha:needAlpha];
            break;
            
        default:        //1.空闲 9.闲置
            
            color = [self colorFromR:180 G:180 B:180 needAlpha:needAlpha];
            break;
    }
    
    
    
    return color;
}

// 根据端子业务状态 返回文字
- (NSString *) msgFromState:(NSInteger) oprStateId {
    
    NSString * msg = @"";
    
    switch (oprStateId) {
            
        case 1:
            msg = @"空闲";
            break;

        case 2:     //预占
            msg = @"预占";
            break;
            
        case 3:     //占用
        
            msg = @"占用";
            break;
            
        case 4:     //预释放
            msg = @"预释放";
            break;
            
        case 5:     //预留
            msg = @"预留";
            break;
            
        case 6:     //预选
            msg = @"预选";
            break;
            
        case 7:     //备用
            msg = @"备用";
            break;
            
        case 8:     //停用
            msg = @"停用";
            break;
            
        case 9:     //闲置
            msg = @"闲置";
            break;
            
        case 10:     //损坏
            msg = @"损坏";
            break;
            
        case 11:     //测试
            msg = @"测试";
            break;
            
        case 12:     //临时占用
            
            msg = @"临时占用";
            break;
   
        default:        //闲置 160065
            
            msg = @"端子";
            break;
    }
    
    
    return msg;
}






- (UIColor *) colorFromR:(float)R
                       G:(float)G
                       B:(float)B
               needAlpha:(BOOL)needAlpha{
    
    return   [UIColor colorWithRed:R/255.0
                             green:G/255.0
                              blue:B/255.0
                             alpha:needAlpha ? 0.4 : 1];
    
}



// 判断对调后 ,是否还需要进行端子跳接
- (NSDictionary *) afterTerminalExchange_IsJumpT: (NSDictionary *) dictionary {

    NSMutableDictionary * resultDic = [NSMutableDictionary dictionaryWithDictionary:dictionary];
    
    // 上部跳接端子
    NSDictionary * upTerm = dictionary[@"upTerm"];
    
    // 底部跳接端子
    NSDictionary * downTerm = dictionary[@"downTerm"];
    
    // 路由
    NSArray * route = dictionary[@"route"];
    
    
    // 有跳接 , 并且类型不为2 (2 是有跳接关系 但没有对端id)
    if ([upTerm[@"hasOptLine"] isEqualToNumber:@true] && ![upTerm[@"type"] isEqualToNumber:@2]) {
        
        NSString * relateEqpId = upTerm[@"relateEqpId"];
        
        NSDictionary * firstTerminal = route.firstObject;
        
        if ([firstTerminal[@"eptTypeId"] isEqualToString:@"317"]) {
            
            NSString * relateResId = firstTerminal[@"relateResId"];
            
            // 证明是同设备的 , 可以进行跳接
            if ([relateEqpId isEqualToString:relateResId]) {
                
                NSMutableDictionary * mt_upTerm = [NSMutableDictionary dictionaryWithDictionary:upTerm];
                mt_upTerm[@"bind"] = @true;
                
                // 修改元数据
                resultDic[@"upTerm"] = mt_upTerm;
            }
            
        }

    }
    
    
    
    // 路由中只有自己的话 , 那么只考虑和顶部端子跳接关系
    if (route.count <= 1) {
        return resultDic;
    }
    
    
    
    // 有跳接 , 并且类型不为2 (2 是有跳接关系 但没有对端id)
    if ([downTerm[@"hasOptLine"] isEqualToNumber:@true] && ![downTerm[@"type"] isEqualToNumber:@2]) {
        
        NSString * relateEqpId = downTerm[@"relateEqpId"];
        
        NSDictionary * lastTerminal = route.lastObject;
        
        // 如果只有路由中只有一个元素
        if (route.count == 1) {
            return resultDic;
        }
        
        
        if ([lastTerminal[@"eptTypeId"] isEqualToString:@"317"]) {
            
            NSString * relateResId = lastTerminal[@"relateResId"];
            
            // 证明是同设备的 , 可以进行跳接
            if ([relateEqpId isEqualToString:relateResId]) {
                
                NSMutableDictionary * mt_downTerm = [NSMutableDictionary dictionaryWithDictionary:downTerm];
                mt_downTerm[@"bind"] = @true;
                
                // 修改元数据
                resultDic[@"downTerm"] = mt_downTerm;
            }
            
        }
        
    }
    
    return resultDic;
}




#pragma mark - 声明单粒 ---

+ (Inc_TE_ViewModel *) shareInstance {
    
    static Inc_TE_ViewModel * instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[super alloc] init];
    });
    
    return instance;
}


- (id) copyWithZone:(NSZone *) zone {
    
    return  [self.class shareInstance];
}

- (id) mutableCopyWithZone:(NSZone *) zone {
    
    return  [self.class shareInstance];
}


- (void) destroy {
    
    // 清空
    
    _Terminal_A_Dict = nil;
    _Terminal_B_Dict = nil;
    
    _terminal_A_ExceptOprStateId = 0;
    _terminal_B_ExceptOprStateId = 0;
    
    _isSameDeviceInOtherSide = false;
}

@end
