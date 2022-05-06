//
//  Yuan_CFConfigModel.m
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2020/7/21.
//  Copyright © 2020 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_CFConfigModel.h"
#import "Yuan_CFConfigVM.h"
@implementation Yuan_CFConfigModel
{
    
    Yuan_CFConfigVM * _viewModel;
    
    NSMutableArray * _xianxinArray;
    
    NSMutableArray * _startDeviceArray;
    
    NSMutableArray * _endDeviceArray;
    
}

#pragma mark - 初始化构造方法

- (instancetype) init {
    
    if (self = [super init]) {
        _viewModel = [Yuan_CFConfigVM shareInstance];
        
        _xianxinArray = [NSMutableArray array];
        
        _startDeviceArray = [NSMutableArray array];
        
        _endDeviceArray = [NSMutableArray array];
    }
    return self;
}



#pragma mark -  数组拆分  ---

- (void) clearUpToArrays:(NSArray *)listArray {
    
    
    for (NSDictionary * dict in listArray) {
        
        NSString * pairId = dict[@"pairId"];
        
        [_xianxinArray addObject:@{@"pairNo":dict[@"pairNo"] ?: @"" ,
                                   @"pairId":pairId ?: @"" ,
                                   @"pairName":dict[@"pairName"] ?: @""
        }];
        
        
        NSArray * connectArray = dict[@"connectList"];
        
        if (!connectArray || connectArray.count == 0) {
            continue;
        }
        
        
        for (NSDictionary * connectDict in connectArray) {
            
            NSDictionary * zhengliDict = [self clearUpSubConfig:connectDict
                                                         pairId:pairId];
            
            if ([zhengliDict[@"location"] isEqualToString:@"start"]) {
                // 证明是起始的组
                [_startDeviceArray addObject:zhengliDict];
            }else if ([zhengliDict[@"location"] isEqualToString:@"end"]) {
                [_endDeviceArray addObject:zhengliDict];
            }
            else {
                continue;
            }
        }
    }
}





/// 根据纤芯的单个Dict 判断应该显示在左上右下 是成端还是熔接 是属于起始 还是终止---
/// @param fiberDict 纤芯dict
- (NSDictionary *) clearUpSubConfig:(NSDictionary *) fiberDict
                             pairId:(NSString *)pairId{
    
    
    
    // 光缆段的起始和终止的设备名称  用于和纤芯去判断
    NSString * cableStart = _viewModel.moBan_Dict[@"cableStart"];
    NSString * cableEnd = _viewModel.moBan_Dict[@"cableEnd"];
    
    
    // 数组里有 一个元素 或 两个元素的情况 ~  0元素的情况在上面已经判断返回 CF_VM_FiberType_None
    
    NSString * resAName = fiberDict[@"resAName"] ?:@"";
    NSString * resBName = fiberDict[@"resBName"] ?:@"";
    
    NSString * resAId = fiberDict[@"resAId"] ?: @"";
    NSString * resBId = fiberDict[@"resBId"] ?: @"";
    
    
    // 只有熔接状态下有效
    
    NSString * tieInName = fiberDict[@"tieInName"] ?: @"";
    NSString * tieInId = fiberDict[@"tieInId"] ?: @"";
    
    // 如果 resAId 或者 resBId 与 pairId 相同的那一组 弃用
    
    
    NSString * resId = @"";    //端子或者对端光缆段的Id , 用于下方view 验证
    NSString * resName = @"";
    
    NSString * qizhi = @"";
    NSString * A_Or_B = @"";
    
    
    
    if (![resAId isEqualToString:pairId]) {
        
        resName = fiberDict[@"resAName"] ?: @"";
        resId = fiberDict[@"resAId"] ?: @"";
        A_Or_B = @"A";
    }else if (![resBId isEqualToString:pairId]) {
        
        resName = fiberDict[@"resBName"] ?: @"";
        resId = fiberDict[@"resBId"] ?: @"";
        A_Or_B = @"B";
    }else {
        resName = @"";
        resId = @"";
        A_Or_B = @"";
    }
    
    
    
    if (tieInName.length > 0 && tieInId.length > 0) {
        
        // 熔接状态下
        if ([tieInName rangeOfString:cableStart].location != NSNotFound) {
            // 证明是熔接是起始设备
            qizhi = @"start";
        }else if([tieInName rangeOfString:cableEnd].location != NSNotFound){
            qizhi = @"end";
        }else {
            qizhi = @"";
        }
        
    } else {
        
        // 成端状态下
        if ([A_Or_B isEqualToString:@"A"]) {
            
            if ([resAName rangeOfString:cableStart].location != NSNotFound) {
                qizhi = @"start";
            }else if ([resAName rangeOfString:cableEnd].location != NSNotFound) {
                qizhi = @"end";
            }else {
                qizhi = @"";
            }
            
        } else if ([A_Or_B isEqualToString:@"B"]) {
            
            if ([resBName rangeOfString:cableStart].location != NSNotFound) {
                qizhi = @"start";
            }else if ([resBName rangeOfString:cableEnd].location != NSNotFound) {
                qizhi = @"end";
            }else {
                qizhi = @"";
            }
            
        }
        
    }
    
    
    
    
    
    // 返回 id 名称 和 起止
    
    return @{@"resId":resId  ?: @"",
             @"resName":resName  ?: @"",
             @"location":qizhi ?: @""};
    
}








