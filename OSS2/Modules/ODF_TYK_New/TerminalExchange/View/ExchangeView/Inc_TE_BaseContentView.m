//
//  Inc_TE_BaseContentView.m
//  OSS2.0-ios-v2
//
//  Created by yuanquan on 2021/8/19.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Inc_TE_BaseContentView.h"
#import "Inc_TE_ExLinkType_NameView.h"

// 显示端子的View
#import "Inc_TE_ExTerminalShowView.h"

// 显示虚线
#import "Inc_TE_ExDashLine.h"

@implementation Inc_TE_BaseContentView

{
    
    Inc_TE_ViewModel * _VM;
    
    BaseScroll_ _nowScrollState;
    
    Inc_TE_ExLinkType_NameView * _leftTypeView;
    Inc_TE_ExLinkType_NameView * _rightTypeView;
    
    
    // originTerm  原始端子
    NSDictionary * _terminal_LinkDict_A;
    
    // swapTerm  目标对调端子
    NSDictionary * _terminal_LinkDict_B;
    
    
    
    
    // 头部跳接关系端子
    NSDictionary * _upTerm_A;
    NSDictionary * _upTerm_B;
    
    // 尾部跳接关系端子
    NSDictionary * _downTerm_A;
    NSDictionary * _downTerm_B;
    
    // 路由
    NSArray * _route_A;
    NSArray * _route_B;
    
    
    
    // 实际展示的链路
    NSMutableArray * _trueLink_A;
    NSMutableArray * _trueLink_B;
    
}

#pragma mark - 初始化构造方法

- (instancetype)initWithEnum:(BaseScroll_) Enum
                       frame:(CGRect) frame{
    
    if (self = [super initWithFrame:frame]) {
        
        _nowScrollState = Enum;
        _VM = Inc_TE_ViewModel.shareInstance;
        [self UI_Init];
        
    }
    return self;
}



/// 根据端子对应的链路数据 , 初始化
- (void) reloadFrom_ADict:(NSDictionary *) terminal_LinkDict_A
                    BDict:(NSDictionary *)terminal_LinkDict_B {
    
    // 赋值
    _terminal_LinkDict_A = terminal_LinkDict_A;
    _terminal_LinkDict_B = terminal_LinkDict_B;
    
    
    // 赋值
    _upTerm_A = terminal_LinkDict_A[@"upTerm"];
    _downTerm_A = terminal_LinkDict_A[@"downTerm"];
    _route_A = terminal_LinkDict_A[@"route"];
    
    _upTerm_B = terminal_LinkDict_B[@"upTerm"];
    _downTerm_B = terminal_LinkDict_B[@"downTerm"];
    _route_B = terminal_LinkDict_B[@"route"];
    
    
    _trueLink_A = NSMutableArray.array;
    _trueLink_B = NSMutableArray.array;
    
    // 对数据进行处理
    [self datasConfig];
    
    // 特殊数据的判断处理
    [self specialDatasConfig];
    
    // 初始化UI
    [self contentUI_Init];
    
    
    
}


