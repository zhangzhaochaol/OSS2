//
//  Yuan_DC_VM.m
//  OSS2.0-ios-v2
//
//  Created by 袁全 on 2021/1/11.
//  Copyright © 2021 青岛英凯利信息科技有限公司. All rights reserved.
//

#import "Yuan_DC_VM.h"
#import "Yuan_PolyLine.h"        // 线资源
@implementation Yuan_DC_VM

{
        // 所有和递归相关的点和线
    NSMutableArray * _myPutCable_IdsArr;

    NSMutableArray * _myPutCable_LinesArray;
    
    NSString * _startPutCableId;
    
    NSString * _endPutCableId;
 
    
    BOOL _circleBreak;
}



#pragma mark - method ---


//. 验证是否有获取线路 和 撤缆的权限  -- 是否是 把山点
- (BOOL) isHaveJurisdictionHandle:(NSArray *)linesArr
                           myDict:(NSDictionary *)myDict {
    
    
    NSString * myId = myDict[@"resId"] ?: @"";
    
    BOOL isStart = false;
    BOOL isEnd = false;
    
    
    for (Yuan_PolyLine * line in linesArr) {
        // eid sid
        
        NSDictionary * singleLinesDict = line.dataSource;
        
        
        
        NSString * sid = singleLinesDict[@"sid"];
        NSString * eid = singleLinesDict[@"eid"];
        
        if ([sid isEqualToString:myId]) {
            isStart = true;
        }
        
        if ([eid isEqualToString:myId]) {
            isEnd = true;
        }
        
    }
    
    if (isStart && isEnd) {
        return NO;
    }
    
    if (!isStart && !isEnd) {
        return NO;
    }
    
    
    return YES;
    
    
}


// 我 当前点的对端点 是不是也是把山点?
- (NSDictionary *) isHaveJurisdictionHandle:(NSArray *)linesArr
                                  pointData:(NSArray *)pointArr
                        myLineFacePointDict:(NSDictionary *)myDict {
    
    NSString * myId = myDict[@"resId"] ?: @"";
    

    
    NSString * myFriendId = @"";
    
    
    for (Yuan_PolyLine * line in linesArr) {
        // eid sid
        
        NSDictionary * singleLinesDict = line.dataSource;
        
        
        
        NSString * sid = singleLinesDict[@"sid"];
        NSString * eid = singleLinesDict[@"eid"];
        
        if ([sid isEqualToString:myId]) {
            myFriendId = eid;
        }
        
        if ([eid isEqualToString:myId]) {
            myFriendId = sid;
        }
        
    }
    
    NSDictionary * myFriendDict;
    
    for (Yuan_MultiPointItem * item in pointArr) {
        NSDictionary * dict = item.dataSource;
        NSString * dict_Id = dict[@"resId"];
        
        if ([myFriendId isEqualToString:dict_Id]) {
            myFriendDict = dict;
        }
    }
    
    
    // 如果对端也是把山点
    if ([self isHaveJurisdictionHandle:linesArr myDict:myFriendDict]) {
        return myFriendDict;
    }
    
    return nil;

}



// 验证起始或终止设备 是否在路由上
- (BOOL) isStartEndDevice_IsInRoute:(NSArray *)linesArr deviceDict:(NSDictionary *) deviceDict {
    
    NSString * deviceId = deviceDict[@"id"];
    
    
    BOOL isStart = false;
    BOOL isEnd = false;
    
    
    for (Yuan_PolyLine * line in linesArr) {
        // eid sid
        
        NSDictionary * singleLinesDict = line.dataSource;
        
        
        
        NSString * sid = singleLinesDict[@"sid"];
        NSString * eid = singleLinesDict[@"eid"];
        
        if ([sid isEqualToString:deviceId]) {
            isStart = true;
        }
        
        if ([eid isEqualToString:deviceId]) {
            isEnd = true;
        }
        
    }
    
    
    // 当 本设备Id 在某条线段起始或终止点出现时 , 证明已连接到路由
    
    if (isStart || isEnd) {
        return YES;
    }
    
    return NO;

}









// 当撤缆时调用 , 哪个资源点应该是我撤缆结束后 , 变为新的选中状态的资源点呢?
- (NSString *) whosAnnoIsMySelectNext:(NSArray *) linesArr myId:(NSString *) myId {
    
    
    NSString * nextId = @"";
    
    for (Yuan_PolyLine * line in linesArr) {
        // eid sid
        
        NSDictionary * singleLinesDict = line.dataSource;
        
        NSString * sid = singleLinesDict[@"sid"];
        NSString * eid = singleLinesDict[@"eid"];
        
        
        if ([sid isEqualToString:myId]) {
            nextId = eid;
            break;
        }
        
        if ([eid isEqualToString:myId]) {
            nextId = sid;
            break;
        }
        
    }
    
    
    if (nextId.length == 0) {
        [[Yuan_HUD shareInstance] HUDFullText:@"当前路由段已清空"];
    }
    
    return nextId;
}





// resType 转 eqpTypeId
- (id) resType_To_EqpTypeId:(NSString *)resType {
    
    
    if ([resType isEqualToAnyString:@"stayPoint",@"supportPoint",@"upPoint", nil]) {
        return @"601";
    }
    
   
    if ([resType isEqualToString:@"marker"]) {
        return @"511";
    }
    
    if ([resType isEqualToString:@"pipeHole"]) {
        return @"503";
    }
    
    if ([resType isEqualToString:@"hole"]) {
        return @"508";
    }
    
    return @"";
}