#pragma mark -  当组合 本纤芯与对端 纤芯或端子数据时 走这个方法  ---



/// 把 saveSingleDictWithFiberID: LinkID: 方法收集起来的dict 装进数组中
/// @param otherTerminalOrFiberDict Z端的dict
- (BOOL) joinSingleDictToLinkSaveHttpArray:(NSDictionary *)otherTerminalOrFiberDict
                                      type:(CF_HeaderCellType_)chengduan_Or_Rongjie
{
    
    if (!_viewModel.baseLink_FiberId || _viewModel.baseLink_FiberId.length == 0) {
        // 证明还没选中 baseLinkDict
        
        [[Yuan_HUD shareInstance] HUDFullText:@"在关联之前,要先选择一个光缆段纤芯"];
        return NO;
    }
    
    // 如果已经有 纤芯了 就给 otherLinkDict 赋值
    
    NSString * other_GID;
    
    if (chengduan_Or_Rongjie == CF_HeaderCellType_ChengDuan) {
        other_GID = otherTerminalOrFiberDict[@"GID"];   // 对方是ODF 成端时
    }
    else if (chengduan_Or_Rongjie == CF_HeaderCellType_RongJie) {
        other_GID = otherTerminalOrFiberDict[@"pairId"];  // 对方是 光缆接头
    }
    else {
        other_GID = @"";
    }
    
    
    if (!other_GID || other_GID.length == 0 || [other_GID isEqual:[NSNull null]]) {
        [[Yuan_HUD shareInstance] HUDFullText:@"您选择的端子或纤芯,缺少必要的GID"];
        return NO;
    }else {
        
        _viewModel.otherLink_FiberOrTerminalID = other_GID;
        
        // *** 每个数组中的map 应该是什么
        NSDictionary * postDict =
        [self saveSingleDictWithFiberID:_viewModel.baseLink_FiberId
                                 LinkID:other_GID];

        
        NSInteger index = 0;
        BOOL postDict_isAlready_exitInArray = NO;
        for (NSDictionary * already_saveDict in _viewModel.linkSaveHttpArray) {
            
            if ([already_saveDict[@"GID"] isEqualToString:postDict[@"GID"]]) {
                // 如果 已经存放进去的数组中map的GID 和 刚创建好的GID 相同 ,
                // 证明 同一个纤芯 , 连接个不同的设备 , 用后设备替换前设备
                
                [_viewModel.linkSaveHttpArray replaceObjectAtIndex:index withObject:postDict];
                
                postDict_isAlready_exitInArray = YES;
                break;
            }
            index++;
            
        }
        
         
        // 如果判断 postDict 并没有存在于数组当中 , 那么就添加进去
        if (!postDict_isAlready_exitInArray) {
            // 把组合好的数据加入数组当中 , 并且清空两个ID
            [_viewModel.linkSaveHttpArray addObject:postDict];
        }
        
        
        
        _viewModel.baseLink_FiberId = nil;
        _viewModel.otherLink_FiberOrTerminalID = nil;
        
        
    }
    
    // 如果成功了 , 还要通知 Yuan_CFConfigController 的 上方 collectionList 刷新自己,
    // 把当前的框变绿色 , 证明已经关联完毕 , 并且将下一个框变为红色
    
    
    // 仅通知 不传值  里面有一个block 回调
    
    [_viewModel viewModel_NotiConfigController_ReloadTheCollection];
    
    return YES;
}