- (void) datasConfig {
    
    // 链路A _ 顶部跳接端子
    if ([_upTerm_A[@"hasOptLine"] isEqualToNumber:@true]) {
        
        NSNumber * type = _upTerm_A[@"type"];
        
        NSMutableDictionary * mt_upTermA = [NSMutableDictionary dictionaryWithDictionary:_upTerm_A];
        mt_upTermA[@"resId"] = _upTerm_A[@"termId"];
        mt_upTermA[@"resName"] = _upTerm_A[@"termName"];
        
        mt_upTermA[@"show"] = @(TE_ExTerShow_Left);
        mt_upTermA[@"terminalType"] = @(TE_ExTerminal_Normal);
        mt_upTermA[@"eptTypeId"] = @"317";

        // 跳接端子不存在
        if (type.integerValue == 2) {
            mt_upTermA[@"resName"] = @"无端子";
        }
        
        [_trueLink_A addObject:mt_upTermA];
        
        

        
        // *** 拼接跳接关系
        NSMutableDictionary * mt_jumpDict = [NSMutableDictionary dictionary];
        mt_jumpDict[@"eptTypeId"] = @"100"; //假设100 为跳接关系的类型id
        mt_jumpDict[@"show"] = @(TE_ExTerShow_Left);
        mt_jumpDict[@"lineType"] = @(TE_ExDashLine_Xu);
        mt_jumpDict[@"jumpType"] = @"up";
        
        // 跳接端子不存在
        if (type.integerValue == 2 && _nowScrollState == BaseScroll_After) {
            mt_jumpDict[@"lineType"] = @(TE_ExDashLine_Warning);
        }
        
        
        // 跳接端子和新路由中的头部端子 不在同一设备中
        if (_nowScrollState == BaseScroll_After) {
            
            NSDictionary * firstTerminal = _route_A.firstObject;
            
            NSString * relateEqpId = _upTerm_A[@"relateEqpId"];
            
            
            if ([firstTerminal[@"eptTypeId"] isEqualToString:@"317"]) {
                
                NSString * relateResId = firstTerminal[@"relateResId"];
                
                // 证明是同设备的 , 可以进行跳接
                if (![relateEqpId isEqualToString:relateResId]) {
                    mt_jumpDict[@"lineType"] = @(TE_ExDashLine_Warning);
                }
            }
        }
        
        
        
        [_trueLink_A addObject:mt_jumpDict];
        
    }
    
    // 链路A _ 路由
    for (NSDictionary * router in _route_A) {
        
        NSInteger index = [_route_A indexOfObject:router];
        
        NSMutableDictionary * mt_route = [NSMutableDictionary dictionaryWithDictionary:router];
        mt_route[@"resId"] = router[@"eptId"];
        mt_route[@"resName"] = router[@"eptName"];
        
        mt_route[@"show"] = @(TE_ExTerShow_Left);
        
        // 端子
        if ([router[@"eptTypeId"] isEqualToString:@"317"]) {
            
            if (index == 0) {
                
                // 证明是对调后的端子 , 需要AB 互换
                if ([_terminal_LinkDict_A.allKeys containsObject:@"afterExchange"]) {
                    mt_route[@"terminalType"] = @(TE_ExTerminal_B);
                }
                else {
                    mt_route[@"terminalType"] = @(TE_ExTerminal_A);
                }
            }
            else {
                mt_route[@"terminalType"] = @(TE_ExTerminal_Normal);
                
                // otherSide 字段 用来判断该端子时对端端子
                mt_route[@"otherSide"] = @"1";
            }
        }
        
        // 纤芯
        if ([router[@"eptTypeId"] isEqualToString:@"702"]) {
            mt_route[@"lineType"] = @(TE_ExDashLine_Fiber);
        }
        
        
        [_trueLink_A addObject:mt_route];
    }
    
    // 链路A _ 尾部跳接端子
    if ([_downTerm_A[@"hasOptLine"] isEqualToNumber:@true]) {
        
        NSNumber * type = _downTerm_A[@"type"];
        // *** 拼接跳接关系
        NSMutableDictionary * mt_jumpDict = [NSMutableDictionary dictionary];
        mt_jumpDict[@"eptTypeId"] = @"100"; //假设100 为跳接关系的类型id
        mt_jumpDict[@"show"] = @(TE_ExTerShow_Left);
        mt_jumpDict[@"lineType"] = @(TE_ExDashLine_Xu);
        mt_jumpDict[@"jumpType"] = @"down";
        
        // 跳接端子不存在
        if (type.integerValue == 2 && _nowScrollState == BaseScroll_After) {
            mt_jumpDict[@"lineType"] = @(TE_ExDashLine_Warning);
        }
        
        
        // 跳接端子和新路由中的底部端子 不在同一设备中
        if (_nowScrollState == BaseScroll_After ) {
            
            if ( _route_A.count > 1) {
                
                NSDictionary *lastTerminal = _route_A.lastObject;
                
                NSString * relateEqpId = _downTerm_A[@"relateEqpId"];
                
                if ([lastTerminal[@"eptTypeId"] isEqualToString:@"317"]) {
                    
                    NSString * relateResId = lastTerminal[@"relateResId"];
                    
                    // 证明是同设备的 , 可以进行跳接
                    if (![relateEqpId isEqualToString:relateResId]) {
                        mt_jumpDict[@"lineType"] = @(TE_ExDashLine_Warning);
                    }
                }
            }
            
            else {
            
                mt_jumpDict[@"lineType"] = @(TE_ExDashLine_Warning);
            }
            
            
        }

        [_trueLink_A addObject:mt_jumpDict];
        
        
        
        
        NSMutableDictionary * mt_downTermA = [NSMutableDictionary dictionaryWithDictionary:_downTerm_A];
        mt_downTermA[@"resId"] = _downTerm_A[@"termId"];
        mt_downTermA[@"resName"] = _downTerm_A[@"termName"];
        
        mt_downTermA[@"show"] = @(TE_ExTerShow_Left);
        mt_downTermA[@"terminalType"] = @(TE_ExTerminal_Normal);
        mt_downTermA[@"eptTypeId"] = @"317";

        // 跳接端子不存在
        if (type.integerValue == 2) {
            mt_downTermA[@"resName"] = @"无端子";
        }
        
        
        [_trueLink_A addObject:mt_downTermA];
    }
    
    
    
    
    
    /// *******
    
    
    
    
    // 链路B _ 顶部跳接端子
    if ([_upTerm_B[@"hasOptLine"] isEqualToNumber:@true]) {
        
        NSNumber * type = _upTerm_B[@"type"];
        
        // 需要为链路增加跳接的线
        NSMutableDictionary * mt_upTermB = [NSMutableDictionary dictionaryWithDictionary:_upTerm_B];
        mt_upTermB[@"resId"] = _upTerm_B[@"termId"];
        mt_upTermB[@"resName"] = _upTerm_B[@"termName"];
        
        mt_upTermB[@"show"] = @(TE_ExTerShow_Right);
        mt_upTermB[@"terminalType"] = @(TE_ExTerminal_Normal);
        mt_upTermB[@"eptTypeId"] = @"317";

        
        // 跳接端子不存在
        if (type.integerValue == 2) {
            mt_upTermB[@"resName"] = @"无端子";
        }
        
        [_trueLink_B addObject:mt_upTermB];
        
        
        // *** 拼接跳接关系
        NSMutableDictionary * mt_jumpDict = [NSMutableDictionary dictionary];
        mt_jumpDict[@"eptTypeId"] = @"100"; //假设100 为跳接关系的类型id
        mt_jumpDict[@"show"] = @(TE_ExTerShow_Right);
        mt_jumpDict[@"lineType"] = @(TE_ExDashLine_Xu);
        mt_jumpDict[@"jumpType"] = @"up";
        
        // 跳接端子不存在
        if (type.integerValue == 2 && _nowScrollState == BaseScroll_After) {
            mt_jumpDict[@"lineType"] = @(TE_ExDashLine_Warning);
        }
        
        
        // 跳接端子和新路由中的头部端子 不在同一设备中
        if (_nowScrollState == BaseScroll_After) {
            
            NSDictionary * firstTerminal = _route_B.firstObject;
            
            NSString * relateEqpId = _upTerm_B[@"relateEqpId"];
            
            
            if ([firstTerminal[@"eptTypeId"] isEqualToString:@"317"]) {
                
                NSString * relateResId = firstTerminal[@"relateResId"];
                
                // 证明是同设备的 , 可以进行跳接
                if (![relateEqpId isEqualToString:relateResId]) {
                    mt_jumpDict[@"lineType"] = @(TE_ExDashLine_Warning);
                }
            }
        }
        
        
        [_trueLink_B addObject:mt_jumpDict];
    }
    
    // 链路B _ 路由
    for (NSDictionary * router in _route_B) {
        
        NSInteger index = [_route_B indexOfObject:router];
        
        NSMutableDictionary * mt_route = [NSMutableDictionary dictionaryWithDictionary:router];
        mt_route[@"resId"] = router[@"eptId"];
        mt_route[@"resName"] = router[@"eptName"];
        
        mt_route[@"show"] = @(TE_ExTerShow_Right);
        
        // 端子
        if ([router[@"eptTypeId"] isEqualToString:@"317"]) {
            
            if (index == 0) {
                
                // 证明是对调后的端子 , 需要AB 互换
                if ([_terminal_LinkDict_B.allKeys containsObject:@"afterExchange"]) {
                    mt_route[@"terminalType"] = @(TE_ExTerminal_A);
                }
                else {
                    mt_route[@"terminalType"] = @(TE_ExTerminal_B);
                }
            }
            else {
                mt_route[@"terminalType"] = @(TE_ExTerminal_Normal);
                
                // otherSide 字段 用来判断该端子时对端端子
                mt_route[@"otherSide"] = @"1";
            }
        }
        
        // 纤芯
        if ([router[@"eptTypeId"] isEqualToString:@"702"]) {
            mt_route[@"lineType"] = @(TE_ExDashLine_Fiber);
        }
        
        
        [_trueLink_B addObject:mt_route];
    }
    
    // 链路B _ 底部跳接端子
    if ([_downTerm_B[@"hasOptLine"] isEqualToNumber:@true]) {
        
        NSNumber * type = _downTerm_B[@"type"];
        
        // 需要为链路增加跳接的线
        NSMutableDictionary * mt_jumpDict = [NSMutableDictionary dictionary];
        mt_jumpDict[@"eptTypeId"] = @"100"; //假设100 为跳接关系的类型id
        mt_jumpDict[@"show"] = @(TE_ExTerShow_Right);
        mt_jumpDict[@"lineType"] = @(TE_ExDashLine_Xu);
        mt_jumpDict[@"jumpType"] = @"down";
        
        // 跳接端子不存在
        if (type.integerValue == 2 && _nowScrollState == BaseScroll_After) {
            mt_jumpDict[@"lineType"] = @(TE_ExDashLine_Warning);
        }
        
        
        // 跳接端子和新路由中的底部端子 不在同一设备中
        if (_nowScrollState == BaseScroll_After ) {
            
            
            if (_route_B.count > 1) {
                
                NSDictionary *lastTerminal = _route_B.lastObject;
                
                NSString * relateEqpId = _downTerm_B[@"relateEqpId"];
                
                if ([lastTerminal[@"eptTypeId"] isEqualToString:@"317"]) {
                    
                    NSString * relateResId = lastTerminal[@"relateResId"];
                    
                    // 证明是同设备的 , 可以进行跳接
                    if (![relateEqpId isEqualToString:relateResId]) {
                        mt_jumpDict[@"lineType"] = @(TE_ExDashLine_Warning);
                    }
                }
            }
            
            else {
                mt_jumpDict[@"lineType"] = @(TE_ExDashLine_Warning);
            }
            
            
            
        }
        
        
        
        [_trueLink_B addObject:mt_jumpDict];
        
        
        // *** 拼接跳接关系
        NSMutableDictionary * mt_downTermB = [NSMutableDictionary dictionaryWithDictionary:_downTerm_B];
        mt_downTermB[@"resId"] = _downTerm_B[@"termId"];
        mt_downTermB[@"resName"] = _downTerm_B[@"termName"];
        
        mt_downTermB[@"show"] = @(TE_ExTerShow_Right);
        mt_downTermB[@"terminalType"] = @(TE_ExTerminal_Normal);
        mt_downTermB[@"eptTypeId"] = @"317";

        // 跳接端子不存在
        if (type.integerValue == 2) {
            mt_downTermB[@"resName"] = @"无端子";
        }
        
        [_trueLink_B addObject:mt_downTermB];
    }
    
}