// 穿缆时 配置起始终止Id们
- (NSArray *) putCableRouteWith:(NSDictionary *)cableDict  {
    
    
    NSArray * routePointArray = cableDict[@"routePointArray"];
    NSArray * routeLineArray = cableDict[@"routeLineArray"];
    
    NSArray * routePointIdsArr = cableDict[@"routePointIdsArr"];
    NSArray * routeLineIdsArr = cableDict[@"routeLineIdsArr"];
    
    NSArray * getLinesPointArray = cableDict[@"getLinesPointArray"];
    NSArray * getLinesLineArray = cableDict[@"getLinesLineArray"];
    
    
    NSString * startId = cableDict[@"startId"];
    NSString * endId = cableDict[@"endId"];
    
    _startPutCableId = startId;
    _endPutCableId = endId;
    
    
    _myPutCable_IdsArr = NSMutableArray.array;
    _myPutCable_LinesArray = NSMutableArray.array;
    
    _circleBreak = NO;
    
    // 从终点往起点递归
    for (Yuan_PolyLine * line in getLinesLineArray) {
        // 综合箱 添加端子
        
        NSDictionary * singleDict = line.dataSource;
        NSString * sid = singleDict[@"sid"];
        NSString * eid = singleDict[@"eid"];
        
        if ([endId isEqualToString:sid]) {
            
            _circleBreak = NO;
            
            if ([eid isEqualToString:_startPutCableId]) {
                [_myPutCable_IdsArr addObject:eid];
                [_myPutCable_LinesArray addObject:singleDict];
            }
            
            
            if ([_myPutCable_IdsArr containsObject:sid]) {
                // 先把终点加进来
                [_myPutCable_IdsArr addObject:sid];
            }
            
            if (![_myPutCable_LinesArray containsObject:singleDict]) {
                [_myPutCable_LinesArray addObject:singleDict];
            }
            
            
            // 开始递归
            [self diGui:eid act:getLinesLineArray lastDiGuiDict:singleDict];
            
            if (_myPutCable_IdsArr.count > 0) {
                break;
            }
        }
        
        if ([endId isEqualToString:eid]) {

            _circleBreak = NO;

            if ([sid isEqualToString:_startPutCableId]) {
                [_myPutCable_IdsArr addObject:eid];
                [_myPutCable_LinesArray addObject:singleDict];
            }
            
            if ([_myPutCable_IdsArr containsObject:sid]) {
                // 先把终点加进来
                [_myPutCable_IdsArr addObject:eid];
            }
            
            if (![_myPutCable_LinesArray containsObject:singleDict]) {
                [_myPutCable_LinesArray addObject:singleDict];
            }
            
            [self diGui:sid act:getLinesLineArray lastDiGuiDict:singleDict];

            if (_myPutCable_IdsArr.count > 0) {
                break;
            }

        }
        
    }
    
    
    
    
    
    NSMutableArray * sectResList = NSMutableArray.array;
    
    for (NSDictionary * dict in _myPutCable_LinesArray) {
        
        NSMutableDictionary * subDict = NSMutableDictionary.dictionary;
        
        subDict[@"resId"] = dict[@"resId"];
        subDict[@"resName"] = dict[@"resName"];
        subDict[@"typeId"] = dict[@"typeId"];  // ---
        
        subDict[@"sid"] = dict[@"sid"];
        subDict[@"eid"] = dict[@"eid"];
        subDict[@"stype"] = dict[@"stype"];
        subDict[@"etype"] = dict[@"etype"];
        subDict[@"stypeId"] = dict[@"stypeId"];
        subDict[@"etypeId"] = dict[@"etypeId"];
        
        [sectResList addObject:subDict];
    }
    
    
    
    
    if (sectResList.count == 0) {
        return @[];
    }
    
    
    return sectResList;
}



- (void) diGui:(NSString *)actId act:(NSArray *)getLinesLineArr lastDiGuiDict:(NSDictionary *)dict{
    
    
    if ([_myPutCable_IdsArr containsObject:_startPutCableId]) {
        
        _circleBreak = YES;
        return;
    }
    
    
    for (Yuan_PolyLine * line in getLinesLineArr) {
        
        if (_circleBreak) {
            break;
        }
        
        NSDictionary * singleDict = line.dataSource;
        
        NSString * sid = singleDict[@"sid"];
        NSString * eid = singleDict[@"eid"];
        
        if ([sid isEqualToString:actId] && singleDict != dict) {
            [_myPutCable_IdsArr addObject:eid];
            [_myPutCable_LinesArray addObject:singleDict];
            [self diGui:eid act:getLinesLineArr lastDiGuiDict:singleDict];
            
        }
        
        if ([eid isEqualToString:actId] && singleDict != dict) {
            [_myPutCable_IdsArr addObject:sid];
            [_myPutCable_LinesArray addObject:singleDict];
            [self diGui:sid act:getLinesLineArr lastDiGuiDict:singleDict];
        }
        
    }
    
    
    if (![_myPutCable_IdsArr containsObject:_startPutCableId]) {
        
        _circleBreak = YES;
        
        if (_myPutCable_IdsArr.count == 1) {
            return;
        }
        
        else {
            
            [_myPutCable_IdsArr removeAllObjects];
            [_myPutCable_LinesArray removeAllObjects];
        }
        
        
        
        return;
    }
    
    
    
}



#pragma mark - 声明单粒 ---

+ (Yuan_DC_VM *) shareInstance {
    
    static Yuan_DC_VM * instance = nil;
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

@end