/// 组合
/// @param GID 当前我点击的纤芯 ID
/// @param linkId_resBID 对端的设备ID  端子或纤芯的ID
- (NSMutableDictionary *) saveSingleDictWithFiberID:(NSString * _Nonnull)GID
                                             LinkID:(NSString *)linkId_resBID{
    
    
    
    // 判断 linkId_resBID 之前存过没有
    
    [_viewModel.linkSaveHttpArray enumerateObjectsUsingBlock:^(id  _Nonnull obj,
                                                               NSUInteger idx,
                                                               BOOL * _Nonnull stop) {
        
        NSDictionary * dict = obj;
        NSArray * optConjunctions = dict[@"optConjunctions"];
        NSDictionary * singleDict = optConjunctions.firstObject;
        if ([singleDict[@"resB_Id"] isEqualToString:linkId_resBID]) {
            [_viewModel.linkSaveHttpArray removeObject:obj];
        }
        
        
    }];
    
    
    
    
    // 默认 当前纤芯就是A   , 对方成端或熔接的 type 就是B
    // 如果B的是熔接 那么B内部的设备都是纤芯 : @"1" 如果B是成端 那么B对应的都是端子 : @"2"
    NSString * resBType = _viewModel.configVC_type == CF_HeaderCellType_RongJie ? @"1" : @"2";
    
    NSString * cableID = _viewModel.moBan_Dict[@"GID"];
    
    NSMutableDictionary * dict = NSMutableDictionary.dictionary;
    
//    _viewModel.startOrEnd
    
    dict[@"pairNo"] =  _viewModel.baseLinkDict[@"pairNo"] ?: @"";;
    
    dict[@"resLogicName"] = @"optPair";
    dict[@"GID"] = GID;
    
    dict[@"optConjunctions"] =
    @[@{
         @"resLogicName" : @"optConjunction",
         @"resA_Type" : @"1",
         @"resB_Type" : resBType,
         @"resA_Id" : GID,
         @"resB_Id" : linkId_resBID,
         @"resAEqp_Id" : cableID,
         @"resZEqp_Id" : _viewModel.resZEqp_Id,
         @"location" : _viewModel.startOrEnd == CF_VC_StartOrEndType_Start? @"start" : @"end",
         @"creater" : @"yuan"
     
    }];
    
    
    return dict;
}








































#pragma mark -  跟王大为交互转码部分  不需要看了   ---