/// 特殊数据判断
- (void) specialDatasConfig {
    
    // MARK: 1. 判断对端端子是否在同一设备中
    
    NSString * relateResId_A;
    NSString * relateResId_B;
    
    for (NSDictionary * dict in _trueLink_A) {
        
        if ([dict.allKeys containsObject:@"otherSide"]) {
            relateResId_A = dict[@"relateResId"] ?: @"";
        }
    }
    
    for (NSDictionary * dict in _trueLink_B) {
        
        if ([dict.allKeys containsObject:@"otherSide"]) {
            relateResId_B = dict[@"relateResId"] ?: @"";
        }
    }
    
    
    // A != B  并且 AB 都存在时
    if (![relateResId_A isEqualToString:relateResId_B] && relateResId_A && relateResId_B) {
        
        // 证明两个对端端子不在同一设备中
        _VM.isSameDeviceInOtherSide = true;
        
        NSMutableArray * mt_A = [NSMutableArray array];
        
        for (NSDictionary * dict in _trueLink_A) {
            
            if ([dict.allKeys containsObject:@"otherSide"]) {
                    
                NSMutableDictionary * mt_Dict = [NSMutableDictionary dictionaryWithDictionary:dict];
                mt_Dict[@"terminalType"] = @(TE_ExTerminal_Warning);
                [mt_A addObject:mt_Dict];
                
                continue;
            }
            
            [mt_A addObject:dict];
        }

        
        NSMutableArray * mt_B = [NSMutableArray array];
        
        for (NSDictionary * dict in _trueLink_B) {
            
            if ([dict.allKeys containsObject:@"otherSide"]) {
                    
                NSMutableDictionary * mt_Dict = [NSMutableDictionary dictionaryWithDictionary:dict];
                mt_Dict[@"terminalType"] = @(TE_ExTerminal_Warning);
                [mt_B addObject:mt_Dict];
                
                continue;
            }
            
            [mt_B addObject:dict];
        }
        
        _trueLink_A = mt_A;
        _trueLink_B = mt_B;
    }
    
    
    
    // MARK: 2.判断 对调后 页面 , 进行尾部跳接关系判断  -- 修改跳接关系状态
    if (_nowScrollState == BaseScroll_After) {
        
        // 尾部端子不在同一设备中
        if ( _VM.isSameDeviceInOtherSide) {
            
            NSMutableArray * mt_A = [NSMutableArray array];
            
            for (NSDictionary * dict in _trueLink_A) {
                
                if ([dict[@"eptTypeId"] isEqualToString:@"100"] &&
                    [dict[@"jumpType"] isEqualToString:@"down"]) {
                        
                    NSMutableDictionary * mt_Dict = [NSMutableDictionary dictionaryWithDictionary:dict];
                    mt_Dict[@"lineType"] = @(TE_ExDashLine_Warning);
                    [mt_A addObject:mt_Dict];
                    
                    continue;
                }
                
                [mt_A addObject:dict];
            }
            
            
            NSMutableArray * mt_B = [NSMutableArray array];
            
            for (NSDictionary * dict in _trueLink_B) {
                
                if ([dict[@"eptTypeId"] isEqualToString:@"100"] &&
                    [dict[@"jumpType"] isEqualToString:@"down"]) {
                        
                    NSMutableDictionary * mt_Dict = [NSMutableDictionary dictionaryWithDictionary:dict];
                    mt_Dict[@"lineType"] = @(TE_ExDashLine_Warning);
                    [mt_B addObject:mt_Dict];
                    
                    continue;
                }
                
                [mt_B addObject:dict];
            }
            
            _trueLink_A = mt_A;
            _trueLink_B = mt_B;
            
        }

    }
    
}



#pragma mark - 特殊对调关系 ---


/// 根据特殊模式下的数据.
- (void) reloadSpecialEnum:(TE_ContentSpecialMode_) specialModel
                     ADict:(NSDictionary *) terminal_LinkDict_A
                     BDict:(NSDictionary *)terminal_LinkDict_B {
    
    // 赋值
    _terminal_LinkDict_A = terminal_LinkDict_A;
    _terminal_LinkDict_B = terminal_LinkDict_B;
    
    
    // 赋值
    _upTerm_A = terminal_LinkDict_A[@"upTerm"];
    _downTerm_A = terminal_LinkDict_A[@"downTerm"];
    _route_A = terminal_LinkDict_A[@"route"];
    
    _upTerm_B = terminal_LinkDict_B[@"upTerm"];
    _downTerm_B = terminal_LinkDict_B[@"downTerm"];
    _route_B = terminal_LinkDict_B[@"route"];
    
    
    _trueLink_A = NSMutableArray.array;
    _trueLink_B = NSMutableArray.array;
    
    
    [self datasConfig_SpecialEnum:specialModel];
    
    // 特殊数据的判断处理
    [self specialDatasConfig];
    
    // 初始化UI
    [self contentUI_Init];

}



- (void) datasConfig_SpecialEnum:(TE_ContentSpecialMode_) specialModel {
    
    // afterExchange
    

    // 链路A _ 顶部跳接端子
    if ([_upTerm_A[@"hasOptLine"] isEqualToNumber:@true]) {
        
        NSNumber * type = _upTerm_A[@"type"];
        
        NSMutableDictionary * mt_upTermA = [NSMutableDictionary dictionaryWithDictionary:_upTerm_A];
        mt_upTermA[@"resId"] = _upTerm_A[@"termId"];
        mt_upTermA[@"resName"] = _upTerm_A[@"termName"];
        
        mt_upTermA[@"show"] = @(TE_ExTerShow_Left);
        mt_upTermA[@"terminalType"] = @(TE_ExTerminal_Normal);
        mt_upTermA[@"eptTypeId"] = @"317";

        // 跳接端子不存在
        if (type.integerValue == 2) {
            mt_upTermA[@"resName"] = @"无端子";
        }
        
        [_trueLink_A addObject:mt_upTermA];
        
        

        
        // *** 拼接跳接关系
        NSMutableDictionary * mt_jumpDict = [NSMutableDictionary dictionary];
        mt_jumpDict[@"eptTypeId"] = @"100"; //假设100 为跳接关系的类型id
        mt_jumpDict[@"show"] = @(TE_ExTerShow_Left);
        mt_jumpDict[@"lineType"] = @(TE_ExDashLine_Xu);
        mt_jumpDict[@"jumpType"] = @"up";
        
        // 跳接端子不存在
        if (type.integerValue == 2 && _nowScrollState == BaseScroll_After) {
            mt_jumpDict[@"lineType"] = @(TE_ExDashLine_Warning);
        }
        
        
        // 跳接端子和新路由中的头部端子 不在同一设备中
        if (_nowScrollState == BaseScroll_After) {
            
            NSDictionary * firstTerminal = _route_A.firstObject;
            
            NSString * relateEqpId = _upTerm_A[@"relateEqpId"];
            
            
            if ([firstTerminal[@"eptTypeId"] isEqualToString:@"317"]) {
                
                NSString * relateResId = firstTerminal[@"relateResId"];
                
                // 证明是同设备的 , 可以进行跳接
                if (![relateEqpId isEqualToString:relateResId]) {
                    mt_jumpDict[@"lineType"] = @(TE_ExDashLine_Warning);
                }
            }
        }
        
        
        
        [_trueLink_A addObject:mt_jumpDict];
        
    }
    
    
    // 链路A _ 路由
    
    NSInteger index_A = 0;
    for (NSDictionary * router in _route_A) {
        
        if (index_A > 0) {
            // 只取一个
            break;
        }
        
        NSInteger index = [_route_A indexOfObject:router];
        
        NSMutableDictionary * mt_route = [NSMutableDictionary dictionaryWithDictionary:router];
        mt_route[@"resId"] = router[@"eptId"];
        mt_route[@"resName"] = router[@"eptName"];
        
        mt_route[@"show"] = @(TE_ExTerShow_Left);
        
        // 端子
        if ([router[@"eptTypeId"] isEqualToString:@"317"]) {
            
            if (index == 0) {
                
                // 证明是对调后的端子 , 需要AB 互换
                if ([_terminal_LinkDict_A.allKeys containsObject:@"afterExchange"]) {
                    mt_route[@"terminalType"] = @(TE_ExTerminal_B);
                }
                else {
                    mt_route[@"terminalType"] = @(TE_ExTerminal_A);
                }
            }
            else {
                mt_route[@"terminalType"] = @(TE_ExTerminal_Normal);
                
                // otherSide 字段 用来判断该端子时对端端子
                mt_route[@"otherSide"] = @"1";
            }
        }
        
        // 纤芯
        if ([router[@"eptTypeId"] isEqualToString:@"702"]) {
            mt_route[@"lineType"] = @(TE_ExDashLine_Fiber);
        }
        
        
        [_trueLink_A addObject:mt_route];
        index_A ++;
        
    }
    
    

    
    // 链路B _ 顶部跳接端子
    if ([_upTerm_B[@"hasOptLine"] isEqualToNumber:@true]) {
        
        NSNumber * type = _upTerm_B[@"type"];
        
        // 需要为链路增加跳接的线
        NSMutableDictionary * mt_upTermB = [NSMutableDictionary dictionaryWithDictionary:_upTerm_B];
        mt_upTermB[@"resId"] = _upTerm_B[@"termId"];
        mt_upTermB[@"resName"] = _upTerm_B[@"termName"];
        
        mt_upTermB[@"show"] = @(TE_ExTerShow_Right);
        mt_upTermB[@"terminalType"] = @(TE_ExTerminal_Normal);
        mt_upTermB[@"eptTypeId"] = @"317";

        
        // 跳接端子不存在
        if (type.integerValue == 2) {
            mt_upTermB[@"resName"] = @"无端子";
        }
        
        [_trueLink_B addObject:mt_upTermB];
        
        
        // *** 拼接跳接关系
        NSMutableDictionary * mt_jumpDict = [NSMutableDictionary dictionary];
        mt_jumpDict[@"eptTypeId"] = @"100"; //假设100 为跳接关系的类型id
        mt_jumpDict[@"show"] = @(TE_ExTerShow_Right);
        mt_jumpDict[@"lineType"] = @(TE_ExDashLine_Xu);
        mt_jumpDict[@"jumpType"] = @"up";
        
        // 跳接端子不存在
        if (type.integerValue == 2 && _nowScrollState == BaseScroll_After) {
            mt_jumpDict[@"lineType"] = @(TE_ExDashLine_Warning);
        }
        
        
        // 跳接端子和新路由中的头部端子 不在同一设备中
        if (_nowScrollState == BaseScroll_After) {
            
            NSDictionary * firstTerminal = _route_B.firstObject;
            
            NSString * relateEqpId = _upTerm_B[@"relateEqpId"];
            
            
            if ([firstTerminal[@"eptTypeId"] isEqualToString:@"317"]) {
                
                NSString * relateResId = firstTerminal[@"relateResId"];
                
                // 证明是同设备的 , 可以进行跳接
                if (![relateEqpId isEqualToString:relateResId]) {
                    mt_jumpDict[@"lineType"] = @(TE_ExDashLine_Warning);
                }
            }
        }
        
        
        [_trueLink_B addObject:mt_jumpDict];
    }
    
    // 链路B _ 路由
    
    NSInteger index_B = 0;
    
    for (NSDictionary * router in _route_B) {
        
        if (index_B > 0) {
            break;
        }
        
        NSInteger index = [_route_B indexOfObject:router];
        
        NSMutableDictionary * mt_route = [NSMutableDictionary dictionaryWithDictionary:router];
        mt_route[@"resId"] = router[@"eptId"];
        mt_route[@"resName"] = router[@"eptName"];
        
        mt_route[@"show"] = @(TE_ExTerShow_Right);
        
        // 端子
        if ([router[@"eptTypeId"] isEqualToString:@"317"]) {
            
            if (index == 0) {
                
                // 证明是对调后的端子 , 需要AB 互换
                if ([_terminal_LinkDict_B.allKeys containsObject:@"afterExchange"]) {
                    mt_route[@"terminalType"] = @(TE_ExTerminal_A);
                }
                else {
                    mt_route[@"terminalType"] = @(TE_ExTerminal_B);
                }
            }
            else {
                mt_route[@"terminalType"] = @(TE_ExTerminal_Normal);
                
                // otherSide 字段 用来判断该端子时对端端子
                mt_route[@"otherSide"] = @"1";
            }
        }
        
        // 纤芯
        if ([router[@"eptTypeId"] isEqualToString:@"702"]) {
            mt_route[@"lineType"] = @(TE_ExDashLine_Fiber);
        }
        
        
        [_trueLink_B addObject:mt_route];
        
        index_B ++;
    }
    
    
    
}