- (NSDictionary *) wangDavieToLonggeMoBanDictChange:(NSDictionary *)wangDavieDict  {
    
    /*
     {
         GID = 004007020000000123664225;
         bigSequence = 12;
         
         mntStateId = 160003;               //维护状态ID
         mntStateName = "\U5e9f\U5f03";     //维护状态name
         oprStateId = 170005;               // 业务状态    ID
         oprStateName = "\U9884\U91ca\U653e"; // 业务状态    name
         optSectId = "\U8881\U5148\U751f\U6d4b\U8bd5\U4e13\U7528"; //所属光缆段ID
         optSectName = 004007010000000002502569;                   //所属光缆段name
         pairId = 004007020000000123664225;         // 纤芯ID
         pairName = "\U8881\U5148\U751f\U6d4b\U8bd5\U4e13\U752812"; // 纤芯name
         pairNo = 12;       //纤芯名称
         propCharId = 40003;  // 产权性质ID
         propCharName = "\U79df\U7528";  // 产权性质name
         property = 67590033;            // 产权归属 id
         propertyName = "\U79fb\U52a8";  // 产权归属 name
         resLogicName = optPair;
     }
     
     */
    
    NSMutableDictionary * newDict = NSMutableDictionary.dictionary;
    
    newDict[@"GID"] = wangDavieDict[@"GID"];
    newDict[@"pairNo"] = wangDavieDict[@"pairNo"];
    newDict[@"bigSequence"] = wangDavieDict[@"bigSequence"];
    newDict[@"oprStateId"] = [self ywzt:wangDavieDict[@"oprStateId"]];  // 业务状态ID
    newDict[@"whzt"] = [self whzt:wangDavieDict[@"mntStateId"]];        // 维护状态ID
    newDict[@"chanquanxz"] = [self cqxz:wangDavieDict[@"propCharId"]];  // 产权性质ID
    newDict[@"prorertyBelong"] = [self cqgs:wangDavieDict[@"property"]];// 产权归属ID
    newDict[@"cableSeg"] = wangDavieDict[@"optSectName"];               // 所属光缆段ID
    newDict[@"resLogicName"] = @"optPair";
    
    
/// MARK: optSectName 本来这个字段应该是 optSectId , 王大为应该是把 optSectName 和 optSectId 传反了
    
    // 如果有需要 把字段替换过来就好了
    
    //cableSeg_Id 所属光缆段ID
    
    
    return newDict;
}


#pragma mark -  转 业务状态ID  ---

- (NSString *) ywzt:(NSString *)yewz {
    
    /**
     170001 空闲
     170002 预占
     170003 占用
     170005 预释放
     170007 预留
     170014 预选
     170015 备用
     160014 停用
     160065 闲置
     170147 损坏
     170046 测试
     170187 临时占用
     
     */
    
    /**
     0 - 请选择, 1 - 空闲, 2 - 预占, 3 - 占用, 4 - 预释放, 5 - 预留, 6 - 预选, 7 - 备用, 8 - 停用, 9 - 闲置, 10 - 损坏, 11 - 测试, 12 - 临时占用,
     */
    
    if (!yewz|| [yewz obj_IsNull]) {
        return @"0";
    }
    
    NSInteger s = yewz ? [yewz integerValue] : 0;
    
    NSString * result;
    
    switch (s) {
        case 170001:
            result = @"1";
            break;
            
        case 170002:
            result = @"2";
            break;
        
        case 170003:
            result = @"3";
            break;
            
        case 170005:
            result = @"4";
            break;
            
        case 170007:
            result = @"5";
            break;
            
        case 170014:
            result = @"6";
            break;
        
        case 170015:
            result = @"7";
            break;
            
        case 160014:
            result = @"8";
            break;
            
        case 160065:
            result = @"9";
            break;
            
        case 170147:
            result = @"10";
            break;
        
        case 170046:
            result = @"11";
            break;
            
        case 170187:
            result = @"12";
            break;
            
        default:
            result = @"0";
            break;
    }
    
    return result;
}


#pragma mark -  转 维护状态ID  ---
- (NSString *) whzt:(NSString *)whzt {
    
    /**
     160001 设计
     160002 在建
     160003 废弃
     160004 可用
     160005 故障
     160060 正常
     170029 割接封锁
     170046 测试
     
     50051  维护
     50060  暂时关闭
     50061  搬迁
     50062  替换
     */
    
    /**
     0 - 请选择, 1 - 设计, 2 - 在建, 3 - 废弃, 4 - 可用, 5 - 故障, 6 - 正常, 7 - 割接封锁, 8 - 测试,
     */
    
    if (!whzt || [whzt obj_IsNull]) {
        return @"0";
    }
    
    NSInteger s = whzt ? [whzt integerValue] : 0;
    
    NSString * result;
    
    switch (s) {
        case 160001:
            result = @"1";
            break;
            
        case 160002:
            result = @"2";
            break;
        
        case 160003:
            result = @"3";
            break;
        
        case 160004:
            result = @"4";
        break;
            
        case 160005:
            result = @"5";
            break;
            
        case 160060:
            result = @"6";
            break;
            
        case 170029:
            result = @"7";
            break;
        
        case 170046:
            result = @"8";
            break;

            
        default:
            result = @"0";
            break;
    }
    
    return result;
    
}

#pragma mark -  转 产权性质  ---

- (NSString *) cqxz:(NSString *)cqxz {
    
    /**
     40001 自有（地皮、房屋自有产权）
     40002 购买
     40003 租用
     40004 借用
     40005 共建（共建共享）
     40039 空闲
     40040 出租
     40041 共享（非共建，只共享）
     40029 其他
     40050 移交
     40051 自建（地皮租用、房屋自建）（不含共享）
     */
    
    /**
     1 - 自有（地皮、房屋自有产权）, 2 - 购买, 3 - 租用, 4 - 借用, 5 - 合建, 6 - 空闲, 7 - 出租, 8 - 共建共享, 9 - 其他, 10 - 移交,
     */
    
    if (!cqxz || [cqxz obj_IsNull]) {
        return @"0";
    }
    
    NSInteger s = cqxz ? [cqxz integerValue] : 0;
    
    NSString * result;
    
    switch (s) {
        case 40001:
            result = @"1";
            break;
        
        case 40002:
            result = @"2";
        break;
        
        case 40003:
            result = @"3";
            break;
        
        case 40004:
            result = @"4";
        break;
        
        case 40005:
            result = @"5";
            break;
        
        case 40039:
            result = @"6";
        break;
       
        case 40040:
            result = @"7";
            break;
            
        case 40041:
            result = @"8";
        break;
        
        case 40029:
            result = @"9";
        break;
        
        case 40050:
            result = @"10";
            break;
        
            
        default:
            result = @"0";
            break;
    }
    
    return result;
    
}

#pragma mark -  转 产权归属  ---

- (NSString *) cqgs:(NSString *)cqgs {
    
    /**
     50045 民间投资
     67590031 电信
     67590032 联通
     67590033 移动
     67590034 其他产权
     67590035 铁塔（自建）
     67590036 信网
     67590037 中国有线
     67590038 客户
     67590040  铁塔（租赁）
     */
    
    /**
     1 - 民间投资, 2 - 电信, 3 - 联通, 4 - 移动, 5 - 其他产权, 6 - 铁塔, 7 - 信网, 8 - 中国有线, 9 - 客户,
     */
    
    if (!cqgs|| [cqgs obj_IsNull]) {
        return @"0";
    }
    
    NSInteger s = cqgs ? [cqgs integerValue] : 0;
    
    NSString * result;
    
    switch (s) {
            
        case 50045:
            result = @"1";
            break;
            
        case 67590031:
            result = @"2";
            break;
    
        case 67590032:
            result = @"3";
            break;
    
        case 67590033:
            result = @"4";
            break;
    
        case 67590034:
            result = @"5";
            break;
    
        case 67590035:
            result = @"6";
            break;
    
        case 67590036:
            result = @"7";
            break;
    
        case 67590037:
            result = @"8";
            break;
    
        case 67590038:
            result = @"9";
            break;
    
        case 67590040:
            result = @"10";
            break;
            
        default:
            break;
    }
    
    return result;
    
}

@end