#pragma mark - contentUI ---


- (void) contentUI_Init {
    
    NSMutableArray * allLeftViews = NSMutableArray.array;
    NSInteger leftFiberCount = 0;
    // 左侧 ---
    for (NSDictionary * elementDict in _trueLink_A) {
        
        NSString * eptTypeId = elementDict[@"eptTypeId"];
        
        // 端子
        if ([eptTypeId isEqualToString:@"317"]) {
            
            NSNumber * terminalType = elementDict[@"terminalType"];
            TE_ExTerminal_ tTEnum = terminalType.integerValue;
            
            NSNumber * show = elementDict[@"show"];
            TE_ExTerShow_ showEnum = show.integerValue;
            
            NSString * resName = elementDict[@"resName"];
            
            // 创建端子
            Inc_TE_ExTerminalShowView * terminalElement =
            [[Inc_TE_ExTerminalShowView alloc] initWithTerminalState:tTEnum
                                                            showEnum:showEnum
                                                                 msg:resName];
            
            // 加入数组中
            [allLeftViews addObject:terminalElement];
            
        }
        
        // 纤芯
        if ([eptTypeId isEqualToString:@"702"]) {
            
            // 如果已经有纤芯了 , 跳过本次循环
            if (leftFiberCount > 0) {
                continue;
            }
            
            NSNumber * lineType = elementDict[@"lineType"];
            TE_ExDashLine_ fiberEnum = lineType.integerValue;
            
            NSNumber * show = elementDict[@"show"];
            TE_ExTerShow_ showEnum = show.integerValue;
            
            
            Inc_TE_ExDashLine * fiberElement = [[Inc_TE_ExDashLine alloc] initWithEnum:fiberEnum
                                                                           leftOrRight:showEnum];
            
            // 加入数组中
            [allLeftViews addObject:fiberElement];
            leftFiberCount++;
        }
        
        
        // 跳接关系
        if ([eptTypeId isEqualToString:@"100"]) {
            
            NSNumber * lineType = elementDict[@"lineType"];
            TE_ExDashLine_ fiberEnum = lineType.integerValue;
            
            NSNumber * show = elementDict[@"show"];
            TE_ExTerShow_ showEnum = show.integerValue;
            
            
            Inc_TE_ExDashLine * fiberElement = [[Inc_TE_ExDashLine alloc] initWithEnum:fiberEnum
                                                                           leftOrRight:showEnum];
            
            // 加入数组中
            [allLeftViews addObject:fiberElement];
        }
        
    }
    
    
    
    // 右侧 ---
    
    NSMutableArray * allRightViews = NSMutableArray.array;
    NSInteger rightFiberCount = 0;

    for (NSDictionary * elementDict in _trueLink_B) {
        
        NSString * eptTypeId = elementDict[@"eptTypeId"];
        
        // 端子
        if ([eptTypeId isEqualToString:@"317"]) {
            
            NSNumber * terminalType = elementDict[@"terminalType"];
            TE_ExTerminal_ tTEnum = terminalType.integerValue;
            
            NSNumber * show = elementDict[@"show"];
            TE_ExTerShow_ showEnum = show.integerValue;
            
            NSString * resName = elementDict[@"resName"];
            
            // 创建端子
            Inc_TE_ExTerminalShowView * terminalElement =
            [[Inc_TE_ExTerminalShowView alloc] initWithTerminalState:tTEnum
                                                            showEnum:showEnum
                                                                 msg:resName];
            
            // 加入数组中
            [allRightViews addObject:terminalElement];
            
        }
        
        // 纤芯
        if ([eptTypeId isEqualToString:@"702"]) {
            
            // 如果已经有纤芯了 , 跳过本次循环
            if (rightFiberCount > 0) {
                continue;
            }
            
            NSNumber * lineType = elementDict[@"lineType"];
            TE_ExDashLine_ fiberEnum = lineType.integerValue;
            
            NSNumber * show = elementDict[@"show"];
            TE_ExTerShow_ showEnum = show.integerValue;
            
            
            Inc_TE_ExDashLine * fiberElement = [[Inc_TE_ExDashLine alloc] initWithEnum:fiberEnum
                                                                           leftOrRight:showEnum];
            
            // 加入数组中
            [allRightViews addObject:fiberElement];
            rightFiberCount++;
        }
        
        
        // 跳接关系
        if ([eptTypeId isEqualToString:@"100"]) {
            
            NSNumber * lineType = elementDict[@"lineType"];
            TE_ExDashLine_ fiberEnum = lineType.integerValue;
            
            NSNumber * show = elementDict[@"show"];
            TE_ExTerShow_ showEnum = show.integerValue;
            
            
            Inc_TE_ExDashLine * fiberElement = [[Inc_TE_ExDashLine alloc] initWithEnum:fiberEnum
                                                                           leftOrRight:showEnum];
            
            // 加入数组中
            [allRightViews addObject:fiberElement];
        }
        
    }
    
    
    [self addSubviews:allLeftViews];
    
    
    float viewHeight = Vertical(40);
    
    for (int i = 0 ; i < allLeftViews.count; i++) {
        
        UIView * view = allLeftViews[i];
        
        [view YuanToSuper_Left:0];
        [view YuanToSuper_Top:Vertical(70) + i * viewHeight];
        [view Yuan_EdgeSize:CGSizeMake(ScreenWidth/2 - Horizontal(20), viewHeight)];
    }
    
    
    [self addSubviews:allRightViews];
    
    for (int i = 0 ; i < allRightViews.count; i++) {
        
        UIView * view = allRightViews[i];
        
        [view YuanToSuper_Right:0];
        [view YuanToSuper_Top:Vertical(70) + i * viewHeight];
        [view Yuan_EdgeSize:CGSizeMake(ScreenWidth/2 - Horizontal(20), viewHeight)];
    }
    
    
    
    // 顶部typeView 适配
    [self typeViewConfig];
    
}



- (void) typeViewConfig {
    
    NSString * resTypeName_A = _terminal_LinkDict_A[@"linkName"];
    NSString * resTypeName_B = _terminal_LinkDict_B[@"linkName"];
    
    [_leftTypeView reloadWithResType:resTypeName_A resName:@""];
    [_rightTypeView reloadWithResType:resTypeName_B resName:@""];
    
}




#pragma mark - UI_Init

- (void) UI_Init {
    
    _leftTypeView = [[Inc_TE_ExLinkType_NameView alloc] init];
    _rightTypeView = [[Inc_TE_ExLinkType_NameView alloc] init];
    
    [_leftTypeView cornerRadius:0 borderWidth:1 borderColor:UIColor.f2_Color];
    [_rightTypeView cornerRadius:0 borderWidth:1 borderColor:UIColor.f2_Color];
    
    [self addSubviews:@[_leftTypeView,_rightTypeView]];
    [self yuan_LayoutSubViews];
}


- (void) yuan_LayoutSubViews {
    
    [_leftTypeView YuanToSuper_Left:1];
    [_leftTypeView YuanToSuper_Top:1];
    [_leftTypeView Yuan_EdgeSize:CGSizeMake(ScreenWidth/2, Vertical(60))];
    
    [_rightTypeView YuanToSuper_Right:1];
    [_rightTypeView YuanToSuper_Top:1];
    [_rightTypeView Yuan_EdgeSize:CGSizeMake(ScreenWidth/2, Vertical(60))];
}

@end
